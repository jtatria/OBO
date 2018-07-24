#!/usr/bin/Rscript

require( xtable )

source( 'inc/obo_util.R',   chdir=TRUE, local=( if( exists( 'ut' ) ) ut else ( ut <- new.env() ) ) )
source( 'inc/obo_graphs.R', chdir=TRUE, local=( if( exists( 'gr' ) ) gr else ( gr <- new.env() ) ) )

PROJ_NAME <- "c3_crouch"

source( sprintf( '%s_data.R', PROJ_NAME ) )

ppmi$G %<>% gr$add_contrib_scores( ppmi$K$membership )
ppmi_sigs <- gr$make_sigs( ppmi$G )
xtable( 
    data.frame( Signature=ppmi_sigs ), align=c( 'p{1cm}', 'p{5cm}' ),
    caption='Cluster identification for the direct cooccurence network of the trial of Arthur Crouch',
    label=sprintf( '%s_ppmi_sig', PROJ_NAME )
) %>%
     print( file=file.path( ut$DIR_TABLE, sprintf( '%s_ppmi_sig.tex', PROJ_NAME ) ) )

difw$G %<>% gr$add_contrib_scores( difw$K$membership )
difw_sigs <- gr$make_sigs( difw$G )
xtable( data.frame( Signature=difw_sigs ), align=c( 'p{1cm}', 'p{5cm}' ),
    caption='Cluster identification for the diff. weighted network of the trial of Arthur Crouch',
    label=sprintf( '%s_difw_sig', PROJ_NAME )
) %>%
     print( file=file.path( ut$DIR_TABLE, sprintf( '%s_difw_sig.tex', PROJ_NAME ) ) )
