#!/usr/bin/Rscript

require( euclid )

PROJ_NAME   <- 'c4_epochs'
DEVICE      <- 'tikz'
TERMS       <- c( 'woman', 'man', 'lord', 'servant' )
K           <- 30

epoch_term_ws <- function(
    term, epochs, base=epochs[[length( epochs )]], k=30, term.filter=rownames( base ),
    epoch.names=sprintf( 'epoch %s', e:length( epochs ) ), term.name.pattern='%s (%s)'
) {
    enns <- lapply( epochs, function( e ) {
        nns <- wspace_neighbors( e, terms=term, filter=rownames( e ) %in% term.filter, k=k )
        nn_terms <- rownames( e )[ nns$nn.idx ]
        return( nn_terms )
    } ) %>% unlist() %>% unique() %>% setdiff( term )

    term_ws <- vapply( 1:length( epochs ), function( i ) {
        epochs[[i]][term,]
    }, rep( 0.0, ncol( epochs[[1]] ) ) ) %>% t()
    rownames( term_ws ) <- sprintf( term.name.pattern, term, epoch.names )
    term_ws %<>% rbind( base[ enns, ] )
    class( term_ws ) <- c( 'wspace', class( term_ws ) )
    return( term_ws )
}

source( sprintf( 'inc_%s_data.R', PROJ_NAME ) )

EPOCH_NAMES <- gsub( 'part_', '', names( epochs ) )
BASE        <- epochs[[20]]
S95_n <- lexical_sample( td$tf.x, filter=( !is.na( td$pos ) & td$pos == 'NN' ), theta=ut$SAMPLE_THETA )
S95_n_terms <- rownames( global )[ S95_n ]
filter <- rownames( BASE )[ rownames( BASE ) %in% S95_n_terms ]

a_epochs <- wspace_align( rev( epochs ), verbose=TRUE ) %>% rev()

term_ws <- sapply( TERMS, function( t ) {
    epoch_term_ws( t, a_epochs, base=BASE, k=K, epoch.names=EPOCH_NAMES, term.filter=filter )
}, simplify=FALSE, USE.NAMES=TRUE )

ut$gr_setup( n=2, device=DEVICE, file=sprintf( '%s_proc', PROJ_NAME ), standAlone=TRUE )
    cex <- par()$cex
    layout( matrix( c( 1:4 ), ncol=2, byrow=TRUE ) )
    par( mar=c( 1, 0, 0, 0 ), cex=cex )
    for( t in names( term_ws ) ) {
        ws <- term_ws[[t]]
        labels=gsub( 'L_([[:upper:]]+)', '[\\L\\1]', rownames( ws ), perl=TRUE )
        alpha <- c( rep( 1, 20 ), rep( .5, nrow( ws ) - 20 ) )
        pos <- plot( term_ws[[t]], mark='terms', alpha=alpha, asp=1, xpd=NA, labels=labels  )
        arrows( pos[1:19,1], pos[1:19,2], pos[2:20,1], pos[2:20,2], length=0.08, lty=1 )
        mtext( t, side=1 )
    }
ut$gr_finish()

