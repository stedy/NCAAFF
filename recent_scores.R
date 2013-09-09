#get schedules/results from NBC

library(XML)
library(stringr)
nbc <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/scoreboard.asp?week=1&conf=-1")
gamedays <- seq(from=as.Date("08/31/13", "%m/%d/%y"), length=15, by="1 week")

results <- c()

for(i in 1:length(nbc)){
  event <- nbc[i][[1]]
  event <- data.frame(lapply(event, as.character), stringsAsFactors=FALSE)
  if(names(event)[1] == "Final"){
  results <- rbind(results, c(event$Final, event$T))
  }
}

current.week <- data.frame(results)
current.week.df <- data.frame(lapply(current.week, 
                                     as.character), stringsAsFactors=FALSE)
names(current.week.df) <- c("away", "home", "score1", "score2")
current.week.df$away <- str_replace_all(current.week.df$away, "[[:digit:]]", "")
current.week.df$home <- str_replace_all(current.week.df$home, "[[:digit:]]", "")

trim.leading <- function (x)  sub("^\\s+", "", x)
current.week.df$away <- trim.leading(current.week.df$away)
current.week.df$home <- trim.leading(current.week.df$home)

current.week <- which(gamedays == Sys.Date())
current.week.df$date <- gamedays[current.week]
write.csv(current.week.df, paste0("archive/week", current.week, 
                                  ".csv"), row.names = F, quote = F)
