
# globals -------------------------------------------------------------------------------------
REBUILD      = TRUE
SAVE_OUT     = TRUE
CACHE        = "/home/jta/desktop/obo/data/tables/offences.RData"

# functions -----------------------------------------------------------------------------------
build <- function() {
    message( 'Building offences dataset' )
    source( "inc/obo_tables.R", chdir=TRUE, local=( ta <<- if( exists( 'ta' ) ) ta else new.env() ) )
    divs <- gather_divs( ta )
    defs <- gather_defs( ta )
    vics <- gather_vics( ta )
    offs <- gather_offs( ta )
    data <- offs %>%
        dplyr::left_join( divs, by='divId' ) %>%
        dplyr::left_join( defs, by='offId' ) %>%
        dplyr::mutate(
            nDefGenM = ifelse( is.na( nDefGenM ), 0L, nDefGenM ),
            nDefGenI = ifelse( is.na( nDefGenI ), 0L, nDefGenI ),
            nDefGenF = ifelse( is.na( nDefGenF ), 0L, nDefGenF ),
            nDef     = nDefGenM + nDefGenI + nDefGenF
        ) %>%
        dplyr::left_join( vics, by='offId' ) %>%
        dplyr::mutate(
            nVicGenM = ifelse( is.na( nVicGenM ), 0L, nVicGenM ),
            nVicGenI = ifelse( is.na( nVicGenI ), 0L, nVicGenI ),
            nVicGenF = ifelse( is.na( nVicGenF ), 0L, nVicGenF ),
            nVic     = nVicGenM + nVicGenI + nVicGenM
        )
    if( SAVE_OUT ) {
        message( sprintf( "Saving offences dataset to %s", CACHE ) )
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

gather_vics <- function( ta ) {
    message( "Gathering victims" )
    vic <- ta$data$jon[ ta$data$jon$type == 'offenceVictim', c('tgtId','payId') ] %>%
        dplyr::rename(
            offId = tgtId,
            vicId = payId
        ) %>%
        dplyr::left_join(
            ta$INIT$per( ta$data$per ) %>% dplyr::select( vicId = entId, gender ), by='vicId'
        ) %>%
        dplyr::select(
            offId, gender
        ) %>% 
        table() %>% ( function( x ) {
            list(
                offId    = dimnames( x )$offId,
                nVicGenF = x[,c('female')],
                nVicGenI = x[,c('indeterminate')],
                nVicGenM = x[,c('male')]
            ) %>% as.data.frame %>% dtplyr::tbl_dt() %>% return
        } )
    return( vic )
}

gather_defs <- function( ta ) {
    message( "Gathering defendants" )
    def <- ta$data$cha[ ta$data$cha$valid, c( 'defId','offId' ) ] %>%
        dplyr::left_join(
            ta$INIT$per( ta$data$per ) %>% dplyr::select( defId = entId, gender ), by='defId'
        ) %>%
        dplyr::select( 
            offId, gender
        ) %>%
        table %>% ( function( x ) {
            list(
                offId    = dimnames( x )$offId,
                nDefGenF = x[,c('female')],
                nDefGenI = x[,c('indeterminate')],
                nDefGenM = x[,c('male')]
            ) %>% as.data.frame %>% dtplyr::tbl_dt() %>% return
        } )
    return( def )
}

gather_offs <- function( ta ) {
    message( "Gathering offences" )
    off <- ta$INIT$lgl( ta$data$off ) %>%
        dplyr::select(
            offId     = entId,
            divId     = divId,
            offCat    = cat,
            offSubcat = subcat
        ) %>%
        dplyr::mutate(
            offViolent = (
                ( offSubcat == 'highwayRobbery' ) |
                ( offSubcat == 'robbery' ) |
                ( offSubcat == 'assaultWithSodomiticalIntent' ) |
                ( offSubcat == 'indecentAssault' ) |
                ( offSubcat == 'assaultWithIntent' ) |
                ( offSubcat == 'rape' ) |
                ( offSubcat == 'pettyTreason' ) |
                ( offSubcat == 'infanticide' ) |
                ( offSubcat == 'manslaughter' ) |
                ( offSubcat == 'murder' ) |
                ( offSubcat == 'threateningBehaviour' ) |
                ( offSubcat == 'riot' ) |
                ( offSubcat == 'assault' ) |
                ( offSubcat == 'wounding' )
            )
        )
    return( off )
}

# main ----------------------------------------------------------------------------------------
if( exists( 'REBUILD' ) && file.exists( CACHE ) ) {
    message( sprintf( 'Loading offences dataset from %s', CACHE ) )
    load( CACHE )
} else {
    data <- build()
}
