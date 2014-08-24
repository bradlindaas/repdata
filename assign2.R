## Analysis Script
## for Reproducible Research (repdata-005): Class Project 2
## August 23, 2014

library(lubridate)
library(plyr)

dataDir <- "/home/rstudio/largedata/"
dataFileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"

if (!file.exists(paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""))) {
    download.file(dataFileURL, destfile = paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""), method="curl")
}

data <- read.csv(paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""))

