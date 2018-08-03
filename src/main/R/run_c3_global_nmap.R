#!/usr/bin/Rscript

source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )

PROJ_NAME <- "c3_global"
DEVICE    <- 'tikz'
SIZE      <- 'tf'

filter_labels <- function( g, filter ) {
    lbls <- gr$pretty_names( g )
    out  <- rep( NA, length( lbls ) )
    out[ filter ] <- lbls[ filter ]
    return( out )
}

layitout <- function( g, ... ) {
    ut$layout_with_fr( g, niter=1000 )
    # gr$layout_per_cluster( g,
    #     lo_func1=ut$layout_with_fr,
    #     lo_func2=ut$layout_in_circle
    # )
}

plotit <- function( g, lo,
    vsizes=( ut$vattr( g, SIZE ) %>% log1p() ) %>% `/`( max( . ) ), vlabels=NULL,
    clusters=FALSE, ealpha=.1, vcex=.4,
    vlabels.cex=.7,
    raster.edges=TRUE, ...
) {
    ut$plot_graph(
        g, lo, vsizes=vsizes, vlabels=vlabels, clusters=clusters, ealpha=ealpha, vcex=vcex,
        vlabels.cex=vlabels.cex, raster.edges=raster.edges, ...
    )
}

source( sprintf( 'inc_%s_data.R', PROJ_NAME ) )

lo_ppmi <- layitout( ppmi$G )
lo_difw <- layitout( difw$G )

ut$gr_setup( y=ut$GR_PLOT_Y * 4, device=DEVICE, file=( fig <- sprintf( '%s_ppmi', PROJ_NAME ) ) )
    par( mar=c( 0,0,0,0 ) )
    plotit( ppmi$G, lo_ppmi )
ut$gr_finish()
# ugly hack to work around tikzDevice bug
if( DEVICE == 'tikz' ) {
    file.rename( file.path( getwd(), "_ras1.png" ), file.path( ut$DIR_PLOT, sprintf( "%s_ras1.png", fig ) ) )
    system( sprintf( "perl -pi -e 's/_ras1/%s_ras1/g' %s", fig, file.path( ut$DIR_PLOT, sprintf( "%s.tex", fig ) )  ) )
}

ut$gr_setup( y=ut$GR_PLOT_Y * 4, device=DEVICE, file=( fig <- sprintf( '%s_difw', PROJ_NAME ) ) )
    par( mar=c( 0,0,0,0 ) )
    plotit( difw$G, lo_difw )
ut$gr_finish()
# ugly hack to work around tikzDevice bug
if( DEVICE == 'tikz' ) {
    file.rename( file.path( getwd(), "_ras1.png" ), file.path( ut$DIR_PLOT, sprintf( "%s_ras1.png", fig ) ) )
    system( sprintf( "perl -pi -e 's/_ras1/%s_ras1/g' %s", fig, file.path( ut$DIR_PLOT, sprintf( "%s.tex", fig ) )  ) )
}
