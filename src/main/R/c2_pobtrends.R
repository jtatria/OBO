#!/usr/bin/Rscript

require( dplyr )
require( magrittr )

rm( list=ls() )

source( 'inc/obo_util.R',  chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

PROJ_NAME <- 'c2_pobtrends'
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, sprintf( "%s.RData", PROJ_NAME ) )
DEVICE    <- 'internal'

make_data <- function() {
    source( 'inc/obo_tables.R', chdir=TRUE, local=( if( exists( 'ta' ) ) ta else ( ta <- new.env() ) ) )
    trials      <- ta$get_trials()
    motifs      <- ta$get_trial_motifs()
    offences    <- ta$get_trial_offs()
    punishments <- ta$get_trial_puns()

    source( 'inc/obo_corpus.R', chdir=TRUE, local=( if( exists( 'cr' ) ) cr else ( cr <- new.env() ) ) )
    freqs <- colSums( cr$data$freq )
    save( trials, motifs, offences, punishments, freqs, file=DATA_FILE )
}

if( !file.exists( DATA_FILE ) ) {
    ut$infof( "Data file %s not found. Regenerating...", DATA_FILE )
    make_data()
}
ut$infof( "Loading data from %s", DATA_FILE )
load( DATA_FILE )

ut$gr_setup( sprintf( "%s_fig1", PROJ_NAME ), n=4, device=DEVICE )
    offences %>%
        select( -divId, -divDate, -paraCt, -nOff, -bViolent ) %>%
        filter( divYear != 1706 ) %>%
        group_by( divYear ) %>%
        summarize_all( sum ) %>%
        tidyr::gather( offCat, N, -divYear, factor_key = TRUE ) %>%
        ut$plot_stacks()
    mtext( side=3, line=0, text='Offence categories', cex=.8 )
    ut$period_lines()

    punishments %>%
        select( -divId, -divDate, -paraCt, -nPun, -bCorporal ) %>%
        filter( divYear != 1706 ) %>%
        group_by( divYear ) %>%
        summarize_all( sum ) %>%
        tidyr::gather( offCat, N, -divYear, factor_key = TRUE ) %>%
        ut$plot_stacks()
    mtext( side=3, line=0, text='Punishment categories', cex=.8 )
    ut$period_lines()

    motifs %>%
        select( divYear, kGender ) %>%
        filter( divYear != 1706 ) %>%
        ut$plot_stacks()
    mtext( side=3, line=0, text='Women in Old Bailey trials', cex=.8 )
    ut$period_lines()

    motifs %>%
        select( divYear, kGroup ) %>%
        filter( divYear != 1706 ) %>%
        ut$plot_stacks()
    mtext( side=3, line=0, text='Groups in Old Bailey trials', cex=.8 )
    ut$period_lines()
ut$gr_finish()

ut$gr_setup( sprintf( "%s_fig2", PROJ_NAME ), n=2, device=DEVICE )
    tmp <- trials %>% group_by( divDate ) %>% summarise( ct=n() )
    plot( NA, xlim=range( tmp$divDate ), ylim=c( 0, 1 ), ylab=NA, xlab=NA, axes=FALSE, xaxs='i' )
    y1 <- tmp$ct / max( tmp$ct )
    y2 <- ( freqs ) / max( ( freqs ), na.rm=TRUE )
    cols <- ut$color_mk_palette()( 2 )
    points( tmp$divDate, y1, cex=.5, col=cols[1] %>% ut$color_add_alpha( alpha=.4 ) )
    lines( as.Date( names( freqs ), '%Y' ), y2, col=cols[2] )
    xaxs <- axisTicks( c( 1674, 1913 ), log=FALSE )
    axis( 1, at=xaxs %>% as.character() %>% as.Date( '%Y' ), labels=xaxs )
    yaxs1 <- axisTicks( range( tmp$ct ), log=FALSE )
    yaxs2 <- axisTicks( range( freqs, na.rm=TRUE ), log=FALSE )
    axis( 2, at=yaxs1 / max( yaxs1 ), labels=yaxs1, las=1 )
    axis( 4, at=yaxs2 / max( yaxs2 ), labels=format( yaxs2, scientific=FALSE ), las=1 )
    box(); ut$period_lines( date=TRUE )
    mtext( side=3, line=0, text="Number of trials per session (dots, left) and total tf per year (line, right)", cex=.8 )

    trials %>% filter( divYear != 1706 ) %>% ut$plot_qs( divYear, paraCt, log='y', xaxs='i' )
    axis( 1 ); axis( 2, las=2 )
    mtext( side=3, line=0, text='Distribution of paragraphs per trial account per year', cex=.8 )
    ut$period_lines()
ut$gr_finish()

