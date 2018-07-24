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
    message( sprintf( "Graph prunned in %8.4f seconds", ( e - s )[3] ) )
    message( sprintf(
        "Edge prunning removed %4.2f%% of edges and dropped %4.2f%% vertices",
        ( ( ne - length( E( g ) ) ) / ne ) * 100,
        ( ( nv - length( V( g ) ) ) / nv ) * 100
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

edge_data <- function( g, weight='weight', comm='comm' ) {
    ewvec <- edge_attr( g, weight )
    vcvec <- vertex_attr( g, comm )
    browser()
    wvec <- edge_attr( g, weigth )
    cvec <- edge_attr( g, weigth )
    vec_n <- vec / max( vec )
    vec_c <- ifelse( crossing( comm, g ), INTER_W, INTRA_W ) * vec_n
    edge_attr( g, attr %.% '_raw' ) <- vec
    edge_attr( g, attr %.% '_n' ) <- vec_n
    edge_attr( g, attr %.% '_c' ) <- vec_c
    return( g )
}

vertex_data <- function( g, comm, ld ) {
    data <- get_terms( ld, names( V( g ) ) )
    for( n in names( data ) ) {
        vertex_attr( g, n ) <- data[[n]] %>% as.numeric
    }
    vertex_attr( g, 'comm' ) <- membership( comm )
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
    nz <- Matrix::nnzero( m ) / ( nr * nc )
    message( sprintf( "%s matrix: %dx%d, %4.2f%% saturation", name, nr, nc, nz * 100 ) )
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

r_mrg <- Matrix::rowSums( lx$cr$data$cooc ) / sum( lx$cr$data$cooc )
c_mrg <- Matrix::colSums( lx$cr$data$cooc ) / sum( lx$cr$data$cooc )
v_data <- lx$mk_samples()

# crouch trial -------------------------------------------------------------------------------------
message( "===== Crouch trial =====")

obo <- wspaces::obo_new( home_dir='/home/jta/desktop/obo' )
crouch_cooc <- obo_count_cooc( obo, ds=obo_mkdocset( obo, 'obo:section', 't18940305-268' ) )
is.lex <- get_terms( v_data, rownames( crouch_cooc ) )$lex

g_crouch_all <- crouch_cooc %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'Crouch all' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>%
    prune


c_crouch_all <- cluster( g_crouch_all )
g_crouch_all %<>% edge_data( c_crouch_all )
g_crouch_all %<>% vertex_data( c_crouch_all, v_data )

write_graph( g_crouch_all, file.path( OUT_DIR, 'crouch_all.gml' ), format='gml' )

g_crouch_lex <- crouch_cooc[ is.lex, is.lex ] %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'Crouch lex' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_crouch_lex <- cluster( g_crouch_lex )
g_crouch_lex %<>% edge_data( c_crouch_lex )
g_crouch_lex %<>% vertex_data( c_crouch_lex, v_data )

write_graph( g_crouch_lex, file.path( OUT_DIR, 'crouch_lex.gml' ), format='gml' )

# full OBO -----------------------------------------------------------------------------------------
message( "===== Full OBO =====")

# s90 all ------------------------------------------------------------------------------------------
message( 's90 all' )
g_s90_all <- v_data$s90_all %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S90 all' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s90_all <- cluster( g_s90_all )
g_s90_all %<>% edge_data( c_s90_all )
g_s90_all %<>% vertex_data( c_s90_all, v_data )

write_graph( g_s90_all, file.path( OUT_DIR, 's90_all.gml' ), format='gml' )

# s95 all ------------------------------------------------------------------------------------------
message( 's95 all' )
g_s95_all <- v_data$s95_all %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S95 all' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s95_all <- cluster( g_s95_all )
g_s95_all %<>% edge_data( c_s95_all )
g_s95_all %<>% vertex_data( c_s95_all, v_data )

write_graph( g_s95_all, file.path( OUT_DIR, 's95_all.gml' ), format='gml' )

# s99 all ------------------------------------------------------------------------------------------
message( 's99 all' )
g_s99_all <- v_data$s99_all %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S99 all' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s99_all <- cluster( g_s99_all )
g_s99_all %<>% edge_data( c_s99_all )
g_s99_all %<>% vertex_data( c_s99_all, v_data )

write_graph( g_s99_all, file.path( OUT_DIR, 's99_all.gml' ), format='gml' )

# s90 lex ------------------------------------------------------------------------------------------
message( 's90 lex' )
g_s90_lex <- v_data$s90_lex %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S90 lex' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s90_lex <- cluster( g_s90_lex )
g_s90_lex %<>% edge_data( c_s90_lex )
g_s90_lex %<>% vertex_data( c_s90_lex, v_data )

write_graph( g_s90_lex, file.path( OUT_DIR, 's90_lex.gml' ), format='gml' )

# s95 lex ------------------------------------------------------------------------------------------
message( 's95 lex' )
g_s95_lex <- v_data$s95_lex %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S95 lex' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s95_lex <- cluster( g_s95_lex )
g_s95_lex %<>% edge_data( c_s95_lex )
g_s95_lex %<>% vertex_data( c_s95_lex, v_data )

write_graph( g_s95_lex, file.path( OUT_DIR, 's95_lex.gml' ), format='gml' )

# s99 lex ------------------------------------------------------------------------------------------
message( 's99 lex' )
g_s99_lex <- v_data$s99_lex %>% `[`( lx$cr$data$cooc, ., . ) %>%
    cooc_to_pmi( rs_=r_mrg, cs_=c_mrg ) %>% print_spm( 'S99 lex' ) %>%
    graph_from_adjacency_matrix( mode='undirected', weighted=TRUE, diag=TRUE ) %>% prune

c_s99_lex <- cluster( g_s99_lex )
g_s99_lex %<>% edge_data( c_s99_lex )
g_s99_lex %<>% vertex_data( c_s99_lex, v_data )

write_graph( g_s99_lex, file.path( OUT_DIR, 's99_lex.gml' ), format='gml' )
