suppressMessages( require( Matrix ) )
suppressMessages( require( wspaces ) )
suppressMessages( require( Rforceatlas ) )

if( !exists( 'ut' ) ) source( 'obo_util.R', chdir=TRUE, local=( ut <<- new.env() ) )

FEATURE_THETA <- .99

reset <- function() {
    rm( gr, envir=.GlobalEnv )
    source( 'inc/obo_graphs.R',   chdir=TRUE, local=( if( exists( 'gr' ) ) gr else ( gr <- new.env() ) ) )
    assign( 'gr', gr, envir=.GlobalEnv )
}

cluster_contribs <- function(
    g, k, mode=c('c2v','v2c','prod'), knames=sprintf( 'k%d', unique( k ) %>% sort() )
) {
    if( !has_vattr( g, 'wgt_v2c' ) || !has_vattr( g, 'wgt_c2v' ) ) {
        g <- add_contrib_scores( g, k )
    }
    ks <- unique( k ) %>% sort()
    v2c <- ut$V( g )$wgt_v2c
    c2v <- ut$V( g )$wgt_c2v
    score <- switch( match.arg( mode ), c2v=c2v, v2c=v2c, prod=( c2v * v2c ) )
    r <- vapply( ks, function( kid ) ifelse( k == kid, score, 0 ), rep( 0, length( score ) ) )
    colnames( r ) <- knames
    return( r )
}

export <- function( g, dir=getwd(), format='graphml', file='obo_graph' ) {
    file = file.path( dir, sprintf( "%s.%s", file, format ) )
    message( sprintf( "Graph exported as %s file to %s", format, file ) )
    igraph::write.graph( g, file=file, format=format )
}

SHAPES <- c(
    'circle',
    'square',
    'csquare',
    'rectangle',
    'crectangle',
    'vrectangle',
    'pie'
)
get_shapes <- function( f ) {
    f <- if( is.factor( f ) ) f else as.factor( f )
    if( length( levels( f ) ) > length( SHAPES ) ) {
        stop( "Too many levels for shapes" )
    }
    shp <- SHAPES[1:length( levels( f ) )]
    return( shp[f] )
}

pretty_names <- function( g ) {
    # gsub( 'L_([[:upper:]]+)', '[\\L\\1]', 'L_MONEY', perl=TRUE )
    out <- names( ut$V( g ) )
    out[ which( out == 'L_PUNCT'  ) ] <- '[punct]'
    out[ which( out == 'L_SHORT'  ) ] <- '[short]'
    out[ which( out == 'L_MONEY'  ) ] <- '[money]'
    out[ which( out == 'L_ORD'    ) ] <- '[ordinal]'
    out[ which( out == 'L_NUMBER' ) ] <- '[cardinal]'
    out[ which( out == 'L_WEIGHT' ) ] <- '[weight]'
    out[ which( out == 'L_LENGTH' ) ] <- '[length]'
    return( out )
}

get_adj <- function( g, type='both', attr='weight', ... ) {
    m <- ut$as_adj( g, type=type, attr=attr, ... )
    return( m )
}

random_layout <- function( g, seed=187, dim=2, bounds=c( -1000, 1000 ) ) {
    set.seed( seed )
    init <- matrix( runif( length( ut$V( g ) ) * dim, bounds[1], bounds[2] ), ncol=dim )
    return( init )
}

#' BLock reduction
#' @export
reduce <- function( g=NULL, k, attr='weight', m=NULL, self=TRUE, symm=FALSE, block.func=mean, mass.func=NULL, value=c('g','m'), normalize=TRUE ) {
    if( is.null( g ) && is.null( m ) ) stop( 'Need one of g or m' )
    if( is.null( m ) ) {
        m <- ut$as_adj( g, type='both', attr=attr, sparse=FALSE )
    }
    ks <- unique( k )
    r_m <- matrix( NA, nrow=length( ks ), ncol=length( ks ) )
    if( !is.null( mass.func ) ) mass <- vector( NA, length( ks ) )
    for( i in 1:length( ks ) ) {
        for( j in 1:( if( symm ) i else length( ks ) ) ) {
            if( !self && i == j ) next
            bm <- m[ k == i, k == j ]
            bv <- block.func( bm )
            r_m[i,j] <- bv
            if( symm ) r_m[j,i] <- bv
        }
        if( !is.null( mass.func ) ) mass[i] <- mass.func( k == i )
    }
    if( normalize ) r_m %<>% `/`( max( r_m ) )
    r <- switch( match.arg( value ),
        'm'=r_m,
        'g'=ut$adj_to_g( r_m, weighted=TRUE, mode=( if( symm ) 'undirected' else 'directed' ) ),
        stop( 'Invalid value type requested' )
    )
    if( igraph::is.igraph( r ) && !is.null( mass.func ) ) {
        ut$V( r )$mass <- mass
    }
    return( r )
}

layout_per_cluster <- function(
    g, membs=ut$vattr( g, 'comm' ),
    weights='weight',
    lo_func1=ut$layout_with_fr, lo_func2=ut$layout_in_circle,
    ...
) {
    pos <- matrix( NA, nrow=length( ut$V( g ) ), ncol=2 )
    ks <- unique( membs )
    m <- ut$as_adj( g, type='both', attr=weights )
    meta <- matrix( 0, nrow=length( ks ), ncol=length( ks ) )
    for( i in 1:length( ks ) ) {
        ki <- ks[i]
        kg <- ut$subg( g, ut$V( g )[ ki == membs ] )
        pos[ membs == ki ] <- lo_func1( kg )
        for( j in 1:length( ks ) ) {
            if( i == j ) next()
            kj <- ks[j]
            meta[i,j] <- sum( m[ membs == ki, membs == kj ] ) + sum( m[ membs == kj, membs == ki ] )
        #meta[ki,kj] <- sum( m[ membs == ki, membs == kj ] ) + sum( m[ membs == kj, membs == ki ] )
        }
    }
    meta    <- meta / max( meta )
    meta_g  <- ut$adj_to_g( meta, mode='undirected', weighted=TRUE, diag=FALSE )
    meta_lo <- lo_func2( meta_g )
    pos <- compose( pos, meta_lo, membs, ... )
    return( pos )
}

termv <- function( g, v ) {
    return( ut$V( g )[ ut$V( g )$term == v ] )
}

has_vattr <- function( g, atr ) {
    return( !is.null( ut$vattr( g, atr ) ) )
}

has_eattr <- function( g, atr ) {
    return( !is.null( ut$eattr( g, atr ) ) )
}
