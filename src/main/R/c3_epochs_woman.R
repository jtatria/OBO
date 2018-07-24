#!/usr/bin/Rscript

require( igraph )

source( "c3_epochs_data.R" )

EGO <- 'woman'

vapply( 1:length( epochs ), function( i ) {
    g <- epochs[[i]]$G
    d <- igraph::degree( g )
    tmp <- rep( NA, nrow( term_data ) )
    tmp[ term_data$term %in% names( d ) ] <- d
    return( tmp )
}, rep( 0.0, nrow( term_data ) ) )
