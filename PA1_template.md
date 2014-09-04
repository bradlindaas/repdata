# Reproducible Research: Peer Assessment 1
Author: Brad Lindaas

The purpose of this research is to answer several questions about data that are related to the "quantified self."

### Data Structure
This assignment makes use of data from a personal activity monitoring device. This device collects data at 5 minute intervals through out the day. The data consists of two months of data from an anonymous individual collected during the months of October and November, 2012 and include the number of steps taken in 5 minute intervals each day.

The variables included in this dataset are:

- `steps`: Number of steps taking in a 5-minute interval (missing values are coded as NA)

- `date`: The date on which the measurement was taken in YYYY-MM-DD format

- `interval`: Identifier for the 5-minute interval in which measurement was taken
 
Additionally, one factor variable (`day`) will be added in the analysis to group the observations into two categories. 

### Specific Data Questions
The assignment will seek to answer the following data questions. The numbers below will serve to clearly annote which data question is being answered in this report.

1. Explore the data by making a histogram of the total number of steps taken each day

2. Calculate and report the mean and median total number of steps taken per day

3. Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)

4. Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

5. Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)

6. Devise and describe a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.

7. Create a new dataset that is equal to the original dataset but with the missing data filled in.

8. Make a histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. 

9. Do these values differ from the estimates from the first part of the assignment? 

10. What is the impact of imputing missing data on the estimates of the total daily number of steps?

11. Create a new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.

12. Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis). 
 
## Loading and preprocessing the data

The data was is a commas separated file, and required little processing other than formatting the date variable. I use the `lubridate` package to accomplish that formatting.


```r
library(lubridate)
library(plyr)
library(ggplot2)
options(scipen=9, digits=2) ## Set numeric display options
setwd("/home/rstudio/RepData_PeerAssessment1/") 
if (!file.exists("activity.csv")) {unzip("activity.zip")}
activity <- read.csv("activity.csv") ## read file
activity$date <- ymd(activity$date) ## transform date using Lubridate
```

## What is mean total number of steps taken per day?

First, let's explore some descriptive statistics on the activity data. We want to look at the data summarized by day, and I will use the `plyr` package to format the data in summary form.

> - 1. Explore the data by making a histogram of the total number of steps taken each day


```r
dailySum <- ddply(activity, c("date"), summarize, Total_Steps=sum(steps)) 
hist(dailySum$Total_Steps, breaks="fd")
```

![plot of chunk dailyHist](figure/dailyHist.png) 

> - 2. Calculate and report the mean and median total number of steps taken per day


```r
mean(dailySum$Total_Steps, na.rm=TRUE)
```

```
## [1] 10766
```

```r
median(dailySum$Total_Steps, na.rm=TRUE)
```

```
## [1] 10765
```

## What is the average daily activity pattern?

Next, we will explore patterns in the intra-day activity. In order to do that I will again use the `plyr` package to summarize the data, this time calcuating the mean number of steps for each 5-min interval in the data set.


```r
intervalMean <- ddply(activity, c("interval"), summarize, Mean_Steps=mean(steps, na.rm=TRUE))
```

> - 3. Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)


```r
g <- ggplot(data=intervalMean, aes(interval, Mean_Steps))
g + geom_line() + theme_bw()
```

![plot of chunk plotInterval](figure/plotInterval.png) 

> - 4. Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?


```r
intervalMean[which.max(intervalMean$Mean_Steps),1]
```

```
## [1] 835
```

## Imputing missing values

There are a significant number of `NA` values found in the `steps` variable. In order to understand the impact of that, let's explore that data topic. 

> - 5. Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)


```r
sum(is.na(activity))
```

```
## [1] 2304
```


> - 6. Devise and describe a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.

My strategy to fill in `NA` values within the `steps` variable with actual data is to replace each `NA` value with the mean value for the `interval` varibale across all observations. 

> - 7. Create a new dataset that is equal to the original dataset but with the missing data filled in.


```r
fixedActivity <- activity ## create a new dataframe for the 'fixed' data
na.steps <- which(is.na(fixedActivity$steps)) # identify the rows 
na.interval <- fixedActivity$interval[na.steps] # identify the interval
fixedSteps <- intervalMean$Mean_Steps[match(na.interval, intervalMean$interval)]
fixedActivity$steps[na.steps] <- fixedSteps 
```

Just two quick tests to insure the `fixedActivity` dataframe has the name number of rows as the original `activity` dataframe and that it contains no `NA` values:


```r
nrow(activity) - nrow(fixedActivity)
```

```
## [1] 0
```

```r
sum(is.na(fixedActivity))
```

```
## [1] 0
```

> - 8. Make a histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. 

We want to look at the data summarized by day, and I will use the `plyr` package to format the data in summary form.


```r
newDailySum <- ddply(fixedActivity, c("date"), summarize, Total_Steps=sum(steps)) 
hist(newDailySum$Total_Steps, breaks="fd")
```

![plot of chunk newHist](figure/newHist.png) 

So now I can report the new mean and median steps:


```r
mean(newDailySum$Total_Steps, na.rm=TRUE) 
```

```
## [1] 10766
```

```r
median(newDailySum$Total_Steps, na.rm=TRUE)
```

```
## [1] 10766
```

> - 9. Do these values differ from the estimates from the first part of the assignment? 

No significant difference. Notice that the mean of the values we are adding to the data to replace NA values (the so-called 'fixed steps') is **37.38** which is the same as the mean of the activity data before we fixed it:  **37.38**. 

> - 10. What is the impact of imputing missing data on the estimates of the total daily number of steps?

It is not surprising that the histograms are the same becuase the mean value of the added values is the same as the mean value of the existing values. This is becuase my method of fixing the `NA` values is essentially a rample from the first distribution.

## Are there differences in activity patterns between weekdays and weekends?

> - 11. Create a new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.


```r
fixedActivity$day[which(wday(fixedActivity$date) %in% c(2,3,4,5,6))] <- c("weekday")
fixedActivity$day[which(wday(fixedActivity$date) %in% c(1,7))] <- c("weekend")
fixedActivity$day <- as.factor(fixedActivity$day)
```

Let's take a look at the structure of the new factor variable to ensure we creates a two-factor varibale as required:


```r
str(fixedActivity$day)
```

```
##  Factor w/ 2 levels "weekday","weekend": 1 1 1 1 1 1 1 1 1 1 ...
```

> - 12. Make a panel plot containing a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis). 

To answer this data question, I will agian turn to the handy toolset `plyr` and calculate summary data, this time using it to summarize and group the data.


```r
intervalMean <- ddply(fixedActivity, c("interval", "day"), summarize, Mean_Steps=mean(steps, na.rm=TRUE))
g <- ggplot(data=intervalMean, aes(interval, Mean_Steps)) + facet_grid(day ~ .)
g  + geom_line() + theme_bw()
```

![plot of chunk panelPlot](figure/panelPlot.png) 

As you can see, at the very least it seems this subject sleeps in a little on the weekends!