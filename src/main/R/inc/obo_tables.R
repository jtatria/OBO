suppressMessages( require( magrittr ) )
suppressMessages( require( dtplyr ) )

source( 'obo_util.R', local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )

DATA_DIR <- ut$DIR_DATA_TBLS
FILE_EXT <- 'csv'
DATE_FRM <- "%Y%m%d"
GEN_LVLS <- c( 'female', 'indeterminate', 'male' )
DATA_FILE <- file.path( ut$DIR_DATA_ROBJ, "tables.RData" )

make_data <- function() {
    rm_dupes <- function( d, ..., fold='first( obs )', colls=TRUE ) {
        if( 'collisions' %in% names( d ) ) d <- select( d, -collisions )
        grps <- as.character( substitute( list( ... ) )[-1] ) # this is fugly.
        vars <- setdiff( names( d ), grps )
        folds <- list()
        for( var in vars ) {
            gsub( 'obs', var, fold )
            folds[[var]] <- reformulate( termlabels=gsub( 'obs', var, fold ) )
        }
        if( colls ) folds[['collisions']] <- reformulate( termlabels="n()" )
        d %<>% dplyr::group_by_( .dots=lazyeval::lazy_dots( ... ) ) %>%
            dplyr::summarise_( .dots = folds ) %>%
            dplyr::ungroup() %>% dplyr::arrange_( .dots=lazyeval::lazy_dots( ... ) )
        return( d )
    }
    
    files <- list.files( DATA_DIR, pattern=sprintf( "\\.%s$", FILE_EXT ) )
    data <- lapply( files, function( f ) {
        message( sprintf( 'Loading table from %s', f ) )
        data.table::fread(
            file.path( DATA_DIR, f ), showProgress=FALSE, colClasses='character',
            verbose=FALSE, sep='@', na.strings='null', quote=''
        )
    } )
    names( data ) <- gsub( "\\..*", '', files )
    
    tstart = proc.time()
    message( "Processing sessions" )
    data$ses %<>% rm_dupes( sesId, sesType ) %>% dplyr::mutate(
        sesType = as.factor( sesType ),
        sesYear = as.integer( sesYear ),
        sesDate = as.Date( sesDate, DATE_FRM ),
        trialCt = as.integer( trialCt )
    )

    message( "Processing documents" )
    data$div %<>% rm_dupes( divId ) %>% dplyr::mutate(
        divType = as.factor( divType ),
        divDate = as.Date( divDate, DATE_FRM ),
        divYear = as.integer( divYear ),
        clen    = as.integer( clen ),
        paraCt  = as.integer( paraCt )
    )

    message( "Processing joins and charges" )
    data$jon %<>% rm_dupes( tgtId, payId ) %>% dplyr::mutate(
        valid = as.logical( valid )
    )
    data$cha %<>% rm_dupes( defId, offId, verId ) %>% dplyr::mutate(
        valid = as.logical( valid )
    )

    message( "Processing entities" )
    for( k in setdiff( names( data ), c( 'ses', 'div', 'cha', 'jon' ) ) ) {
        s <- proc.time()
        data[[k]] %<>% rm_dupes( divId, entId )
        if( k == 'pla' ) {
            data[[k]] %<>% dplyr::mutate(
                plaType = as.factor( plaType )
            )    
        } else {
            data[[k]] %<>% dplyr::mutate(
                oboType = as.factor( oboType )
            )
        }
        if( k == 'per' ) {
            data[[k]] %<>% dplyr::mutate(
                given   = as.character( given ),
                surname = as.character( surname ),
                gender  = factor( gender, label=GEN_LVLS )
            )
        }
        if( k %in% c( 'off', 'pun', 'ver' ) ) {
            data[[k]] %<>% dplyr::mutate(
                cat    = as.factor( cat ),
                subcat = as.factor( subcat )
            )
        }
        if( k == 'off' ) {
            data[[k]] %<>% dplyr::mutate(
                kViolent = cat %in% c(
                    'kill',
                    'violentTheft'
                ) | subcat %in% c(
                    # violence
                    'assault',
                    'riot',
                    'threateningBehaviour',
                    'wounding',
                    # sexual
                    'assaultWithIntent',
                    'assaultWithSodomiticalIntent',
                    'indecentAssault',
                    'rape'
                )
            )
        }
        if( k == 'pun' ) {
            data[[k]] %<>% dplyr::mutate(
                kCorporal = cat %in% c(
                    'death',
                    'corporal'
                ) | subcat %in% c(
                    'branding',
                    'brandingOnCheek'
                )
            )
        }
        t <- proc.time() - s
        message( sprintf(
            "Processed %s in %.2f seconds: %7d dupes removed from %7d total obs (%4.2f%%)",
            k, t[3], ( d = sum( data[[k]]$collisions - 1 ) ), ( t = nrow( data[[k]] ) ), 
            ( d / t ) * 100
        ) )
    }
    ttime = proc.time() - tstart
    message( sprintf( "Duplicates removed. Total time: %.2f seconds.", ttime[3] ) )

    save( data, file=DATA_FILE )
}

na_level <- function( factor, na='noValue' ) {
    lvls <- c( levels( factor ), na )
    factor <- addNA( factor )
    levels( factor ) <- lvls
    return( factor )
}

df_table <- function( tbl, rn=names( dimnames( tbl ) )[1], fctr=TRUE ) {
    d <- list( dimnames( tbl )[[1]] ) %>% as.data.frame( stringsAsFactors=fctr )
    for( i in 1:dim( tbl )[2] ) {
        d <- cbind( d, tbl[ , i ] )
    }
    names( d ) <- c( names( dimnames( tbl ) )[1], dimnames( tbl )[[2]] )
    return( d %>% dtplyr::tbl_dt() )
}

gather_persons <- function() {
    data$per %>% dplyr::mutate(
        gender  = na_level( gender, na='indeterminate' ),
        oboType = na_level( oboType, na='noType' )
    ) %>%
    dplyr::select( entId, divId, gender, oboType ) %>%
    dplyr::left_join(
        data$cha %>%
        dplyr::select( entId = defId ) %>%
        dplyr::mutate( charge=TRUE ), by='entId' 
    ) %>%
    dplyr::left_join( 
        data$jon %>% 
        dplyr::filter( type=='offenceVictim' ) %>%
        dplyr::select( entId = payId ) %>%
        dplyr::mutate( victim=TRUE ), by='entId'
    ) %>% dplyr::mutate(
        charge = !is.na( charge ) | ( oboType == 'defendantName' ),
        victim = !is.na( victim ) | ( oboType == 'victimName'    & !charge )
    ) %>%
    return()
}

get_defs <- function( per ) {
    per %>%
    dplyr::filter( charge ) %>%
    dplyr::select( divId, gender ) %>%
    table %>% df_table() %>%
    dplyr::transmute(
        divId = divId,
        nDefGenM = male,
        nDefGenI = indeterminate,
        nDefGenF = female
    ) %>%
    return()
}

get_vics <- function( per ) {
    per %>% 
    dplyr::filter( victim ) %>%
    dplyr::select( divId, gender ) %>% 
    table %>% df_table( fctr=FALSE ) %>%
    dplyr::transmute(
        divId = divId,
        nVicGenM = male,
        nVicGenI = indeterminate,
        nVicGenF = female
    ) %>%
    return()
}

get_offs <- function() {
    data$off %>%
    dplyr::select( divId, cat ) %>%
    table %>% df_table( fctr=FALSE ) %>%
    left_join( 
        data$off %>%
        dplyr::select( divId, kViolent ) %>%
        dplyr::group_by( divId ) %>%
        dplyr::summarize( 
            nOff = n(),
            bViolent = any( kViolent ) 
        ), by='divId' 
    ) %>% 
    return()
}

get_puns <- function() {
    data$pun %>%
    dplyr::select( divId, cat ) %>%
    table %>% df_table( fctr=FALSE ) %>%
    dplyr::left_join(
        data$pun %>%
        dplyr::select( divId, kCorporal ) %>%
        dplyr::group_by( divId ) %>%
        dplyr::summarize(
            nPun = n(),
            bCorporal = any( kCorporal )
        ), by='divId'
    ) %>% 
    return()
}

get_trials <- function() {
    data$div %>%
    dplyr::filter( divType == 'trialAccount' ) %>%
    dplyr::select( divId, divYear, divDate, paraCt ) %>%
    return()
}

get_trial_motifs <- function() {
    per <- gather_persons()
    get_trials() %>%
    dplyr::left_join( get_defs( per ) %>% dplyr::mutate( bDef=TRUE ), by='divId' ) %>%
    dplyr::mutate( 
        bDef     = !is.na( bDef ),
        nDefGenM = ifelse( is.na( nDefGenM ), 0L, nDefGenM ),
        nDefGenF = ifelse( is.na( nDefGenF ), 0L, nDefGenF ),
        nDefGenI = ifelse( is.na( nDefGenI ), 0L, nDefGenI ),
        nDef     = nDefGenM + nDefGenI + nDefGenF,
        bGrpDef  = nDef > 1,
        bFemDef  = nDefGenF > 0
    ) %>%    
    dplyr::left_join( get_vics( per ) %>% dplyr::mutate( bVic=TRUE ), by='divId' ) %>%
    dplyr::mutate(
        bVic     = !is.na( bVic ),
        nVicGenM = ifelse( is.na( nVicGenM ), 0L, nVicGenM ),
        nVicGenF = ifelse( is.na( nVicGenF ), 0L, nVicGenF ),
        nVicGenI = ifelse( is.na( nVicGenI ), 0L, nVicGenI ),
        nVic     = nVicGenM + nVicGenI + nVicGenF,
        bGrpVic  = nVic > 1,
        bFemVic  = nVicGenF > 0
    ) %>%
    dplyr::mutate(
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
    dplyr::mutate(
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
    dplyr::mutate(
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

if( !file.exists( DATA_FILE ) ) make_data()
message( sprintf( "Loading tabular data from %s", DATA_FILE ) )
load( DATA_FILE )
