require( wspaces )

if( !exists( 'ut' ) ) source( 'obo_util.R', chdir=TRUE, local=( ut <<- new.env() ) )

#' MAGIC
reset <- function( func=NULL ) {
    rm( gv, envir=.GlobalEnv )
    tryCatch(
        source( 'inc/obo_glove.R', chdir=TRUE, local=( gv <- new.env() ) ),
        error=function( e ) {
            message( sprintf( 'source failed: %sFix it and run reset again', e ) )
            ut <- list2env( list( reset=reset ) )
            assign( 'gv', gv, envir=.GlobalEnv )
        }
    )
    assign( 'gv', gv, envir=.GlobalEnv )
    if( !is.null( func ) ) debug( get0( as.character( substitute( func ) ), envir=gv ) )
}

GLOVE_FILE <- 'vectors.bin'
VOCAB_FILE <- 'vocab.txt'
GRDSQ_FILE <- 'gradsq.bin'

load_glove <- function(
    dir, vector.file=GLOVE_FILE, vocab.file=VOCAB_FILE,
    load.grads=FALSE, grads.file=GRDSQ_FILE, td=NULL, td.suffix=NULL, normalize=TRUE
) {
    vocab <- load_vocab( file.path( dir, vocab.file ) )
    vects <- read_vectors( file.path( dir, vector.file ), n=nrow( vocab ) )
    vdim <- dim( vects )[1] - 1
    
    w_vecs <- vects[ 1:vdim,,1 ] %>% t()
    rownames( w_vecs ) <- vocab$term
    c_vecs <- vects[ 1:vdim,,2 ] %>% t()
    rownames( c_vecs ) <- vocab$term
    w_bias <- vects[ vdim+1,,1 ]
    names( w_bias ) <- vocab$term
    c_bias <- vects[ vdim+1,,2 ]
    names( c_bias ) <- vocab$term
    
    model <- w_vecs + c_vecs
    if( normalize ) {
        model <- vapply( 1:nrow( model ), function( i ) {
            model[i,] %>% `/`( `^`( ., 2 ) %>% sum %>% sqrt ) %>% return()
        }, rep( 0.0, ncol( model ) ) ) %>% t()
    }
    
    rownames( model ) <- vocab$term    
    
    if( !is.null( td ) ) vocab %<>% dplyr::left_join( td, by='term' )
    
    attr( model, 'proc' ) <- list(
        wrd_vecs = w_vecs,
        ctx_vecs = c_vecs,
        wrd_bias = w_bias,
        ctx_bias = c_bias
    )
    attr( model, 'term_data' ) <- vocab
    class( model ) <- c( 'glove', 'wspace', class( model ) )
    return( model )
}

#' MAGIC
reset <- function( func=NULL ) {
    rm( gv, envir=.GlobalEnv )
    tryCatch(
        source( 'inc/obo_glove.R', chdir=TRUE, local=( gv <- new.env() ) ),
        error=function( e ) {
            message( sprintf( 'source failed: %sFix it and run reset again', e ) )
            ut <- list2env( list( reset=reset ) )
            assign( 'gv', gv, envir=.GlobalEnv )
        }
    )
    assign( 'gv', gv, envir=.GlobalEnv )
    if( !is.null( func ) ) debug( get0( as.character( substitute( func ) ), envir=gv ) )
}

load_vocab <- function( file ) {
    vocab <- readLines( ( con <- file( file ) ) ) %>% strsplit( ' ' )
    close( con )
    df <- vapply( 1:length( vocab ), function( i ) vocab[[i]], c( 'a','a' ) ) %>% t() %>% as.data.frame()
    df[[1]] %<>% as.character()
    df[[2]] %<>% as.character() %>% as.integer()
    names( df ) <- c( 'term', 'tf' )
    rownames( df ) <- df$term
    return( df )
}

plot.neighbours <- function(
    model, term, k=100, filter=rep( TRUE, nrow( model ) ), size=rep( 1, nrow( model ) ),
    method=c('pca','sne'),
    ...
) {
    nn   <- wspace_neighbors( model, term, k=k, filter=filter )
    size <- size[ nn$nn.idx ] %>% log1p() %>% `/`( max( . ) ) %>% `+`( .1 )
    pos <- switch( match.arg( method ),
        pca=prcomp( model[ nn$nn.idx, ] )[['x']][,1:2],
        sne=Rtsne::Rtsne( model[ nn$nn.idx, ] )[['Y']]
    )
    plot( pos, type='n', asp=1, axes=FALSE, ylab=NA, xlab=NA, ... )
    text( pos, labels=rownames( model )[ nn$nn.idx ], cex=c( 2, size[2:length( size )] ) )
}
