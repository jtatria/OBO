#!/usr/bin/Rscript

require( sna )
require( dplyr )

source( 'inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )
source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )

PROJ_NAME <- "c3_global"
DEVICE <- 'tikz'
source( sprintf( '%s_data.R', PROJ_NAME ) )

need.save <- FALSE
if( !gr$has_vattr( ppmi$G, 'wgt_v2c' ) || !gr$has_vattr( ppmi$G, 'wgt_c2v' ) ) {
    need.save <- TRUE
    message( 'Computing contribution scores for ppmi network' )
    ppmi$G %<>% gr$add_contrib_scores( ppmi$K$membership )
}
if( !gr$has_vattr( difw$G, 'wgt_v2c' ) || !gr$has_vattr( difw$G, 'wgt_c2v' ) ) {
    need.save <- TRUE
    message( 'Computing contribution scores for difw network' )
    difw$G %<>% gr$add_contrib_scores( difw$K$membership )
}
if( need.save ) save_data()

# strengt-centrality plots --------------------------------------------------------------------

plot_str <- function( g ) {
    tf <- gr$vattr( g, 'tf' )
    st <- igraph::strength( g )
    wt <- ( gr$vattr( g, 'wgt_v2c' ) * gr$vattr( g, 'wgt_c2v' ) )
    k <- gr$vattr( g, 'comm' )
    col <- ut$color_mk_palette()( length( unique( k ) ) )[ k ]
    x <- wt
    y <- st
    z <- tf %>% log1p() %>% `/`( max( . ) )
    plot( x, y, cex=z, xaxs='i', col=col, pch=19, log='xy', asp=1, axes=FALSE, xlab=NA, ylab=NA )
    axis( 2, at=( tks <- axTicks( 2 ) ), labels=format( tks, scientific=FALSE ), las=1 )
    axis( 1, at=( tks <- axTicks( 1 ) ), labels=format( tks, scientific=FALSE ), las=1 )
    box()
}

ut$gr_setup( sprintf( '%s_strength', PROJ_NAME ), n=2, device=DEVICE )
par( xpd=FALSE )
plot_str( ppmi$G )
mtext( side=3, line=0, text='Direct cooccurrence network', cex=.8 )
plot_str( difw$G )
mtext( side=3, line=0, text='Difference weighted network', cex=.8 )
ut$gr_finish()

# block models --------------------------------------------------------------------------------
message( 'Block models' )

m <- gr$get_adj( ppmi$G, sparse=FALSE )
d <- simdiv( m, mode=1 )
d <- 1 - ( ( d + t( d ) ) / 2 )
difw_scores <- difw %>% { gr$cluster_contribs( .$G, .$K$membership, mode='c2v' ) }

# 10 blocks: all communities in difw.
message( 'Generating model with 10 blocks' )
k1 <- kmeans( d, 10 )$cluster
score <- c2v_contrib( m, k1 )
ppmi_scores <- vapply( 1:length( unique( k1 ) ), function( kid ) ifelse( k1 == kid, score, 0 ), rep( 0, length( score ) ) )

cap1 <- intersect( gr$vattr( ppmi$G, 'term' ), gr$vattr( difw$G, 'term' ) )
ppmi_s <- ppmi_scores[ gr$V( ppmi$G )$term %in% cap1, ]
difw_s <- difw_scores[ gr$V( difw$G )$term %in% cap1, ]
x1 <- simdiv( ppmi_s, difw_s, trans=TRUE )

# 4 blocks: exclude small communities in difw
message( 'Generating model with four blocks' )
k2 <- kmeans( d, 4 )$cluster
score <- c2v_contrib( m, k2 )
ppmi_scores <- vapply( 1:length( unique( k2 ) ), function( kid ) ifelse( k2 == kid, score, 0 ), rep( 0, length( score ) ) )

# top 4 clusters
kf <- difw$K$membership %>% table() %>% as.vector() %>% order( decreasing=TRUE ) %>% `[`( 1:4 )
cap2 <- intersect( gr$V( difw$G )$term[ gr$V( difw$G )$comm %in% kf ], cap1 )
ppmi_s <- ppmi_scores[ gr$V( ppmi$G )$term %in% cap2, ]
difw_s <- difw_scores[ gr$V( difw$G )$term %in% cap2, kf ]
x2 <- simdiv( ppmi_s, difw_s, trans=TRUE )

ut$gr_setup( sprintf( '%s_assoc', PROJ_NAME ), n=1, device=DEVICE )
    cex <- par()$cex; layout( matrix( 1:2, ncol=2 ), respect=TRUE )
    par( mar=c( 2.1,2.1,2.1,2.1 ), oma=c( 0,1,1,1 ), cex=cex )

    ut$plot_heat( x1 / max( x1 ), legend=FALSE, axes=FALSE ); box()
    axis( 1, line=-1, at=( 1:10 ), labels=1:10, las=1, tick=FALSE )
    axis( 2, at=( 1:10 ), labels=10:1, las=1, tick=FALSE )
    mtext( side=3, las=1, 'All communities', cex=.8 )

    ut$plot_heat( x2 / max( x2 ) , legend=TRUE, axes=FALSE ); box()
    axis( 1, line=-1, at=( 1:4 ), labels=kf, las=1, tick=FALSE )
    axis( 2, at=( 1:4 ), labels=4:1, las=1, tick=FALSE )
    mtext( side=3, las=1, 'Largest four communities', cex=.8 )

    mtext( side=2, las=0, 'Eq. classes', line=2, cex=.8 )
ut$gr_finish()

# Cross-tabulation: counts
ppmi_k <- k1[ gr$V( ppmi$G )$term %in% cap1 ]
difw_k <- gr$V( difw$G )$comm[ gr$V( difw$G )$term %in% cap1 ]
ut$latex_xtab.default( ppmi_k, difw_k, file=file.path( ut$DIR_TABLE, sprintf( '%s_block1.tex', PROJ_NAME ) ),
    'Eq. classes', 'Communities',
    caption=c(
        'Cross classification of terms into 10 equivalence classes in lower-order network and all communities in higher-order network',
        'Cross-tabulation of 10-block model and communities'
    ),
    label=sprintf( 'tab:%s_block1', PROJ_NAME )
)
message( '10-block chisq:' )
chisq.test( ppmi_k, difw_k )

# Cross-tabulation: counts
ppmi_k <- k2[ gr$V( ppmi$G )$term %in% cap2 ]
difw_k <- gr$V( difw$G )$comm[ gr$V( difw$G )$term %in% cap2 ]
ut$latex_xtab.default( ppmi_k, difw_k, file=file.path( ut$DIR_TABLE, sprintf( '%s_block2.tex', PROJ_NAME ) ),
    'Eq. classes', 'Communities',
    caption=c(
        'Cross classification of terms into 4 equivalence classes in lower-order network and 4 largest communities in higher-order network',
        'Cross-tabulation of 4-block model and communities'
    ),
    label=sprintf( 'tab:%s_block2', PROJ_NAME )
)
message( '4-block chisq:' )
chisq.test( ppmi_k, difw_k )

