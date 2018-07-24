#!/usr/bin/Rscript

source( 'inc/obo_util.R',  chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME <- "c4_epochs"
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s.RData', PROJ_NAME ) )
REDUCTIONS <- c()

make_data <- function() {
    source( 'inc/obo_glove.R',  chdir=TRUE, local=( if( exists( 'gv' ) ) gv else ( gv <- new.env() ) ) )
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )

    global <- gv$load_glove( file.path( ut$DIR_DATA_GLOVE, 'global' ), td=cr$get_terms() )
    td <- attr( global, 'term_data' )

    epochs <- list()
    ts <- proc.time()
    for( d in list.files( ut$DIR_DATA_GLOVE ) ) {
        if( d %in% c( '', 'global' ) ) next
        dir <- file.path( ut$DIR_DATA_GLOVE, d )
        ut$infof( "Loading vector space model data from %s", dir )
        ws <- gv$load_glove( dir )
        ut$infof( "Loaded vector space with %d dimensions for %d terms", ncol( ws ), nrow( ws ) )
        epochs[[d]] <- ws
    }
    te <- proc.time()
    ut$infof(
        "Loaded vector space model with %d epochs in %8.4f seconds",
        length( epochs ), ( te - ts )[3]
    )

    save( global, epochs, td, file=DATA_FILE )
}


if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )
