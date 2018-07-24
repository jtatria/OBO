source( "inc/obo_corpus.R", chdir=TRUE, local=( cr <- new.env() ) )
source( "inc/obo_util.R"  , chdir=TRUE, local=( ut <- new.env() ) )
suppressMessages( require( wspaces ) )
suppressMessages( require( dplyr ) )

# Add term text and arrow to lexical plot
mark_term <- function( term, col='red' ) {
    d <- data_()
    x = which( rownames( d ) == term );
    y = d$tf[ x ]
    ut$guides( x, y, symbol=16, scol=col, label='xy', yadj=c( -.1, -.2 ) )
    text( x, y, '\U2190 ' %.% term, adj=c( -.15, .15 ) )
}

DATA <- NULL
data_ <- function() {
    if( is.null( DATA ) ) {
        message( "Generating dataset..." )
        lex_sort = c( 'NN', 'NP', 'V', 'ADJ', 'ADV', 'ART', 'CONJ', 'PP', 'PR', 'CARD', 'O' )
        d <- cbind( data.frame( row.names=rownames( cr$data$lxcn ) ),
            tf  = cr$data$lxcn$tf,
            df  = cr$data$lxcn$df,
            rnk = class_rank( cr$data$lxcn$tf, labels=1:100 ),
            mss = class_mass( cr$data$lxcn$tf, labels=1:100, log=TRUE ),
            pos = factor( cr$data$posc$POS_prob, levels=lex_sort ),
            lex = !(
                cr$data$posc$POS_prob %in% setdiff( obo_all_pos(), c( obo_lex_pos(), 'CARD', 'O' ) )
            ),
            pos_naif = factor( cr$data$posc$POS_naif, levels=lex_sort )
        )
        ools <- rowSums( cr$data$freq ) <= 0
        if( any( ools ) ) {
            message( sprintf( 'Dropping %d empirical O.O.L. terms.', length( ools[ools] ) ) )
            d <- d[ !ools, ]
        }
        DATA <<- d
    }
    return( DATA )
}

# pos distributions --------------------------------------------------------------------------------
plot_pos_heat <- function( ... ) {
    d <- data_()
    table( d$pos_naif, d$pos ) %>% ut$plot_heat( ... )
    title( xlab='Probabilistic: p( pos | term ) / p( pos )', line=4 )
    title( ylab='Naive: max( pos | term )',                  line=4 )
    title( main='Cross classification of POS classes' )
    abline( v=5.5, col='red' )
    abline( h=6.5, col='red' )
    axis(
        1, at=c( 3, 8.5 ), labels=c( 'lexicals', 'functionals' ),
        line=-1.2, tick=FALSE, cex.axis=.7
    )
    axis(
        2, at=c( 3.5, 9 ), labels=c( 'functionals', 'lexicals' ),
        line=-1.0, tick=FALSE, cex.axis=.7
    )
}

plot_pos_rank <- function( ... ) {
    d <- data_()
    table( d$rnk, d$pos ) %>%
    ut$plot_stacks( k=1, log='x', border=NA, axes=FALSE, ... )
    ut$guides( ( 1:100 + .5 ), rep( 1, 100 ), lty=1, lwd=.5 )
    ut$pbox( bty='o')
    axis( 1, at=ut$log_ticks( seq( 1, 7, 2 ), 2 ), cex.axis=.8 )
    axis( 2, cex.axis=.8 )
    title( main="POS distribution across rank classes", outer=TRUE, line=-2 )
    title( xlab="(log) Rank class" )
    title( ylab="Proportion of total tokens" )
}

plot_pos_mass <- function( ... ) {
    d <- data_()
    table( d$mss, d$pos ) %>%
    ut$plot_stacks( k=1, log='x', border=NA, axes=FALSE, ... )
    ut$guides( ( 1:100 + .5 ), rep( 1, 100 ), lty=1, lwd=.5 )
    ut$pbox( bty='o' )
    axis( 1, at=ut$log_ticks( seq( 1, 7, 2 ), 2 ), cex.axis=.8 )
    axis( 2, cex.axis=.8 )
    title( main="POS distribution across mass classes", outer=TRUE, line=-2 )
    title( xlab="(log) Mass class" )
    title( ylab="Proportion of total tokens" )
}

plot_pos_time <- function( ... ) {
    d <- data_()
    d %>% select( pos ) %>% lexical_join( cr$data$freq ) %>% group_by( pos ) %>%
        summarize_all( .funs=sum ) %>%
        tidyr::gather( year, N, 2:length( . ) ) %>%
        ut$plot_stacks()
    title( main="POS distribution across time", outer=TRUE, line=-2 )
        title( xlab="Year" )
        title( ylab="Proportion of total tokens" )
}

# population rank-freq -----------------------------------------------------------------------------
plot_freq_rank <- function() {
    d <- data_()
    op <- par( mai=par('mai')+c( 0, strwidth( max( d$tf ), unit='i' ), 0, 0 ) )
    plot( d$tf, type='l', ylab=NA, xlab=NA, axes=FALSE, log='xy' ); box( bty='l' )
    axis( 1, at=c( ut$log_ticks( c( 1, 10 ), 4 ), length( d$tf ) ) )
    axis( 2, at=c( ut$log_ticks( c( 1, 10 ), 6 ), max( d$tf ) ), las=2 )
    title( main='Frequency/rank term distribution', outer=TRUE, line=-2 )
    title( xlab='(log) Lexicon rank' )
    title( ylab='(log) Total term frequency', line=5 )
    mark_term( 'prisoner' )
    mark_term( 'kill' )
    mark_term( 'man' )
    mark_term( 'woman' )
    par( op ); rm( op )
}

# lexicon sample -----------------------------------------------------------------------------------
lex_sample <- function( x, theta ) {
    return( is.na( x ) | x <= theta )
}

mk_samples <- function() {
    d <- data_()
    l <- d$lex
    f <- d$tf 
    d$lex_cover <- ifelse( l,
        # cumsum( ifelse( d$lex, d$tf, 0 ) / sum( d$tf ) ) + ( sum( d$tf[ !d$lex ] ) / sum( d$tf ) ),
        cumsum( ifelse( d$lex, d$tf, 0 ) / sum( d$tf[ d$lex ] ) ),
        NA
    )
    
    d$lex_cover <- ifelse( l, cumsum( ifelse( l, f, 0 ) / sum( f[ l ] ) ), NA )
    d$all_cover <- ifelse( l, cumsum( ifelse( l, f, 0 ) / sum( f ) ) + ( sum( f[ !l ] ) / sum( f ) ), NA )
    
    d$s90 <- lex_sample( d$lex_cover, .90 )
    d$s95 <- lex_sample( d$lex_cover, .95 )
    d$s99 <- lex_sample( d$lex_cover, .99 )
    return( d )
}

plot_sample_cover <- function( coverage ) {
    sizes <- vapply( seq( 0, 1, .01 ), function( theta ) sum( lex_sample( coverage, theta ) ), 1L )
    cover <- seq( 0, 1, .01 )
    plot(
        sizes, cover, log='x', ylab="Proportion of total tokens", xlab="(log) Sample size",
        xaxs='i', yaxs='i', type='l',
        # ylim=c( .5, 1 ), xlim=c( 188, 77712 )
    )
    ut$guides(
        c( sizes[91], sizes[96], sizes[100] ), c( cover[91], cover[96], cover[100] ),
        fill=1, fcol=rgb( 0, 0, 0, .1 ), labels='xy', ylab=c( '90%%', '95%%', '99%%' ),
        yadj=c( -.2, 1.3 )
    )
    title( main="Sample sizes of different corpus coverages", outer=TRUE, line=-2 )
    rm( sizes, cover )
}
