library(plyr)
library(RSQLite)
results <- read.table('current_standings.txt', sep = ' ', colClasses = "character", header = T)
names(results) <- c('school', 'conf', 'overall')
results$confwins <- as.numeric(sapply(strsplit(results[, 2], "-"), "[[", 1))
results$confloss <- as.numeric(sapply(strsplit(results[, 2], "-"), "[[", 2))
results$school <- gsub("^\\s*\\d* ", "", results$school)

all.teams <- read.csv("all_teamsclean.txt", header = F, colClasses = "character",
                      strip.white = T)
names(all.teams) <- c("conference", "school", "picker")
merged <- merge(all.teams, results)
merged$confpercent <- merged$confwins/(merged$confwins + merged$confloss)
conferences <- unique(all.teams$conference)
final <- c()

for(i in conferences){
  temp <- merged[merged$conference == i, ]
  temp2 <- temp[order(temp$confpercent, decreasing = T), ]
  vals <- seq(25, 1, by = -2)
  points <- seq(25, -5, by = -2)
  points <- points[1:nrow(temp2)]
  ranks <- 1:length(points)
  scoretables <- data.frame(ranks, points, temp$confpercent)
  k <- rank(-scoretables[, 3], ties = "min")
  scorefinal <- merge(k, scoretables, by.x=1, by.y=1)
  temp2$points <- scorefinal$points
  temp2 <- temp2[order(temp2$points, decreasing = T), ]
  temp2$confpercent <- signif(as.numeric(temp2$confpercent, 2))
  final <- rbind(final,temp2)
}

scores <- ddply(final, 'picker', function(x) data.frame(score = sum(as.numeric(x$points))))
standings <- scores[order(scores$score, decreasing = T), ]
print.data.frame(standings, row.names=F)
standings <- standings[standings$picker != "", ]

conn <- dbConnect(SQLite(), dbname="site/ncaaff.db")
dbSendQuery(conn, "DROP table if exists standings;")
dbWriteTable(conn, "standings", standings)
dbSendQuery(conn, "DROP table if exists allconf;")
dbWriteTable(conn, "allconf", final)
dbDisconnect(conn)

#read in file for D3 plot
d3raw <- read.csv("site/static/points_by_week.csv")
standings <- standings[order(standings$picker, decreasing=F), ]
current <- c('Y2013', Sys.Date(), 'score', standings$score)
d3raw <- rbind(d3raw,current)
write.csv(d3raw, "site/static/points_by_week.csv", row.names=F, quote=F)
