# globals ------------------------------------------------------------------------------------------

REBUILD      = FALSE
SAVE_OUT     = TRUE
CACHE        = "/home/jta/desktop/obo/data/tables/persons.RData"

TRIALS_ONLY  = TRUE

# functions ----------------------------------------------------------------------------------------
build <- function() {
    message( 'Building persons dataset' )
    source( "inc/obo_tables.R", chdir=TRUE, local=( ta <<- if( exists( 'ta' ) ) ta else new.env() ) )
    div <- gather_divs( ta )
    cha <- gather_chas( ta )
    vic <- gather_vics( ta )
    ext <- gather_exts( ta )
    data <- ta$INIT$per( ta$data$per ) %>% dplyr::transmute(
        entId    = entId,
        oboType  = oboType,
        given    = given,
        surname  = surname,
        gender   = gender,
        age      = age,
        occ      = occ,
        bGiven   = !is.na( given ),
        bSurname = !is.na( surname ),
        bName    = ( bGiven & bSurname ),
        bAge     = !is.na( age ),
        bOcc     = !is.na( occ ),
        divId = divId
    ) %>% 
        dplyr::left_join( div, by='divId' ) %>%
        dplyr::left_join( cha, by='entId' ) %>%
        dplyr::left_join( vic, by='entId' ) %>%
        dplyr::left_join( ext, by='entId' )
    if( TRIALS_ONLY ) {
        data <- data[ d$divType == 'trialAccount', ]
    }
    if( SAVE_OUT ) {
        message( sprintf( "Saving persons dataset to %s", CACHE ) )
        save( data, file=CACHE )
    }
    return( data )
}

data_collapse_frame <- function( j, keep, key=tarId ) {
    selects <- list( lazyeval::lazy( key ), lazyeval::lazy( collisions ) ) %>%
        data.table::setattr( 'names', c( 'id_', 'type_' ) )
    renames <- list( lazyeval::lazy( id_ ), lazyeval::lazy( type_ ) ) %>%
        data.table::setattr( 'names', c( 'entId', keep ) )
    j %<>% dplyr::filter( type == keep ) %>% dplyr::select_( .dots=selects ) %>%
        dplyr::group_by( id_ ) %>% dplyr::summarise( type_ = sum( type_ ) ) %>%
        dplyr::rename_( .dots=renames )
    return( j )
}

gather_divs <- function( ta ) {
    message( "Gathering documents" )
    div <- ta$INIT$div( ta$data$div ) %>% dplyr::select( -collisions )
    return( div )
}

gather_chas <- function( ta ) {
    message( "Gathering charges" )
    cha <- ta$data$cha %>% dplyr::group_by( defId ) %>% dplyr::summarise(
        nCharges = sum( collisions )
    ) %>% dplyr::rename(
        entId = defId
    )
    return( cha )
}

gather_vics <- function( ta ) {
    message( "Gathering victims" )
    vic <- ta$data$jon %>% dplyr::filter(
        type == 'offenceVictim'
    ) %>% dplyr::group_by( payId ) %>% dplyr::summarise(
        nVictim = sum( collisions )
    ) %>% dplyr::rename(
        entId = payId
    )
    return( vic )
}

gather_exts <- function( ta ) {
    message( 'Gathering extra information' )
    jon <- ta$data$jon %>% dplyr::filter( valid )
    pun <- data_collapse_frame( jon, 'defendantPunishment', tgtId )
    pla <- data_collapse_frame( jon, 'nameAlias'          , tgtId )
    ali <- data_collapse_frame( jon, 'persNamePlace'      , tgtId )
    occ <- data_collapse_frame( jon, 'persNameOccupation' , tgtId )
    d <- pun %>%
        dplyr::full_join( pla, by='entId' ) %>%
        dplyr::full_join( ali, by='entId' ) %>%
        dplyr::full_join( occ, by='entId' ) %>%
        dplyr::transmute(
            entId = entId,
            nDefPuns = ifelse( is.na( defendantPunishment ), 0L, defendantPunishment ),
            nPerAlis = ifelse( is.na(          nameAlias  ), 0L,          nameAlias  ),
            nPerPlas = ifelse( is.na(      persNamePlace  ), 0L,      persNamePlace  ),
            nPerOccs = ifelse( is.na( persNameOccupation  ), 0L, persNameOccupation  )
        )
    return( d )
}

# main ---------------------------------------------------------------------------------------------
if( exists( 'REBUILD' ) && file.exists( CACHE ) ) {
    message( sprintf( 'Loading persons dataset from %s', CACHE ) )
    load( CACHE )
} else {
    data <- build()
}
