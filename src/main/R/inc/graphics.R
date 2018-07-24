# geoms --------------------------------------------------------------------------------------------
# 
#' Compute lower and upper bounds for stacked plots
#'
#' Compute lower and upper bounds for each factor level in y across each value in x for
#' stacked area or box plots.
#'
#' d should be a data.frame object containing the crosstabulation of a series against the factor
#' that is to be stacked, in long form as (x,y,count) tuples. This can be produced by
#' \code{as.data.frame( table( d$x, d$y ) )} or \code{data_frame_table( d, x, y )}.
#'
#' \code{\link{data_make_ribbons}} calls this function internally. \code{\link{plot_ribbons}} calls
#' this function internally via \code{\link{data_make_ribbons}} if the ribbons are not given.
#'
#' This function is exported in order to facilitate the construction of ribbons for contingency
#' tables computed by other means.
#'
#' @param d      A data frame with at least three columns: one for the x factor, one for the y
#'               factor and one for each x-y combination magnitude.
#' @param x      Column name for x factor levels.
#' @param y      Column name for y factor levels.
#' @param N      Column name for x-y combination magnitudes.
#' @param ratios Logical indicating whether to include relative ribbons (i.e. ratios). Defaults to
#'               TRUE.
#' @param sort   Logical indicating whether ribbons should be sorted in descending frequency order
#'               (i.e. larger y level ribbons on top) or aan index vector into unique values of y
#'               for custom sorting. Defaults to TRUE. Set to FALSe for natural order.
#' @param drop_p Logical indicating whether to drop the computed total probability for each y
#'               level. Ignored if ratios == FALSE. Defaults to TRUE.
#'
#' @return A dataset with the same number of rows as d, the columns for x, y and total count and at
#'         least two columns indicating lower and upper bounds for each observation's ribbon at
#'         each value of x, named nhi and nlo. If ratios == TRUE, the result will also contain phi
#'         and plo, and, if drop_p == FALSE, an extra column named P containing the total
#'         probability for each y level (i.e. sum( N_y ) / sum( d ) ).
#'
#' @export
#' @importFrom magrittr %<>% %>%
#' @importFrom lazyeval lazy
#' @importFrom dplyr select_ group_by mutate ungroup arrange
old_stacks <- function( d, x, y, N, ratios=TRUE, sort=FALSE, drop_p=TRUE ) {
    src_vars  <- list( lazyeval::lazy( x ), lazyeval::lazy( y ), lazyeval::lazy( N ) )
    src_names <- dplyr::select_( d, .dots=src_vars ) %>% names()
    names( src_vars ) <- c( 'x', 'y', 'N' )
    tmp      <- dplyr::select_( d, .dots=src_vars )
    cats     <- unique( tmp$y )
    # sorting k
    if( length( sort ) == 1 && is.logical( sort ) ) { # logical.
        if( sort ) { # sort in descending freq order.
            tmp %<>% dplyr::group_by( y ) %>%
                dplyr::mutate( kTotal = sum( N ) ) %>% # compute total per group
                dplyr::ungroup() %>%                   # ungroup
                dplyr::arrange( kTotal, x ) %>%        # sort by group size then by x
                dplyr::select( -kTotal )               # delete group total
        }
    } else if( is.integer( sort ) && all( sort %in% 1:length( cats ) ) ) { # sort by index vector.
        ksort <- sort( cats )[sort]
        tmp$sort__ <- vapply( tmp$y, function( x ) which( ksort == x ), 1L )
        tmp %<>% arrange( sort__ ) %>% select( -sort__ )
    } else { # invalid sort value.
        stop( 'sort must be logical value or index vector into unique values of y.' )
    }
    # absolute stacks
    tmp %<>% dplyr::group_by( x ) %>% dplyr::mutate(
        nhi = cumsum( N ),
        nlo = c( 0, nhi[ -n() ] ) # TODO understand what is going on here.
    )
    # relative stacks
    if ( ratios ) {
        tmp %<>% dplyr::mutate(
            P = ifelse( N > 0, N / sum( N ), 0 ),
            phi = cumsum( P ),
            plo = c( 0, phi[ -n() ] )
        )
        if( drop_p ) {
            tmp %<>% dplyr::select( -P )
        }
    }
    # restore variable names
    names( tmp )[1:3] <- src_names
    return( tmp )
}

make_stacks <- function( ... ) {
    UseMethod( 'make_stacks' )
}

make_stacks.integer <- function( x, ... ) {
    make_stacks( as.factor( x ), ... ) %>%
        dplyr::mutate(
            x = as.integer( levels( x )[ as.integer( x ) ] )
        )
}

make_stacks.factor <- function( x, y, N, ... ) {
    if( missing( y ) ) stop( 'missing value for y factor' )
    if( missing( N ) ) {
        table( x, y ) %>% make_stacks.table( ... )
    } else {
        if( 
            length( N ) == length( x ) &&
            length( N ) == length( y ) && 
            length( N ) == ( length( unique( x ) * length( unique( y ) ) ) ) 
        ) {
            list( x, y, N ) %>% as.data.frame() %>% make_stacks.data.frame( ... )
        } else {
            stop( 'wrong dimension for freq vector' )
        }
    }
}

make_stacks.table <- function( tbl, ... ) {
    tbl %>% as.data.frame() %>% make_stacks.data.frame( ... )
}

make_stacks.data.frame <- function(
    df, xna="NA_x", yna="NA_y", kna=0, keepNames=TRUE, sort=TRUE, ratios=TRUE 
) {
    if( length( df ) != 3 ) {
        return( make_stacks( df[[1]], df[[2]] ) )
    }
    # I hate the tidyverse. This is here because tidyr::gather silently convertes counts to dbl.
    # Update: this occurs when the source df contains zeros. e.g. the raw freqs dataset without any 
    # filling. Still hate the hadleyverse, though...
    if( !is.integer( df[[3]] ) && !is.numeric( df[[3]] ) ) stop( "Count vector is not a number" )
    if( is.numeric( df[[3]] ) ) df[[3]] <- as.integer( df[[3]] )
    if( !is.factor( df[[2]] ) ) {
        warning( 'Coercing y to factor: labels may be wrong' )
        df[[2]] <- as.factor( df[[2]] )
    }
    if( any( is.na( df[[2]] ) ) ) {
        warning( sprintf( 'NA values in y: adding %s level', yna ) )
        addNA( df[[2]] )
        levels( df[[2]] ) <- c( levels( df[[2]] ), yna )
    }
    if( ( length( unique( df[[1]] ) ) * length( unique( df[[2]] ) ) ) != nrow( df ) ) {
        stop( "Wrong df shape for stacks: need long-form (i.e. as.data.frame( table( x,y ) )" )
    }
    cats <- unique( df[[2]] )
    var_names <- names( df )
    names( df ) <- c( 'x', 'y', 'N' )
    df %<>% dplyr::arrange( y, x )
    # sorting k 
    if( length( sort ) == 1 && is.logical( sort ) && sort ) { # logical.
        comp <- df %>% dplyr::group_by( y ) %>% dplyr::summarize( sortk = sum( N ) )
        comp %<>% dplyr::mutate( y = factor( y, levels=levels( y )[ order( comp$sortk ) ] ) )
        df %<>% 
            dplyr::mutate( y = factor( y, levels=levels( y )[ order( comp$sortk ) ] ) ) %>% 
            dplyr::arrange( as.integer( y ) )
    } else if( is.integer( sort ) && all( sort %in% 1:length( cats ) ) ) { # sort by index vector.
        df %<>%
            dplyr::mutate( y = factor( y, levels=levels( y )[sort] ) ) %>%
            dplyr::arrange( as.integer( y ) )
    }
    
    # absolute stacks
    df %<>% dplyr::group_by( x ) %>% dplyr::mutate(
        nhi = cumsum( N ),
        nlo = c( 0, nhi[ -n() ] ) # TODO understand what is going on here.
    )
    
    # relative stacks
    if ( ratios ) {
        df %<>% dplyr::mutate(
            P = ifelse( N > 0, N / sum( N ), 0 ),
            phi = cumsum( P ),
            plo = c( 0, phi[ -n() ] )
        )
    }
    if( keepNames ) names( df )[1:3] <- var_names
    return( df %>% dplyr::ungroup()  )
}

#' Compute quantiles on y over groups of x.
#'
#' This function will produce a data frame with the requested quantiles for y by each of the groups
#' produced by values of x on the given data frame d.
#'
#' The returned data is suitable for use as primitive for box and whikers plots.
#'
#' @param d      A data frame
#' @param x      The unquoted name of a grouping variable. Rows in the returned value will
#'               correspond to unique values in x.
#' @param y      The unquoted name of a variable for which to compute quantiles.
#' @param probs  Numeric vector specifying the probabilities at which to compute quantiles. Must
#'               be odd-numbered length. Default is \code{c( .09, .25, .5, .75, .91 )}.
#' @param minmax Logical. Include min and max in columns called 'min' and 'max', respectively.
#'               Adding 0 and 1 to probs achieves the same result minus the correct column names.
#'
#' @return A data frame with as many rows as there are unique values in x, a 'ct' column including
#'         the number of observations per group, and a set of columns for each value of probs, with
#'         names starting with 'q'. If minmax is TRUE, the returned data frame will also contain
#'         columns called 'min' and 'max'.
#'         
#' @export
#' @importFrom lazyeval lazy
#' @importFrom dplyr select_ summarize_
make_quants <- function( d, x, y, probs=c( 0.09, 0.25, 0.50, 0.75, 0.91 ), minmax=TRUE ) {
    vars <- list( lazyeval::lazy( x ), lazyeval::lazy( y ) )
    names( vars ) <- c( 'x', 'y' )
    quants <- list( N = reformulate( 'n()' ) )
    if( minmax ) {
        quants[['min']] <- reformulate( 'min( y )' )
        quants[['max']] <- reformulate( 'max( y )' )
    }
    for( i in 1:length( probs ) ) {
        name  <- paste( 'q', gsub( '\\.', '', sprintf( "%02d", probs[i] * 100 ) ), sep = '' )
        value <- reformulate( sprintf( "quantile( y, probs=probs )[%d]", i ) )
        quants[[name]] <- value
    }
    out <- d %>% select_( .dots=vars ) %>% group_by( x ) %>% summarize_( .dots=quants )
    return( out )
}

make_ellipse <- function( pos, k ) {
    o  <- centroid( pos )
    axis <- t( pos[1,] - pos[2,] )
    orth <- axis %*% matrix( c( 0, 1, -1, 0 ), 2 )
    norm <- norm( t( orth ) )
    p1 <- o + ( orth / norm ) * k
    p2 <- o + ( orth / norm ) * k * -1
    browser()
}

#' make scale with arbitrary ranges.
#' TODO: add prior func
make_scale <- function( x, lo=0, hi=1 ) {
    if( ( r <- diff( range( x ) ) ) == 0 ) {
        return( rep( mean( c( lo, hi ) ), length( x ) ) )
    }
    a <- diff( c( lo, hi ) ) / r
    b <- hi - max( x ) * a
    return( a * x  + b )
}

#  pretty -------------------------------------------------------------------------------------

#' Draws correct box around plot area.
plot_box <- function( bty, lwd=1, lty=1, col=par('fg') ) {
    if( !grep( '(]|[olcu7])', bty, ignore.case=TRUE ) ) stop(
        'invalid value specified for graphical parameter "bty"'
    ) else {
        if( grepl( '(]|[olcu])', bty, ignore.case=TRUE ) ) {
            abline( h=y_base(), lty=lty, lwd=lwd )
        }
        if( grepl( '[olcu]', bty, ignore.case=TRUE ) ) {
            abline( v=x_base(), lty=lty, lwd=lwd )
        }
        if( grepl( '(]|[oc7])', bty, ignore.case=TRUE ) ) {
            abline( h=y_top(), lty=lty, lwd=lwd )
        }
        if( grepl( '(]|[ou7])', bty, ignore.case=TRUE ) ) {
            abline( v=x_top(), lty=lty, lwd=lwd )
        }
    }
}

#' Generate tick marks for log-scale axes.
#' 
#' Genereates marks for log-scales by creating the given breaks for each power of base.
#' 
#' @param breaks A vector with the desired breaks at each power of base. Explicitly for now,
#'               eventually they will be generated automatically.
#' @param exp    Maximum exponent.
#' @param base   Base to use. Defaults to 10.
#' 
#' @return A vector of unique elements at each element of breaks to the power of 0 to max_exp - 1.
#' 
#' @export
# TODO: add max param for auto max_exp 
log_ticks <- function( breaks, max_exp, base=10 ) {
    out <- c()
    for( ex in 0:( max_exp - 1 ) ) {
        out <- c( out, setdiff( breaks * base^ex, out ) )
    }
    return( out )
}

#' Add orthogonal guides from the axes to the given point.
#' 
#' Adds segments parallel to the axes from the orthogonal axis base to the given points.
#' 
#' Optionally, adds symbols at the given points, and labels with their (x, y) locations near the 
#' corresponding axis. Calls \code{link{x_guide}}, \code{\link{y_guide}} and \code{link{points}} 
#' internally, passing all dots arguments to those functions to override defaults.
#' 
#' @param x      Vector with x axis locations.
#' @param y      Vector with y axis locations.
#' @param symbol Optional symbol to add at the given points. See \code{[ar('pch')]} for values. 
#'               Defaults to NA (no symbol)
#' @param gcol   Color for segments. Defaults to par('fg')
#' @param scol   Color for symbols. Defaults to par('fg'). Ignored unless !is.na( symbol )
#' @param labels Add labels next to axes. Defaults to NA (no labels). Other values have no effect 
#'               for now.
#' @param yadj   Adjustment for y-axis labels. See \code{par('adj')} for values.
#' @param xadj   Adjustment for y-axis labels. See \code{par('adj')} for values.
#' @param ylab   Vector with formats for the y-axis labels. If the given format includes no 
#'               placeholder variables it will work as override.
#' @param xlab   Vector with formats for the y-axis labels. If the given format includes no 
#'               placeholder variables it will work as override.
#' @param lty    Line type for segments. Defaults to '2', dashed lines. See \code{par('lty')} for 
#'               values.
#' @param ...    Other arguments passed to internally called functions with plot parameters.
#' 
#' @export
guides <- function( 
    x, y, symbol=NA, gcol=par('fg'), scol=par('fg'), 
    xdir=1, ydir=2, fill=NA, fcol=color_add_alpha(), fborder=NA,
    labels=NA, yadj=c( -.2, -.2 ), xadj=c( -.2, -.2 ), ylab=NA, xlab=NA,
    lty=2, ...
) {
    x_guide( x, y, gcol=gcol, lty=lty, ..., dir=xdir )
    y_guide( x, y, gcol=gcol, lty=lty, ..., dir=ydir )
    
    if( !is.na( symbol ) ) points( x, y, pch=symbol, col=scol, ... )
    
    if( !is.na( labels ) ) {
        if( grep( 'x', labels ) ) {
            lbls = if( !is.na( xlab ) && length( x ) == length( xlab ) ) {
                sprintf( xlab, x )    
            } else x
            lab_y <- switch( xdir,
                y_base(),
                stop( 'this should never happen.' ),
                {
                    xadj[2] <- 1 + ( 1 - sqrt( ( xadj[2] - .5 )^2 ) )
                    y_top()
                },
                stop( 'this should never happen.' )
            )
            text( x, lab_y, labels=lbls, adj=xadj, xpd=TRUE, cex=.8 )
        }
        if( grep( 'y', labels ) ) {
            lbls = if( !is.na( ylab ) && length( y ) == length( ylab ) ) {
                sprintf( ylab, y )    
            } else y
            lab_x <- switch( ydir,
                stop( 'this should never happen.' ),
                x_base(),
                stop( 'this should never happen.' ),
                {
                    x_top()
                    xadj[1] <- 1 + ( 1 - sqrt( ( xadj[1] - .5 )^2 ) )
                }
            )
            text( x_base(), y, labels=lbls, adj=yadj, xpd=TRUE, cex=.8 )
        }
    }
    
    if( !is.na( fill ) && fill != 0 ) {
        fill <- sign( fill[1] )
        if( fill > 0 ) {
            x_lo <- if( ydir == 2 ) x_base() else x
            x_hi <- if( ydir == 2 ) x else x_top()
            y_lo <- if( xdir == 1 ) y_base() else y
            y_hi <- if( xdir == 1 ) y else y_top()
            rect( x_lo, y_lo, x_hi, y_hi, col=fcol, border=fborder )
        } else if( fill < 0 ) {
            if( xdir == 1 ) {
                x_crd <- c( x_base(), x, x, x_top(), x_top(), x_base() )
                if( ydir == 2 ) {
                    y_crd <- c( y, y, y_base(), y_base(), y_top(), y_top() )
                } else {
                    y_crd <- c( y_base(), y_base(), y, y, y_top(), y_top() )
                }
            } else {
                x_crd <- c( x_base(), x_top(), x_top(), x, x, x_base() )
                if( ydir == 2 ) {
                    y_crd <- c( y_base(), y_base(), y_top(), y_top(), y, y )
                } else {
                    y_crd <- c( y_base(), y_base(), y, y, y_top(), y_top() )
                }
            }
            polygon( x_crd, y_crd, col=fcol, border=fborder )
        } else {
            stop( 'this should never happen.' )
        }
    }
}

#' Draw vertical line from the x axis to the given points.
#' 
#' @param x Vector with x locations.
#' @param y Vector with y locations.
#' @param gcol Line color. Defaults to \code{par('fg')}.
#' @param dir One of 1 or 3 for bottom or top
#' @param ... Other parameters passed to \code{\link{segments}}.
#' 
#' @export
x_guide <- function( x, y, gcol=par('fg'), dir=1, ...
) {
    rev <- switch( dir[1],
        FALSE,
        stop( 'Invalid direction given for x_guide: only 1 or 3 are valid.' ),
        TRUE,
        stop( 'Invalid direction given for x_guide: only 1 or 3 are valid.' )
    )
    y_src <- if( rev ) rep( y_top(), length( y ) ) else rep( y_base(), length( y ) )
    segments( x, y_src, x, y, col=gcol, ... )
}

#' Draw horizontal line from the y axis to the given points.
#' 
#' @param x Vector with x locations.
#' @param y Vector with y locations.
#' @param gcol Line color. Defaults to \code{par('fg')}.
#' @param dir One of 2 or 4 for left or right
#' @param ... Other parameters passed to \code{\link{segments}}.
#' 
#' @export
y_guide <- function( x, y, gcol=par('fg'), dir=2, ... 
) {
    rev <- switch( dir[1],
        stop( 'Invalid direction given for x_guide: only 1 or 3 are valid.' ),
        FALSE,
        stop( 'Invalid direction given for x_guide: only 1 or 3 are valid.' ),
        TRUE
    )
    x_src <- if( rev ) rep( x_top(), length( x ) ) else rep( x_base(), length( x ) )
    segments( x_src, y, x, y, col=gcol, ... )
}

# units and coords ---------------------------------------------------------------------------------

#' Number of x-axis user units in n inches.
#' @export
x_unit <- function( n=1 ) {
    # Size of the NDC x-axis unit in inches
    usr <- par('usr')
    pin <- par('pin')
    # x size divided by x-axis range
    return( ( pin[1] / ( usr[2] - usr[1] ) ) * n )
}

#' Number of y-axis user units in n inches.
#' @export
y_unit <- function( n=1 ) {
    # Size of the NDC y-axis unit in inches
    usr <- par('usr')
    pin <- par('pin')
    # x size divided by x-axis range
    return( ( pin[2] / ( usr[4] - usr[3] ) ) * n )
}

#' Number of inches in n x-axis user units.
#' @export
x_inch <- function( n=1 ) {
    return( xinch( n ) )
}

#' Number of inches in n y-axis user units.
#' @export
y_inch <- function( n=1 ) {
    return( yinch() )
}

#' NDC for arbitrary position on x axis given as proportion of plot area
x_pos <- function( p=.5 ) {
    raw <- par('usr')[1] + ( ( par('usr')[2] - par('usr')[1] ) * p )
    if( par('xlog') ) {
        return( 10^raw )
    } else {
        return( raw )
    }
}

#' NDC for arbitrary position on y axis given as proportion of plot area
y_pos <- function( p=.5 ) {
    raw <- par('usr')[3] + ( ( par('usr')[4] - par('usr')[3] ) * p )
    if( par('ylog') ) {
        return( 10^raw )
    } else {
        return( raw )
    }
}

#' NDC for left-most points in plot.
x_base <- function() x_pos( 0 )

#' NDC for bottom points in plot.
y_base <- function() y_pos( 0 )

#' NDC for right-most point in plot.
x_top <- function() x_pos( 1 )

#' NDC for top point in plot.
y_top <- function() y_pos( 1 )

#' NDC range for left-right axis
x_range <- function() c( x_base(), x_top() )

#' NDC range for bottom-top axis
y_range <- function() c( y_base(), y_top() )

text_size <- function() {
    plot( NA, xlim=c( 0, 11 ), ylim=c( -1, 1 ), ylab=NA, xlab=NA )
    text( cumsum( 1:10 ) %>% `/`( max( . ) / 10 ), rep( 0, 10 ), cex=1:10 )
}

# util ----------------------------------------------------------------------------------------

#' Convenience function to make qualitative palettes depending on number of levels.
#' TODO: add more options, facilitate choice of palettes.
#' Used internally by plotting functions if user gives no palette.
color_mk_palette <- function( ... ) {
    function( n ) {
        viridis::viridis_pal( ... )( n )
    } %>% return()
}

color_interpolate <- function( col1, col2=NULL, inner=is.null( col2 ) ) {
    if( inner ) {
        if( is.null( col2 ) ) col2 <- col1
        col <- matrix( NA, nrow=length( col1 ), ncol=length( col2 ) )
        for( i in 1:length( col1 ) ) {
            for( j in 1:length( col2 ) ) {
                col[i,j] <- color_interpolate( col1[i], col2[j] )
            }
        }
        rownames( col ) <- col1
        colnames( col ) <- col2
    } else {
        col <- apply( cbind( col1, col2 ), 1, function( x ) {
            return( colorRampPalette( x )( 3 )[2] )
        } )
    }
    return( col )
}

color_add_alpha <- function( col=par('fg'), alpha=.1 ) {
    if( is.matrix( col ) ) {
        cnames <- colnames( col ); rnames <- rownames( col )
        col <- apply( col, 2, function( c ) color_add_alpha( c, alpha ) ) %>% as.matrix()
        colnames( col ) <- cnames; rownames( col ) <- rnames # I fucking hate apply.
    } else {
        col <- col2rgb( col, alpha=TRUE )
        col[4,] <- round( col[4,] * alpha, 0 )
        col %<>% apply( 2, function( x ) {
            rgb( x[1], x[2], x[3], x[4], maxColorValue=255 )
        } )
    }
    return( col )
}
