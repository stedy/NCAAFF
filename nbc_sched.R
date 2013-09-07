#get schedules/results from NBC

library(XML)
library(stringr)
nbc <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/scoreboard.asp?week=1&conf=-1")
seqs <- seq(from=4, to=length(nbc), by=3)
gamedays <- seq(from=as.Date("08/31/13", "%m/%d/%y"), length=15, by="1 week")

results <- c()

for(i in 1:length(nbc)){
  event <- nbc[i][[1]]
  event <- data.frame(lapply(event, as.character), stringsAsFactors=FALSE)
  if(names(event)[1] == "Final"){
  results <- rbind(results, c(event$Final, event$T))
  }
}

week1 <- data.frame(results)
week1.df <- data.frame(lapply(week1, as.character), stringsAsFactors=FALSE)
names(week1.df) <- c("away", "home", "score1", "score2")
week1.df$away <- str_replace_all(week1.df$away, "[[:digit:]]", "")
week1.df$home <- str_replace_all(week1.df$home, "[[:digit:]]", "")

trim.leading <- function (x)  sub("^\\s+", "", x)
week1.df$away <- trim.leading(week1.df$away)
week1.df$home <- trim.leading(week1.df$home)

week1.df$date <- gamedays[1]
write.csv(week1.df, "archive/week1.csv", row.names = F, quote = F)
