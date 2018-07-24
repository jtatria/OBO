# globals ------------------------------------------------------------------------------------------

REBUILD      = FALSE
SAVE_OUT     = TRUE
CACHE        = "/home/jta/desktop/obo/data/tables/charges.RData"

# functions ----------------------------------------------------------------------------------------

build <- function() {
    message( 'Building charges dataset' )
    source( "inc/obo_tables.R", chdir=TRUE, local=( ta <- if( exists( 'ta' ) ) ta else new.env() ) )
    div <- gather_divs( ta )
    def <- gather_defendants( ta )
    off <- gather_offences( ta )
    ver <- gather_verdicts( ta )
    data <- ta$data$cha[ ta$data$cha$valid, ] %>%
        dplyr::select(
            chaId = chaId,
            divId = divId,
            defId = defId,
            offId = offId,
            verId = verId
        ) %>%
        dplyr::left_join( div, by='divId' ) %>%
        dplyr::left_join( def, by='defId' ) %>%
        dplyr::left_join( off, by='offId' ) %>%
        dplyr::left_join( ver, by='verId' )
    if( SAVE_OUT ) {
        message( sprintf( "Saving charges dataset to %s", CACHE ) )
        save( data, file=CACHE )
    }
    return( data )
}

gather_divs <- function( ta ) {
    message( "Gathering documents" )
    div <- ta$INIT$div( ta$data$div ) %>% select(
        divId,
        divType,
        divYear,
        divDate
    )
    return( div )
}

gather_defendants <- function( ta ) {
    message( "Gathering defendants" )
    def <- ta$INIT$per( ta$data$per )[ , c( 'entId', 'gender', 'age', 'occ' ) ] %>% 
        dplyr::rename( defId = entId )
    pun <- ta$INIT$lgl( ta$data$pun )[ , c( 'entId', 'cat' ) ] %>%
        dplyr::rename( punId = entId )
    jon <- ta$data$jon[ ta$data$jon$type == 'defendantPunishment', c( 'tgtId', 'payId' ) ] %>%
        dplyr::rename(
            defId = tgtId,
            punId = payId
        ) %>% dplyr::left_join( pun, by='punId' ) %>%
        dplyr::select( defId, cat ) %>% table %>% as.data.frame.matrix
    jon$defId <- rownames( jon )
    jon %<>% dtplyr::tbl_dt()
    def %<>% dplyr::left_join( jon, by='defId' ) %>%
        dplyr::rename(
            defGen     = gender,
            defAge     = age,
            defOcc     = occ,
            nPunCorp   = corporal,
            nPunDeath  = death,
            nPunPrison = imprison,
            nPunMisc   = miscPunish,
            nPunNone   = noPunish,
            nPunTrans  = transport
        )
    return( def )
}

gather_offences <- function( ta ) {
    message( "Gathering offences" )
    off <- ta$INIT$lgl( ta$data$off )[ , c( 'entId', 'cat', 'subcat' ) ] %>% 
        dplyr::rename( offId = entId ) %>% 
        dplyr::mutate(
            kOffViolent = (
                ( subcat == 'highwayRobbery' ) |
                ( subcat == 'robbery' ) |
                ( subcat == 'assaultWithSodomiticalIntent' ) |
                ( subcat == 'indecentAssault' ) |
                ( subcat == 'assaultWithIntent' ) |
                ( subcat == 'rape' ) |
                ( subcat == 'pettyTreason' ) |
                ( subcat == 'infanticide' ) |
                ( subcat == 'manslaughter' ) |
                ( subcat == 'murder' ) |
                ( subcat == 'threateningBehaviour' ) |
                ( subcat == 'riot' ) |
                ( subcat == 'assault' ) |
                ( subcat == 'wounding' )
            )
        )
    vic <- ta$INIT$per( ta$data$per )[ , c( 'entId', 'gender' ) ] %>%
        dplyr::rename( vicId = entId )
    jon <- ta$data$jon[ ta$data$jon$type == 'offenceVictim', c( 'tgtId', 'payId' ) ] %>%
        dplyr::rename(
            offId = tgtId, vicId = payId
        ) %>% dplyr::left_join( vic, by='vicId' ) %>%
        dplyr::select( offId, gender ) %>% table %>% as.data.frame.matrix
    jon$offId <- rownames( jon )
    jon %<>% dtplyr::tbl_dt()
    off %<>% dplyr::left_join( jon, by='offId' ) %>%
        dplyr::rename(
            offCat    = cat,
            offSubcat = subcat,
            nVicGenF  = female,
            nVicGenM  = male,
            nVicGenI  = indeterminate
        )
    return( off )
}

gather_verdicts <- function( ta ) {
    message( "Gathering verdicts" )
    ver <- ta$INIT$lgl( ta$data$ver ) %>%
        dplyr::select(
            verId     = entId,
            verCat    = cat,
            verSubcat = subcat
        )
    return( ver )
}

# main ---------------------------------------------------------------------------------------------
if( exists( 'REBUILD' ) && file.exists( CACHE ) ) {
    message( sprintf( 'Loading charges dataset from %s', CACHE ) )
    load( CACHE )
} else {
    data <- build()
}
