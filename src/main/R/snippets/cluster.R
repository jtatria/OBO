source( 'c3_global_data.R' )

k_funcs <- list(
    'cluster_fast_greedy',
    #'cluster_spinglass',
    'cluster_louvain',
    'cluster_walktrap',
    'cluster_label_prop',
    'cluster_edge_betweenness',
    'cluster_optimal',
    'cluster_infomap',
    'cluster_leading_eigen'
)

k_test <- function( g, k_func_name ) {
    k_func <- getExportedValue( 'igraph', k_func_name )
    t <- proc.time()
    K <- tryCatch( k_func( g ), error=function( e ) return( e ) )
    t <- proc.time() - t
    out <- list(
        func=k_func_name,
        K=K,
        time=t
    )
    return( out )
}
