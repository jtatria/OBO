#!/usr/bin/Rscript

require( dplyr )
require( wspaces )

source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )

PROJ_NAME    <- 'c3_epochs'
XS_DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s_X.RData', PROJ_NAME ) ) 
SN_DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s_G.RData', PROJ_NAME ) )
PRUNE_TOL    <- 0
CLUSTER_CONTRIBS <- FALSE

make_xs <- function() {
    ls <- lexical_sample( td$tf, ( !is.na( td$pos ) & td$pos %in% c( 'NN' ) ), theta=ut$EPOCH_SAMPLE_THETA )
    message( sprintf( "Lexical sample for tetha %4.2f contains %d terms", ut$EPOCH_SAMPLE_THETA, sum( ls ) ) )
    fs <- lexical_sample( td$tf, theta=gr$FEATURE_THETA )
    message( sprintf( "Feature sample for theta %4.2f contains %d terms", gr$FEATURE_THETA, sum( fs ) ) )
    
    xs <- list()
    for( edir in list.dirs( ut$DIR_DATA_SAMPLES, recursive=FALSE ) ) {
        ename <- sname <- gsub( ".*/", "", edir )
        epoch <- load_sample( edir, lxcn=cr$data$lxcn )
        X  <- epoch$cooc %>% weight_sample( cr$data$cooc )
        els <- ls[ 1:nrow( X ) ] & ( X %>% rowSums() %>% `>`( 0 ) )
        efs <- fs[ 1:nrow( X ) ] & ( X %>% colSums() %>% `>`( 0 ) )
        ut$infof(
            "Computing %s similarity matrix for %d terms using %d features",
            ename, sum( els ), sum( efs )
        )
        X <- X[els,efs] %>% simdiv( mode=ut$HIGH_MODE )
        xs[[ename]] <- X
    }
    save( xs, file=XS_DATA_FILE )
}

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
    term_data <- cr$get_terms()
    
    if( !file.exists( XS_DATA_FILE ) ) {
        ut$infof( "Similarity matrices data file %s not found. Recreating...", XS_DATA_FILE )
        make_xs( term_data )
    } else {
        load( XS_DATA_FILE )
    }
    
    epochs <- lapply( xs, function( X ) graph_make(
        X, prune.tol=PRUNE_TOL, #prune.sort=wspaces::graph_edge_score,
        vertex.data=term_data, cluster.contribs=CLUSTER_CONTRIBS, verbose=TRUE
    ) )
    
    save( epochs, term_data, file=DATA_FILE )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )
