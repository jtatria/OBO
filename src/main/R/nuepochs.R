source( 'c3_epochs_data.R' )

align <- function( g1, g2, k1, k2, vertex.id.1='term', vertex.id.2='term' ) {
    ks1 <- graph_cluster_contribs( g1, k1 )
}
debug( align )

g1 <- epochs[[7]]$difw$G
g2 <- epochs[[8]]$difw$G
k1 <- epochs[[7]]$difw$K$membership
k2 <- epochs[[8]]$difw$K$membership
align( g1, g2, k1, k2 )

