# An Analysis of the Impact of Weather Events in the US

This report is intended to be used by FEMA as it prepares for the annual strategic plan. While weather by its nature an unplanned event, we can certainly plan for the likelihood of a range of weather events occurring. There are many adverse impacts from weather that can require a response from the US Federal Government (specifically, FEMA). This document will serve to document the types of events that have the largest impact on human health and economic activity, and ensure FEMA gives these events the appropriate priority in planning.

## Synopsis
Since 1950, NOAA has been collecting information on the impact of adverse weather in the United States and territories. This data can be used to ensure activities and preparation is aligned to the most likely need. Weather is unpredictable, but we know it can impact the United States and our citizens in two difficult ways: casualties (fatalities and injuries) and economic loss (crop damage and property damage). FEMA should have specific plans in place for response and (potentially) mitigation of the top weather events that contribute to those adverse effects of weather. 

The analysis will show that from a health standpoint, tornados create the most casualties in the United States. From an economic standpoint, drought is the largest economically damaging weather for crops, and flooding is the cause of most economic damage for property.

## Data Processing
This report explores the NOAA Storm Database to reach its conclusions. The background on the data can be [found online.](https://d396qusza40orc.cloudfront.net/repdata%2Fpeer2_doc%2Fpd01016005curr.pdf) The events in the database start in the year 1950 and end in November 2011. In the earlier years of the database there are generally fewer events recorded, most likely due to a lack of good records. More recent years should be considered more complete.

The first step in analysis is to load the data.


```r
library(plyr)
library(ggplot2)
library(gridExtra)
```

```
## Loading required package: grid
```

```r
dataDir <- "/home/rstudio/largedata/"
dataFileURL <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!file.exists(paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""))) {
    download.file(dataFileURL, destfile = paste(dataDir, "repdata-data-StormData.csv.bz2", sep=""), method="curl")
}
data <- read.csv(bzfile(paste(dataDir, "repdata-data-StormData.csv.bz2", sep="")))
```

For this analysis, we want to answer two data questions:

1. Across the United States, which types of events (as indicated in the `EVTYPE` variable) are most harmful with respect to population health?

2. Across the United States, which types of events have the greatest economic consequences?

This is a fairly large dataset with 902297 observations and 37 variables. Since we are going to focus attention on variables in the data that can help us answer those two questions above, let's remove unneeded variables. 

The nature of the data questions allow us to make some simplifying changes to the data

* The questions do not require us to answer how health or economic impacts change over time, so we can ignore date and time information. We will look at total impact for all dates in the set
* The questions do not require us to answer how health or economic impacts change by geography, so we can ignore state and geo code information and look at all locations.
* The questions require us only to look at type (`EVTYPE`) and health impacts (injuries and fatalities) and economic impacts (crop and property damage)

Based on this, we subset the data to reduce the number of variables down to the ones needed to analysis


```r
interestingVars <- c("EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP",  "CROPDMG", "CROPDMGEXP")
data <- data[interestingVars]
```

Now we have reduced the number of variables to 7 which will help us manage the analysis. 

Moving to the `EVTYPE` variable, we see there is a large number (985) of types. Likely there is need to clean this up. Right away, we see there is punctuation and other noise in the types, so we will remove punctuation and format all the values in lower case to make it easier to use.


```r
data$EVTYPE <- gsub("[[:blank:][:punct:]+]", " ", tolower(data$EVTYPE))
```

Doing that reduced the number of unique types to 874.

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

Doing that reduced the number of unique types to 549. There may be additional opportunity to consolidate these types if other researchers wish to review the remaining types for redundancy.

The last bit of data processing is to create some aggregate data frames to show health and economic impacts.

### Health Impact

For health impact, we are looking at the total number of fatalities and the total number of injuries for each weather event type. This will show a fairly direct impact to health of the US population. 


```r
health <- ddply(data, .(EVTYPE), summarize, fatalities = sum(FATALITIES), injuries = sum(INJURIES))
health <- arrange(health, desc(fatalities), desc(injuries))
head(health, 10)
```

```
##               EVTYPE fatalities injuries
## 1            tornado       5661    91407
## 2     excessive heat       1903     6525
## 3        flash flood       1018     1785
## 4               heat        937     2100
## 5          lightning        817     5232
## 6  thunderstorm wind        709     9458
## 7              flood        470     6789
## 8        rip current        368      232
## 9          high wind        293     1471
## 10         avalanche        224      170
```

To see if this data makes sense, we found that the tornado type had the highest fatalities with a total of 5661. Likewise the tornado type had the highest injuries with a total of 9.1407 &times; 10<sup>4</sup>.

### Economic Impact
For economic impact, we are looking at the total dollar value of damage done to crops and the total dollar value of damage done to property for each weather type. This will show a fairly direct impact to economic activity in the US.

Economic impact data to property is stored in two variables. The `PROPDMG` variable contains the raw number, and the `PROPDMGEXP` stores the exponents data. But the exponent is not directly stored, nor is it consistent. Instead it is a factor variable like `m` or `M` for 'million'. These need to be translated to 10^6. The same is true for `CROPDMG` and `CROPDMGEXP`. 

Valid text values for exponent are B (10^9), M|m (10^6), K|k (10^3) and H|h (10^2). Some exponent values are numeric, and those will be treated as exponents directly. Other values not described will be translated to 10^0, but these errors account for less than .003% of the data.


```r
findExp <- function(exp) {
    if (exp %in% c("b", "B")) return (9)
    else if (exp %in% c("b", "B")) return (9)
    else if (exp %in% c("m", "M")) return (6)
    else if (exp %in% c("k", "K")) return (3)
    else if (exp %in% c("h", "H")) return (2)
    else if (exp %in% c("b", "B")) return (9)
    else if (exp %in% c(0,1,2,3,4,5,6,7,8,9)) return (exp)
    else return(0)
}
data$RealCropDamage <- data$CROPDMG * 10 ^ sapply(data$CROPDMGEXP, FUN=findExp)
data$RealPropDamage <- data$PROPDMG * 10 ^ sapply(data$PROPDMGEXP, FUN=findExp)
econ <- ddply(data, .(EVTYPE), summarize, crop = sum(RealCropDamage), prop = sum(RealPropDamage))
econ <- arrange(econ, desc(prop), desc(crop))
head(econ, 10)
```

```
##               EVTYPE      crop      prop
## 1        flash flood 1.437e+09 6.835e+12
## 2  thunderstorm wind 1.224e+09 2.096e+12
## 3            tornado 4.175e+08 1.608e+11
## 4              flood 5.662e+09 1.447e+11
## 5          hurricane 5.515e+09 8.476e+10
## 6               hail 3.026e+09 4.598e+10
## 7        storm surge 5.000e+03 4.332e+10
## 8          lightning 1.209e+07 1.814e+10
## 9     tropical storm 6.783e+08 7.704e+09
## 10      winter storm 2.694e+07 6.689e+09
```

To see if this data makes sense, we found that the drought type had the most crop economic impact with a total of $1.3973 &times; 10<sup>10</sup>. Likewise the flash flood type had the most property damage with a total of $6.8354 &times; 10<sup>12</sup>.

## Results

### Health Impact

FEMA planners would focus on the following weather events that have historically resulted in largest number of total fatalities and injuries in the United States:


```r
fatalData <- head(arrange(health, desc(fatalities)), 10)
injuryData <- head(arrange(health, desc(injuries)), 10)
g1 <- ggplot(data = fatalData, aes(reorder(EVTYPE, fatalities), fatalities)) + geom_bar(stat="identity") + coord_flip() + theme_bw() + xlab("Weather Event")
g2 <- ggplot(data = injuryData, aes(reorder(EVTYPE, injuries), injuries)) + geom_bar(stat="identity") + coord_flip() + theme_bw() + xlab("Weather Event")
grid.arrange(g1, g2, main="Figure 1: Total Health Impact in the US (1950 - 2011)")
```

![plot of chunk healthPlot](figure/healthPlot.png) 

### Economic Impact

FEMA planners would focus on the following weather events that have historically resulted in most damage to the United States economy:


```r
cropData <- head(arrange(econ, desc(crop)), 10)
propData <- head(arrange(econ, desc(prop)), 10)
g1 <- ggplot(data = cropData, aes(reorder(EVTYPE, crop), crop)) + geom_bar(stat="identity") + coord_flip() + theme_bw() + xlab("Weather Event") + ylab("Crop Damage")
g2 <- ggplot(data = propData, aes(reorder(EVTYPE, prop), prop)) + geom_bar(stat="identity") + coord_flip() + theme_bw() + xlab("Weather Event") + ylab("Property Damage")
grid.arrange(g1, g2, main="Figure 2: Total Economic Impact in the US (1950 - 2011)")
```

![plot of chunk econPlot](figure/econPlot.png) 
