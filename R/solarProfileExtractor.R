# Objective: Extract solar data for any post code and any date between 1 January 1990 and
#            31 December 2013


# Create a function to easily extract the desired daily solar radiation profiles
SolarProfile <- function(Date, POA.CODE){
  library(data.table)
  # Date <- "2013-06-24"; POA.CODE <- 2551
  Date.1 <- as.POSIXlt(Date, format = "%Y-%m-%d")
  year <- Date.1$year + 1900
  file <- paste0("solar_ghi_", year, ".RData")
  directoryPath <- file.path("C:/Users/Grant/Google3/Google Drive/R/Projects/NSWelec/data/Solar")
  filePath <- file.path(directoryPath, file)
  directoryPath.2 <- file.path("C:/Users/Grant/Google3/Google Drive/R/Projects/PVanalytics/data")
  
  filePath.2 <- file.path(directoryPath.2, "POA_Index.RData")
  if(!exists(paste0("POA.Index"))){
    load(filePath.2)
  }  
  if(!exists(paste0("solar_ghi_", year))){
    load(filePath)
  }  
  lookUpDate.1 <- as.POSIXct(paste0(Date, " 06:00:00"), format = "%Y-%m-%d %H:%M:%S")
  lookUpDate.2 <- as.POSIXct(paste0(Date, " 19:00:00"), format = "%Y-%m-%d %H:%M:%S")
  lookUpLat <- POA.Index[(POA == POA.CODE), LAT]
  lookUpLon <- paste0("LON", POA.Index[POA == POA.CODE, LON])
  lookUpCols <- c("DATETIME", lookUpLon)
  solarData <- solar_ghi_2013[(LAT == lookUpLat & DATETIME >= lookUpDate.1 & DATETIME <= lookUpDate.2), lookUpCols, with = F]
  setnames(solarData, lookUpLon, "SolarRad")
  solarData[is.na(SolarRad), 2] <- 0
  return(solarData)
}

# Extract data relating to a single day in a specific post code
Solar.Data <- SolarProfile("2013-06-24", 2551)








# Tests:
# Date.1 <- as.POSIXlt("2012-06-24", format = "%Y-%m-%d") 
# year <- Date.1$year + 1900
# 
# file <- paste0("solar_ghi_", year, ".RData")
# filePath <- file.path("C:/Users/Grant/Google3/Google Drive/R/Projects/NSWelec/data/Solar", file)
# 
# if(!exists(paste0("solar_ghi_", year))){
#   load(filePath)
#   }
# 
# years <- seq(from = 1990, to = 2013, by = 1)
# which(years %in% 2013)


