require( dplyr )
require( alluvial )

tit <- as.data.frame(Titanic, stringsAsFactors = FALSE)
head(tit)

alluvial(tit[,1:4], freq=tit$Freq,
         col = ifelse(tit$Survived == "Yes", "orange", "grey"),
         border = ifelse(tit$Survived == "Yes", "orange", "grey"),
         hide = tit$Freq == 0,
         cex = 0.7
)

tit %>% group_by(Class, Survived) %>%
  summarise(n = sum(Freq)) -> tit2d

alluvial(tit2d[,1:2], freq=tit2d$n)

tit %>% group_by(Sex, Class, Survived) %>%
  summarise(n = sum(Freq)) -> tit3d

alluvial(tit3d[,1:3], freq=tit3d$n)

alluvial(
  tit3d[,1:3], 
  freq=tit3d$n,
  col = ifelse( tit3d$Sex == "Female", "pink", "lightskyblue"),
  border = "grey",
  alpha = 0.7,
  blocks=FALSE
)

alluvial(tit2d[,1:2], freq=tit2d$n, hide=tit2d$n < 150)

d <- data.frame(
  x = c(1, 2, 3),
  y = c(3 ,2, 1),
  freq=c(1,1,1)
)
alluvial(d[,1:2], freq=d$freq, col=1:3, alpha=1)
# Reversing the order
alluvial(d[ 3:1, 1:2 ], freq=d$freq, col=3:1, alpha=1)

alluvial(tit3d[,1:3], freq=tit3d$n, 
         col = ifelse( tit3d$Survived == "Yes", "orange", "grey" ),
         alpha = 0.8,
         layer = tit3d$Survived == "No"
)


tit %>% group_by(Sex, Age, Survived) %>%
  summarise( n= sum(Freq)) -> x

tit %>% group_by(Survived, Age, Sex) %>%
  summarise( n= sum(Freq)) -> y

alluvial(x[,1:3], freq=x$n, 
         col = ifelse(x$Sex == "Male", "orange", "grey"),
         alpha = 0.8,
         blocks=FALSE
)

alluvial(y[,1:3], freq=y$n, 
         # col = RColorBrewer::brewer.pal(8, "Set1"),
         col = ifelse(y$Sex == "Male", "orange", "grey"),
         alpha = 0.8,
         blocks = FALSE,
         ordering = list(
           order(y$Survived, y$Sex == "Male"),
           order(y$Age, y$Sex == "Male"),
           NULL
         )
)

pal <- c("red4", "lightskyblue4", "red", "lightskyblue")

tit %>%
  mutate(
    ss = paste(Survived, Sex),
    k = pal[ match(ss, sort(unique(ss))) ]
  ) -> tit


alluvial(tit[,c(4,2,3)], freq=tit$Freq,
         hide = tit$Freq < 10,
         col = tit$k,
         border = tit$k,
         blocks=FALSE,
         ordering = list(
           NULL,
           NULL,
           order(tit$Age, tit$Sex )

         )
)

