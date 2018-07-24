require( dplyr )
require( magrittr )

source( 'inc/obo_tables.R', chdir=TRUE, local=( if( exists( 'ta' ) ) ta else ( ta <- new.env() ) ) )

na_level <- function( factor, na='noValue' ) {
    lvls <- c( levels( factor ), na )
    factor <- addNA( factor )
    levels( factor ) <- lvls
    return( factor )
}

df_table <- function( tbl, rn=names( dimnames( tbl ) )[1] ) {
    d <- list( dimnames( tbl )[[1]] ) %>% as.data.frame()
    for( i in 1:dim( tbl )[2] ) {
        d <- cbind( d, tbl[ , i ] )
    }
    names( d ) <- c( names( dimnames( tbl ) )[1], dimnames( tbl )[[2]] )
    return( d %>% dtplyr::tbl_dt() )
}

gather_persons <- function() {
    ta$data$per %>% mutate(
        gender  = na_level( gender, na='indeterminate' ),
        oboType = na_level( oboType, na='noType' )
    ) %>%
    select( entId, divId, gender, oboType ) %>%
    left_join(
        ta$data$cha %>%
        select( entId = defId ) %>%
        mutate( charge=TRUE ), by='entId' 
    ) %>%
    left_join( 
        ta$data$jon %>% 
        filter( type=='offenceVictim' ) %>%
        select( entId = payId ) %>%
        mutate( victim=TRUE ), by='entId'
    ) %>% mutate(
        charge = !is.na( charge ) | ( oboType == 'defendantName' ),
        victim = !is.na( victim ) | ( oboType == 'victimName'    & !charge )
    ) %>%
    return()
}

get_defs <- function( per ) {
    per %>% 
    filter( charge ) %>%
    select( divId, gender ) %>% 
    table %>% df_table() %>%
    transmute(
        divId = divId,
        nDefGenM = male,
        nDefGenI = indeterminate,
        nDefGenF = female
    ) %>%
    return()
}

get_vics <- function( per ) {
    per %>% 
    filter( victim ) %>%
    select( divId, gender ) %>% 
    table %>% df_table() %>%
    transmute(
        divId = divId,
        nVicGenM = male,
        nVicGenI = indeterminate,
        nVicGenF = female
    ) %>%
    return()
}

get_offs <- function() {
    ta$data$off %>%
    select( divId, cat ) %>%
    table %>% df_table %>%
    left_join( 
        ta$data$off %>%
        select( divId, kViolent ) %>%
        group_by( divId ) %>%
        summarize( 
            nOff = n(),
            bViolent = any( kViolent ) 
        ), by='divId' 
    ) %>% 
    return()
}

get_puns <- function() {
    ta$data$pun %>%
    select( divId, cat ) %>%
    table %>% df_table %>%
    left_join(
        ta$data$pun %>%
        select( divId, kCorporal ) %>%
        group_by( divId ) %>%
        summarize(
            nPun = n(),
            bCorporal = any( kCorporal )
        ), by='divId'
    ) %>% 
    return()
}

get_trials <- function() {
    ta$data$div %>%
    filter( divType == 'trialAccount' ) %>%
    select( divId, divYear, clen, paraCt ) %>%
    return()
}

get_trial_motifs <- function() {
    per <- gather_persons()
    get_trials() %>%
    left_join( get_defs( per ) %>% mutate( bDef=TRUE ), by='divId' ) %>%
    mutate( 
        bDef     = !is.na( bDef ),
        nDefGenM = ifelse( is.na( nDefGenM ), 0L, nDefGenM ),
        nDefGenF = ifelse( is.na( nDefGenF ), 0L, nDefGenF ),
        nDefGenI = ifelse( is.na( nDefGenI ), 0L, nDefGenI ),
        nDef     = nDefGenM + nDefGenI + nDefGenF,
        bGrpDef  = nDef > 1,
        bFemDef  = nDefGenF > 0
    ) %>%    
    left_join( get_vics( per ) %>% mutate( bVic=TRUE ), by='divId' ) %>%
    mutate(
        bVic     = !is.na( bVic ),
        nVicGenM = ifelse( is.na( nVicGenM ), 0L, nVicGenM ),
        nVicGenF = ifelse( is.na( nVicGenF ), 0L, nVicGenF ),
        nVicGenI = ifelse( is.na( nVicGenI ), 0L, nVicGenI ),
        nVic     = nVicGenM + nVicGenI + nVicGenF,
        bGrpVic  = nVic > 1,
        bFemVic  = nVicGenF > 0
    ) %>%
    mutate(
        kGender = paste( as.integer( bFemDef ), as.integer( bFemVic ), sep='' ) %>%
            strtoi( base=2 ) %>%
            factor( labels=c( 'neither', 'victim', 'defendant', 'both' ) ),
        kGroup  = paste( as.integer( bGrpDef ), as.integer( bGrpVic ), sep='' ) %>%
            strtoi( base=2 ) %>%
            factor( labels=c( 'neither', 'victims', 'defendants', 'both' ) )
    ) %>%
    return()
}

get_trial_offs <- function() {
    get_trials() %>%
    left_join( get_offs(), by='divId' ) %>%
    mutate(
        breakingPeace = ifelse( is.na( breakingPeace ), 0L, breakingPeace ),
        damage        = ifelse( is.na( damage        ), 0L, damage        ),
        deception     = ifelse( is.na( deception     ), 0L, deception     ),
        kill          = ifelse( is.na( kill          ), 0L, kill          ),
        miscellaneous = ifelse( is.na( miscellaneous ), 0L, miscellaneous ),
        royalOffences = ifelse( is.na( royalOffences ), 0L, royalOffences ),
        sexual        = ifelse( is.na( sexual        ), 0L, sexual        ),
        theft         = ifelse( is.na( theft         ), 0L, theft         ),
        violentTheft  = ifelse( is.na( violentTheft  ), 0L, violentTheft  ),
        nOff     = ifelse( is.na( nOff ), 0L, nOff ),
        bViolent = ifelse( is.na( bViolent ), FALSE, bViolent )
    ) %>%
    return()
}

get_trial_puns <- function() {
    get_trials() %>%
    left_join( get_puns(), by='divId' ) %>%
    mutate(
        corporal   = ifelse( is.na( corporal   ), 0L, corporal   ),
        death      = ifelse( is.na( death      ), 0L, death      ),
        imprison   = ifelse( is.na( imprison   ), 0L, imprison   ),
        miscPunish = ifelse( is.na( miscPunish ), 0L, miscPunish ),
        noPunish   = ifelse( is.na( noPunish   ), 0L, noPunish   ),
        transport  = ifelse( is.na( transport  ), 0L, transport  ),
        nPun      = ifelse( is.na( nPun ), 0L, nPun ),
        bCorporal = ifelse( is.na( bCorporal ), FALSE, bCorporal )
    ) %>%
    return()
}


