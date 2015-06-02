# Objective: Extract one day of solar radiation data given the post code and date

library(data.table)

# Step 1: load the solar data for 2013 and the spatial coordinates for the post codes
setwd("C:/Users/Grant/Google3/Google Drive/R/Projects/PVanalytics/data")
load("solar_ghi_2013.RData")
load("LatLongNSW.RData")

# Step 2: Convert the post code data frame to a data table
POA.Index = data.table(LatLongNSW)
POA.Index$LAT <- NA # Latitude column with values that match the LAT values in solar_ghi_2013
POA.Index$LON <- NA # Longitude column with values that match the LON values in solar_ghi_2013

# Step 3: Extract the vector of longitudes in the solar_ghi_2013 data set
solar_ghi_2013.Names <- names(solar_ghi_2013)
solar_ghi_2013.Names <- solar_ghi_2013.Names[3:length(solar_ghi_2013.Names)]
solar_ghi_2013.Longitude <- as.numeric(substr(solar_ghi_2013.Names, 4, 10))

# Record the closest location match contained in solar_ghi_2013 data set
for (i in 1:length(POA.Index$LAT)){
    # Extract the latitude for the first location in LatLongNSW data set
    latitude <- POA.Index$Latitude[i]
    longitude <- POA.Index$Longitude[i]
    
    # Select the rows that most closely matches the post code latitude
    latitude.match <- solar_ghi_2013[which(abs(solar_ghi_2013$LAT-latitude)==min(abs(solar_ghi_2013$LAT-latitude))), LAT][1]
    
    # Select the column that most closely matches the post code longitude
    longitude.match <- solar_ghi_2013.Longitude[which(abs(solar_ghi_2013.Longitude-longitude)==min(abs(solar_ghi_2013.Longitude-longitude)))] 
    
    # Save the matched latitude and longitude in the LatLongNSW data set
    
    POA.Index$LAT[i] <- latitude.match
    POA.Index$LON[i] <- longitude.match
}

setkey(POA.Index, LAT)
save(POA.Index, file = "POA_INDEX.RData")

# Change UTC time to Sydney local time
attr(solar_ghi_2013$DATETIME,"tzone") <- "Australia/Sydney"

# Look up and extract data for a given date and location
lookUpDate.1 <- as.POSIXct("2013-06-24 06:00:00", format = "%Y-%m-%d %H:%M:%S")
lookUpDate.2 <- as.POSIXct("2013-06-24 19:00:00", format = "%Y-%m-%d %H:%M:%S")
lookUpLat <- POA.Index[(POA == 2551), LAT]
lookUpLon <- paste0("LON", POA.Index[POA == 2551, LON])
lookUpCols <- c("DATETIME", lookUpLon)
solarData <- solar_ghi_2013[(LAT == lookUpLat & DATETIME >= lookUpDate.1 & DATETIME <= lookUpDate.2), lookUpCols, with = F]
setnames(solarData, lookUpLon, "SolarRad")
solarData[is.na(SolarRad)] <- 0

# Create a function to easily extract desired profiles
SolarProfile <- function(Date, POA.CODE){
  lookUpDate.1 <- as.POSIXct(paste0(Date, " 06:00:00"), format = "%Y-%m-%d %H:%M:%S")
  lookUpDate.2 <- as.POSIXct(paste0(Date, " 19:00:00"), format = "%Y-%m-%d %H:%M:%S")
  lookUpLat <- POA.Index[(POA == POA.CODE), LAT]
  lookUpLon <- paste0("LON", POA.Index[POA == POA.CODE, LON])
  lookUpCols <- c("DATETIME", lookUpLon)
  solarData <- solar_ghi_2013[(LAT == lookUpLat & DATETIME >= lookUpDate.1 & DATETIME <= lookUpDate.2), lookUpCols, with = F]
  setnames(solarData, lookUpLon, "SolarRad")
  solarData[is.na(SolarRad)] <- 0
  return(solarData)
}

# Extract data relating to a single day in a specific post code
Solar.Data <- SolarProfile("2013-06-24", 2551)
