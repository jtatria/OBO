#!/usr/bin/Rscript

source( 'c4_epochs_data.R' )
require( euclid )

PROJ_NAME <- 'c4_epochs'
AXIS1     <- c( 'lord', 'servant' )
AXIS2     <- c( 'man', 'woman' )
DEVICE    <- 'internal'

onto_plane <- function( model, a1, a2, filter=rep( TRUE, nrow( model ) ) ) {
    if( is.character( a1 ) && length( a1 ) != 2 ) stop( 'invalid value for a1' )
    if( is.character( a2 ) && length( a2 ) != 2 ) stop( 'invalid value for a2' )
    if( !all( ( t <- c( a1, a2 ) ) %in% rownames( model ) ) ) {
        ut$stopf(
            "Missing terms for axis: %s",
            paste( t[ which( !t %in% rownames( model ) )], collapse=", ")
        )
    }
    if( is.logical( filter ) && length( filter ) != nrow( model ) ) stop( 'wrong length for logical filter' )
    if( is.character( filter ) ) {
        filter <- rownames( model ) %in% filter
    }
    head1 <- model[ a1[1], ]
    tail1 <- model[ a1[2], ]
    head2 <- model[ a2[1], ]
    tail2 <- model[ a2[2], ]
    d1    <- model[filter,] %>% vproj( rbind( head1 - tail1 ) %>% vunit(), scalar=TRUE )
    d2    <- model[filter,] %>% vproj( rbind( head2 - tail2 ) %>% vunit(), scalar=TRUE )
    pos <- cbind( d2, d1 )
    colnames( pos ) <- c( paste( rev( a2 ), collapse='->' ), paste( rev( a1 ), collapse='->' ) )
    return( pos )
}

S95_n  <- lexical_sample( td$tf.x, filter=( !is.na( td$pos ) & td$pos == 'NN' ), theta=ut$SAMPLE_THETA )
S95_n_terms <- td$term[ S95_n ]

epos <- lapply( epochs, function( e ) { onto_plane( e, AXIS1, AXIS2, filter=S95_n_terms  ) } )
gpos <- onto_plane( global, AXIS1, AXIS2, filter=S95_n_terms  )
ecs  <- vapply( 1:length( epos ), function( i ) C( epos[[i]] ), c(0,0) ) %>% t()

ut$gr_setup( n=2, device=DEVICE, file=sprintf( '%s_endo', PROJ_NAME ) )
    chart( ecs, C( gpos ), scale=FALSE )
    arrows( ecs[1:19,1], ecs[1:19,2], ecs[2:20,1], ecs[2:20,2], length=.1 )
    points( ecs[c( 1, 15, 20 ), ], pch=19 )
    text( ecs[20,] %>% rbind(), labels='Word space centroid in 1913', pos=3 )
    text( ecs[1, ] %>% rbind(), labels='Word space centroid in 1683', pos=4, offset=1 )
    text( ecs[15,] %>% rbind(), labels='Word space centroid in 1853', pos=1 )
    points( C( gpos ), col='red', pch=19 )
    text( C( gpos ), labels="Global word space centroid", pos=2, offset=1 )
    mtext( '$v_{woman} \\rightarrow v_{man}$', side=1, las=0 )
    mtext( '$v_{servant} \\rightarrow v_{lord}$', side=2, las=0 )
ut$gr_finish()
    