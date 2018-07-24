suppressMessages( require( wspaces ) )
suppressMessages( require( magrittr ) )

# POB specific functions.
# Much of this should eventually move upstream as generic methods (e.g. get_cooc_mrg, fill_zero_freqs, etc.)

if( !exists( 'ut' ) ) source( "obo_util.R", local=( ut <<- new.env() ) )

# Default location for corpus data file
DATA_FILE   <- file.path( ut$DIR_DATA_ROBJ, "corpus.RData" )

# There's no surviving session papers for 1701 and 1705.
DUMMY_YEARS <- c( '1701', '1705' )

# Null part of speech
POS_NULL    <- 'XX'

# POS tag sorting vector for plotting and printing
POS_SORT    <- c( 'NN', 'NP', 'V', 'ADJ', 'ADV', 'ART', 'CONJ', 'PP', 'PR', 'CARD', 'O' )

# Auxiliary verbs
AUXS <- c(
    'do',
    'does',
    'did',
    # 'has',
    'have',
    'had',
    'is',
    'am',
    'are',
    'was',
    'were',
    'be',
    'being',
    # 'been',
    'may',
    'must',
    'might',
    'should',
    'could',
    'would',
    'shall',
    'will',
    'can'
)

make_data <- function() {
    data       <- load_corpus( ut$DIR_DATA, attach=FALSE )
    POS_data   <- names( data$posc )
    POS_totals <- colSums( data$posc )

    message( "Adding POS factors and conf. values" )
    data$posc$POS_naif_conf <- apply( data$posc[, POS_data ], 1, function( x ) {
        if( all( x == 0 ) ) return( 0 )
        pos <- which.max( x )
        if( length( pos ) != 1 ) return( 0 )
        else return( x[pos] / sum( x ) )
    } )
    
    # Naif POS disambiguation
    data$posc$POS_naif      <- apply( data$posc[, POS_data ], 1, function( x ) {
        if( all( x == 0 ) ) return( POS_NULL )
        pos <- which.max( x )
        if( length( pos ) != 1 ) return( POS_NULL )
        else return( names( x )[pos] )
    } ) %>% factor()
    
    # Confidence for probabilistic POS disambiguation
    data$posc$POS_prob_conf <- apply( data$posc[, POS_data ], 1, function( x ) {
        if( all( x == 0 ) ) return( 0 )
        dif <- x / sum( x ) - ( POS_totals / sum( POS_totals ) )
        return( max( dif ) )
    } )
    
    # Probabilistic POS disambiguation
    data$posc$POS_prob      <- apply( data$posc[, POS_data ], 1, function( x ) {
        if( all( x == 0 ) ) return( POS_NULL )
        dif <- x / sum( x ) - ( POS_totals / sum( POS_totals ) )
        return( names( x )[ which.max( dif ) ] )
    } ) %>% factor()
    
    message( "Filling in values for 1701 and 1705" )
    # Correction for empty years in 1701 and 1705
    data$freq[['1701']] <- 0#data$freq[['1700']]
    data$freq[['1705']] <- 0#data$freq[['1704']]
    data$freq <- data$freq[ , order( names( data$freq ) ) ]
    
    message( sprintf( "Saving corpus data to %s", DATA_FILE ) )
    save( data, file=DATA_FILE )
}

get_terms <- function() {
    d <- data.frame( row.names=rownames( data$lxcn ) )
    d$term      <- rownames( d )
    d$tf        <- data$lxcn$tf
    d$df        <- data$lxcn$df
    d$inc       <- rowSums( data$freq ) > 0
    d$global    <- all( data$freq > 0 )
    d$cover     <- d$tf / sum( d$tf )
    d$rnk       <- class_rank( data$lxcn$tf, labels=1:100 )
    d$mss       <- class_mass( data$lxcn$tf, labels=1:100, log=TRUE )
    d$pos       <- factor( data$posc$POS_prob, levels=POS_SORT )
    d$pos_naif  <- factor( data$posc$POS_naif, levels=POS_SORT )
    d$lex       <- ( d$pos %in% lector_lex_pos() ) & ( !rownames( d ) %in% AUXS )
    return( d )
}
term_data <- get_terms

if( !file.exists( DATA_FILE ) ) make_data()
message( sprintf( "Loading corpus data from %s", DATA_FILE ) )
load( DATA_FILE )


