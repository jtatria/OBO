# globals ------------------------------------------------------------------------------------------

REBUILD      = TRUE
SAVE_OUT     = TRUE
CACHE        = "/home/jta/desktop/obo/data/tables/trials.RData"

RETAIN_AUDIT = FALSE

# functions ----------------------------------------------------------------------------------------
build <- function() {
    message( "Building trials dataset" )
    source( "inc/obo_tables.R", chdir=TRUE, local=( ta <- if( exists( 'ta' ) ) ta else new.env() ) )
    off <- gather_offs( ta )
    ver <- gather_vers( ta )
    pun <- gather_puns( ta )
    per <- gather_pers( ta )
    div <- ta$INIT$div( ta$data$div )
    data <- div %>% dplyr::filteR( divType == 'trialAccount' ) %>%
        dplyr::select(
            divId,
            divYear,
            divDate,
            clen,
            paraCt
        ) %>%
        dplyr::left_join( off, by='divId' ) %>%
        dplyr::mutate(
            nOff       = ifelse( is.na( nOff       ), 0L, nOff       ),
            nOffBrkpea = ifelse( is.na( nOffBrkpea ), 0L, nOffBrkpea ),
            nOffDamage = ifelse( is.na( nOffDamage ), 0L, nOffDamage ),
            nOffDecept = ifelse( is.na( nOffDecept ), 0L, nOffDecept ),
            nOffKill   = ifelse( is.na( nOffKill   ), 0L, nOffKill   ),
            nOffMisc   = ifelse( is.na( nOffMisc   ), 0L, nOffMisc   ),
            nOffRoyal  = ifelse( is.na( nOffRoyal  ), 0L, nOffRoyal  ),
            nOffSexual = ifelse( is.na( nOffSexual ), 0L, nOffSexual ),
            nOffTheft  = ifelse( is.na( nOffTheft  ), 0L, nOffTheft  ),
            nOffVtheft = ifelse( is.na( nOffVtheft ), 0L, nOffVtheft )
        ) %>%
        dplyr::left_join( ver, by='divId' ) %>%
        dplyr::mutate(
            nVer       = ifelse( is.na( nVer       ), 0L, nVer       ),
            nVerGuilty = ifelse( is.na( nVerGuilty ), 0L, nVerGuilty ),
            nVerMisc   = ifelse( is.na( nVerMisc   ), 0L, nVerMisc   ),
            nVerInncnt = ifelse( is.na( nVerInncnt ), 0L, nVerInncnt ),
            nVerSpec   = ifelse( is.na( nVerSpec   ), 0L, nVerSpec   )
        ) %>%
        dplyr::left_join( pun, by='divId' ) %>%
        dplyr::mutate(
            nPun       = ifelse( is.na( nPun       ), 0L, nPun       ),
            nPunCorp   = ifelse( is.na( nPunCorp   ), 0L, nPunCorp   ),
            nPunDeath  = ifelse( is.na( nPunDeath  ), 0L, nPunDeath  ),
            nPunPrison = ifelse( is.na( nPunPrison ), 0L, nPunPrison ),
            nPunMisc   = ifelse( is.na( nPunMisc   ), 0L, nPunMisc   ),
            nPunNone   = ifelse( is.na( nPunNone   ), 0L, nPunNone   ),
            nPunTrans  = ifelse( is.na( nPunTrans  ), 0L, nPunTrans  )
        ) %>%
        dplyr::left_join( per, by='divId' ) %>%
        dplyr::mutate(
            nOth       = ifelse( is.na( nOth       ), 0L, nOth     ),
            nOthGenI   = ifelse( is.na( nOthGenI   ), 0L, nOthGenI ),
            nOthGenM   = ifelse( is.na( nOthGenM   ), 0L, nOthGenM ),
            nOthGenF   = ifelse( is.na( nOthGenF   ), 0L, nOthGenF ),
            nDef       = ifelse( is.na( nDef       ), 0L, nDef     ),
            nDefGenI   = ifelse( is.na( nDefGenI   ), 0L, nDefGenI ),
            nDefGenM   = ifelse( is.na( nDefGenM   ), 0L, nDefGenM ),
            nDefGenF   = ifelse( is.na( nDefGenF   ), 0L, nDefGenF ),
            nVic       = ifelse( is.na( nVic       ), 0L, nVic     ),
            nVicGenI   = ifelse( is.na( nVicGenI   ), 0L, nVicGenI ),
            nVicGenM   = ifelse( is.na( nVicGenM   ), 0L, nVicGenM ),
            nVicGenF   = ifelse( is.na( nVicGenF   ), 0L, nVicGenF )
        )
    if( SAVE_OUT ) {
        message( sprintf( "Saving trials dataset to %s", CACHE ) )
        save( data, file=CACHE )
    }
    return( data )
}

collapse_table <- function( table ) {
    d <- table %>% as.data.frame.matrix %>% data.table::data.table( keep.rownames=TRUE ) 
    d$total <- rowSums( table )
    return( tbl_dt( d ) )
}

gather_offs <- function( ta ) {
    message( 'Gathering offences' )
    off <- ta$INIT$lgl( ta$data$off )
    vio <- off %>% dplyr::transmute(
        divId = divId,
        violent = (
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
    ) %>% table %>% collapse_table() %>% dplyr::select( divId = rn, kOffViolent = `TRUE` )
    d <- off[, c('divId', 'cat') ] %>% table %>% collapse_table() %>%
        dplyr::transmute(
            divId      = rn,
            nOff       = as.integer( total ),
            nOffBrkpea = breakingPeace,
            nOffDamage = damage,
            nOffDecept = deception,
            nOffKill   = kill,
            nOffMisc   = miscellaneous,
            nOffRoyal  = royalOffences,
            nOffSexual = sexual,
            nOffTheft  = theft,
            nOffVtheft = violentTheft
        ) %>% data.table::setkey( divId )
    d %<>% dplyr::left_join( vio, by='divId' )
    rm( off, vio )
    return( d )
}

gather_vers <- function( ta ) {
    message( 'Gathering verdicts' )
    d <- ta$INIT$lgl( ta$data$ver )[, c('divId','cat') ] %>% table %>% collapse_table() %>%
        dplyr::transmute(
            divId      = rn,
            nVer       = as.integer( total ),
            nVerGuilty = guilty,
            nVerMisc   = miscVerdict,
            nVerInncnt = notGuilty,
            nVerSpec   = specialVerdict
        ) %>% data.table::setkey( divId )
    return( d )
}

gather_puns <- function( ta ) {
    message( "Gathering punishments" )
    pun <- ta$INIT$lgl( ta$data$pun )
    cor <- pun %>% dplyr::transmute(
        divId = divId,
        coporal = (
            cat == 'corporal' |
            cat == 'death' |
            subcat == 'branding' | 
            subcat == 'brandingOnCheek'
        )
    ) %>% table %>% collapse_table() %>% dplyr::select( divId = rn, kPunCorp = `TRUE` )
    d <- pun[, c( 'divId', 'cat' ) ] %>% table %>% collapse_table() %>%
        dplyr::transmute(
            divId      = rn,
            nPun       = as.integer( total ),
            nPunCorp   = corporal,
            nPunDeath  = death,
            nPunPrison = imprison,
            nPunMisc   = miscPunish,
            nPunNone   = noPunish,
            nPunTrans  = transport
        ) %>% data.table::setkey( divId )
    d %<>% dplyr::left_join( cor, by='divId' )
    rm( pun, cor )
    return( d )
}

gather_pers <- function( ta ) {
    message( 'Gathering persons' )
    per <- ta$INIT$per( ta$data$per )
    oth <- per %>% `[`(
        .$oboType != 'defendantName' & .$oboType != 'victimName',
        c( 'divId', 'gender' )
    ) %>% table %>% collapse_table() %>% dplyr::transmute(
        divId    = rn,
        nOth     = as.integer( total ),
        nOthGenI = indeterminate,
        nOthGenM = male,
        nOthGenF = female
    ) %>% data.table::setkey( divId )
    def <- gather_defs( ta, per )
    vic <- gather_vics( ta, per )
    
    d <- oth %>% full_join( def, by='divId' ) %>% full_join( vic, by='divId' )
    rm( per, oth, def, vic )
    return( d )
}

gather_defs <- function( ta, per ) {
    message( 'Gathering defendants' )
    div_def_type <- per[ per$oboType == 'defendantName', c( 'divId', 'gender' ) ] %>%
        table %>% collapse_table %>% 
        dplyr::transmute(
            divId     = rn,
            nDefT     = as.integer( total ),
            nDefGenIT = as.integer( indeterminate ),
            nDefGenMT = as.integer( male ),
            nDefGenFT = as.integer( female )
        ) %>% data.table::setkey( divId )
    
    # Def by join
    div_def_join <- ( 
        dplyr::left_join( ta$data$cha, dplyr::select( per, defId=entId, gender ), by='defId' 
    ) %>%
        dplyr::group_by( divId, defId ) %>%
        dplyr::summarize( gender=first( gender ) ) )[,c('divId','gender')] %>%
        table %>% collapse_table %>%
        dplyr::transmute(
            divId     = rn,
            nDefJ     = as.integer( total ),
            nDefGenIJ = as.integer( indeterminate ),
            nDefGenMJ = as.integer( male ),
            nDefGenFJ = as.integer( female )
        ) %>% data.table::setkey( divId )
    
    # Defs, type and join
    div_def <- dplyr::full_join( div_def_type, div_def_join, by='divId' ) %>% dplyr::mutate(
        nDefGenFT = ifelse( is.na( nDefGenFT ), 0L, nDefGenFT ),
        nDefGenIT = ifelse( is.na( nDefGenIT ), 0L, nDefGenIT ),
        nDefGenMT = ifelse( is.na( nDefGenMT ), 0L, nDefGenMT ),
        nDefT     = ifelse( is.na( nDefT     ), 0L, nDefT     ),
        nDefGenFJ = ifelse( is.na( nDefGenFJ ), 0L, nDefGenFJ ),
        nDefGenIJ = ifelse( is.na( nDefGenIJ ), 0L, nDefGenIJ ),
        nDefGenMJ = ifelse( is.na( nDefGenMJ ), 0L, nDefGenMJ ),
        nDefJ     = ifelse( is.na( nDefJ     ), 0L, nDefJ     )
    ) %>% dplyr::transmute( # final def ds columns, everything else is dropped.
        divId    = divId,
        nDef     = as.integer( ifelse( nDefT     > nDefJ    , nDefT    , nDefJ     ) ),
        nDefGenF = as.integer( ifelse( nDefGenFT > nDefGenFJ, nDefGenFT, nDefGenFJ ) ),
        nDefGenI = as.integer( ifelse( nDefGenIT > nDefGenIJ, nDefGenIT, nDefGenIJ ) ),
        nDefGenM = as.integer( ifelse( nDefGenMT > nDefGenMJ, nDefGenMT, nDefGenMJ ) )
    )
    return( div_def )
}

gather_vics <- function( ta, per ) {
    message( 'Gathering victims' )
    # Vic by type.
    div_vic_type <- per[ per$oboType == 'victimName', c( 'divId', 'gender' ) ] %>%
        table %>% collapse_table %>%
        dplyr::transmute(
            divId     = rn,
            nVicT     = as.integer( total ),
            nVicGenIT = as.integer( indeterminate ),
            nVicGenMT = as.integer( male ),
            nVicGenFT = as.integer( female )
        ) %>% data.table::setkey( divId )
    
    # Vic by join.
    div_vic_join <- dplyr::left_join(
        ta$data$jon[ ta$data$jon$type == 'offenceVictim', c( 'payId' ) ],
        dplyr::select( per, divId, payId=entId, gender ), by='payId'
    ) %>% dplyr::group_by( divId, payId ) %>% dplyr::summarize( gender=first( gender ) ) %>% 
        dplyr::select( divId, gender ) %>% table %>% collapse_table() %>%
        dplyr::transmute(
            divId     = rn,
            nVicJ     = as.integer( total ),
            nVicGenIJ = as.integer( indeterminate ),
            nVicGenMJ = as.integer( male ),
            nVicGenFJ = as.integer( female )
        ) %>% data.table::setkey( divId )
    
    # Vics, by type and join.
    div_vic <- dplyr::full_join( div_vic_type, div_vic_join, by='divId' ) %>% dplyr::mutate(
        nVicGenFT = ifelse( is.na( nVicGenFT ), 0L, nVicGenFT ),
        nVicGenIT = ifelse( is.na( nVicGenIT ), 0L, nVicGenIT ),
        nVicGenMT = ifelse( is.na( nVicGenMT ), 0L, nVicGenMT ),
        nVicT     = ifelse( is.na( nVicT     ), 0L, nVicT     ),
        nVicGenFJ = ifelse( is.na( nVicGenFJ ), 0L, nVicGenFJ ),
        nVicGenIJ = ifelse( is.na( nVicGenIJ ), 0L, nVicGenIJ ),
        nVicGenMJ = ifelse( is.na( nVicGenMJ ), 0L, nVicGenMJ ),
        nVicJ     = ifelse( is.na( nVicJ     ), 0L, nVicJ     )
    ) %>% dplyr::transmute(
        divId    = divId,
        nVic     = as.integer( ifelse( nVicT     > nVicJ    , nVicT    , nVicJ     ) ),
        nVicGenF = as.integer( ifelse( nVicGenFT > nVicGenFJ, nVicGenFT, nVicGenFJ ) ),
        nVicGenI = as.integer( ifelse( nVicGenIT > nVicGenIJ, nVicGenIT, nVicGenIJ ) ),
        nVicGenM = as.integer( ifelse( nVicGenMT > nVicGenMJ, nVicGenMT, nVicGenMJ ) )
    )
    return( div_vic )
}

build_trials <- function( div, off, ver, pun, per ) {
    message( "Building trials dataset" )
    div %<>% `[`( .$divType == 'trialAccount', c('divId','divYear','divDate','clen','paraCt') ) %>%
        dplyr::left_join( off, by='divId' ) %>%
        dplyr::mutate(
            nOff       = ifelse( is.na( nOff       ), 0L, nOff       ),
            nOffBrkpea = ifelse( is.na( nOffBrkpea ), 0L, nOffBrkpea ),
            nOffDamage = ifelse( is.na( nOffDamage ), 0L, nOffDamage ),
            nOffDecept = ifelse( is.na( nOffDecept ), 0L, nOffDecept ),
            nOffKill   = ifelse( is.na( nOffKill   ), 0L, nOffKill   ),
            nOffMisc   = ifelse( is.na( nOffMisc   ), 0L, nOffMisc   ),
            nOffRoyal  = ifelse( is.na( nOffRoyal  ), 0L, nOffRoyal  ),
            nOffSexual = ifelse( is.na( nOffSexual ), 0L, nOffSexual ),
            nOffTheft  = ifelse( is.na( nOffTheft  ), 0L, nOffTheft  ),
            nOffVtheft = ifelse( is.na( nOffVtheft ), 0L, nOffVtheft )
        ) %>%
        dplyr::left_join( ver, by='divId' ) %>%
        dplyr::mutate(
            nVer       = ifelse( is.na( nVer       ), 0L, nVer       ),
            nVerGuilty = ifelse( is.na( nVerGuilty ), 0L, nVerGuilty ),
            nVerMisc   = ifelse( is.na( nVerMisc   ), 0L, nVerMisc   ),
            nVerInncnt = ifelse( is.na( nVerInncnt ), 0L, nVerInncnt ),
            nVerSpec   = ifelse( is.na( nVerSpec   ), 0L, nVerSpec   )
        ) %>%
        dplyr::left_join( pun, by='divId' ) %>%
        dplyr::mutate(
            nPun       = ifelse( is.na( nPun       ), 0L, nPun       ),
            nPunCorp   = ifelse( is.na( nPunCorp   ), 0L, nPunCorp   ),
            nPunDeath  = ifelse( is.na( nPunDeath  ), 0L, nPunDeath  ),
            nPunPrison = ifelse( is.na( nPunPrison ), 0L, nPunPrison ),
            nPunMisc   = ifelse( is.na( nPunMisc   ), 0L, nPunMisc   ),
            nPunNone   = ifelse( is.na( nPunNone   ), 0L, nPunNone   ),
            nPunTrans  = ifelse( is.na( nPunTrans  ), 0L, nPunTrans  )
        ) %>%
        dplyr::left_join( per, by='divId' ) %>%
        dplyr::mutate(
            nOth       = ifelse( is.na( nOth       ), 0L, nOth     ),
            nOthGenI   = ifelse( is.na( nOthGenI   ), 0L, nOthGenI ),
            nOthGenM   = ifelse( is.na( nOthGenM   ), 0L, nOthGenM ),
            nOthGenF   = ifelse( is.na( nOthGenF   ), 0L, nOthGenF ),
            nDef       = ifelse( is.na( nDef       ), 0L, nDef     ),
            nDefGenI   = ifelse( is.na( nDefGenI   ), 0L, nDefGenI ),
            nDefGenM   = ifelse( is.na( nDefGenM   ), 0L, nDefGenM ),
            nDefGenF   = ifelse( is.na( nDefGenF   ), 0L, nDefGenF ),
            nVic       = ifelse( is.na( nVic       ), 0L, nVic     ),
            nVicGenI   = ifelse( is.na( nVicGenI   ), 0L, nVicGenI ),
            nVicGenM   = ifelse( is.na( nVicGenM   ), 0L, nVicGenM ),
            nVicGenF   = ifelse( is.na( nVicGenF   ), 0L, nVicGenF )
        )
    return( div )
}

# main ---------------------------------------------------------------------------------------------
if( exists( 'REBUILD' ) && file.exists( CACHE ) ) {
    message( sprintf( 'Loading trials cache from %s', CACHE ) )
    load( CACHE )
} else {
    data <- build()
}

