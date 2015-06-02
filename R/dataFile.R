# Add data file to app
library(data.table)
setwd("C:/Users/Grant/Google3/Google Drive/R/Projects/PVanalytics/data")
load("solar_ghi_2013.RData")
solar_ghi_2013[,DATETIME2 := DATETIME]
solar_ghi_2013.2 = data.table(LAT = solar_ghi_2013[,LAT], DATETIME.UTC = solar_ghi_2013[,DATETIME], DATETIME.NSW = solar_ghi_2013[,DATETIME], POA = solar_ghi_2013[,LON142.025] )
#solar_ghi_2013$DATETIME2 <- solar_ghi_2013$DATETIME
attr(solar_ghi_2013.2$DATETIME.NSW,"tzone") <- "Australia/Sydney"

setkey(solar_ghi_2013.2, LAT)
haskey(solar_ghi_2013.2)

tables()

lookUpDate.1 <- as.POSIXct("2013-06-24 06:00:00", format = "%Y-%m-%d %H:%M:%S")
lookUpDate.2 <- as.POSIXct("2013-06-24 19:00:00", format = "%Y-%m-%d %H:%M:%S")


solarData <- solar_ghi_2013.2[(solar_ghi_2013$LAT == -37.275), ]

solarData.1 <- solarData[(solarData$DATETIME.UTC >= lookUpDate.1 & solarData$DATETIME.UTC <= lookUpDate.2),]


# Graph the intra-day profile
library(ggplot2)
qplot(DATETIME.NSW, POA, data = solarData.1, geom = c("point", "smooth"))

ggplot(data=solarData.1,aes(x=DATETIME.NSW, y=POA)) + 
  geom_smooth(colour="red") + 
  ylab("Solar radiation") + 
  xlab("Time") + 
#  scale_x_datetime(limits=c((timestamp()), (timestamp()))) +
  ggtitle("Solar radiation for Sydney") 
