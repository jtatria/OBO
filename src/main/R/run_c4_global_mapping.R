#!/usr/bin/Rscript

source( 'inc/obo_glove.R',  chdir=TRUE, local=( if( exists( 'gv' ) ) gv else ( gv <- new.env() ) ) )
source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
source( 'inc_c3_global_data.R', local=( c3 <- new.env() ) )

PROJ_NAME <- 'c4_global'
DEVICE    <- 'tikz'

# Load global model
ws <- gv$load_glove( file.path( ut$DIR_DATA_GLOVE, 'global' ), td=cr$get_terms() )
td <- attr( ws, 'term_data' )

# Build lex sampling vector
S95_n <- lexical_sample( td$tf.x, filter=( !is.na( td$pos ) & td$pos == 'NN' ), theta=ut$SAMPLE_THETA )

# Extract data from c3 sn.
common <- with( c3$ppmi, which( td$term %in% ut$V( G )$term ) )
k      <- with( c3$ppmi, K$membership[ ut$V( G )$term %in% td$term ] )
size   <- with( c3$ppmi, graph_cluster_contribs( G, K$membership, mode='vc' )[ ut$V( G )$term %in% td$term ] )

# tSNE global map
ut$gr_setup( y=ut$GR_PLOT_Y * 2, device=DEVICE, file=( fig <- sprintf( '%s_tsne', PROJ_NAME ) ) )
par( mar=c( 0,0,0,0 ) )
plot( ws, inc=common, size=( size + .1 ), col=ut$color_mk_palette()( length( unique( k ) ) )[k], asp=1 )
ut$gr_finish()

# NN maps
ut$gr_setup( device=DEVICE, file=sprintf( '%s_nns', PROJ_NAME ) )
    cex <- par()$cex
    layout( matrix( c(1,3,2), ncol=3 ), widths=c( 1,.2,1 ), respect=TRUE )
    par( mar=c(0,0,0,0), cex=cex )
    gv$plot.neighbours( ws, 'prisoner',   k=100, filter=S95_n, size=td$tf.x, method='sne' )
    gv$plot.neighbours( ws, 'prosecutor', k=100, filter=S95_n, size=td$tf.x, method='sne' )
ut$gr_finish()

# Gender-Status plane projection
ut$gr_setup( y=ut$GR_PLOT_Y * 2, device=DEVICE, file=sprintf( '%s_axes', PROJ_NAME ) )
    v_lord <- ws['lord',]
    v_serv <- ws['servant',]
    v_male <- ws['man',]
    v_fema <- ws['woman',]
    a1 <- ws[common,] %>% euclid::vproj( rbind( v_lord - v_serv ) %>% euclid::vunit(), scalar=TRUE )
    a2 <- ws[common,] %>% euclid::vproj( rbind( v_male - v_fema ) %>% euclid::vunit(), scalar=TRUE )
    pos <- cbind( a2, a1 )
    cex <- td$tf.x[common] %>% log() %>% `/`( max( . ) )
    col <- ut$color_mk_palette()( unique( k ) %>% length() )[k]
    plot( pos, asp=1, cex=cex, col=col, pch=19, axes=FALSE, ylab=NA, xlab=NA )
    #brd <- euclid::border( pos, idx=TRUE, k=4 )
    brd <- border( pos, idx=TRUE, k=4 )
    text( pos[ brd, ], labels=td$term[ common ][ brd ], pos=1, cex=.8 )
    abline( h=0, v=0, xpd=FALSE, lwd=.8 )
    mtext( '$v_{woman} \\rightarrow v_{man}$', side=1, las=0 )
    mtext( '$v_{servant} \\rightarrow v_{lord}$', side=2, las=0 )
ut$gr_finish()
