#!/usr/bin/Rscript

require( dplyr )
require( magrittr )
require( wspaces )
require( Matrix )

source( 'inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )
source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )

DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s.RData', "epoch_param_test" ) )

TOLS <- c( 1 )#0, 1, 2 )
SCORES <- list( 
    'w'=function( g ) graph_edge_score( g, score.func=graph_edge_score_ident )#,
    #'s'=function( g ) graph_edge_score( g, score.func=graph_edge_score_mlf )
)
LS_THETA <- ut$EPOCH_SAMPLE_THETA
FS_THETA <- gr$FEATURE_THETA

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
    td <- cr$get_terms()
    ls <- lexical_sample( td$tf, ( !is.na( td$pos ) & td$pos == 'NN' ), theta=LS_THETA )
    fs <- lexical_sample( td$tf, theta=FS_THETA )
    
    tmp <- data.frame()
    out <- data.frame()
    
    for( edir in list.dirs( ut$DIR_DATA_SAMPLES, recursive=FALSE ) ) {
        ename <- sname <- gsub( ".*/", "", edir )
        epoch <- load_sample( edir, lxcn=cr$data$lxcn )
        
        tmp[ 1, 'epoch' ] <- ename
        
        X  <- epoch$cooc %>% weight_pmi()
        els <- ls[ 1:nrow( X ) ] & ( X %>% rowSums() %>% `>`( 0 ) )
        efs <- fs[ 1:nrow( X ) ]
        
        X <- X[els,efs] %>% simdiv( mode=ut$HIGH_MODE, quiet=TRUE )
        G <- igraph::graph_from_adjacency_matrix( X, mode='directed', weighted=TRUE, diag=FALSE )
        tmp[ 1, 'e_pre' ] <- e_pre <- length( igraph::E( G ) )
        tmp[ 1, 'v_pre' ] <- v_pre <- length( igraph::V( G ) )
        for( score in names( SCORES ) ) {
            edges <- igraph::E( G )[ order( SCORES[[score]]( G ), decreasing=TRUE ) ]
            for( tol in TOLS ) {
                message( sprintf( "Pruning according to %s, tolerance %d", score, tol ) )
                G_p <- graph_prune( G, edges=edges, tol=tol, verbose=TRUE )
                e_pos <- length( igraph::E( G_p ) )
                v_pos <- length( igraph::V( G_p ) )
                e_red <- ( ( e_pre - e_pos ) / e_pre )
                v_red <- ( ( v_pre - v_pos ) / v_pre )
                tmp[ 1, paste( 'e', score, tol, sep='_' ) ] <- e_red
                tmp[ 1, paste( 'v', score, tol, sep='_' ) ] <- v_red
            }
        }
        out <- rbind( out, tmp )
    }
    browser()
    #save( out, file=DATA_FILE )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
load( DATA_FILE )

out