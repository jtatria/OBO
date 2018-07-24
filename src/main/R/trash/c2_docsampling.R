#!/usr/bin/Rscript

require( magrittr )
require( dplyr )

rm( list=ls() )

source( 'inc/obo_util.R',  chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME <- 'c2_docsampling'
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( "%s.RData", PROJ_NAME ) )
DEVICE    <- 'tikz'

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )

    lctr <- ut$io_index()

    # testimony and complement
    ds1 <- lector_sample( lctr, ut$sample_testimony() )
    ds2 <- lector_sample( lctr, ut$sample_testimony(), negate=TRUE )

    # lex sample: tf \in top 95%
    ts <- lexical_sample( cr$data$lxcn$tf )

    # year frequencies
    freq1 <- lector_count_freqs( lctr, ds1 )
    freq2 <- lector_count_freqs( lctr, ds2 )

    # weighted and normalized frequencies
    wfreq1 <- tfidf( freq1 %>% as.matrix(), cr$data$lxcn$df, lector_numdocs( lctr ), normal=TRUE )
    wfreq2 <- tfidf( freq2 %>% as.matrix(), cr$data$lxcn$df, lector_numdocs( lctr ), normal=TRUE )

    # self div
    sdiv1 <- simdiv( wfreq1[ts,], trans=TRUE )
    sdiv2 <- simdiv( wfreq2[ts,], trans=TRUE )

    # parallel div
    div <- simdiv( wfreq1[ts,], wfreq2[ts,], inner=FALSE, trans=TRUE )

    # tfs.
    tf1 <- colSums( freq1 )
    tf2 <- colSums( freq2 )

    vecs <- data.frame( tf1=tf1, tf2=tf2, div=div )

    save(
        freq1,
        freq2,
        wfreq1,
        wfreq2,
        sdiv1,
        sdiv2,
        vecs,
        file=DATA_FILE
    )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )

ut$gr_setup( sprintf( '%s_fig1', PROJ_NAME ), n=2, device=DEVICE )
    cols <- ut$color_mk_palette()( 2 )
    plot( NA, xlim=range( 1674:1913 ), ylim=c( 1, ( max( c( vecs$tf1, vecs$tf2 ) ) ) ), ylab=NA, xlab=NA, axes=FALSE, xaxs='i', log='y' )
    lines( as.integer( names( freq1 ) ), ( vecs$tf1 ) %>% zoo::rollmean( k=2, fill='extend' ), col=cols[1] )
    lines( as.integer( names( freq2 ) ), ( vecs$tf2 ) %>% zoo::rollmean( k=2, fill='extend' ), col=cols[2] )
    axis( 1 ); axis( 2, at=axTicks( 2 ), labels=format( axTicks( 2 ), scientific=FALSE ), las=1 )
    mtext( side=3, line=0, text='Term frequencies in $C_{testimony}$ (red) and its complement (blue)', cex=.8 )
    ut$period_lines()
    box()

    plot( NA, xlim=range( 1674:1913 ), ylim=range( vecs$div, na.rm=TRUE ), ylab=NA, xlab=NA, axes=FALSE, xaxs='i' )
    lines( as.integer( names( freq1 ) ), vecs$div, col=cols[1] )
    axis( 1 ); axis( 2 )
    mtext( side=3, line=0, text='Cosine similarities of tf distributions between $C_{testimony}$ and its complement (LS95)', cex=.8 )
    ut$period_lines()
    box()
ut$gr_finish()

imgs <- list( sdiv1, sdiv2 )
titles <- c(
    "$C_{testimony}$",
    "$\\sim C_{testimony}$"
)
rasters <- list()
for( i in 1:length( imgs ) ) {
    rasters[[i]] <- tempfile()
    png( rasters[[i]], width=480, height=480 )
    par( mar=c( 0,0,0,0 ) )
    ut$plot_heat( imgs[[i]], axes=FALSE, legend=FALSE, pty='m', nan.rm='min' )
    dev.off()
}
ut$gr_setup( fig <- sprintf( '%s_fig1', PROJ_NAME ), n=1, device=DEVICE )
layout( matrix( 1:length( imgs ), ncol=length( imgs ) ) )
par( mar=c( 2,.5,2,.5 ) )
par( oma=c( 0,0,0,0 ) )
for( i in 1:length( imgs ) ) {
    plot( NA, type='n', xlim=c( 1674, 1913 ), ylim=c( 1674, 1913 ), pty='s', xlab=NA, ylab=NA, axes=FALSE )
    ut$gr_add_raster( rasters[[i]] )
    title( main=titles[i] )
    axis( 1 )
    ut$period_lines()
    box()
}
ut$gr_finish()

# ugly hack to work around tikzDevice bug
file.rename( file.path( getwd(), "_ras1.png" ), file.path( ut$DIR_PLOT, sprintf( "%s_ras1.png", fig ) ) )
system( sprintf( "perl -pi -e 's/_ras1/%s_ras1/g' %s", fig, file.path( ut$DIR_PLOT, sprintf( "%s.tex", fig ) )  ) )
