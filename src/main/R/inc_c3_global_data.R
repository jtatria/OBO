require( Matrix )

source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) gr else ( gr <<- new.env() ) ) )

PROJ_NAME   <- "c3_global"
DATA_FILE   <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s.RData', PROJ_NAME ) )
COOC_FILE   <- file.path( ut$DIR_DATA, 'samples', 'cooc.bin' )
HIGH_FUNC   <- function( X ) simdiv( X, mode=ut$HIGH_MODE )

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
    X  <- read_cooccur( COOC_FILE, lxcn=cr$data$lxcn ) %>% weight_sample( cr$data$cooc )
    #X  <- read_cooccur( COOC_FILE, lxcn=cr$data$lxcn ) %>% weight_pmi( alpha=.75 )
    td <- cr$get_terms()

    # term samples
    ls <- lexical_sample( td$tf, !is.na( td$pos ) & td$pos == 'NN', theta=ut$SAMPLE_THETA )
    fs <- lexical_sample( td$tf, theta=gr$FEATURE_THETA )
    ut$infof("Lexical sample for tetha %4.2f contains %d terms", ut$SAMPLE_THETA, sum( ls ) )

    sn_func <- function( X, ls, fs, td, ... ) {
        wspaces::graph_make( X, ls=ls, fs=fs, vertex.data=td,
            prune.tol=ut$PRUNE_TOLERANCE, verbose=TRUE, cluster.contribs=TRUE, ...
        )
    }

    ppmi <- sn_func( X, ls, fs, td )
    difw <- sn_func( X, ls, fs, td, sim.func=HIGH_FUNC )

    ppmi$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_ppmi", PROJ_NAME ) )
    difw$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_difw", PROJ_NAME ) )

    ut$infof('Saving data to %s. Please wait...', DATA_FILE )
    save( td, X, ppmi, difw, file=DATA_FILE )
    message( 'All done.' )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )

# s <- c( rep( "Direct coocc. netowrk", length( gr$V( ppmi$G ) ) ), rep( "Diff. weighted netowrk", length( gr$V( difw$G ) ) ) )
# k <- c( gr$V( ppmi$G )$comm, gr$V( difw$G )$comm )
# i <- 1; table( s, k ) %>% addmargins( 2, list( 'mod.'=function( ... ) {
#     m <- if( i == 1 ) difw$K %>% igraph::modularity() else ppmi$K %>% igraph::modularity()
#     i <<- i + 1
#     return( sprintf( '%6.4f', m ) )
# } ) ) %>% ut$latex_xtab.table( row_lab='Netowrk', col_lab='Community sizes and total modularity' )

# tiny <- gr$vattr( difw$G ) %>% as.data.frame() %>% `[`( gr$vattr( difw$G )$comm %in% which( table( difw$K$membership ) < 10 ), )
# tiny[ order( tiny$comm ), c( 'term', 'tf', 'df', 'cover', 'rnk', 'pos', 'lex', 'wgt_v2c', 'wgt_c2v' ) ] %>% xtable::xtable()

