#!/usr/bin/Rscript

require( dplyr )
require( magrittr )
require( wspaces )

source( 'inc/obo_util.R',  chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME = 'c2_klingenstein'
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( "%s.RData", PROJ_NAME ) )
THESAURUS <- file.path( ut$DIR_DATA_EXT, 'rogets.dsv' )
THES_COLC <- list( character = c( 1,7,8,13:20 ), integer = c( 2:6, 9:12 ) )
SYMSET_ID <- c('class', 'section', 'subSecn', 'headNum', 'term' )
SMOOTH_K  <- 2

DEVICE <- 'tikz'

divvec <- function( d0, d1, mode=4 ) {
    if( nrow( d0 ) != nrow( d1 ) && ncol( d0 ) != ncol( d1 ) ) {
        ut$stopf( "Objects are not isomorhpic!" )
    }
    if( is.data.frame( d0 ) ) {
        d0 %<>% ungroup() %>% select( matches( '[0-9]+' ) )
        m0 <- d0 %>% as.matrix()
    } else {
        m0 <- d0
    }
    if( is.data.frame( d1 ) ) {
        d1 %<>% ungroup() %>% select( matches( '[0-9]+' ) )
        m1 <- d1 %>% as.matrix()
    } else {
        m1 <- d1
    }
    v <- simdiv(
        ( m0 - m1 ), m1, inner=FALSE, trans=TRUE, rm_zeros=( mode == 3 || mode == 4 ), mode=mode
    )
    names( v ) <- colnames( d0 )
    return( v )
}

plot_divs <- function( x, d1, d2=NULL, colf=ut$color_mk_palette(), smoothf=function( y ) y, fit=TRUE, ... ) {
    div_line <- function( x, d, side, col ) {
        y <- d %>% `+`( min( . ) * -1 ) %>% `/`( max( . ) )
        lines( x, y %>% smoothf() , col=col )
        ylab <- axisTicks( range( d ), log=FALSE )
        axis( side=side, at=( ylab %>% `+`( min( . ) * -1 ) %>% `/`( max( . ) ) ), labels=ylab  )
        if( fit ) {
            fit <- lm( y ~ x )
            lbl <- sprintf( "$\\quad\\leftarrow\\hat{\\beta}=%f$", coef( fit )[2] )
            lines( x, fitted.values( fit ), col=col, lty=2 )
            axis( 4, at=fitted.values( fit )[ length( x ) ], labels=lbl, las=1, cex.axis=.6 )
        }
    }
    if( !is.null( d2 ) && length( d1 ) != length( d2 ) ) stop( 'd1 and d2 lengts not equal' )
    x <- if( is.null( x ) ) 1:length( d1 ) else x
    xlim <- range( x ); ylim <- c( 0, 1 )
    cols <- if( is.null( d2 ) ) colf( 1 ) else colf( 2 )
    plot( NA, xlim=xlim, ylim=ylim, xlab=NA, ylab=NA, xaxs='i', axes=FALSE, ... ); axis( 1 )
    div_line( x, d1, 2, col=cols[1] )
    if( !is.null( d2 ) ) div_line( x, d2, 4, col=cols[2] )
    ut$period_lines()
    box()
}

make_data <- function() {
    # gather frequencies for the given divIds
    sample_freqs <- function( lctr, divIds=NULL, U=NULL ) {
        if( !is.null( divIds ) ) {
            ds <- lector_mkdocset( lctr, ut$DOCFIELD_SECTION, divIds )
            if( !is.null( U ) ) ds <- lector_intersect( ds, U )
        } else if( !is.null( U ) ) {
            ds <- U
        } else {
            warning( "No divIds or U given; nothing to do" )
        }
        d <- lector_count_freqs( lctr, ds )
        return( d )
    }

    # sum freq vectors from the given frees on the groups defined by the given syms df
    coarse <- function( syms, freqs, symkey='term', level='headNum' ) {
        s <- proc.time()
        d <- syms %>% lexical_join( freqs, k1=symkey, mode='inner', no.rn=TRUE )
        d1 <- d %>%
            group_by( class, section, subSecn, headNum, term ) %>%
            summarize_all( mean )
        d2 <- d1 %>%
            select( -term ) %>%
            summarise_all( sum )
        e <- proc.time() - s
        ut$infof( "Coarsing: %d -> %d -> %d in %4.2f seconds", nrow( d ), nrow( d1 ), nrow( d2 ), e[3] )
        return( d2 )
    }

    source( 'inc/obo_tables.R', chdir=TRUE, local=( if( exists( 'ta' ) ) ta else ( ta <- new.env() ) ) )
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )

    lctr <- lector_new( home_dir=ut$DIR_HOME )
    U <- lector_sample( lctr, ut$sample_testimony() )
    D <- lector_numdocs( lctr )
    S <- lexical_sample( cr$data$lxcn$tf, theta=ut$SAMPLE_THETA )
    df <- cr$data$lxcn$df

    ut$infof( "Gathering counts for general sample" )
    full_f <- sample_freqs( lctr, U=U )

    ut$infof( "Gathering counts for violent offences" )
    viol_f <- sample_freqs( lctr, U=U, divIds=(
        ta$get_trial_offs() %>% `[`( .$bViolent, 'divId' ) %>% unlist()
    ) )

    ut$infof( "Gathering counts for corporal punishments" )
    corp_f <- sample_freqs( lctr, U=U, divIds=(
        ta$get_trial_puns() %>% `[`( .$bCorporal, 'divId' ) %>% unlist()
    ) )

    motifs <- ta$get_trial_motifs()
    ut$infof( "Gathering counts for cases with groups" )
    grps_f <- sample_freqs( lctr, U=U, divIds=(
        motifs %>% `[`( ( .$bGrpDef | .$bGrpVic ), 'divId' ) %>% unlist()
    ) )

    ut$infof( "Gathering counts for cases with females" )
    fems_f <- sample_freqs( lctr, U=U, divIds=(
        motifs %>% `[`( ( .$bFemDef | .$bFemVic ), 'divId' ) %>% unlist()
    ) )
    rm( lctr )

    freqs <- list(
        full = full_f,
        corp = corp_f,
        fems = fems_f,
        grps = grps_f,
        viol = viol_f
    )

    message( "Computing TF/IDF weights" )
    full_w <- tfidf( freqs$full %>% as.matrix(), df, D, normal=TRUE )
    corp_w <- tfidf( freqs$corp %>% as.matrix(), df, D, normal=TRUE )
    fems_w <- tfidf( freqs$fems %>% as.matrix(), df, D, normal=TRUE )
    grps_w <- tfidf( freqs$grps %>% as.matrix(), df, D, normal=TRUE )
    viol_w <- tfidf( freqs$viol %>% as.matrix(), df, D, normal=TRUE )

    wfreqs <- list(
        full = full_w,
        corp = corp_w,
        fems = fems_w,
        grps = grps_w,
        viol = viol_w
    )
    dimnames( wfreqs$full ) <- dimnames( freqs$full )
    dimnames( wfreqs$corp ) <- dimnames( freqs$corp )
    dimnames( wfreqs$fems ) <- dimnames( freqs$fems )
    dimnames( wfreqs$grps ) <- dimnames( freqs$grps )
    dimnames( wfreqs$viol ) <- dimnames( freqs$viol )


    ut$infof( "Loading thesaurus from %s", THESAURUS )
    thesaurus <- data.table::fread( THESAURUS, sep="@", quote='',
        colClasses=list(
            character = c( 1,7,8,13:20 ),
            integer = c( 2:6, 9:12 )
        )
    ) %>% as.data.frame()
    symset <- thesaurus[ , SYMSET_ID ]

    ut$infof( "Coarsing frequencies to head level. This will take a while..." )
    st <- proc.time()
    full_c <- coarse( symset, freqs$full )
    corp_c <- coarse( symset, freqs$corp )
    fems_c <- coarse( symset, freqs$fems )
    grps_c <- coarse( symset, freqs$grps )
    viol_c <- coarse( symset, freqs$viol )
    ut$infof( "Frequencies coarsed in %4.2f seconds", ( proc.time() - st )[3] )

    coars <- list(
        full = full_c,
        corp = corp_c,
        fems = fems_c,
        grsp = grps_c,
        viol = viol_c
    )

    save(
        freqs,
        wfreqs,
        coars,
        S, U,
        file=DATA_FILE
    )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )

message( "Computing JSD over coarse freq vectors" )
corp_jsd <- divvec( coars$full, coars$corp, mode=4 )
fems_jsd <- divvec( coars$full, coars$fems, mode=4 )
grps_jsd <- divvec( coars$full, coars$grps, mode=4 )
viol_jsd <- divvec( coars$full, coars$viol, mode=4 )

message( "Computing cossim over TF/IDF vectors for S95" )
corp_cos <- divvec( wfreqs$full[S,], wfreqs$corp[S,], mode=2 )
fems_cos <- divvec( wfreqs$full[S,], wfreqs$fems[S,], mode=2 )
grps_cos <- divvec( wfreqs$full[S,], wfreqs$grps[S,], mode=2 )
viol_cos <- divvec( wfreqs$full[S,], wfreqs$viol[S,], mode=2 )

sdvecs <- data.frame(
    corp_jsd,
    fems_jsd,
    grps_jsd,
    viol_jsd,
    corp_cos,
    fems_cos,
    grps_cos,
    viol_cos
)

d <- sdvecs[55:nrow( sdvecs )-1,]
x <- as.integer( rownames( d ) )
smooth <- function( y ) zoo::rollmean( y, k=SMOOTH_K, fill='extend' )

ut$gr_setup( sprintf( '%s_fig1', PROJ_NAME ), n=4, device=DEVICE )
    plot_divs( x, d[,1], d[,5] * -1, smoothf=smooth )
    mtext( side=3, line=0, text="$C_{corporal}$" )
    plot_divs( x, d[,2], d[,6] * -1, smoothf=smooth )
    mtext( side=3, line=0, text="$C_{women}$" )
    plot_divs( x, d[,3], d[,7] * -1, smoothf=smooth )
    mtext( side=3, line=0, text="$C_{groups}$" )
    plot_divs( x, d[,4], d[,8] * -1, smoothf=smooth )
    mtext( side=3, line=0, text="$C_{violence}$" )
ut$gr_finish()



