# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

suppressWarnings( require( euclid ) )
suppressMessages( require( magrittr ) )
suppressWarnings( require( Matrix ) )
suppressWarnings( require( wspaces ) )
#suppressMessages( require( functional ) )

# graphical helper functions
source( 'graphics.R', local=TRUE )
source( 'imports.R',  local=TRUE )

#' MAGIC
reset <- function( func=NULL ) {
    rm( ut, envir=.GlobalEnv )
    tryCatch(
        source( 'inc/obo_util.R', chdir=TRUE, local=( ut <- new.env() ) ),
        error=function( e ) {
            message( sprintf( 'source failed: %sFix it and run reset again', e ) )
            ut <- list2env( list( reset=reset ) )
            assign( 'ut', ut, envir=.GlobalEnv )
        }
    )
    assign( 'ut', ut, envir=.GlobalEnv )
    if( !is.null( func ) ) debug( get0( as.character( substitute( func ) ), envir=ut ) )
}


# File system constants -----------------------------------------------------------------------
DIR_HOME         <- file.path( '/home/jta/desktop/obo' )
DIR_DATA         <- file.path( DIR_HOME, 'data'    )
DIR_DATA_SAMPLES <- file.path( DIR_DATA, 'samples' )
DIR_DATA_TBLS    <- file.path( DIR_DATA, 'tables'  )
DIR_DATA_ROBJ    <- file.path( DIR_DATA, 'robjs'   )
DIR_DATA_GRPH    <- file.path( DIR_DATA, 'graphs'  )
DIR_DATA_GLOVE   <- file.path( DIR_DATA, 'glove'   )
DIR_DATA_EXT     <- file.path( DIR_DATA, 'ext'     )
DIR_PLOT         <- file.path( DIR_HOME, 'plots'   )
DIR_TABLE        <- file.path( DIR_HOME, 'tables'  )

FILE_GLOVE_VECTS <- 'vectors.bin'
FILE_GLOVE_VOCAB <- 'vocab.txt'

# Graphical parameters ------------------------------------------------------------------------
GR_PLOT_X <- 6
#GR_PLOT_X <- 397 / 72.27 # Pagewidth in TeX points / TeX points per inch.
GR_PLOT_Y <- 2
GR_PTS    <- 5
GR_MAR    <- c( 2.1, 7.1, 2.1, 7.1 )

YEARS_PUB   <- c( 1729, 1778 )
YEARS_JUR   <- c( 1834, 1861 )
COLOR_PUB   <- 'red'
COLOR_JUR   <- 'blue'
COLOR_SCALE <- function( n ) {
    viridis::viridis_pal( option='D' )( n + 1 )[ 2:( n + 1 ) ]
}

# Semnet parameters ---------------------------------------------------------------------------
SAMPLE_THETA       <- .95
EPOCH_SAMPLE_THETA <- .90
HIGH_MODE          <- 1 # Passed to simdiv: Diff. Weighted cooc-retrieval
PRUNE_TOLERANCE    <- 2 # Connectivity threshold for edge prunning

# Index constants -----------------------------------------------------------------------------

# Text fields
FIELD_RAW_FULL   <- "full_text";  # Field name for raw text, no conflation.
FIELD_LEMMA_FULL <- "full_lemma"; # Field name for lemmatized text, no conflation.
FIELD_RAW_CONF   <- "wrk_text";   # Field name for raw text, conflated.
FIELD_LEMMA_CONF <- "wrk_lemma";  # Field name for lemmatized text, conflated.

# Document metadata fields
DOCFIELD_SESSION    <- "obo_session";   # Court session
DOCFIELD_DATE       <- "obo_date";      # Session date
DOCFIELD_YEAR       <- "obo_year";      # Session year
DOCFIELD_SECTION    <- "obo_section";   # Section id
DOCFIELD_TYPE       <- "obo_type";      # Section type
DOCFIELD_XPATH      <- "obo_xpath";     # XML source location
DOCFIELD_OFF_CAT    <- "obo_offCat";    # Trial offence categories
DOCFIELD_OFF_SUBCAT <- "obo_offSubcat"; # Trial offence sub-categories
DOCFIELD_VER_CAT    <- "obo_verCat";    # Trial verdict categories
DOCFIELD_VER_SUBCAT <- "obo_verSubcat"; # Trial verdict sub-categories
DOCFIELD_PARAID     <- "obo_paraId";    # In-section paragprah index

FIELD_LEGAL      <- "ent_legal"; # Legal entities flag

# Lector conf values
obo_conf <- function() {
    conf <- lector_mkconf(
        home_dir     = ut$DIR_HOME,
        doc_id       = DOCFIELD_SECTION,
        field_txt    = FIELD_LEMMA_CONF,
        field_split  = DOCFIELD_YEAR,
        field_filter = DOCFIELD_TYPE,
        filter_term  = 'trialAccount'
    )
    return( conf )
}

# Logging and debugging functions ------------------------------------------------------------------

#' Print message with the given format and parameters.
infof <- function( ... ) {
    message( sprintf( ... ) )
}

#' Print warning with the given format and parameters.
warnf <- function( ... ) {
    warning( sprintf( ... ) )
}

#' Error out with message according to the given format and parameters.
stopf <- function( ... ) {
    stop( sprintf( ... ) )
}

#' Execute the given function and return \emph{input}.
#'
#' Use this function to debug data processing pipelines like so:
#' data %>% some_mysterious_transform() %>% pass( my_debug_function ) %>% ..., where
#' my_debug_function can be, e.g. print or str.
#'
#' @param x   Some object, usually passed implicitly as part of a magrittr pipe call.
#' @param fun A function to run on x. Typically some non-destructive diagnosis function.
#'
#' @return x, after having called fun on x (and \emph{not} fun( x ) )
#'
#' @export
pass <- function( x, fun ) {
    fun( x )
    return( x )
}

# IO Fnctions --------------------------------------------------------------------------------------

#' Load all files from the given directory.
#'
#' Reads all files in the given directory with the given extension as tables, assgining them to
#' the given environment under names inferred from the file names.
#'
#' This function will scan all files in the given directory and match their filenames against the
#' given extension. It will then read every file that matches the given extension as a DSV file
#' using \code{\link{data.table::fread}}. If assign is TRUE, it will then proceed to assign all the
#' loaded data frames to the given environment under symbols equal to the corresponding filename
#' minus the given extension. If assign is FALSE, it will return a list containing all the loaded
#' data frames under entries named in a likewise fashion.
#'
#' @param dir    The directory to search for files.
#' @param name   An optional filename pattern to filter found files.
#' @param ext    The filaname extension of files that should be loaded.
#' @param env    The environment onto which to assign loaded data frames.
#' @param assign Logical indicating whether data frames should be assigned.
#' @param colc   Passed to \code{\link{data.table::fread}} as colClasses.
#'
#' @return a list with named data frames.
#'
#' @export
#' @importFrom data.table fread
io_load_dir <- function(
    dir, name='', ext='csv', env=.GlobalEnv, assign=FALSE, quiet=TRUE, colc='character', sep='@',
    na.strings=c('null')
) {
    files <- list.files( dir, pattern = paste( name, "\\.", ext, "$", sep ='' ) )
    lst <- list()
    for( f in files ) {
        d <- data.table::fread( file.path( dir, f ),
            colClasses=colc, verbose=!quiet, sep=sep, na.strings=na.strings, quote=''
        )
        lst[[ gsub( "\\..*", '', f ) ]] <- d
    }
    if( assign ) {
        for( n in names( lst ) ) {
            assign( n, lst[[n]], envir=env )
        }
    } else {
        return( lst )
    }
}

# Open a Lector backend with the correct configuration values
open_index <- function() {
    lctr <- lector_new( obo_conf() )
    return( lctr )
}


# Document sampling queries ------------------------------------------------------------------------

# The universe
sample_universe <- function() {
    rJava::.jinit()
    rJava::.jnew( "org.apache.lucene.search.MatchAllDocsQuery" ) %>%
    return()
}

# C_{legal}
sample_legal <- function() {
    rJava::.jinit()
    rJava::.jnew(
        "org.apache.lucene.search.AutomatonQuery",
        rJava::.jnew( "org.apache.lucene.index.Term", FIELD_LEGAL, "" ),
        rJava::J( "org.apache.lucene.util.automaton.Automata", "makeAnyString" )
    ) %>%
    return()
}

# C_{trial}
sample_trials <- function() {
    rJava::.jinit()
    rJava::.jnew(
        "org.apache.lucene.search.TermQuery",
        rJava::.jnew( "org.apache.lucene.index.Term", DOCFIELD_TYPE, "trialAccount" )
    ) %>%
    return()
}

# C_{testimony}
sample_testimony <- function() {
    rJava::.jinit()
    bldr <- rJava::.jnew( rJava::J( "org.apache.lucene.search.BooleanQuery" )$Builder )
    bldr %<>% rJava::J(
        "add", sample_trials(), rJava::J("org.apache.lucene.search.BooleanClause")$Occur$MUST
    )
    bldr %<>% rJava::J(
        "add", sample_legal(), rJava::J("org.apache.lucene.search.BooleanClause")$Occur$MUST_NOT
    )
    bldr %>% rJava::J( "build" ) %>%
    return()
}

# Plotting and printing functions-------------------------------------------------------------------

# Setup graphical device
gr_setup <- function(
    # file, dimensions, rows, device, ... to device function
    file, x=GR_PLOT_X, y=GR_PLOT_Y, n=1, device=c( 'tikz','svg','png','internal' ), ...,
    # font, units, resolution, background
    family='ComputerModern', units='in', res=600, bg='transparent',
    # Par overrides
    mfrow=c( n, 1 ), mar=GR_MAR, xpd=NA, cex=.66, las=1, xaxs='i'
) {
    device <- match.arg( device )
    if( dev.cur() != 1 ) dev.off()
    if( !file.exists( DIR_PLOT ) ) dir.create( DIR_PLOT )
    switch( device,
        tikz = {
            require( tikzDevice )
            file <- file.path( DIR_PLOT, paste( file, '.tex', sep='' ) )
            tikz( file=file, width=x, height=y * n, pointsize=GR_PTS, onefile=FALSE, engine='luatex', ... )
        },
        svg = {
            require( extrafont )
            file <- file.path( DIR_PLOT, paste( file, '.svg', sep='' ) )
            svg( file=file, width=x, height=y * n, pointsize=GR_PTS, onefile=FALSE, family=family, ... )
        },
        png = {
            file <- file.path( DIR_PLOT, paste( file, '.png', sep='' ) )
            png( file=file, width=x, height=y*n, units=units, res=res, pointsize=GR_PTS, bg=bg, ... )
        },
        internal = {
            dev.new( ... )
        }
    )
    infof( 'Plotting to %s', file )
    par( mfrow=mfrow, mar=mar, xpd=xpd, cex=cex, las=las, xaxs=xaxs )
}

# Close graphics device, if needed
gr_finish <- function( box=FALSE ) {
    if( box ) box( which='outer', col='red' )
    if( names( dev.cur() ) %in% c( 'png', 'svg', 'tikz output' ) ) {
        dev.off()
    }
}

# Shoe effective plot margins
gr_test <- function() {
    plot( NA, xlim=c(0,1), ylim=c(0,1) )
    box( 'p' ); box( 'i', col='blue' ); box( 'f', col='green' ); box( 'o', col='red' )
}

# Add raster images to plot
gr_add_raster <- function( file ) {
    rasterImage( png::readPNG( file ), x_base(), y_base(), x_top(), y_top() )
}

# Add vertical periodization lines to plots with years as the X axis
period_lines <- function( lbls=TRUE, date=FALSE, cex=.7 ) {
    x1 <- if( date ) YEARS_PUB %>% as.character() %>% as.Date( '%Y' ) else YEARS_PUB
    x2 <- if( date ) YEARS_JUR %>% as.character() %>% as.Date( '%Y' ) else YEARS_JUR
    abline( v=x1, col=COLOR_PUB, xpd=FALSE )
    abline( v=x2, col=COLOR_JUR, xpd=FALSE )
    if( lbls ) axis(
        1, at=c( x1, x2 ), labels=c( 'expansion', 'regulation', 'CCC act', 'OAP act' ),
        line=-1.2, tick=FALSE, cex.axis=cex
    )
}

plot_qs <- function(
    d, x, y, probs=c( 0.09, 0.25, 0.50, 0.75, 0.91 ), minmax=FALSE, scale_func,
    polys=TRUE, k=5, yaxis=missing( scale_func ), outliers=FALSE, qs=NULL,
    legend=TRUE, nopar=TRUE, axes=TRUE,
    col=color_mk_palette()( 1 ), bty='o',
    ...
) {
    qs <- if( is.null( qs ) ) {
        make_quants( d, x, y, probs=probs, minmax=minmax )
    } else qs
    series <- dplyr::select( qs, dplyr::starts_with( 'q' ) ) %>%
        dplyr::select( order( colnames( . ) ) )
    smooth_func <-if( is.na( k ) ) function( x ) x else
        function( x ) zoo::rollmean( x, k=k, fill='extend' )
    scale_func <- if( missing( scale_func ) ) function( x ) x else scale_func
    trans_func <- function( x ) scale_func( smooth_func( x ) )

    bands <- floor( length( series ) / 2 )
    mid <- bands + 1

    if( legend ) {
        if( !nopar ) {
            pad <- max( strwidth( 'median line', units='inch' ) )
            op <- par( omi=par('omi') + c( 0,0,0, pad ) )
        }
        on.exit( {
            lgd_lty=c()
            lgd_lwd=c()
            lgd_lab=c()
            if( minmax ) {
                lgd_lab=c( lgd_lab, 'min/max' )
                lgd_lwd=c( 0.2 )
                lgd_lty=c( 1 )
            }
            for( b in bands:1 ) {
                labs <- as.integer( gsub( 'q', '', c( names( series )[mid-b], names( series )[mid+b] ) ) )
                lgd_lab=c( lgd_lab, ( sprintf("%d/%d range", labs[1], labs[2] ) ) )
                lgd_lwd=c( lgd_lwd, 1 / ( b + 1 ) )
                lgd_lty=c( lgd_lty, b + 1 )
            }
            lgd_lab=c( lgd_lab, 'median' )
            lgd_lty=c( lgd_lty, 1 )
            lgd_lwd=c( lgd_lwd, 1 )
            x <- x_pos( 1 )
            y <- y_pos( .5 )
            legend(
                x, y, legend=lgd_lab, lty=lgd_lty, lwd=lgd_lwd, yjust=.5, xpd=NA, cex=.8, bty='n', col=col
            )
            if( !nopar ) par( op )
        }, add=TRUE )
    }

    ord <- c( min( qs$x ), max( qs$x ) )
    abs <- if( !minmax & !outliers ) {
        c(
            min( select( series, 1 )                %>% smooth_func ) %>% scale_func,
            max( select( series, length( series ) ) %>% smooth_func ) %>% scale_func
        )
    } else if( outliers ) {
        c(
            min( select_( d, .dots=list( lazyeval::lazy( y ) ) ) ) %>% scale_func,
            max( select_( d, .dots=list( lazyeval::lazy( y ) ) ) ) %>% scale_func
        )
    } else {
        c(
            min( qs$min %>% smooth_func ) %>% scale_func,
            max( qs$max %>% smooth_func ) %>% scale_func
        )
    }

    plot( NA, xlim=ord, ylim=abs, type='n', ylab=NA, xlab=NA, axes=axes, bty=bty, ... )

    # minmax lines
    if( minmax ) {
        lines( qs$x, qs$min %>% trans_func, lwd=0.2, col=col )
        lines( qs$x, qs$max %>% trans_func, lwd=0.2, col=col )
    }

    # quantile lines and polys
    for( b in bands:1 ) {
        lo <- unlist( select( series, mid - b ) )
        hi <- unlist( select( series, mid + b ) )
        wd <- 1 / ( b + 1 )
        ty <- b + 1
        lines( qs$x, lo %>% trans_func, lwd=wd, lty=ty, col=col )
        lines( qs$x, hi %>% trans_func, lwd=wd, lty=ty, col=col )
        if( polys ) {
            polygon(
                c( qs$x, rev( qs$x ) ),
                c( lo %>% trans_func, rev( hi %>% trans_func ) ),
                lwd=wd, col=color_add_alpha( col, .1 ), border=NA
            )
        }
    }

    if( outliers ) {
        qvars <- grep( 'q', colnames( qs ) )
        pts <- dplyr::select_(
            d, .dots=list( key=lazyeval::lazy( x ), y=lazyeval::lazy( y ) )
        ) %>% data_ljoin(
            dplyr::select( qs, key=x, lo=qvars[1], hi=qvars[length(qvars)] ), lk=key, rk=key
        ) %>% dplyr::filter( y < lo | y > hi ) %>% dplyr::rename( x=key )
        points( pts$x, pts$y %>% scale_func, cex=.1 )
    }

    # median line
    lines( qs$x, unlist( select( series, mid ) ) %>% trans_func, lwd=1, col=col )
}

plot_heat <- function( m, ...,                                           # data and plot args
    ncol=100, rev=TRUE, scale_func=log1p,                                # matrix parameters
    col=color_mk_palette()( ncol ), legend=TRUE, axes=TRUE,                    # plot parameters
    xlab=NA, ylab=NA, las=2, pty='s', na.rm=c('asis','min','max'), nan.rm=c('asis','min','max')
) {
    if( rev ) m %<>% apply( 2, rev ) %>% t
    x <- nrow( m )
    y <- ncol( m )

    na.rm  <- match.arg( na.rm )
    nan.rm <- match.arg( nan.rm )
    na.fill  <- switch( na.rm,  min=min( m[!is.na(m) ] ), max=max( m[!is.na(m)] ), NA )
    nan.fill <- switch( nan.rm, min=min( m[!is.nan(m)] ), max=max( m[!is.nan(m)] ), NaN )
    m[ is.nan( m ) ] <- nan.fill
    m[ is.na( m ) ] <- na.fill

    op <- par( pty=pty, no.readonly=TRUE ); on.exit( par( op ) )
    image( 1:x, 1:y, m %>% scale_func, col=col, axes=FALSE, ylab=NA, xlab=NA, ... )

    if( axes ) {
        axis( 1, 1:x, labels=rownames( m ), lty=0, cex.axis=.8, las=las )
        axis( 2, 1:y, labels=colnames( m ), lty=0, cex.axis=.8, las=las )
    }

    if( legend ) {
        x_lo <- x_top()  + ( x_inch( .1 ) ) # .1 inches to the right of plot.
        x_hi <- x_top()  + ( x_inch( .4 ) ) # .4 inches to the right of plot.
        y_lo <- y_base() + ( y_inch( .2 ) ) # .3 inches above lower extreme.
        y_hi <- y_top()  - ( y_inch( .2 ) ) # .3 inches below upper extreme.
        y_mid <-( y_hi + y_lo ) / 2         # midpoint in y
        rasterImage( as.raster( rev( col ), ncol=1 ), x_lo, y_lo, x_hi, y_hi, xpd=NA )
        text( x_hi, y_lo, min( m ), cex=.7, pos=4, xpd=NA )
        text( x_hi, y_mid, min( m ) + ( ( max( m ) - min( m ) ) / 2 ), cex=.7, pos=4, xpd=NA )
        text( x_hi, y_hi, max( m ), cex=.7, pos=4, xpd=NA )
    }
}

plot_stacks <- function(
    ..., ratios=TRUE,
    legend=TRUE, col_f=color_mk_palette(), as.boxes=FALSE, as.ribbons=FALSE, # plot params
    klab=NA, xlab=NA, ylab=NA, xaxs='i', yaxs='i', border=par('fg'), axes=TRUE, log="",
    ribbons.k=5,
    boxes.width=NA,
    nopar=TRUE,
    lty=1, lwd=.3
) {
    stacks <- make_stacks( ..., ratios=ratios )
    if( as.boxes & as.ribbons ) stop( 'as.boxes and as.ribbons can\'t both be true.' )
    x    <- stacks[[1]]
    f    <- as.factor( stacks[[2]] )
    lo   <- ( if( ratios ) stacks[['plo']] else stacks[['nlo']] )
    hi   <- ( if( ratios ) stacks[['phi']] else stacks[['nhi']] )
    cols <- col_f( length( levels( f ) ) )

    if( legend ) {
        if( !nopar ) {
            pad <- max( strwidth( levels( stacks[[2]] ), units='inch' ) )
            # op <- par( mai=par('mai') + c( 0,0,0, pad ) )
            op <- par( omi=par('omi') + c( 0,0,0, pad ) )
        }
        on.exit( {
            x <- x_top()
            y <- y_pos( .5 )
            lgd <- if( !is.na( klab ) & length( klab ) == length( levels( f ) ) ) {
                klab
            } else {
                rev( levels( f ) )
            }
            col <- rev( cols )
            legend( x, y, yjust=.5, legend=lgd, fill=col, xpd=NA, cex=.8, bty='n' )
            if( !nopar ) par( op )
        }, add=TRUE )
    }

    boxes <- is.factor( x ) & !is.numeric( x )
    if( !boxes & as.boxes ) boxes <- TRUE
    if( boxes & as.ribbons ) boxes <- FALSE
    if( boxes ) {
        plot_stack_boxes(
            x, f, lo, hi,
            width=boxes.width, lty=lty, lwd=lwd,
            cols=cols, xaxs=xaxs, yaxs=yaxs, xlab=xlab, ylab=ylab, border=border, axes=axes, log=log
        )
    } else {
        plot_stack_areas(
            x, f, lo, hi,
            k=ribbons.k, lty=lty, lwd=lwd,
            cols=cols, xaxs=xaxs, yaxs=yaxs, xlab=xlab, ylab=ylab, border=border, axes=axes, log=log
        )
    }
}

plot_stack_areas <- function(
    x, f, lo, hi, ...,             # data and plot args.
    k=3, sm_func=function( x ) zoo::rollmean( x, k=k, fill='extend' ),
    #Curry( zoo::rollmean, k=k, fill='extend' ), # area parameters
    cols=color_mk_palette()( length( levels( as.factor( f ) ) ) ),
    border=par('fg'), lty=1, lwd=1
) {
    if( !is.numeric( lo ) | !is.numeric( hi ) ) stop( 'lo and hi are not numeric' )
    x <- if( !is.numeric( x ) ) {
        message( 'coercing x to numeric!' )
        as.numeric( x )
    } else x
    if( !is.factor( f ) ) {
        message( 'coercing f to factor!' )
        as.factor( f )
    } else f
    if( length( cols ) != length( cats <- levels( f ) ) ) {
        stop( 'color vector and number of ribbons differ!' )
        # TODO warning( 'recycling colors!')
    }
    abs <- c( min( x ), max( x ) )
    ord <- c( 0, max( hi ) )
    plot(
        NA, xlim=abs, ylim=ord, type='n', ...
    )

    # ribbons.
    for( cat in cats ) {
        filt <- f == cat
        col   = cols[ which( cat == cats ) ]
        x_lo  = x[filt]
        x_hi  = x_lo %>% rev()
        y_lo  = lo[filt] %>% sm_func()
        y_hi  = hi[filt] %>% sm_func() %>% rev()
        polygon( c( x_lo, x_hi ), c( y_lo, y_hi ), col=col, border=border, lty=lty, lwd=lwd )
    }
}

plot_stack_boxes <- function(
    x, f, lo, hi, ...,             # data and plot args
    width=NULL,                              # box parameters
    cols=color_mk_palette()( length( levels( as.factor( f ) ) ) ),
    border=par('fg'), lty=1, lwd=1
) {
    if( !is.numeric( lo ) | !is.numeric( hi ) ) stop( 'lo and hi are not numeric' )
    x <- if( !is.factor( x ) ) {
        message( 'coercing x to factor!' )
        as.factor( x )
    } else x
    f <- if( !is.factor( f ) ) {
        message( 'coercing f to factor!' )
        as.factor( f )
    } else f
    if( length( cols ) != length( cats <- levels( f ) ) ) {
        stop( 'color vector and number of levels in f differ!' )
        # TODO warning( 'recycling colors!')
    }
    abs <- c( .5, length( levels( x ) ) + .5 )
    ord <- c( 0, max( hi ) )
    plot(
        NA, xlim=abs, ylim=ord, type='n', ...
    )

    # boxes
    w <- if( is.null( width ) ) {
        rep( 1, length( x ) )
    } else if( is.function( width ) ) {
        width( as.integer( x ) %>% unique )
    } else if(
        ( is.numeric( width ) || is.integer( width ) ) &&
        length( width ) == length( unique( as.integer( x ) ) )
    ) {
        width
    }
    w <- w / sum( w ) * ( x_top() - x_base() )

    x_rt <- .5
    for( stack in levels( x ) ) {
        x_lf <- x_rt
        x_rt <- x_lf + w[ which( levels( x ) == stack ) ]
        for( cat in levels( f ) ) {
            y_lo <- lo[ x == stack & f == cat ]
            y_hi <- hi[ x == stack & f == cat ]
            col <- cols[which( levels( f ) == cat )]
            rect( x_lf, y_lo, x_rt, y_hi, col=col, border=border, lty=lty, lwd=lwd )
        }
    }
}

plot_graph_align <- function( m, theta_func=function( x ) { x > 0 }) {
    k1 = nrow( m ); k2 = ncol( m )
    plot( NA, ylim=c( 1, max( k1, k2 ) ), xlim=c(-1,2 ), bty='n', axes=FALSE, ylab=NA, xlab=NA )
    for( i in 1:nrow( m ) ) {
        i_y <- y_pos( i / max( k1, k2 ) )
        points( 0, i_y )
    }
    for( j in 1:ncol( m ) ) {
        j_y <- y_pos( j / max( k1, k2 ) )
        points( 1, j_y )
    }
    for( i in 1:nrow( m ) ) {
        for( j in 1:ncol( m ) ) {
            if( theta_func( m[i,j] ) ) {
                i_y <- y_pos( i / max( k1, k2 ) ) + 1
                j_y <- y_pos( j / max( k1, k2 ) ) + 1
                segments( 0, i_y, 1, j_y, lwd=m[i,j] )
            }
        }
    }
}

add_term_mark <- function( term, col='red' ) {
    x = which( rownames( terms ) == term );
    y = terms$tf[ x ]
    guides( x, y, symbol=16, scol=col, label='xy', yadj=c( -.1, -.2 ) )
    label <- if( grepl( 'tikz', names( dev.cur() ) ) ) {
        sprintf( '$\\leftarrow %s$', term )
    } else {
        sprintf( '\U2190 %s', term )
    }
    text( x, y, label, adj=c( -.15, .15 ) )
}

plot_graph <- function( g, pos=layout_nicely( g ),
    # what to draw
    vertices=TRUE, edges=TRUE, clusters=TRUE, labels=TRUE,
    # vertex params
    vcols=NULL, vsizes=NULL, vlabels=NULL, valpha=1, vcex=1, vlabels.cex=1, vlabels.pos=1,
    # edge params
    eattr='weight', ealpha=.5, ecex=1, elabels=FALSE, elabels.cex=.3,
    # cluster params
    cattr='comm', calpha=.2,
    # shape and size of plot
    margin=0.05, asp=NA, square=FALSE,
    # mark vertices?
    vmarks=NULL, vmarks.cex=2,
    # behaviour
    add=FALSE, debug=FALSE,
    raster=FALSE, raster.vertices=FALSE, raster.edges=FALSE, raster.clusters=FALSE,
    ...
) {
    if( !vertices && !edges && !clusters && !labels && add ) return()
    if( raster ) {
        raster.vertices=TRUE; raster.edges=TRUE; raster.clusters=TRUE
    }
    if( is.function( pos ) ) {
        pos <- pos( g, ... )
    }

    # TODO: refactor this
    # we need comms for colors, so if no comms, all vs in one comm
    if( is.null( vattr( g, cattr ) ) ) {
        comms <- rep( 1, length( V( g ) ) )
        clusters=FALSE
    } else {
        comms <- vattr( g, cattr )
    }
    comms %<>% as.factor() %>% as.integer()
    ccols <- color_mk_palette()( length( unique( comms ) ) )
    if( is.null( vcols ) ) {
        vcols <- color_mk_palette()( length( unique( comms ) ) )[comms]
    } else {
        if( length( vcols ) == 1 ) {
            vcols <- rep( vcols, lenth( V( g ) ) )
        } else if( length( vcols ) != length( V( g ) ) ) {
            stop( 'invalid value for vcols' )
        }
    }

    pos %<>% euclid::center() %>% euclid::resize()

    if( !add ) {
        # set margins
        xlim <- range( pos[,1] ) * ( 1 + margin )
        ylim <- range( pos[,2] ) * ( 1 + margin )
        # create canvas
        plot( NA, xlim=xlim, ylim=ylim, axes=FALSE, xlab=NA, ylab=NA, asp=asp )
    }

    # edge mesh at bottom
    if( edges ) {
        if( raster.edges ) {
            par <- par( no.readonly=TRUE )
            png( file=( ras <- tempfile() ), height=1600, width=1600, bg='transparent' )
            par( par ); par( mar=c( 0,0,0,0 ) )
            plot( NA, xlim=xlim, ylim=ylim, axes=FALSE, xlab=NA, ylab=NA, asp=asp )
        }
        draw_edges(
            g, pos, eattr, vcols, alpha=ealpha, cex=ecex, labels=elabels, debug=debug, raster=raster.edges
        )
        if( raster.edges ) {
            dev.off()
            gr_add_raster( ras )
        }
    }

    # then clusters
    if( clusters ) draw_clusters(
        comms, pos, ccols, alpha=calpha, K=margin, debug=debug
    )

    # then vertices on top
    if( vertices ) {
        if( raster.vertices ) {
            par <- par( no.readonly=TRUE )
            png( file=( ras <- tempfile() ), height=1600, width=1600, bg='transparent' )
            par( par ); par( mar=c( 0,0,0,0 ) )
            plot( NA, xlim=xlim, ylim=ylim, axes=FALSE, xlab=NA, ylab=NA, asp=asp )
        }
        draw_vertices(
            g, pos, vcols, size=vsizes, alpha=valpha, K=margin, cex=vcex, debug=debug
        )
        if( raster.vertices ) {
            dev.off()
            gr_add_raster( ras )
        }
    }
    # then labels
    if( labels ) draw_labels(
        g, loc=pos, labels=vlabels, cex=vlabels.cex, marks=vmarks, marks.cex=vmarks.cex, pos=vlabels.pos, debug=debug
    )
}

draw_edges <- function(
    g, pos, attr, vcols, alpha=.5, cex=1, labels=FALSE, debug=FALSE, raster=FALSE, ...
) {
    if( debug ) return()
    if( !is.null( eattr( g, attr ) ) ) {
        m <- as_adj( g, type='both', attr=attr )
    } else {
        m <- as_adj( g, type='both' )
    }
    e <- Matrix::which( m != 0, arr.ind=TRUE )
    if( !is.null( vcols ) ) {
        colm  <- color_interpolate( unique( vcols ) ) %>% color_add_alpha( alpha=alpha )
        cols <- cbind( vcols[e[,1]], vcols[e[,2]] ) %>% apply( 1, function( col ) {
            return(
                colm[ which( col[1] == rownames( colm ) ), which( col[2] == colnames( colm ) ) ]
            )
        } )
    } else {
        cols <- rep( par()$fg, nrow( e ) )
    }
    lwds <- ( m[ e ] * cex ) + .1
    e_src <- pos[e[,1],]
    e_tgt <- pos[e[,2],]
    segments( e_src[,1], e_src[,2], e_tgt[,1], e_tgt[,2], col=cols, lwd=lwds )
    if( labels ) message( 'elabels not supported yet' )
}

draw_clusters <- function( ks, pos, cols, alpha=.2, K=.05, debug=FALSE, ... ) {
    if( debug ) return()
    K <- K * xinch()
    for( k in unique( ks ) ) {
        col  <- color_add_alpha( cols[k], alpha=alpha )
        kpos <- pos[which( ks == k ),]
        if( is.matrix( kpos ) && nrow( kpos ) > 1 ) {
            o    <- C( kpos )
            cbrd <- kpos[ chull( kpos ), ]
            cbrd <- resize( cbrd, K, abs=TRUE )
            if( nrow( kpos ) == 2 ) {
                l0 <- vadd( o, vorth( vdif( kpos[1,], kpos[2,] ), cw=T ) %>% vunit() %>% smul( K ) )
                l1 <- vadd( o, vorth( vdif( kpos[1,], kpos[2,] ), cw=F ) %>% vunit() %>% smul( K ) )
                cbrd <- rbind( kpos, l0, l1 ) %>% `[`( chull( . ), T )
            }
            poly <- xspline( interpolate( cbrd ), open=FALSE, shape=-.5, draw=FALSE )
            polygon( poly, col=col, border=NA )
        } else {
            symbols( kpos[1], kpos[2], circle=K, fg=NA, bg=col, add=TRUE, inches=FALSE )
        }
    }
}

draw_vertices <- function( g, pos, cols=NULL, size=NULL, alpha=1, K=.05, cex=1, debug=FALSE, ... ) {
    K <- K * xinch()
    if( !is.null( size ) ) {
        if( is.character( size ) && !is.null( vattr( g, size ) ) ) {
            size <- vattr( g, size )
        } else if( length( size ) == 1 ) {
            message( 'single value passed as vertex size. better passed as cex' )
            size <- rep( size, length( V( g ) ) )
        } else if( !is.integer( size ) && !is.numeric( size ) ) {
            stop( 'invalid value for size' )
        }
    } else {
        size <- rep( 1, length( V( g ) ) )
    }
    size %<>% make_scale( lo=K, ... )
    if( is.null( cols ) ) {
        cols <- rep( color_mk_palette()( 1 )[1], nrow( pos ) )
    }
    cols %<>% color_add_alpha( alpha=alpha )
    if( !debug ) {
        symbols( pos, circle=( size * K * cex ), add=TRUE, inch=FALSE, bg=cols, fg=cols )
    } else {
        n <- cols %>% unique() %>% length()
        size <- sort( size )[ seq.int( 1, length( size ), length.out=n ) ]
        x <- seq( par()$usr[1] + ( K * 10 ) , par()$usr[2] - ( K * 10 ), length.out=n )
        y <- rep( par()$usr[3] + diff( c( par()$usr[3], par()$usr[4] ) ) / 2, n )
        symbols( x=x, y=y, circles=( size * K * cex ), add=TRUE, inch=FALSE, bg=unique( cols ), fg=unique( cols ) )
        text( x, y, labels=c( 1:n ), pos=3 )
        text( x, y, labels=sprintf( "%8.6f", size ), srt=-90, adj=c( -K * 10, 0.5 ) )
    }
}

draw_labels <- function(
    g, loc, labels=NULL, label.attr='name', cex=1, marks=NULL, marks.cex=2, pos=1, debug=FALSE
) {
    if( !is.null( labels ) ) {
        if( length( labels ) == 1 ) {
            if( is.character( labels ) && !is.null( vattr( g, labels ) ) ) {
                lbls <- vattr( g, labels )
            } else if( is.logical( labels ) && labels ) {
                if( !is.null( names( V( g ) ) ) ) {
                    lbls <- names( V( g ) )
                } else {
                    lbls <- as.character( 1:nrow( loc ) )
                }
            }
        } else {
            lbls <- labels
        }
        cex <- if( length( cex ) == 1 ) rep( cex, nrow( loc ) ) else cex
        if( !is.null( marks ) ) {
            cex[ lbls %in% marks ] %<>% `*`( marks.cex )
        }
        if( !debug ){
            text( loc, labels=lbls, cex=cex, pos=pos )
        } else {
            k <- min( length( unique( cex ) ), 10 )
            if( k > 10 ) {
                cex <- sort( cex )[ seq.int( 1, length( size ), length.out=k ) ]
            } else {
                cex <- unique( cex )
            }
            K <- .05 *xinch()
            x <- seq( par()$usr[1] + ( K * 10 ) , par()$usr[2] - ( K * 10 ), length.out=k )
            y <- rep( par()$usr[3] + diff( c( par()$usr[3], par()$usr[4] ) ) / 4, k )
            text( x, y, labels=sprintf( "%4.2f", cex ), cex=cex, adj=c( .5, .5 ) )
        }
    }
}

latex_xtab <- function( ... ) {
    UseMethod( 'latex_xtab' )
}

latex_xtab.default <- function( row_k, col_k, ..., margins=FALSE ) {
    tb <- table( row_k, col_k )
    tb <- if( margins ) addmargins( tb ) else tb
    tb %>% latex_xtab( ... )
}

latex_xtab.table <- function( tbl, row_lab, col_lab, file='', ... ) {
    if( ( dim( tbl ) %>% length() ) > 2 ) stop( 'Tables with rank  > 2 not supported' )
    cols <- dimnames( tbl )[[1]]
    rows <- dimnames( tbl )[[2]]
    headers <- list()
    headers$pos <- list( 0, 0 )
    headers$command <- c(
        sprintf( '& \\multicolumn{%d}{c}{ %s } \\\\\n', length( cols ), col_lab ),
        sprintf( '%s & %s \\\\\n', row_lab, paste( cols, collapse=' & ') )
    )
    xt <- xtable::xtable( tbl, ... )
    r <- print( xt, add.to.row=headers, include.colnames=FALSE, file=file )
    invisible( r )
}


# OBSOLETE data clean ------------------------------------------------------------------------------

#' Convenience wrapper for dplyr::left_join
#'
#' This function provides a convenient and simple to use wrapper for \code{\link{dplyr::left_join}}
#' that allows joining the given data frames or data tables over arbitrary keys.
#'
#' dplyr::left_join assumes that data frames must be joined on similarly named variables in the
#' given data frames. This function takes the given variable names for the left and right data
#' sets and constructs temporary join variables before calling dplyr::left_join on the modified
#' data sets.
#'
#' @param l      Data frame to which variables from r will be added.
#' @param r      Data frame from which variables to l will be added.
#' @param lkey   Variable to use as join key in l.
#' @param rkey   Variable to use as join key in r.
#' @param drop_r Logical value indicating whether variables in r already present in l should be
#'               dropped before joining.
#' @param drop_l Logical value indicating whether variables in l also present in r should be
#'               overwritten by their values in r.
#'
#' @return A data frame or data table containing the results of the join.
#'
#' @export
#' @importFrom dplyr ungroup select_ mutate_ left_join
data_ljoin <- function( l, r, lk=entId, rk=entId, drop_r=TRUE, drop_l=FALSE ) {
    dplyr::ungroup( l ); dplyr::ungroup( r )
    l_sk = key( l )
    r_sk = key( r )
    if( drop_l ) dplyr::select_( # TODO remove list() ?
        l, .dots=c( setdiff( names( l ), names( r ) ), list( lazyeval::lazy( lk ) ) )
    ) -> l
    if( drop_r ) dplyr::select_(
        r, .dots=c( setdiff( names( r ), names( l ) ), list( lazyeval::lazy( rk ) ) )
    ) -> r
    l <- dplyr::mutate_( l, .dots=list( 'key_' = lazyeval::lazy( lk ) ) )
    r <- dplyr::rename_( r, .dots=list( 'key_' = lazyeval::lazy( rk ) ) )
    out <- dplyr::left_join( l, r, by='key_' ) %>% select( -key_ )
    data.table::setkeyv( # TODO get rid of data.table?
        out, unique( c( l_sk, r_sk ) )[ unique( c( l_sk, r_sk ) ) %in% names( out ) ]
    )
    return( out )
}

# OBSOLETE data proc -------------------------------------------------------------------------------
#' Convert a contingency table to a data frame.
#'
#' Convert a contingency table to long or wide format, preserving factor names in order to make it
#' useful as input for hadleyverse data manipulation and plotting functions.
#'
#' This function will coerce a contingency table (like the ones produced by \code{\link{table}})
#' into a data frame, but unlike the data frame resulting from coercion with as.data.frame, this
#' function will preserve factor names and rename the 'Freq' variable produced by that method with
#' a more reasonable 'N'. This function is also capable of producing wide format tables for table
#' of more than two variables.
#'
#' @param x      A data frame or a contingency table.
#' @param ...    If x is a data.frame, arguments passed to select with variables to include in the
#'               table. Ignored otherwise.
#' @param format A character vector indicating one of 'long' or 'wide' format.
#' @param names  A logical value indicating whether variable names should be added to the
#'               resulting data frame.
#' @param total  A logical value indicating whether totals should be added to the resulting
#'               data frame.
#' @param blanks Logical. Add placeholder names for blank factor levels (i.e. column names in
#'               input)
#' @param rows   Character vector of length one. One of "name" or "var", put rownames as
#'               rownames or variable. Default rownames. Ignored if names == FALSE.
#'
#' @return A data frame suitable for direct manipulation or plotting using hadleyverse functions
#'         from dplyr or ggvis.
#'
#' @export
data_frame_table <- function( x, ... ) UseMethod( "data_frame_table" )

#' @inherit frametable
#'
#' @export
data_frame_table.table <- function(
    x, format=c( 'wide', 'long' ), names=TRUE, total=TRUE, blanks=TRUE, rows=c( 'name', 'var' )
) {
    format <- match.arg( format )

    if( blanks ) {
        for( b in which( dimnames( x )[[2]] == '' ) ) {
            dimnames( x )[[2]][b] <- paste( 'blank_', b, sep = '' )
        }
    }

    if( format == 'wide' ) {
        if( length( dim( x ) ) == 2 ) {
            d <- dtplyr::tbl_dt( as.data.frame.matrix( x ) ) # TODO why matrix?
            if( names ) {
                if( match.arg( rows ) == 'name' ) {
                    rownames( d ) <- rownames( x )
                } else {
                    d$row.name <- rownames( x )
                    d <- dplyr::select( d, row.name, dplyr::one_of( colnames( x ) ) )
                }
            }
            if( total ) d$total <- rowSums( x )
            return( d )
        } else {
            message(
                "Wide format not supported for high-dimensional tables. Defaulting to long format."
            )
        }
    }
    as.data.frame( x ) %>%dplyr::rename( N = Freq ) %>%
    return()
}

#' @inherit frametable
#'
#' @export
data_frame_table.data.frame <- function(
    d, ..., format=c( 'wide', 'long' ), names=T, total=T, blanks=T, rows=c( 'name', 'var' )
) {
    d %>% dplyr::select_( .dots=lazyeval::lazy_dots( ... ) ) %>% table() %>%
    data_frame_table( format=format, names=names, total=total, blanks=blanks, rows=rows )
}

#' Select and collapse data frame.
#'
#' This function provides a convenient wrapper to select and collapse a data frame based on the
#' value of a variable named 'type'. Given the calling conventions in dplyr functions, the name
#' of the grouping variable is for now hardcoded.
#'
#' @param j    A data frame, with one variable named 'type'
#' @param keep A value of type to collapse data on.
#' @param key  A name for the key variable in the output data frame.
#'
#' @return a selected and collapsed data frame, whatever that means.
#'
#' @export
data_collapse_frame <- function( j, keep, key=tarId ) {
    selects <- list( lazyeval::lazy( key ), lazyeval::lazy( collisions ) ) %>%
        data.table::setattr( 'names', c( 'id_', 'type_' ) )
    renames <- list( lazyeval::lazy( id_ ), lazyeval::lazy( type_ ) ) %>%
        data.table::setattr( 'names', c( 'entId', keep ) )
    j %<>% dplyr::filter( type == keep ) %>% dplyr::select_( .dots=selects ) %>%
        dplyr::group_by( id_ ) %>% dplyr::summarise( type_ = sum( type_ ) ) %>%
        dplyr::rename_( .dots=renames )
    return( j )
}

#' Make ribbons for plotting stacked area plots.
#'
#' Makes ribbons from values in a vector in order to plot said values with stacked area plots.
#' Unlike normal plots, in which every data point is associated to one value on the ordinate axis,
#' ribbons require two values on the ordinate axis for each point: a lower and upper bound
#' (ymin, ymax).
#'
#' The values of ymin and ymax are normally computed automatically by surface area plot functions.
#' This function can be used to prepare data for more primitive plotting facilities by constructing
#' the two necessary series from the values in y.
#'
#' @param d      A data frame, typically the result of calling as.data.frame on a contingency table,
#'               but see \code{\link{data_frame_table}} for a more robust procedure.
#' @param x      Column in d to map to absissas (e.g. year).
#' @param y      Column in d to map to ordinates (i.e. classes that will define marks for each x
#'               value).
#' @param ratios Logical. Make ribbons over ratios instead of absolute counts. The ratios for all
#'               ribbons add up to 1 over each value of x, so the stacked ribbons will cover
#'               the entire plot area vertically.
#' @param both   Logical. Compute ribbons for counts \emph{and} ratios.
#' @param sort   Logical. Sort values by frequency.
#' @param ...    Additional params passed to \code{\link{dplyr::filter}}.
#'
#' @return d with additional columns 'nFrom' and 'nTo' indicating the lower and upper
#'         bounds of the ribbons. If ratios, the columns are named pFrom and pTo.
#'
#' @export
#' @importFrom magrittr %>%
#' @importFrom dplyr filter_ select_ group_by_ mutate ungroup arrange_ select
data_make_ribbons <- function( d, x, y, ratios=TRUE, sort=TRUE, drop.lvls=TRUE ) {
    d <- select_( d, .dots=list( lazyeval::lazy( x ), lazyeval::lazy( y ) ) )
    var_names <- names( d )
    if( drop.lvls ) d[[var_names[1]]] <- droplevels( d[[var_names[1]]] )
    d %>% table() %>% data_frame_table( format='long' ) %>%
        dplyr::group_by_( .dots=lazyeval::lazy( x ) ) %>%
        make_stacks( x, y, N, ratios=ratios, sort=sort ) %>%
    return()
}
