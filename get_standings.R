#get standings
library(XML)
library(stringr)
library(RSQLite)

atc <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A001")
atclean <- as.data.frame(atc[3])
atclean <- atclean[, c(1,2,7)]
atclean <- atclean[c(4:10, 14:20), ]
names(atclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

big12 <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A071")
big12clean <- as.data.frame(big12[3])
big12clean <- big12clean[, c(1,2,7)]
big12clean <- big12clean[c(3:12), ]
names(big12clean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

amer <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A122")
amerclean <- as.data.frame(amer[3])
amerclean <- amerclean[, c(1,2,7)]
amerclean <- amerclean[c(3:12), ]
names(amerclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

bigten <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A004")
bigtenclean <- as.data.frame(bigten[3])
bigtenclean <- bigtenclean[, c(1,2,7)]
bigtenclean <- bigtenclean[c(4:9, 13:18), ]
names(bigtenclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

cusa <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A072")
cusaclean <- as.data.frame(cusa[3])
cusaclean <- cusaclean[, c(1,2,7)]
cusaclean <- cusaclean[c(4:10, 14:20), ]
names(cusaclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

mac <- readHTMLTable(doc= "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A006")
macclean <- as.data.frame(mac[3])
macclean <- macclean[, c(1,2,7)]
macclean <- macclean[c(4:10, 14:19), ]
names(macclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

mwc <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A087")
mwcclean <- as.data.frame(mwc[3])
mwcclean <- mwcclean[, c(1,2,7)]
mwcclean <- mwcclean[c(4:9, 13:18), ]
names(mwcclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

pac12 <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A007")
pac12clean <- as.data.frame(pac12[3])
pac12clean <- pac12clean[, c(1,2,7)]
pac12clean <- pac12clean[c(4:9, 13:18), ]
names(pac12clean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

sec <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A008")
secclean <- as.data.frame(sec[3])
secclean <- secclean[, c(1,2,7)]
secclean <- secclean[c(4:10, 14:20), ]
names(secclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

sun <- readHTMLTable(doc = "http://scores.nbcsports.msnbc.com/cfb/standings.asp?conf=1a%3A090")
sunclean <- as.data.frame(sun[3])
sunclean <- sunclean[, c(1,2,7)]
sunclean <- sunclean[c(3:10), ]
names(sunclean) <- c("Team", "Conference", "Overall")
Sys.sleep(5)

final <- rbind(atclean, big12clean, amerclean, bigtenclean, cusaclean, macclean, mwcclean, pac12clean, secclean, sunclean)
final$Team <- str_replace_all(final$Team, "[[:digit:]]", "")
trim.leading <- function (x)  sub("^\\s+", "", x)
final$Team <- trim.leading(final$Team)

conn <- dbConnect(SQLite(), dbname="site/ncaaff.db")
dbSendQuery(conn, "DROP table if exists raw_conference")
dbWriteTable(conn, "raw_conference", final)
dbDisconnect(conn)
write.table(final, "current_standings.txt", row.names = F)
