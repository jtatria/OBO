require( wspaces )

source( '../inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )
source( '../inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) ut else ( gr <- new.env() ) ) )

make_data <- function() {
    source( '../inc/obo_corpus.R', chdir=TRUE, local=( cr <- new.env() ) )
    # Open index
    lctr <- lector_new( cr$obo_conf() )
    # Get population docset
    U <- lector_sample( lctr, cr$SAMPLE_TESTIMONY )

    # Get female trials cooccurrence counts 
    source( '../inc/obo_tables.R', chdir=TRUE, local=( ta <- new.env() ) )
    motifs <- ta$get_trial_motifs()
    divIds <- motifs %>% `[`( ( .$bFemDef | .$bFemVic ), 'divId' ) %>% unlist()
    ds <- lector_mkdocset( lctr, cr$DOCFIELD_SECTION, divIds )
    ds <- lector_intersect( U, ds )
    cooc_fems <- lector_count_cooc( lctr, ds )
    
    browser()
    # Define lexical and feature samples
    td <- cr$term_data()
    ls <- lexical_sample( td$tf, !is.na( td$pos ) & td$pos == 'NN', theta=ut$SAMPLE_THETA )
    fs <- lexical_sample( td$tf, theta=gr$FEATURE_THETA )
    
    # Compute PMI weights for fems and complement
    X_1 <- cooc_fems %>% cr$weight_sample( cr$data$cooc )
    X_2 <- ( cr$data$cooc - cooc_fems  ) %>% cr$weight_sample( cr$data$cooc )
    
    semnet <- wspaces::graph_make( cooc, ls=ls, td=td, x2_mode=ut$HIGH_MODE )
    ppmi   <- semnet[[1]]
    difw   <- semnet[[2]]
    
    ppmi$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_ppmi", PROJ_NAME ) )
    difw$G %>% gr$export( dir=ut$DIR_DATA_GRPH, file=sprintf( "%s_difw", PROJ_NAME ) )

    save(
        td,
        cooc,
        ppmi,
        difw,
        file=DATA_FILE
    )
}
