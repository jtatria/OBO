
source( 'inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )
source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )
source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )

PROJ_NAME <- 'c3_epochs'
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( '%s.RData', PROJ_NAME ) )

convert <- function( ename, td, S ) {
    sample <- load_sample( file.path( ut$DIR_DATA_SAMPLES, ename ), cr$data$lxcn )
    E <- epochs[[ename]]
    S <- S[1:nrow( E$ppmi )]
    ppmi <- list(
        X=E$ppmi[S,S],
        G=E$g_ppmi,
        K=gr$cluster( E$g_ppmi, clust_func=igraph::cluster_louvain, undirected=TRUE ),
        theta=min( gr$eattr( E$g_ppmi, 'weight' ) )
    )
    class( ppmi ) <- 'semnet'

    difw <- list(
        X=E$difw,
        G=E$g_difw,
        K=gr$cluster( E$g_difw, clust_func=igraph::cluster_louvain, undirected=TRUE ),
        theta=min( gr$eattr( E$g_difw, 'weight' ) )
    )
    class( difw ) <- 'semnet'
    
    out <- list(
        cooc=E$cooc,
        ppmi=ppmi,
        difw=difw
    )
    
    return( out )
}

load( DATA_FILE )

src <- epochs
td <- cr$get_terms()
S  <- lexical_sample( td$tf, td$lex, ut$EPOCH_SAMPLE_THETA )
epochs <- lapply( as.list( names( src ) ), function( e ) convert( e, td, S ) )
names( epochs ) <- names( src )
save( epochs, file=file.path( ut$DIR_DATA_ROBJ, sprintf( '%s_out.RData', PROJ_NAME ) ) )
