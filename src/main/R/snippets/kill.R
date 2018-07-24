require( wspaces )

source('../inc/obo_util.R',   chdir=TRUE, local=( ut <- new.env() ) )
source('../inc/obo_corpus.R', chdir=TRUE, local=( cr <- new.env() ) )
source('../inc/obo_graphs.R', chdir=TRUE, local=( gr <- new.env() ) )

YEAR1 <- '1786'
YEAR2 <- '1882'
TERM <- 'kill'

obo <- lector_new( home_dir=ut$DIR_HOME )
U  <- lector_sample( obo, ut$sample_testimony() )
TD <- cr$get_terms()
LS <- lexical_sample( TD$tf, TD$lex, theta=.9 )
FS <- lexical_sample( TD$tf, TD$lex, gr$FEATURE_THETA )

ds1 <- lector_mkdocset( obo, ut$DOCFIELD_YEAR, YEAR1 ) %>% lector_intersect( U )
X1  <- lector_count_cooc( obo, ds1 ) %>% cr$sample_weight()

ds2 <- lector_mkdocset( obo, ut$DOCFIELD_YEAR, YEAR2 ) %>% lector_intersect( U )
X2  <- lector_count_cooc( obo, ds2 ) %>% cr$sample_weight()

ls <- ( rownames( X1 ) %in% TD$term[ LS ] )
fs <- ( colnames( X1 ) %in% TD$term[ FS ] )
S1 <- wspaces::graph_make( X1, ls=ls, fs=fs, td=TD )

ls <- ( rownames( X2 ) %in% TD$term[ LS ] )
fs <- ( colnames( X2 ) %in% TD$term[ FS ] )
S2 <- wspaces::graph_make( X2, ls=ls, fs=fs, td=TD )

# ppmi comparison
