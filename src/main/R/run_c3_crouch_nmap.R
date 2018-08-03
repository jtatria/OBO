#!/usr/bin/Rscript

source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) gr else ( gr <- new.env() ) ) )

PROJ_NAME <- "c3_crouch"
DEVICE    <- 'tikz'

MARKS     <- c( 'prisoner', 'prosecutrix', 'hardwork', 'cistern' )
EGO       <- 'prosecutrix'
SIZE      <- 'tf'
DEBUG     <- FALSE

layitout <- function( g, ... ) {
    # layout_witf_fa2( g, iter=1000 )
    # gr$layout_with_fr( g, weights=gr$eattr( g, 'weight_c' ), niter=5000 )
    gr$layout_per_cluster( g,
        lo_func1=function( g ) ut$layout_with_fr( g ),
        lo_func2=ut$layout_in_circle
        #lo_func2=function( g ) layout_with_fa2( g, G=100, iter=10000, force=TRUE )
    )
}

plotit <- function( g, lo,
    vsizes=( ut$vattr( g, SIZE ) %>% log1p() ) %>% `/`( max( . ) ),
    vlabels=gr$pretty_names( g ),
    marks=MARKS, clusters=FALSE
) {
    ut$plot_graph(
        g, lo, vsizes=vsizes, vlabels=vlabels, vmarks=marks, vcex=.5, vlabels.cex=.6,
        clusters=clusters, debug=FALSE
    )
}

source( sprintf( 'inc_%s_data.R', PROJ_NAME ) )

# Network maps --------------------------------------------------------------------------------

lo_ppmi <- layitout( ppmi$G )
lo_difw <- layitout( difw$G )

ut$gr_setup( y=ut$GR_PLOT_Y * 2, device=DEVICE, file=sprintf( '%s_ppmi', PROJ_NAME ) )
    par( mar=c(0,0,0,0) )
    plotit( ppmi$G, lo_ppmi, vs=( ut$vattr( ppmi$G )$tf %>% log1p() ) %>% `/`( max( . ) ) )
ut$gr_finish()

vs <- ( ut$vattr( difw$G )$tf %>% log1p() ) %>% `/`( max( . ) )
ut$gr_setup( y=ut$GR_PLOT_Y * 2, device=DEVICE, file=sprintf( '%s_difw', PROJ_NAME ) )
    par( mar=c(0,0,0,0) )
    plotit( difw$G, lo_difw, vs=( ut$vattr( difw$G )$tf %>% log1p() ) %>% `/`( max( . ) ) )
ut$gr_finish()

# Ego networks --------------------------------------------------------------------------------

ego_ppmi <- ut$ego_graph( ppmi$G, nodes=gr$termv( ppmi$G, EGO ), order=2 )[[1]]
ego_difw <- ut$ego_graph( difw$G, nodes=gr$termv( difw$G, EGO ), order=2 )[[1]]

lofunc <- function( g ) ut$layout_with_fr( g, niter=5000 )
ut$gr_setup( device=DEVICE, file=sprintf( '%s_egos', PROJ_NAME ) )
    cex <- par()$cex
    layout( matrix( c(1,3,2), ncol=3 ), widths=c( 1,.2,1 ), respect=TRUE )
    par( mar=c(0,0,0,0), cex=cex )
    plotit( ego_ppmi, lofunc, 'tf', marks=EGO, clusters=FALSE )
    plotit( ego_difw, lofunc, 'tf', marks=EGO, clusters=FALSE )
ut$gr_finish()

