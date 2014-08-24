# An Analysis of the Impact of Weather Events in the US

This report is intended to be used by FEMA as it prepares for the annual strategic plan. While weather by its nature an unplanned event, we can certainly plan for the liklihood of a range of weather events occuring. There are many adverse impacts from weather that can require a response from the US Federal Government (specifically, FEMA). This document will serve to document the types of events that have the largest impact on human health and economic activity, and ensure FEMA gives these events the appropraite priority in planning.

## Synopsis
No more than 10 sent.


## Data Processing
This report explores the NOAA Storm Database to reach its conclusions. The background on the data can be [found online.](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf) The events in the database start in the year 1950 and end in November 2011. In the earlier years of the database there are generally fewer events recorded, most likely due to a lack of good records. More recent years should be considered more complete.

The first step in analysis is to load the data.


```r
library(plyr)
dataDir <- "/home/rstudio/largedata/"
dataFileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!file.exists(paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""))) {
    download.file(dataFileURL, destfile = paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""), method="curl")
}
data <- read.csv(bzfile(paste(dataDir, "repdata-data-StormData.csv.bz2", sep="")), nrows=10000)
```

For this analysis, we want to answer two data questions:

1. Across the United States, which types of events (as indicated in the `EVTYPE` variable) are most harmful with respect to population health?

2. Across the United States, which types of events have the greatest economic consequences?

This is a fairly large dataset with 10000 observations and 37 variables. Since we are going to focus attention on variables in the data that can help us answer those two questions above, let's remove unneeded variables. 

The nature of the data questions allow us to make some simplyfying changes to the data

* The questions do not require us to answer how health or economic impacts change over time, so we can ignore date and time information. We will look at total impact for all dates in the set
* The questions do not require us to answer how health or economic impacts change by geography, so we can ignore state and geo code information and look at all locations.
* The questions require us only to look at type (`EVTYPE`) and health impacts (injuries and fatalities) and economic impacts (crop and property damage)

Based on this, we subset the data to reduce the number of variables down to the ones needed to analysis


```r
interestingVars <- c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP",  "CROPDMG", "CROPDMGEXP")
data <- data[interestingVars]
```

Now we have reduced the number of varibales to 7 which will help us manage the analysis. 

Moving to the `EVTYPE` variable, we see there is a large number (3) of types. Likely there is need to clean this up. Right away, we see there is punctuation and other noise in the types, so we will remove punctuation and format all the values in lower case to make it easier to use.


```r
data$EVTYPE <- gsub("[[:blank:][:punct:]+]", " ", tolower(data$EVTYPE))
```

Doing that reduced the number of unique types to 3.

Last, we see there are a significant number of types that need to consolidated into a single type. Please see the following consolidation chart

Type Content | Consolidates into
--- | ---
contains blizzard | blizzard
contains tornado | tornado
starts with bitter wind chill | bitter wind chill
starts with dry microburst | dry mircoburst
starts with flash flood | flash flood
starts with hail | hail
starts with heavy snow | heavy snow
starts with high wind | high wind
starts with hurricane | hurricane
starts with heavy rain | heavy rain
starts with ice | ice
starts with landslide | landslide
starts with lightning | lightning
starts with thunderstorm wind | thunderstorm wind
starts with tstm | thunderstorm wind
starts with summary | summary

Running the code to consolidate using this table will reduce duplicates:


```r
data$EVTYPE[grep("tornado", data$EVTYPE)] <- c("tornado")
data$EVTYPE[grep("blizzard", data$EVTYPE)] <- c("blizzard")
data$EVTYPE[grep("^bitter wind chill", data$EVTYPE)] <- c("bitter wind chill")
data$EVTYPE[grep("^dry microburst", data$EVTYPE)] <- c("dry microburst")
data$EVTYPE[grep("^flash flood", data$EVTYPE)] <- c("flash flood")
data$EVTYPE[grep("^hail", data$EVTYPE)] <- c("hail")
data$EVTYPE[grep("^heavy snow", data$EVTYPE)] <- c("heavy snow")
data$EVTYPE[grep("^high wind", data$EVTYPE)] <- c("high wind")
data$EVTYPE[grep("^hurricane", data$EVTYPE)] <- c("hurricane")
data$EVTYPE[grep("^heavy rain", data$EVTYPE)] <- c("heavy rain")
data$EVTYPE[grep("^ice", data$EVTYPE)] <- c("ice")
data$EVTYPE[grep("^landslide", data$EVTYPE)] <- c("landslide")
data$EVTYPE[grep("^lightning", data$EVTYPE)] <- c("lightning")
data$EVTYPE[grep("^thunderstorm wind", data$EVTYPE)] <- c("thunderstorm wind")
data$EVTYPE[grep("^tstm", data$EVTYPE)] <- c("thunderstorm wind")
data$EVTYPE[grep("^summary", data$EVTYPE)] <- c("summary")
```

Doing that reduced the number of unique types to 3. There may be additional opportunity to consolidate these types if other researchers wish to review the remaining types for redundancy.

The last bit of data processing is to create some aggregate data frames to show health and economic impacts.

### Health Impact

For health impact, we are looking at the total number of fatalities and the total number of injuries for each weather event type. This will show a fairly direct impact to health of the US population. 


```r
health <- ddply(data, .(EVTYPE), summarize, fatalities = sum(FATALITIES),injuries = sum(INJURIES))
```

To see if this data makes sense, we found that the tornado type had the highest fatalities with a total of 518. Likewise the tornado type had the highest injuries with a total of 7781.

### Economic Impact
For economic impact, we are looking at the total dollar value of damage done to crops and the total dollar value of damage done to property for each weather type. This will show a fairly direct impact to economic activity in the US.


## Results
There should be a section titled Results in which your results are presented.

The analysis document must have at least one figure containing a plot.

Your analyis must have no more than three figures. Figures may have multiple plots in them (i.e. panel plots), but there cannot be more than three figures total.
