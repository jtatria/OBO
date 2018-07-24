source( '../inc/obo_tables.R' )

death <- data$jon %>%
    dplyr::filter( type == 'defendantPunishment' ) %>%
    dplyr::select( 
        defId = tgtId,
        punId = payId
    ) %>%
    dplyr::left_join( 
        data$pun %>%
        dplyr::select( punId=entId, cat, punDiv=divId ) 
    ) %>% 
    dplyr::filter( cat == 'death' ) %>%
    dplyr::left_join( 
        data$per %>%
        dplyr::select( defId = entId, age, perDiv=divId ) 
    ) %>% 
    dplyr::filter( !is.na( age ) ) %>%
    dplyr::left_join(
        data$div %>%
        dplyr::select( perDiv=divId, paraCt ) 
    )

death$age_num <- as.integer( death$age )
death$age_num[ death$age == "13 Years"                                ] <- 13
death$age_num[ death$age == "17 years of age"                         ] <- 17
death$age_num[ death$age == "eighteen"                                ] <- 18
death$age_num[ death$age == "eleven years old and six months"         ] <- 11
death$age_num[ death$age == "fifteen"                                 ] <- 15
death$age_num[ death$age == "Forty"                                   ] <- 40
death$age_num[ death$age == "fourteen"                                ] <- 14
death$age_num[ death$age == "fourteen or fifteen years of age"        ] <- 15
death$age_num[ death$age == "nineteen"                                ] <- 19
death$age_num[ death$age == "Nineteen"                                ] <- 19
death$age_num[ death$age == "not 12 years old"                        ] <- 11
death$age_num[ death$age == "seventeen"                               ] <- 17
death$age_num[ death$age == "Seventeen"                               ] <- 17
death$age_num[ death$age == "seventeen years"                         ] <- 17
death$age_num[ death$age == "seventeen years of age"                  ] <- 17
death$age_num[ death$age == "seventeen years old"                     ] <- 17
death$age_num[ death$age == "sixteen"                                 ] <- 16
death$age_num[ death$age == "Sixteen"                                 ] <- 16
death$age_num[ death$age == "sixty"                                   ] <- 60
death$age_num[ death$age == "something more than twenty years of age" ] <- 20
death$age_num[ death$age == "ten"                                     ] <- 10
death$age_num[ death$age == "Ten next February"                       ] <- 10
death$age_num[ death$age == "thirteen"                                ] <- 13
death$age_num[ death$age == "twelve"                                  ] <- 12
death$age_num[ death$age == "twenty"                                  ] <- 20
death$age_num[ death$age == "twenty one"                              ] <- 21
death$age_num[ death$age == "twenty years"                            ] <- 20
death$age_num[ death$age == "twenty-four"                             ] <- 24
death$age_num[ death$age == "twenty-seven or twenty-eight"            ] <- 27
death$age_num[ death$age == "twenty-three"                            ] <- 23
death$age_num[ death$age == "twenty-two"                              ] <- 22

