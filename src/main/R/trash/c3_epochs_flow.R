source( 'c3_epochs_data.R' )

# Edge type. One of 'ppmi' for direct cooc or 'difw' for diff. weighted.
EMODE <- 'ppmi'
# Similarity measure. One of the modes accepted by wspaces::simdiv
SMODE <- 6

# Compute cluster scores for all epochs
t_ks <- lapply( epochs, function( e ){
    ppmi <- gr$cluster_contribs( e$ppmi$G, e$ppmi$K$membership, mode='c2v' )
    difw <- gr$cluster_contribs( e$ppmi$G, e$ppmi$K$membership, mode='c2v' )
    return( list( ppmi=ppmi, difw=difw ) )
} )
names( t_ks ) <- sprintf( 't%d', 1:length( t_ks ) )

graph_make_rivers <- function(
    g1, g2, k1=gr$vattr( g1, 'comm' ), k2=gr$vattr( g2, 'comm' ), vid1='term', vid2=vid1, mode=6
) {
    browser()
    # vertex intersection
    cap <- intersect( gr$vattr( g1, vid1 ), gr$vattr( g2, vid2 ) )
    f1 <- gr$vattr( g1, vid1 ) %in% cap
    f2 <- gr$vattr( g2, vid2 ) %in% cap
    # cluster scores
    ks1 <- gr$cluster_contribs( g1, k1, mode='c2v' )
    ks2 <- gr$cluster_contribs( g2, k2, mode='c2v' )
    # distance matrix
    d   <- 1 - simdiv( ks1[f1,], ks2[f2,], mode=mode, trans=TRUE )
    # adjacency matrix
    n <- nrow( d ) + ncol( d )
    m <- matrix( 0, nrow=n, ncol=n )
    m[ 1:nrow( d ), ( nrow( d ) + 1 ):n ] <- d
    
    # cluster names
    knames  <- c( sprintf( 't%d_k%d', i, 1:ncol( ks1 ) ), sprintf( 't%d_k%d', j, 1:ncol( ks2 ) ) )
    
    el <- which( m > 0, arr.ind=TRUE )
    knames  <- c( sprintf( 't%d_k%d', i, 1:ncol( ks1 ) ), sprintf( 't%d_k%d', j, 1:ncol( ks2 ) ) )
    edges   <- knames[ el ] %>% matrix( nrow=nrow( el ), ncol=ncol( el ) )
    weights <- m[ el ]
    rivers <- rbind( rivers, data.frame( edges[,1], edges[,2], weights ) )
}

rivers <- NULL
local(
    for( i in 1:( length( t_ks ) - 1 ) ) {
        emode <- EMODE
        smode <- SMODE
        
        j   <- i + 1
        g1  <- epochs[[i]][[emode]]$G
        g2  <- epochs[[j]][[emode]]$G
        k1  <- epochs[[i]][[emode]]$K$membership
        k2  <- epochs[[j]][[emode]]$K$membership
        cap <- intersect( gr$V( g1 )$term, gr$V( g2 )$term )
        f1 <- gr$V( g1 )$term %in% cap
        f2 <- gr$V( g2 )$term %in% cap
        ks1 <- t_ks[[i]][[emode]][ f1, ]
        ks2 <- t_ks[[j]][[emode]][ f2, ]
        d   <- 1 - simdiv( ks1, ks2, mode=smode, trans=TRUE )
        
        n <- nrow( d ) + ncol( d )
        m <- matrix( 0, nrow=n, ncol=n )
        m[ 1:nrow( d ), ( nrow( d ) + 1 ):n ] <- d
        
        el <- which( m > 0, arr.ind=TRUE )
        knames  <- c( sprintf( 't%d_k%d', i, 1:ncol( ks1 ) ), sprintf( 't%d_k%d', j, 1:ncol( ks2 ) ) )
        edges   <- knames[ el ] %>% matrix( nrow=nrow( el ), ncol=ncol( el ) )
        weights <- m[ el ]
        rivers <<- rbind( rivers, data.frame( edges[,1], edges[,2], weights ) )
    }    
)

names( rivers ) <- c('src','tgt','wgt')

