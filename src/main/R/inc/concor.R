
concor_split <- function( m, conv=.999, max.iter=50 ) {
    m <- if( is.list( m ) ) do.call( rbind, m ) else m
    x <- cor( m )
    iter <- 1
    while( min( abs( x ) ) < conv && iter <= max.iter ) {
        x %<>% cor()
        iter %<>% `+`( 1 )
    }
    split <- m[1,]
    browser()
}