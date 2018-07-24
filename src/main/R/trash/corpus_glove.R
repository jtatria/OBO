require( wordVectors )
require( dplyr )

source( 'funcs.R' )

# filesystem constants
lx_base  <- "/home/data/obo/glove/models/model_parts"
lx_file  <- "vocab.txt"
vs_base  <- "/home/gorgonzola/data/obo/glove/models/marks_npunct_i25"
vs_file  <- "word2vec.txt"
pos_file <- "/home/gorgonzola/data/obo/lemmaPosTable.csv"

# read global lx
g_lx <- read.table( paste( lx_base, 'global', lx_file, sep = '/' ), quote = '', comment.char =  '', sep = ' ' )
names( g_lx ) <- c( 'term', 'global' )

# read partial lxs
p_lx <- lapply( grep( "part_", list.dirs( lx_base ), value = TRUE ), function( p ) {
  l = read.table( paste( p, lx_file, sep = '/' ), quote = '', comment.char = '', sep = ' ' )
  names( l ) <- c( 'term', gsub( ".*/part_", "p", p ) )
  l
} )
names( p_lx ) <- gsub( ".*/part_", "p", grep( "part_", list.dirs( lx_base ), value = TRUE ) )

# add partial lxs to global lx
for( p in p_lx  ) {
  g_lx <- merge( g_lx, p, all.x = TRUE )
}
rm( p )

# NAs are 0
g_lx[ is.na( g_lx ) ] <- 0L

# compute summaries for partial lxs in glx
g_lx$max_all <- apply( g_lx[ , grep( 'p', names( g_lx ) ) ], 1, max  )
g_lx$min_all <- apply( g_lx[ , grep( 'p', names( g_lx ) ) ], 1, min  )
g_lx$min_gt0 <- apply( g_lx[ , grep( 'p', names( g_lx ) ) ], 1, function( x ) {
  ifelse( length( x[ x > 0 ] ) > 0, min( x[ x > 0 ] ), 0 )
} )
g_lx$full    <- apply( g_lx[ , grep( 'p', names( g_lx ) ) ], 1, function( x ) { all( x > 0 ) } )

# read POS data
pos_data <- read.table( pos_file, header = TRUE, sep = "@", quote = "", comment.char = "" )
# NAs are 0
pos_data[ is.na( pos_data ) ] <- 0
# rename id column
names( pos_data )[1] <- 'term'
# lexical sort of POS tag columns
pos_data <- pos_data[ , c( 'term', sort( names( pos_data )[ -1 ] ) ) ]
# extract POS classes from POS tag prefixes
pos_classes <- unique( gsub( "_.*", "", names( pos_data )[ -1 ] ) )
# add total, just in case it comes in handy
pos_data$pos_total <- apply( pos_data[, -1], 1, sum )

# group pos counts in classes. this is where the whole 'data frame' thingy starts to suck.
for( pos in pos_classes ) {
  filter <- grep( paste( "^", pos, sep = "" ), names( pos_data ) )
  if( length( filter ) > 1 ) { # really?!? what happened with 'everything is a vector'
    pos_data[ , pos ] <- apply( pos_data[ , filter ], 1, sum )
  } else {
    pos_data[ , pos ] <- pos_data[ , filter ]
  }
  # pos_data[ , pos ] <- as.matrix( pos_data ) %>% apply( 1, sum ) ?
}
rm( )
# drop tags, retain classes
pos_data <- pos_data[, grep( "_", names( pos_data ), invert = TRUE ) ]

# merge POS data to global lexicon
g_lx <- merge( g_lx, pos_data, all.x = TRUE, all.y = FALSE )

# compute max pos class
g_lx[ , pos_classes ] %>% apply( 1, function( x ) {
  maxPOS = pos_classes[ which( x == max( x ) ) ]
  ifelse( length( maxPOS ) == 0, NA, maxPOS )
} ) %>% unlist() %>% as.factor() -> g_lx$max_POS

# sort global lexicon in descending frequency order
g_lx <- g_lx[ order( -g_lx$global ), ]

# load global vector space
g_vs <- read.vectors( paste( vs_base, 'global', vs_file, sep = "/" ) )

# load partial vector spaces
p_vs <- lapply( grep( "part_", list.dirs( vs_base ), value = TRUE ), function( x ) {
  read.vectors( paste( x, vs_file, sep = "/" ) )
} )
names( p_vs ) <- gsub( '.*/part_', 'p', grep( "part_", list.dirs( vs_base ), value = TRUE ) )

