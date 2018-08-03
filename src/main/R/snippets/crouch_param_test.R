source( 'inc/obo_util.R',   chdir=TRUE, local=( ut <- new.env() ) )
source( 'inc/obo_corpus.R', chdir=TRUE, local=( cr <- new.env() ) )
source( 'inc/obo_graphs.R', chdir=TRUE, local=( gr <- new.env() ) )

lctr  <- ut$open_index()
u    <- lector_sample( lctr, ut$sample_testimony() )
ds   <- lector_mkdocset( lctr, ut$DOCFIELD_SECTION, "t18940305-268" )
ds   <- lector_intersect( ds, u )

X <- lector_count_cooc( lctr, ds )
td <- term_data( cr$get_terms(), rownames( X ) )
ls <- td$lex

X_pob <- weight_pmi( X )
X_sam <- weight_sample( X, cr$data$cooc )

G_pob_w_0 <- graph_make( X_pob, ls=ls, prune.tol=0 )
G_pob_w_1 <- graph_make( X_pob, ls=ls, prune.tol=1 )
G_pob_w_2 <- graph_make( X_pob, ls=ls, prune.tol=2 )

G_pob_s_0 <- graph_make( X_pob, ls=ls, prune.tol=0, prune.sort=graph_edge_score )
G_pob_s_1 <- graph_make( X_pob, ls=ls, prune.tol=1, prune.sort=graph_edge_score )
G_pob_s_2 <- graph_make( X_pob, ls=ls, prune.tol=2, prune.sort=graph_edge_score )

G_sam_w_0 <- graph_make( X_sam, ls=ls, prune.tol=0 )
G_sam_w_1 <- graph_make( X_sam, ls=ls, prune.tol=1 )
G_sam_w_2 <- graph_make( X_sam, ls=ls, prune.tol=2 )

G_sam_s_0 <- graph_make( X_sam, ls=ls, prune.tol=0, prune.sort=graph_edge_score )
G_sam_s_1 <- graph_make( X_sam, ls=ls, prune.tol=0, prune.sort=graph_edge_score )
G_sam_s_2 <- graph_make( X_sam, ls=ls, prune.tol=0, prune.sort=graph_edge_score )
