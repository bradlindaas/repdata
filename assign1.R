## Analysis Script
## for Reproducible Research (repdata-005): Class Project 1
## August 17, 2014

library(lubridate)
library(plyr)

## This is my working directory
## Simply change the dataDir variable to wherever your data is located and this script will process fine
## note: these path notations assume you run R in a UNIX environment. Adjust as needed
dataDir <- "/home/rstudio/largedata/"
dataFileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"

if (!file.exists(paste(dataDir, "activity.csv", sep=""))) {
    download.file(dataFileURL, destfile = paste(dataDir, "repdata-data-activity.zip", sep=""), method="curl")
    unzip(paste(dataDir, "repdata-data-activity.zip", sep=""), exdir=dataDir)
}

activity <- read.csv(paste(dataDir, "activity.csv", sep=""))
activity$date <- ymd(activity$date)
data <- ddply(activity, c("day"), summarize, sum=sum(steps))