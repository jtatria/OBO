require( Matrix )

source( 'inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME <- "c3_crouch"
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s.RData', PROJ_NAME ) )

PRUNE_TOL <- 0
HIGH_FUNC <- function( X ) simdiv( X, mode=ut$HIGH_MODE )

make_data <- function() {
    source( 'inc/obo_corpus.R', chdir=TRUE, local=( cr <- new.env() ) )
    source( 'inc/obo_graphs.R', chdir=TRUE, local=( gr <- new.env() ) )
    lctr  <- ut$open_index()
    u  <- lector_sample( lctr, ut$sample_testimony() )
    ds <- lector_mkdocset( lctr, ut$DOCFIELD_SECTION, "t18940305-268" )
    ds <- lector_intersect( ds, u )
    X  <- lector_count_cooc( lctr, ds ) %>% weight_sample( cr$data$cooc )
    td <- term_data( cr$get_terms(), rownames( X ) )
    ls <- td$lex

    ppmi <- wspaces::graph_make( X, ls=ls, prune.tol=PRUNE_TOL, vertex.data=td )
    difw <- wspaces::graph_make( X, ls=ls, prune.tol=PRUNE_TOL, vertex.data=td, sim.func=HIGH_FUNC )

    ppmi$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_ppmi", PROJ_NAME ) )
    difw$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_difw", PROJ_NAME ) )

    save( td, X, ppmi, difw, file=DATA_FILE )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )
