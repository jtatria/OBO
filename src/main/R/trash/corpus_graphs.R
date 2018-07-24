#!/usr/bin/r

# globals ------------------------------------------------------------------------------------------
INTRA_W <- 1000
INTER_W <- 1
OUT_DIR <- "/home/jta/desktop/obo/data/graphs"

# functions ----------------------------------------------------------------------------------------
prune <- function( g ) {
    nv <- length( V( g ) )
    ne <- length( E( g ) )
    s <- proc.time()
    g %<>% graph_prune_connected( verbose=TRUE )
    e <- proc.time()
    message( sprintf( 
        "Graph prunned in %8.4f seconds; theta: %6.5f",
        ( e - s )[3], min( edge_attr( g, 'weight' ) ) 
    ) )
    message( sprintf(
        "Edge prunning removed %4.2f%% of edges and dropped %4.2f%% of vertices",
        ( ( ne - length( E( g ) ) ) / ne ) * 100, ( ( nv - length( V( g ) ) ) / nv ) * 100
    ) )
    return( g )
}

cluster <- function( g ) {
    s <- proc.time()
    c <- cluster_louvain( g )
    e <- proc.time()
    message( sprintf( "Communities extracted in %8.4f seconds", ( e - s )[3] ) )
    return( c )
}

edge_data <- function( g, comm, attr='weight' ) {
    vec <- edge_attr( g, attr )
    vec_n <- vec / max( vec )
    vec_c <- ifelse( crossing( comm, g ), INTER_W, INTRA_W ) * vec_n
    edge_attr( g, attr %.% '_raw' ) <- vec
    edge_attr( g, attr %.% '_n' ) <- vec_n
    edge_attr( g, attr %.% '_c' ) <- vec_c
    edge_attr( g, 'Weight' ) < vec_c
    return( g )
}

vertex_data <- function( g, comm, ld ) {
    data <- term_data( ld, names( V( g ) ) )
    for( n in names( data ) ) {
        vertex_attr( g, n ) <- data[[n]] %>% as.numeric
    }
    vertex_attr( g, 'comm' ) <- membership( comm )
    vertex_attr( g, 'idf' ) <- idf( data$df, max( data$df ) + 1 ) # ugly hack
    vertex_attr( g, 'Label' ) <- vertex_attr( g, 'name' )
    vertex_attr( g, 'v2c_weight' ) <- comm_vertex_weigth( comm, g )
    vertex_attr( g, 'c2v_weight' ) <- vertex_comm_weight( comm, g )
    return( g )
}

vertex_delete <- function( g, vertices, drop.orphans=TRUE ) {
    old_n <- length( V( g ) )
    g <- g - vertices
    if( drop.orphans ) {
        orphans <- V( g )[ degree( g ) < 1 ]
        message( sprintf( "%d orphan nodes removed after vertex deletion", length( orphans ) ) )
        g <- g - orphans
    }
    return( g )
}

print_spm <- function( m, name ) {
    nr <- nrow( m )
    nc <- ncol( m )
    nz <- Matrix::nnzero( m )
    message( sprintf( "%s matrix: %dx%d with %d entries (%4.2f%% saturation)",
        name, nr, nc, nz, ( nz / ( nr * nc ) ) * 100 )
    )
    return( m )
}

# main ---------------------------------------------------------------------------------------------
source( "lexical_sample.R", chdir = TRUE, local=( lx <- new.env() ) )
source( "tables_trials.R",  chdir = TRUE, local=( tr <- new.env() ) )
suppressMessages( require( magrittr ) )
suppressMessages( require( igraph ) )

if( !file.exists( OUT_DIR ) ) {
    dir.create( OUT_DIR, showWarnings=FALSE )
}

cooc    <- lx$cr$data$cooc
N       <- sum( cooc )
r_mrg   <- Matrix::rowSums( cooc ) / N
c_mrg   <- Matrix::colSums( cooc ) / N
samples <- lx$mk_samples() %>% `[`( TRUE, c( 'tf', 'df', 'pos', 'lex', 's90', 's95', 's99' ) )

# crouch trial -------------------------------------------------------------------------------------
message( "===== Crouch trial =====")

obo <- wspaces::obo_new( home_dir='/home/jta/desktop/obo' )

crouch_pmi <- obo_count_cooc( obo, ds=obo_mkdocset( obo, 'obo:section', 't18940305-268' ) ) %>%
    cooc_to_pmi( rs_=term_data( r_mrg, rownames( . ) ), cs_=term_data( r_mrg, rownames( . ) ) ) %>%
    print_spm( 'Crouch trial' )

g_crouch <- crouch_pmi %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>%
    prune

c_crouch <- cluster( g_crouch )
g_crouch %<>% edge_data( c_crouch )
g_crouch %<>% vertex_data( c_crouch, samples )
write_graph( g_crouch, file.path( OUT_DIR, 'crouch.gml' ), format='gml' )

# full OBO -----------------------------------------------------------------------------------------
message( "===== Full OBO =====")

g_s90 <- samples$s90 %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=term_data( r_mrg, rownames( . ) ), cs_=term_data( r_mrg, rownames( . ) ) ) %>%
    print_spm( 'Corpus 90%' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>%
    prune

c_s90 <- cluster( g_s90 )
g_s90 %<>% edge_data( c_s90 )
g_s90 %<>% vertex_data( c_s90, samples )
write_graph( g_s90, file.path( OUT_DIR, 's90.gml' ), format='gml' )

g_s95 <- samples$s95 %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=term_data( r_mrg, rownames( . ) ), cs_=term_data( r_mrg, rownames( . ) ) ) %>%
    print_spm( 'Corpus 95%' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>%
    prune

c_s95 <- cluster( g_s95 )
g_s95 %<>% edge_data( c_s95 )
g_s95 %<>% vertex_data( c_s95, samples )
write_graph( g_s95, file.path( OUT_DIR, 's95.gml' ), format='gml' )

g_s99 <- samples$s99 %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=term_data( r_mrg, rownames( . ) ), cs_=term_data( r_mrg, rownames( . ) ) ) %>%
    print_spm( 'Corpus 99%' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>%
    prune

c_s99 <- cluster( g_s99 )
g_s99 %<>% edge_data( c_s99 )
g_s99 %<>% vertex_data( c_s99, samples )
write_graph( g_s99, file.path( OUT_DIR, 's99.gml' ), format='gml' )
