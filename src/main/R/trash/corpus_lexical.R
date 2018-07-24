source( 'lexical_sample.R', chdir=TRUE, local=( lx <- list2env( list( noplot = TRUE ) ) ) )

d <- lx$d %>% lexical_join( lx$cr$data$freq )
freq_r <- d %>% select( matches( '^[0-9]+$' ) ) %>% as.matrix
freq_w <- weight_tfidf( freq_r, lx$d$df, idf_mode=0 )

size <- 1000

full_fltr <- rep( TRUE, nrow( lx$d ) )
lexi_fltr <- lx$d$pos %in% c( 'ADJ','ADV','NN','NP','V' )
noun_fltr <- lx$d$pos %in% c( 'NN', 'NP' )

period <- list();
for( measure in c( 'cos', 'rr2', 'rho' ) ) {
    func <-   switch( measure,
        'cos' = function( x ) vector_cosine( as.matrix( x ), transpose = FALSE ),
        'rho' = function( x ) cor( x, method = 'spearman' ),
        'rr2' = function( x ) cor( x, method = 'pearson' )
    )
    for( dataset in c( 'raw', 'wgt' ) ) {
        data <- switch( dataset, 'raw' = freq_r, 'wgt' = freq_w )
        for( sample in c( 'full', 'lexi', 'noun' ) ) {
            fltr = switch( sample, 'full' = full_fltr, 'lexi' = lexi_fltr, 'noun' = noun_fltr )
            res <- func( data[ fltr, ][ 1:size, ] )
            period[[ paste( sample, dataset, measure, sep = '_' ) ]] <- res
        }
    }
}

select( d, matches( '^[0-9]+$' ) )[2,] %>% as.matrix %>% as.vector %>% `/`( colSums( select( d, matches( '^[0-9]+$' ) ) ) ) %>% plot( type ='s' )

