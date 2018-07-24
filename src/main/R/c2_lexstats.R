#!/usr/bin/Rscript

require( magrittr )
require( dplyr )
require( wspaces )

rm( list=ls() )

source( 'inc/obo_util.R',  chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME <- 'c2_lexstats'
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( "%s.RData", PROJ_NAME ) )
DEVICE    <- 'internal'

#' Freqs contains zeros for 1701 and 1705. They used to be replaced with adjacent values on load, 
#' but I decided it is wiser not to fill in values, but to add zero columns in order to keep freq 
#' at 240 years long.
#' 
#' This function may be used to apply a correction for downstream consumers that will cry if freqs
#' contain zeros (see lexstats figure 2 for an example)
fill_zero_freqs <- function( frq ) {
    message( "NB: Filling zero columns in freq dataset with average of adjacent columns" )
    z <- which( colSums( frq ) == 0 )
    for( i in z ) {
        frq[[i]] <- ( ( frq[[i-1]] + frq[[i+1]] ) / 2 ) %>% as.integer()
    }
    return( frq )
}

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
    terms <- cr$get_terms()
    terms <- terms[ terms$inc, ]
    freqs <- cr$data$freq %>% fill_zero_freqs()
    save( terms, freqs, file=DATA_FILE )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )

mark_term <- function( term, col='red' ) {
    x = which( rownames( terms ) == term );
    y = terms$tf[ x ]
    ut$guides( x, y, symbol=16, scol=col, label='xy', yadj=c( -.1, -.2 ) )
    label <- if( grepl( 'tikz', names( dev.cur() ) ) ) {
        sprintf( '$\\leftarrow %s$', term )
    } else {
        sprintf( '\U2190 %s', term )
    }
    text( x, y, label, adj=c( -.15, .15 ) )
}

png( bg <- tempfile(), width=1800, height=600, bg='transparent' )
par( mar=c(0,0,0,0) )
plot( terms$tf, type='l', ylab=NA, xlab=NA, axes=FALSE, log='xy', xaxs='i', yaxs='i', lwd=2, col=ut$color_mk_palette()( 1 ) )
dev.off()
ut$gr_setup( sprintf( "%s_fig1", PROJ_NAME ), device=DEVICE )
    plot( terms$tf, type='n', ylab=NA, xlab=NA, axes=FALSE, log='xy', xaxs='i', yaxs='i' )
    box( bty='o' )
    ut$gr_add_raster( bg )
    axis( 1, at=c( ut$log_ticks( c( 1, 10 ), 4 ), length( terms$tf ) ) )
    axis( 2, at=c( ut$log_ticks( c( 1, 10 ), 6 ), max( terms$tf ) ), las=1, xpd=FALSE )
    mark_term( 'prisoner' )
    mark_term( 'man' )
    mark_term( 'woman' )
    mark_term( 'kill' )
ut$gr_finish()

ut$gr_setup( sprintf( "%s_fig2", PROJ_NAME ), device=DEVICE )
    wd <- terms %>% group_by( rnk ) %>% summarise( wd=sum( tf )  ) %>% select( wd ) %>% unlist()
    table( terms$mss, terms$pos ) %>%
    ut$plot_stacks( boxes.width=sqrt( wd ), axes=FALSE, nopar=TRUE, sort=11:1 )
    axis( 2, las=1 )
    box()
ut$gr_finish()

ut$gr_setup( sprintf( "%s_fig3", PROJ_NAME ), device=DEVICE )
    terms %>% select( pos ) %>% wspaces::lexical_join( freqs ) %>%
        group_by( pos ) %>% summarize_all( sum ) %>%
    tidyr::gather( year, N, -pos ) %>%
    transmute( year = as.integer( year ), pos=pos, N=N ) %>%
    ut$plot_stacks( sort=11:1 )
    ut$period_lines()
    axis( 2, las=1 )
ut$gr_finish()

