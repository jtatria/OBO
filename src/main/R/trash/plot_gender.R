source( 'tables_build_trials.R', chdir = TRUE )

whiskers <- function( x ) {
    return( quantile( x, probs = c( 0.09, 0.25, 0.50, 0.75, 0.91 ) ) )
}

qs <- trials %>% group_by( divYear ) %>% summarize(
    ct = n(),
    min = min( divLength ),
    q09 = whiskers( divLength )[1],
    q25 = whiskers( divLength )[2],
    q50 = whiskers( divLength )[3],
    q75 = whiskers( divLength )[4],
    q91 = whiskers( divLength )[5],
    max = max( divLength )
) %>% rename( year = divYear )

plot( qs$year, rep( 0, length( qs$year ) ), type = 'n', ylim = c( 0, log10( max( qs$max ) ) ) )
polygon(
    c( qs$year[ 3:( length( qs$year ) - 2 ) ], rev( qs$year[ 3:( length( qs$year ) - 2 ) ] ) ),
    c( zoo::rollmean( log10( qs$q09 + 1 ), k=5 ), rev( zoo::rollmean( log10( qs$q91 + 1 ), k=5 ) ) ),
    col='snow1', border=NA
)
polygon(
    c( qs$year[ 3:( length( qs$year ) - 2 ) ], rev( qs$year[ 3:( length( qs$year ) - 2 ) ] ) ),
    c( zoo::rollmean( log10( qs$q25 + 1 ), k=5 ), rev( zoo::rollmean( log10( qs$q75 + 1 ), k=5 ) ) ),
    col='snow2', border=NA
)
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$min + 1 ), k=5 ), lty=3, lwd=.4 )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$q09 + 1 ), k=5 ), lty=2, lwd=.8 )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$q25 + 1 ), k=5 ) )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$q50 + 1 ), k=5 ), lty=1, lwd=2 )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$q75 + 1 ), k=5 ) )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$q91 + 1 ), k=5 ), lty=2, lwd=.8 )
lines( qs$year[ 3:( length( qs$year ) - 2 ) ], zoo::rollmean( log10( qs$max + 1 ), k=5 ), lty=3, lwd=.4 )


ver_cats <- data_ljoin(
    obo_tables$ver %>% select( div = divId, cat = verdictCategory ),
    obo_tables$div %>% select( div = entId, year = year ),
    lk = div,
    rk = div
) %>% plot_ribbons( year, cat )

off_cats <- data_ljoin(
    obo_tables$off %>% select( div = divId, cat = offenceCategory ),
    obo_tables$div %>% select( div = entId, year = year ),
    lk = div, rk = div
) %>% plot_ribbons( year, cat, ratios = TRUE )

lvl <- c( 'ind', 'female', 'ind', 'male' )
obo_tables$per %>% mutate(
    gender = factor( gender ),
    gender = factor( lvl[gender] )
) %>% select( div = divId, gender = gender ) %>% data_ljoin(
    obo_tables$div %>% select( div = entId, year = year ),
    lk = div,
    rk = div
) %>% plot_ribbons( year, gender )



