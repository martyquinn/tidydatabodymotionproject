# Tidy Data Set for Project Body Motion Measurements
Marty Quinn  
October 16, 2016  



## Instructions for project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

    1 Merges the training and the test sets to create one data set.
    2 Extracts only the measurements on the mean and standard deviation for each measurement.
    3 Uses descriptive activity names to name the activities in the data set
    4 Appropriately labels the data set with descriptive variable names.
    5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## Overview of steps taken to satisfy the requirements of the steps 1-4:

We don't create the combined file first, but rather tidy each test and training 
set separately, then combine them for each type of data, X (features), y (activites), and subject (subject ids). 
Finally, we combine them all together. 
Note: during the combining, we always put the training datasets first.

## Get and unzip the data
Get data and unzip in subdirectory ./data. This ends up creating the data
in directory data/UCI HAR Dataset.

```r
library(dplyr) 
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
if(!file.exists("./data")){dir.create("./data")}
dataurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataurl,destfile="./data/bodymotion.zip",method="curl")

unzip(zipfile="./data/bodymotion.zip",exdir="./data")
```

 
## Start tidying 
Read the features descriptions dataset so we can create a logical vector of the columns 
we need to keep for this assignment. As the instructions state: 

>Extract only the measurements on the mean and standard deviation for each measurement. 

That means, from my reading, that any of the recorded variables which had mean or 
std functions applied to them. 
So, the only columns we need to keep are the ones that have -mean() or -std() in them. 
We'll use grep to identify them.

```r
features <- read.table("data/UCI HAR Dataset/features.txt", header = FALSE)
```
## Create the subset of features containing only -mean() and -std()
This 'features' data frame is named with prefix 'subsetted'.

```r
subsettedfeatures <- grep("-mean\\(\\)|-std\\(\\)", features$V2)
```
use the subset of features vector to select out 
our columns of interest from the test and train datasets.

```r
train <- read.table("data/UCI HAR Dataset/train/X_train.txt")
subfeattrain <- train[,subsettedfeatures]
test <- read.table("data/UCI HAR Dataset/test/X_test.txt")
subfeattest <- test[,subsettedfeatures]

namestotransform <- features[subsettedfeatures,2]
```
##Tidy up the subset of column names in namestotransform
1. removing -, (),
2. changing BodyBody to Body
3. t to time
4. f to freq
5. acc to accel to make it more like accelerometer but nnot quite so long.
6. make name all lowercase letters

```r
namestotransform <- gsub("-","", namestotransform)
namestotransform <- gsub("\\(\\)","", namestotransform)
namestotransform <- gsub("BodyBody","Body", namestotransform)
namestotransform <- gsub("^t", "time",namestotransform)
namestotransform <- gsub("^f", "freq", namestotransform)
namestotransform <- gsub("Acc", "Accel", namestotransform)
namestotransform <- tolower(namestotransform)
```

##Assign the transformed, expanded and cleaned up names to be the colnames of each subsetted features dataset. 

```r
colnames(subfeattest) <- namestotransform
colnames(subfeattrain) <- namestotransform
```

## Add descriptive column to the movement id actions file. 
These next steps read the activity labels and then adds labels for each activity number
so they are human readable character strings.

```r
activitylabels <- read.table("data/UCI HAR Dataset/activity_labels.txt")
activitiestrain <- read.table("data/UCI HAR Dataset/train/y_train.txt")
activitiestest <- read.table("data/UCI HAR Dataset/test/y_test.txt")


activitiestrain <- cbind(activitiestrain, factor(activitiestrain$V1,
                    levels = c(1:6),
                    labels = as.character(activitylabels[,2]))) 
activitiestest <- cbind(activitiestest, factor(activitiestest$V1,
                    levels = c(1:6),
                    labels = as.character(activitylabels[,2])))
                   
colnames(activitiestrain) <- c("activityid", "activity")
colnames(activitiestest) <- c("activityid", "activity")
head(activitiestrain)
```

```
##   activityid activity
## 1          5 STANDING
## 2          5 STANDING
## 3          5 STANDING
## 4          5 STANDING
## 5          5 STANDING
## 6          5 STANDING
```

```r
head(activitiestest)
```

```
##   activityid activity
## 1          5 STANDING
## 2          5 STANDING
## 3          5 STANDING
## 4          5 STANDING
## 5          5 STANDING
## 6          5 STANDING
```
## Combine the y activity datasets

```r
combinedactivity <- rbind(activitiestrain, activitiestest)
nrow(activitiestrain)
```

```
## [1] 7352
```

```r
nrow(activitiestest)
```

```
## [1] 2947
```

```r
nrow(combinedactivity)
```

```
## [1] 10299
```

```r
str(combinedactivity)
```

```
## 'data.frame':	10299 obs. of  2 variables:
##  $ activityid: int  5 5 5 5 5 5 5 5 5 5 ...
##  $ activity  : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 5 5 5 5 5 5 5 5 5 5 ...
```
## Combine the features datasets


```r
combinedsubfeat <- rbind(subfeattrain, subfeattest)
nrow(subfeattrain)
```

```
## [1] 7352
```

```r
nrow(subfeattest)
```

```
## [1] 2947
```

```r
nrow(combinedsubfeat)
```

```
## [1] 10299
```

```r
str(combinedsubfeat)
```

```
## 'data.frame':	10299 obs. of  66 variables:
##  $ timebodyaccelmeanx      : num  0.289 0.278 0.28 0.279 0.277 ...
##  $ timebodyaccelmeany      : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
##  $ timebodyaccelmeanz      : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
##  $ timebodyaccelstdx       : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
##  $ timebodyaccelstdy       : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
##  $ timebodyaccelstdz       : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
##  $ timegravityaccelmeanx   : num  0.963 0.967 0.967 0.968 0.968 ...
##  $ timegravityaccelmeany   : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
##  $ timegravityaccelmeanz   : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
##  $ timegravityaccelstdx    : num  -0.985 -0.997 -1 -0.997 -0.998 ...
##  $ timegravityaccelstdy    : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
##  $ timegravityaccelstdz    : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
##  $ timebodyacceljerkmeanx  : num  0.078 0.074 0.0736 0.0773 0.0734 ...
##  $ timebodyacceljerkmeany  : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
##  $ timebodyacceljerkmeanz  : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
##  $ timebodyacceljerkstdx   : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
##  $ timebodyacceljerkstdy   : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
##  $ timebodyacceljerkstdz   : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
##  $ timebodygyromeanx       : num  -0.0061 -0.0161 -0.0317 -0.0434 -0.034 ...
##  $ timebodygyromeany       : num  -0.0314 -0.0839 -0.1023 -0.0914 -0.0747 ...
##  $ timebodygyromeanz       : num  0.1077 0.1006 0.0961 0.0855 0.0774 ...
##  $ timebodygyrostdx        : num  -0.985 -0.983 -0.976 -0.991 -0.985 ...
##  $ timebodygyrostdy        : num  -0.977 -0.989 -0.994 -0.992 -0.992 ...
##  $ timebodygyrostdz        : num  -0.992 -0.989 -0.986 -0.988 -0.987 ...
##  $ timebodygyrojerkmeanx   : num  -0.0992 -0.1105 -0.1085 -0.0912 -0.0908 ...
##  $ timebodygyrojerkmeany   : num  -0.0555 -0.0448 -0.0424 -0.0363 -0.0376 ...
##  $ timebodygyrojerkmeanz   : num  -0.062 -0.0592 -0.0558 -0.0605 -0.0583 ...
##  $ timebodygyrojerkstdx    : num  -0.992 -0.99 -0.988 -0.991 -0.991 ...
##  $ timebodygyrojerkstdy    : num  -0.993 -0.997 -0.996 -0.997 -0.996 ...
##  $ timebodygyrojerkstdz    : num  -0.992 -0.994 -0.992 -0.993 -0.995 ...
##  $ timebodyaccelmagmean    : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ timebodyaccelmagstd     : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ timegravityaccelmagmean : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ timegravityaccelmagstd  : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ timebodyacceljerkmagmean: num  -0.993 -0.991 -0.989 -0.993 -0.993 ...
##  $ timebodyacceljerkmagstd : num  -0.994 -0.992 -0.99 -0.993 -0.996 ...
##  $ timebodygyromagmean     : num  -0.969 -0.981 -0.976 -0.982 -0.985 ...
##  $ timebodygyromagstd      : num  -0.964 -0.984 -0.986 -0.987 -0.989 ...
##  $ timebodygyrojerkmagmean : num  -0.994 -0.995 -0.993 -0.996 -0.996 ...
##  $ timebodygyrojerkmagstd  : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ freqbodyaccelmeanx      : num  -0.995 -0.997 -0.994 -0.995 -0.997 ...
##  $ freqbodyaccelmeany      : num  -0.983 -0.977 -0.973 -0.984 -0.982 ...
##  $ freqbodyaccelmeanz      : num  -0.939 -0.974 -0.983 -0.991 -0.988 ...
##  $ freqbodyaccelstdx       : num  -0.995 -0.999 -0.996 -0.996 -0.999 ...
##  $ freqbodyaccelstdy       : num  -0.983 -0.975 -0.966 -0.983 -0.98 ...
##  $ freqbodyaccelstdz       : num  -0.906 -0.955 -0.977 -0.99 -0.992 ...
##  $ freqbodyacceljerkmeanx  : num  -0.992 -0.995 -0.991 -0.994 -0.996 ...
##  $ freqbodyacceljerkmeany  : num  -0.987 -0.981 -0.982 -0.989 -0.989 ...
##  $ freqbodyacceljerkmeanz  : num  -0.99 -0.99 -0.988 -0.991 -0.991 ...
##  $ freqbodyacceljerkstdx   : num  -0.996 -0.997 -0.991 -0.991 -0.997 ...
##  $ freqbodyacceljerkstdy   : num  -0.991 -0.982 -0.981 -0.987 -0.989 ...
##  $ freqbodyacceljerkstdz   : num  -0.997 -0.993 -0.99 -0.994 -0.993 ...
##  $ freqbodygyromeanx       : num  -0.987 -0.977 -0.975 -0.987 -0.982 ...
##  $ freqbodygyromeany       : num  -0.982 -0.993 -0.994 -0.994 -0.993 ...
##  $ freqbodygyromeanz       : num  -0.99 -0.99 -0.987 -0.987 -0.989 ...
##  $ freqbodygyrostdx        : num  -0.985 -0.985 -0.977 -0.993 -0.986 ...
##  $ freqbodygyrostdy        : num  -0.974 -0.987 -0.993 -0.992 -0.992 ...
##  $ freqbodygyrostdz        : num  -0.994 -0.99 -0.987 -0.989 -0.988 ...
##  $ freqbodyaccelmagmean    : num  -0.952 -0.981 -0.988 -0.988 -0.994 ...
##  $ freqbodyaccelmagstd     : num  -0.956 -0.976 -0.989 -0.987 -0.99 ...
##  $ freqbodyacceljerkmagmean: num  -0.994 -0.99 -0.989 -0.993 -0.996 ...
##  $ freqbodyacceljerkmagstd : num  -0.994 -0.992 -0.991 -0.992 -0.994 ...
##  $ freqbodygyromagmean     : num  -0.98 -0.988 -0.989 -0.989 -0.991 ...
##  $ freqbodygyromagstd      : num  -0.961 -0.983 -0.986 -0.988 -0.989 ...
##  $ freqbodygyrojerkmagmean : num  -0.992 -0.996 -0.995 -0.995 -0.995 ...
##  $ freqbodygyrojerkmagstd  : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
```
## Put proper column names to the subject id files.

```r
subjecttrain <- read.table("data/UCI HAR Dataset/train/subject_train.txt")
subjecttest  <- read.table("data/UCI HAR Dataset/test/subject_test.txt")
colnames(subjecttrain) <- "subjectid"
colnames(subjecttest) <- "subjectid"

head(subjecttrain)
```

```
##   subjectid
## 1         1
## 2         1
## 3         1
## 4         1
## 5         1
## 6         1
```

```r
tail(subjecttest)
```

```
##      subjectid
## 2942        24
## 2943        24
## 2944        24
## 2945        24
## 2946        24
## 2947        24
```
## Combine the subject id datasets

```r
combinedsubject <- rbind(subjecttrain, subjecttest)
head(combinedsubject)
```

```
##   subjectid
## 1         1
## 2         1
## 3         1
## 4         1
## 5         1
## 6         1
```

```r
tail(combinedsubject)
```

```
##       subjectid
## 10294        24
## 10295        24
## 10296        24
## 10297        24
## 10298        24
## 10299        24
```

## Finally, combine all the combined training and test files into the final combined file. 

```r
combined <- cbind(combinedsubject, combinedactivity, combinedsubfeat)

str(combined)
```

```
## 'data.frame':	10299 obs. of  69 variables:
##  $ subjectid               : int  1 1 1 1 1 1 1 1 1 1 ...
##  $ activityid              : int  5 5 5 5 5 5 5 5 5 5 ...
##  $ activity                : Factor w/ 6 levels "WALKING","WALKING_UPSTAIRS",..: 5 5 5 5 5 5 5 5 5 5 ...
##  $ timebodyaccelmeanx      : num  0.289 0.278 0.28 0.279 0.277 ...
##  $ timebodyaccelmeany      : num  -0.0203 -0.0164 -0.0195 -0.0262 -0.0166 ...
##  $ timebodyaccelmeanz      : num  -0.133 -0.124 -0.113 -0.123 -0.115 ...
##  $ timebodyaccelstdx       : num  -0.995 -0.998 -0.995 -0.996 -0.998 ...
##  $ timebodyaccelstdy       : num  -0.983 -0.975 -0.967 -0.983 -0.981 ...
##  $ timebodyaccelstdz       : num  -0.914 -0.96 -0.979 -0.991 -0.99 ...
##  $ timegravityaccelmeanx   : num  0.963 0.967 0.967 0.968 0.968 ...
##  $ timegravityaccelmeany   : num  -0.141 -0.142 -0.142 -0.144 -0.149 ...
##  $ timegravityaccelmeanz   : num  0.1154 0.1094 0.1019 0.0999 0.0945 ...
##  $ timegravityaccelstdx    : num  -0.985 -0.997 -1 -0.997 -0.998 ...
##  $ timegravityaccelstdy    : num  -0.982 -0.989 -0.993 -0.981 -0.988 ...
##  $ timegravityaccelstdz    : num  -0.878 -0.932 -0.993 -0.978 -0.979 ...
##  $ timebodyacceljerkmeanx  : num  0.078 0.074 0.0736 0.0773 0.0734 ...
##  $ timebodyacceljerkmeany  : num  0.005 0.00577 0.0031 0.02006 0.01912 ...
##  $ timebodyacceljerkmeanz  : num  -0.06783 0.02938 -0.00905 -0.00986 0.01678 ...
##  $ timebodyacceljerkstdx   : num  -0.994 -0.996 -0.991 -0.993 -0.996 ...
##  $ timebodyacceljerkstdy   : num  -0.988 -0.981 -0.981 -0.988 -0.988 ...
##  $ timebodyacceljerkstdz   : num  -0.994 -0.992 -0.99 -0.993 -0.992 ...
##  $ timebodygyromeanx       : num  -0.0061 -0.0161 -0.0317 -0.0434 -0.034 ...
##  $ timebodygyromeany       : num  -0.0314 -0.0839 -0.1023 -0.0914 -0.0747 ...
##  $ timebodygyromeanz       : num  0.1077 0.1006 0.0961 0.0855 0.0774 ...
##  $ timebodygyrostdx        : num  -0.985 -0.983 -0.976 -0.991 -0.985 ...
##  $ timebodygyrostdy        : num  -0.977 -0.989 -0.994 -0.992 -0.992 ...
##  $ timebodygyrostdz        : num  -0.992 -0.989 -0.986 -0.988 -0.987 ...
##  $ timebodygyrojerkmeanx   : num  -0.0992 -0.1105 -0.1085 -0.0912 -0.0908 ...
##  $ timebodygyrojerkmeany   : num  -0.0555 -0.0448 -0.0424 -0.0363 -0.0376 ...
##  $ timebodygyrojerkmeanz   : num  -0.062 -0.0592 -0.0558 -0.0605 -0.0583 ...
##  $ timebodygyrojerkstdx    : num  -0.992 -0.99 -0.988 -0.991 -0.991 ...
##  $ timebodygyrojerkstdy    : num  -0.993 -0.997 -0.996 -0.997 -0.996 ...
##  $ timebodygyrojerkstdz    : num  -0.992 -0.994 -0.992 -0.993 -0.995 ...
##  $ timebodyaccelmagmean    : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ timebodyaccelmagstd     : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ timegravityaccelmagmean : num  -0.959 -0.979 -0.984 -0.987 -0.993 ...
##  $ timegravityaccelmagstd  : num  -0.951 -0.976 -0.988 -0.986 -0.991 ...
##  $ timebodyacceljerkmagmean: num  -0.993 -0.991 -0.989 -0.993 -0.993 ...
##  $ timebodyacceljerkmagstd : num  -0.994 -0.992 -0.99 -0.993 -0.996 ...
##  $ timebodygyromagmean     : num  -0.969 -0.981 -0.976 -0.982 -0.985 ...
##  $ timebodygyromagstd      : num  -0.964 -0.984 -0.986 -0.987 -0.989 ...
##  $ timebodygyrojerkmagmean : num  -0.994 -0.995 -0.993 -0.996 -0.996 ...
##  $ timebodygyrojerkmagstd  : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
##  $ freqbodyaccelmeanx      : num  -0.995 -0.997 -0.994 -0.995 -0.997 ...
##  $ freqbodyaccelmeany      : num  -0.983 -0.977 -0.973 -0.984 -0.982 ...
##  $ freqbodyaccelmeanz      : num  -0.939 -0.974 -0.983 -0.991 -0.988 ...
##  $ freqbodyaccelstdx       : num  -0.995 -0.999 -0.996 -0.996 -0.999 ...
##  $ freqbodyaccelstdy       : num  -0.983 -0.975 -0.966 -0.983 -0.98 ...
##  $ freqbodyaccelstdz       : num  -0.906 -0.955 -0.977 -0.99 -0.992 ...
##  $ freqbodyacceljerkmeanx  : num  -0.992 -0.995 -0.991 -0.994 -0.996 ...
##  $ freqbodyacceljerkmeany  : num  -0.987 -0.981 -0.982 -0.989 -0.989 ...
##  $ freqbodyacceljerkmeanz  : num  -0.99 -0.99 -0.988 -0.991 -0.991 ...
##  $ freqbodyacceljerkstdx   : num  -0.996 -0.997 -0.991 -0.991 -0.997 ...
##  $ freqbodyacceljerkstdy   : num  -0.991 -0.982 -0.981 -0.987 -0.989 ...
##  $ freqbodyacceljerkstdz   : num  -0.997 -0.993 -0.99 -0.994 -0.993 ...
##  $ freqbodygyromeanx       : num  -0.987 -0.977 -0.975 -0.987 -0.982 ...
##  $ freqbodygyromeany       : num  -0.982 -0.993 -0.994 -0.994 -0.993 ...
##  $ freqbodygyromeanz       : num  -0.99 -0.99 -0.987 -0.987 -0.989 ...
##  $ freqbodygyrostdx        : num  -0.985 -0.985 -0.977 -0.993 -0.986 ...
##  $ freqbodygyrostdy        : num  -0.974 -0.987 -0.993 -0.992 -0.992 ...
##  $ freqbodygyrostdz        : num  -0.994 -0.99 -0.987 -0.989 -0.988 ...
##  $ freqbodyaccelmagmean    : num  -0.952 -0.981 -0.988 -0.988 -0.994 ...
##  $ freqbodyaccelmagstd     : num  -0.956 -0.976 -0.989 -0.987 -0.99 ...
##  $ freqbodyacceljerkmagmean: num  -0.994 -0.99 -0.989 -0.993 -0.996 ...
##  $ freqbodyacceljerkmagstd : num  -0.994 -0.992 -0.991 -0.992 -0.994 ...
##  $ freqbodygyromagmean     : num  -0.98 -0.988 -0.989 -0.989 -0.991 ...
##  $ freqbodygyromagstd      : num  -0.961 -0.983 -0.986 -0.988 -0.989 ...
##  $ freqbodygyrojerkmagmean : num  -0.992 -0.996 -0.995 -0.995 -0.995 ...
##  $ freqbodygyrojerkmagstd  : num  -0.991 -0.996 -0.995 -0.995 -0.995 ...
```

```r
head(combined)
```

```
##   subjectid activityid activity timebodyaccelmeanx timebodyaccelmeany
## 1         1          5 STANDING          0.2885845        -0.02029417
## 2         1          5 STANDING          0.2784188        -0.01641057
## 3         1          5 STANDING          0.2796531        -0.01946716
## 4         1          5 STANDING          0.2791739        -0.02620065
## 5         1          5 STANDING          0.2766288        -0.01656965
## 6         1          5 STANDING          0.2771988        -0.01009785
##   timebodyaccelmeanz timebodyaccelstdx timebodyaccelstdy timebodyaccelstdz
## 1         -0.1329051        -0.9952786        -0.9831106        -0.9135264
## 2         -0.1235202        -0.9982453        -0.9753002        -0.9603220
## 3         -0.1134617        -0.9953796        -0.9671870        -0.9789440
## 4         -0.1232826        -0.9960915        -0.9834027        -0.9906751
## 5         -0.1153619        -0.9981386        -0.9808173        -0.9904816
## 6         -0.1051373        -0.9973350        -0.9904868        -0.9954200
##   timegravityaccelmeanx timegravityaccelmeany timegravityaccelmeanz
## 1             0.9633961            -0.1408397            0.11537494
## 2             0.9665611            -0.1415513            0.10937881
## 3             0.9668781            -0.1420098            0.10188392
## 4             0.9676152            -0.1439765            0.09985014
## 5             0.9682244            -0.1487502            0.09448590
## 6             0.9679482            -0.1482100            0.09190972
##   timegravityaccelstdx timegravityaccelstdy timegravityaccelstdz
## 1           -0.9852497           -0.9817084           -0.8776250
## 2           -0.9974113           -0.9894474           -0.9316387
## 3           -0.9995740           -0.9928658           -0.9929172
## 4           -0.9966456           -0.9813928           -0.9784764
## 5           -0.9984293           -0.9880982           -0.9787449
## 6           -0.9989793           -0.9867539           -0.9973064
##   timebodyacceljerkmeanx timebodyacceljerkmeany timebodyacceljerkmeanz
## 1             0.07799634            0.005000803           -0.067830808
## 2             0.07400671            0.005771104            0.029376633
## 3             0.07363596            0.003104037           -0.009045631
## 4             0.07732061            0.020057642           -0.009864772
## 5             0.07344436            0.019121574            0.016779979
## 6             0.07793244            0.018684046            0.009344434
##   timebodyacceljerkstdx timebodyacceljerkstdy timebodyacceljerkstdz
## 1            -0.9935191            -0.9883600            -0.9935750
## 2            -0.9955481            -0.9810636            -0.9918457
## 3            -0.9907428            -0.9809556            -0.9896866
## 4            -0.9926974            -0.9875527            -0.9934976
## 5            -0.9964202            -0.9883587            -0.9924549
## 6            -0.9948136            -0.9887145            -0.9922663
##   timebodygyromeanx timebodygyromeany timebodygyromeanz timebodygyrostdx
## 1      -0.006100849       -0.03136479        0.10772540       -0.9853103
## 2      -0.016111620       -0.08389378        0.10058429       -0.9831200
## 3      -0.031698294       -0.10233542        0.09612688       -0.9762921
## 4      -0.043409983       -0.09138618        0.08553770       -0.9913848
## 5      -0.033960416       -0.07470803        0.07739203       -0.9851836
## 6      -0.028775508       -0.07039311        0.07901214       -0.9851808
##   timebodygyrostdy timebodygyrostdz timebodygyrojerkmeanx
## 1       -0.9766234       -0.9922053           -0.09916740
## 2       -0.9890458       -0.9891212           -0.11050283
## 3       -0.9935518       -0.9863787           -0.10848567
## 4       -0.9924073       -0.9875542           -0.09116989
## 5       -0.9923781       -0.9874019           -0.09077010
## 6       -0.9921175       -0.9830768           -0.09424758
##   timebodygyrojerkmeany timebodygyrojerkmeanz timebodygyrojerkstdx
## 1           -0.05551737           -0.06198580           -0.9921107
## 2           -0.04481873           -0.05924282           -0.9898726
## 3           -0.04241031           -0.05582883           -0.9884618
## 4           -0.03633262           -0.06046466           -0.9911194
## 5           -0.03763253           -0.05828932           -0.9913545
## 6           -0.04335526           -0.04193600           -0.9916216
##   timebodygyrojerkstdy timebodygyrojerkstdz timebodyaccelmagmean
## 1           -0.9925193           -0.9920553           -0.9594339
## 2           -0.9972926           -0.9938510           -0.9792892
## 3           -0.9956321           -0.9915318           -0.9837031
## 4           -0.9966410           -0.9933289           -0.9865418
## 5           -0.9964730           -0.9945110           -0.9928271
## 6           -0.9960147           -0.9930906           -0.9942950
##   timebodyaccelmagstd timegravityaccelmagmean timegravityaccelmagstd
## 1          -0.9505515              -0.9594339             -0.9505515
## 2          -0.9760571              -0.9792892             -0.9760571
## 3          -0.9880196              -0.9837031             -0.9880196
## 4          -0.9864213              -0.9865418             -0.9864213
## 5          -0.9912754              -0.9928271             -0.9912754
## 6          -0.9952490              -0.9942950             -0.9952490
##   timebodyacceljerkmagmean timebodyacceljerkmagstd timebodygyromagmean
## 1               -0.9933059              -0.9943364          -0.9689591
## 2               -0.9912535              -0.9916944          -0.9806831
## 3               -0.9885313              -0.9903969          -0.9763171
## 4               -0.9930780              -0.9933808          -0.9820599
## 5               -0.9934800              -0.9958537          -0.9852037
## 6               -0.9930177              -0.9954243          -0.9858944
##   timebodygyromagstd timebodygyrojerkmagmean timebodygyrojerkmagstd
## 1         -0.9643352              -0.9942478             -0.9913676
## 2         -0.9837542              -0.9951232             -0.9961016
## 3         -0.9860515              -0.9934032             -0.9950910
## 4         -0.9873511              -0.9955022             -0.9952666
## 5         -0.9890626              -0.9958076             -0.9952580
## 6         -0.9864403              -0.9952748             -0.9952050
##   freqbodyaccelmeanx freqbodyaccelmeany freqbodyaccelmeanz
## 1         -0.9947832         -0.9829841         -0.9392687
## 2         -0.9974507         -0.9768517         -0.9735227
## 3         -0.9935941         -0.9725115         -0.9833040
## 4         -0.9954906         -0.9835697         -0.9910798
## 5         -0.9972859         -0.9823010         -0.9883694
## 6         -0.9966567         -0.9869395         -0.9927386
##   freqbodyaccelstdx freqbodyaccelstdy freqbodyaccelstdz
## 1        -0.9954217        -0.9831330        -0.9061650
## 2        -0.9986803        -0.9749298        -0.9554381
## 3        -0.9963128        -0.9655059        -0.9770493
## 4        -0.9963121        -0.9832444        -0.9902291
## 5        -0.9986065        -0.9801295        -0.9919150
## 6        -0.9976438        -0.9922637        -0.9970459
##   freqbodyacceljerkmeanx freqbodyacceljerkmeany freqbodyacceljerkmeanz
## 1             -0.9923325             -0.9871699             -0.9896961
## 2             -0.9950322             -0.9813115             -0.9897398
## 3             -0.9909937             -0.9816423             -0.9875663
## 4             -0.9944466             -0.9887272             -0.9913542
## 5             -0.9962920             -0.9887900             -0.9906244
## 6             -0.9948507             -0.9882443             -0.9901575
##   freqbodyacceljerkstdx freqbodyacceljerkstdy freqbodyacceljerkstdz
## 1            -0.9958207            -0.9909363            -0.9970517
## 2            -0.9966523            -0.9820839            -0.9926268
## 3            -0.9912488            -0.9814148            -0.9904159
## 4            -0.9913783            -0.9869269            -0.9943908
## 5            -0.9969025            -0.9886067            -0.9929065
## 6            -0.9952180            -0.9901788            -0.9930667
##   freqbodygyromeanx freqbodygyromeany freqbodygyromeanz freqbodygyrostdx
## 1        -0.9865744        -0.9817615        -0.9895148       -0.9850326
## 2        -0.9773867        -0.9925300        -0.9896058       -0.9849043
## 3        -0.9754332        -0.9937147        -0.9867557       -0.9766422
## 4        -0.9871096        -0.9936015        -0.9871913       -0.9928104
## 5        -0.9824465        -0.9929838        -0.9886664       -0.9859818
## 6        -0.9848902        -0.9927862        -0.9807784       -0.9852871
##   freqbodygyrostdy freqbodygyrostdz freqbodyaccelmagmean
## 1       -0.9738861       -0.9940349           -0.9521547
## 2       -0.9871681       -0.9897847           -0.9808566
## 3       -0.9933990       -0.9873282           -0.9877948
## 4       -0.9916460       -0.9886776           -0.9875187
## 5       -0.9919558       -0.9879443           -0.9935909
## 6       -0.9916595       -0.9853661           -0.9948360
##   freqbodyaccelmagstd freqbodyacceljerkmagmean freqbodyacceljerkmagstd
## 1          -0.9561340               -0.9937257              -0.9937550
## 2          -0.9758658               -0.9903355              -0.9919603
## 3          -0.9890155               -0.9892801              -0.9908667
## 4          -0.9867420               -0.9927689              -0.9916998
## 5          -0.9900635               -0.9955228              -0.9943890
## 6          -0.9952833               -0.9947329              -0.9951562
##   freqbodygyromagmean freqbodygyromagstd freqbodygyrojerkmagmean
## 1          -0.9801349         -0.9613094              -0.9919904
## 2          -0.9882956         -0.9833219              -0.9958539
## 3          -0.9892548         -0.9860277              -0.9950305
## 4          -0.9894128         -0.9878358              -0.9952207
## 5          -0.9914330         -0.9890594              -0.9950928
## 6          -0.9905000         -0.9858609              -0.9951433
##   freqbodygyrojerkmagstd
## 1             -0.9906975
## 2             -0.9963995
## 3             -0.9951274
## 4             -0.9952369
## 5             -0.9954648
## 6             -0.9952387
```

```r
summary(combined)
```

```
##    subjectid       activityid                  activity   
##  Min.   : 1.00   Min.   :1.000   WALKING           :1722  
##  1st Qu.: 9.00   1st Qu.:2.000   WALKING_UPSTAIRS  :1544  
##  Median :17.00   Median :4.000   WALKING_DOWNSTAIRS:1406  
##  Mean   :16.15   Mean   :3.625   SITTING           :1777  
##  3rd Qu.:24.00   3rd Qu.:5.000   STANDING          :1906  
##  Max.   :30.00   Max.   :6.000   LAYING            :1944  
##  timebodyaccelmeanx timebodyaccelmeany timebodyaccelmeanz
##  Min.   :-1.0000    Min.   :-1.00000   Min.   :-1.00000  
##  1st Qu.: 0.2626    1st Qu.:-0.02490   1st Qu.:-0.12102  
##  Median : 0.2772    Median :-0.01716   Median :-0.10860  
##  Mean   : 0.2743    Mean   :-0.01774   Mean   :-0.10892  
##  3rd Qu.: 0.2884    3rd Qu.:-0.01062   3rd Qu.:-0.09759  
##  Max.   : 1.0000    Max.   : 1.00000   Max.   : 1.00000  
##  timebodyaccelstdx timebodyaccelstdy  timebodyaccelstdz
##  Min.   :-1.0000   Min.   :-1.00000   Min.   :-1.0000  
##  1st Qu.:-0.9924   1st Qu.:-0.97699   1st Qu.:-0.9791  
##  Median :-0.9430   Median :-0.83503   Median :-0.8508  
##  Mean   :-0.6078   Mean   :-0.51019   Mean   :-0.6131  
##  3rd Qu.:-0.2503   3rd Qu.:-0.05734   3rd Qu.:-0.2787  
##  Max.   : 1.0000   Max.   : 1.00000   Max.   : 1.0000  
##  timegravityaccelmeanx timegravityaccelmeany timegravityaccelmeanz
##  Min.   :-1.0000       Min.   :-1.000000     Min.   :-1.00000     
##  1st Qu.: 0.8117       1st Qu.:-0.242943     1st Qu.:-0.11671     
##  Median : 0.9218       Median :-0.143551     Median : 0.03680     
##  Mean   : 0.6692       Mean   : 0.004039     Mean   : 0.09215     
##  3rd Qu.: 0.9547       3rd Qu.: 0.118905     3rd Qu.: 0.21621     
##  Max.   : 1.0000       Max.   : 1.000000     Max.   : 1.00000     
##  timegravityaccelstdx timegravityaccelstdy timegravityaccelstdz
##  Min.   :-1.0000      Min.   :-1.0000      Min.   :-1.0000     
##  1st Qu.:-0.9949      1st Qu.:-0.9913      1st Qu.:-0.9866     
##  Median :-0.9819      Median :-0.9759      Median :-0.9665     
##  Mean   :-0.9652      Mean   :-0.9544      Mean   :-0.9389     
##  3rd Qu.:-0.9615      3rd Qu.:-0.9464      3rd Qu.:-0.9296     
##  Max.   : 1.0000      Max.   : 1.0000      Max.   : 1.0000     
##  timebodyacceljerkmeanx timebodyacceljerkmeany timebodyacceljerkmeanz
##  Min.   :-1.00000       Min.   :-1.000000      Min.   :-1.000000     
##  1st Qu.: 0.06298       1st Qu.:-0.018555      1st Qu.:-0.031552     
##  Median : 0.07597       Median : 0.010753      Median :-0.001159     
##  Mean   : 0.07894       Mean   : 0.007948      Mean   :-0.004675     
##  3rd Qu.: 0.09131       3rd Qu.: 0.033538      3rd Qu.: 0.024578     
##  Max.   : 1.00000       Max.   : 1.000000      Max.   : 1.000000     
##  timebodyacceljerkstdx timebodyacceljerkstdy timebodyacceljerkstdz
##  Min.   :-1.0000       Min.   :-1.0000       Min.   :-1.0000      
##  1st Qu.:-0.9913       1st Qu.:-0.9850       1st Qu.:-0.9892      
##  Median :-0.9513       Median :-0.9250       Median :-0.9543      
##  Mean   :-0.6398       Mean   :-0.6080       Mean   :-0.7628      
##  3rd Qu.:-0.2912       3rd Qu.:-0.2218       3rd Qu.:-0.5485      
##  Max.   : 1.0000       Max.   : 1.0000       Max.   : 1.0000      
##  timebodygyromeanx  timebodygyromeany  timebodygyromeanz 
##  Min.   :-1.00000   Min.   :-1.00000   Min.   :-1.00000  
##  1st Qu.:-0.04579   1st Qu.:-0.10399   1st Qu.: 0.06485  
##  Median :-0.02776   Median :-0.07477   Median : 0.08626  
##  Mean   :-0.03098   Mean   :-0.07472   Mean   : 0.08836  
##  3rd Qu.:-0.01058   3rd Qu.:-0.05110   3rd Qu.: 0.11044  
##  Max.   : 1.00000   Max.   : 1.00000   Max.   : 1.00000  
##  timebodygyrostdx  timebodygyrostdy  timebodygyrostdz 
##  Min.   :-1.0000   Min.   :-1.0000   Min.   :-1.0000  
##  1st Qu.:-0.9872   1st Qu.:-0.9819   1st Qu.:-0.9850  
##  Median :-0.9016   Median :-0.9106   Median :-0.8819  
##  Mean   :-0.7212   Mean   :-0.6827   Mean   :-0.6537  
##  3rd Qu.:-0.4822   3rd Qu.:-0.4461   3rd Qu.:-0.3379  
##  Max.   : 1.0000   Max.   : 1.0000   Max.   : 1.0000  
##  timebodygyrojerkmeanx timebodygyrojerkmeany timebodygyrojerkmeanz
##  Min.   :-1.00000      Min.   :-1.00000      Min.   :-1.00000     
##  1st Qu.:-0.11723      1st Qu.:-0.05868      1st Qu.:-0.07936     
##  Median :-0.09824      Median :-0.04056      Median :-0.05455     
##  Mean   :-0.09671      Mean   :-0.04232      Mean   :-0.05483     
##  3rd Qu.:-0.07930      3rd Qu.:-0.02521      3rd Qu.:-0.03168     
##  Max.   : 1.00000      Max.   : 1.00000      Max.   : 1.00000     
##  timebodygyrojerkstdx timebodygyrojerkstdy timebodygyrojerkstdz
##  Min.   :-1.0000      Min.   :-1.0000      Min.   :-1.0000     
##  1st Qu.:-0.9907      1st Qu.:-0.9922      1st Qu.:-0.9926     
##  Median :-0.9348      Median :-0.9548      Median :-0.9503     
##  Mean   :-0.7313      Mean   :-0.7861      Mean   :-0.7399     
##  3rd Qu.:-0.4865      3rd Qu.:-0.6268      3rd Qu.:-0.5097     
##  Max.   : 1.0000      Max.   : 1.0000      Max.   : 1.0000     
##  timebodyaccelmagmean timebodyaccelmagstd timegravityaccelmagmean
##  Min.   :-1.0000      Min.   :-1.0000     Min.   :-1.0000        
##  1st Qu.:-0.9819      1st Qu.:-0.9822     1st Qu.:-0.9819        
##  Median :-0.8746      Median :-0.8437     Median :-0.8746        
##  Mean   :-0.5482      Mean   :-0.5912     Mean   :-0.5482        
##  3rd Qu.:-0.1201      3rd Qu.:-0.2423     3rd Qu.:-0.1201        
##  Max.   : 1.0000      Max.   : 1.0000     Max.   : 1.0000        
##  timegravityaccelmagstd timebodyacceljerkmagmean timebodyacceljerkmagstd
##  Min.   :-1.0000        Min.   :-1.0000          Min.   :-1.0000        
##  1st Qu.:-0.9822        1st Qu.:-0.9896          1st Qu.:-0.9907        
##  Median :-0.8437        Median :-0.9481          Median :-0.9288        
##  Mean   :-0.5912        Mean   :-0.6494          Mean   :-0.6278        
##  3rd Qu.:-0.2423        3rd Qu.:-0.2956          3rd Qu.:-0.2733        
##  Max.   : 1.0000        Max.   : 1.0000          Max.   : 1.0000        
##  timebodygyromagmean timebodygyromagstd timebodygyrojerkmagmean
##  Min.   :-1.0000     Min.   :-1.0000    Min.   :-1.0000        
##  1st Qu.:-0.9781     1st Qu.:-0.9775    1st Qu.:-0.9923        
##  Median :-0.8223     Median :-0.8259    Median :-0.9559        
##  Mean   :-0.6052     Mean   :-0.6625    Mean   :-0.7621        
##  3rd Qu.:-0.2454     3rd Qu.:-0.3940    3rd Qu.:-0.5499        
##  Max.   : 1.0000     Max.   : 1.0000    Max.   : 1.0000        
##  timebodygyrojerkmagstd freqbodyaccelmeanx freqbodyaccelmeany
##  Min.   :-1.0000        Min.   :-1.0000    Min.   :-1.0000   
##  1st Qu.:-0.9922        1st Qu.:-0.9913    1st Qu.:-0.9792   
##  Median :-0.9403        Median :-0.9456    Median :-0.8643   
##  Mean   :-0.7780        Mean   :-0.6228    Mean   :-0.5375   
##  3rd Qu.:-0.6093        3rd Qu.:-0.2646    3rd Qu.:-0.1032   
##  Max.   : 1.0000        Max.   : 1.0000    Max.   : 1.0000   
##  freqbodyaccelmeanz freqbodyaccelstdx freqbodyaccelstdy  freqbodyaccelstdz
##  Min.   :-1.0000    Min.   :-1.0000   Min.   :-1.00000   Min.   :-1.0000  
##  1st Qu.:-0.9832    1st Qu.:-0.9929   1st Qu.:-0.97689   1st Qu.:-0.9780  
##  Median :-0.8954    Median :-0.9416   Median :-0.83261   Median :-0.8398  
##  Mean   :-0.6650    Mean   :-0.6034   Mean   :-0.52842   Mean   :-0.6179  
##  3rd Qu.:-0.3662    3rd Qu.:-0.2493   3rd Qu.:-0.09216   3rd Qu.:-0.3023  
##  Max.   : 1.0000    Max.   : 1.0000   Max.   : 1.00000   Max.   : 1.0000  
##  freqbodyacceljerkmeanx freqbodyacceljerkmeany freqbodyacceljerkmeanz
##  Min.   :-1.0000        Min.   :-1.0000        Min.   :-1.0000       
##  1st Qu.:-0.9912        1st Qu.:-0.9848        1st Qu.:-0.9873       
##  Median :-0.9516        Median :-0.9257        Median :-0.9475       
##  Mean   :-0.6567        Mean   :-0.6290        Mean   :-0.7436       
##  3rd Qu.:-0.3270        3rd Qu.:-0.2638        3rd Qu.:-0.5133       
##  Max.   : 1.0000        Max.   : 1.0000        Max.   : 1.0000       
##  freqbodyacceljerkstdx freqbodyacceljerkstdy freqbodyacceljerkstdz
##  Min.   :-1.0000       Min.   :-1.0000       Min.   :-1.0000      
##  1st Qu.:-0.9920       1st Qu.:-0.9865       1st Qu.:-0.9895      
##  Median :-0.9562       Median :-0.9280       Median :-0.9590      
##  Mean   :-0.6550       Mean   :-0.6122       Mean   :-0.7809      
##  3rd Qu.:-0.3203       3rd Qu.:-0.2361       3rd Qu.:-0.5903      
##  Max.   : 1.0000       Max.   : 1.0000       Max.   : 1.0000      
##  freqbodygyromeanx freqbodygyromeany freqbodygyromeanz freqbodygyrostdx 
##  Min.   :-1.0000   Min.   :-1.0000   Min.   :-1.0000   Min.   :-1.0000  
##  1st Qu.:-0.9853   1st Qu.:-0.9847   1st Qu.:-0.9851   1st Qu.:-0.9881  
##  Median :-0.8917   Median :-0.9197   Median :-0.8877   Median :-0.9053  
##  Mean   :-0.6721   Mean   :-0.7062   Mean   :-0.6442   Mean   :-0.7386  
##  3rd Qu.:-0.3837   3rd Qu.:-0.4735   3rd Qu.:-0.3225   3rd Qu.:-0.5225  
##  Max.   : 1.0000   Max.   : 1.0000   Max.   : 1.0000   Max.   : 1.0000  
##  freqbodygyrostdy  freqbodygyrostdz  freqbodyaccelmagmean
##  Min.   :-1.0000   Min.   :-1.0000   Min.   :-1.0000     
##  1st Qu.:-0.9808   1st Qu.:-0.9862   1st Qu.:-0.9847     
##  Median :-0.9061   Median :-0.8915   Median :-0.8755     
##  Mean   :-0.6742   Mean   :-0.6904   Mean   :-0.5860     
##  3rd Qu.:-0.4385   3rd Qu.:-0.4168   3rd Qu.:-0.2173     
##  Max.   : 1.0000   Max.   : 1.0000   Max.   : 1.0000     
##  freqbodyaccelmagstd freqbodyacceljerkmagmean freqbodyacceljerkmagstd
##  Min.   :-1.0000     Min.   :-1.0000          Min.   :-1.0000        
##  1st Qu.:-0.9829     1st Qu.:-0.9898          1st Qu.:-0.9907        
##  Median :-0.8547     Median :-0.9290          Median :-0.9255        
##  Mean   :-0.6595     Mean   :-0.6208          Mean   :-0.6401        
##  3rd Qu.:-0.3823     3rd Qu.:-0.2600          3rd Qu.:-0.3082        
##  Max.   : 1.0000     Max.   : 1.0000          Max.   : 1.0000        
##  freqbodygyromagmean freqbodygyromagstd freqbodygyrojerkmagmean
##  Min.   :-1.0000     Min.   :-1.0000    Min.   :-1.0000        
##  1st Qu.:-0.9825     1st Qu.:-0.9781    1st Qu.:-0.9921        
##  Median :-0.8756     Median :-0.8275    Median :-0.9453        
##  Mean   :-0.6974     Mean   :-0.7000    Mean   :-0.7798        
##  3rd Qu.:-0.4514     3rd Qu.:-0.4713    3rd Qu.:-0.6122        
##  Max.   : 1.0000     Max.   : 1.0000    Max.   : 1.0000        
##  freqbodygyrojerkmagstd
##  Min.   :-1.0000       
##  1st Qu.:-0.9926       
##  Median :-0.9382       
##  Mean   :-0.7922       
##  3rd Qu.:-0.6437       
##  Max.   : 1.0000
```

## Step 4: Save combined tidied data (named tidybodymotion.txt)

```r
write.table(combined, file="data/tidybodymotion.txt", row.names=FALSE)
```
## Read it in with the following...
*read.table("data/tidybodymotion.txt", header = TRUE)*

## Create the 2nd tidy set aggregating the data by average. 
As stated in the instructions:

> From the data set in step 4, creates a second, 
> independent tidy data set with the average of each variable for each activity 
> and each subject.

```r
library(plyr)
```

```
## -------------------------------------------------------------------------
```

```
## You have loaded plyr after dplyr - this is likely to cause problems.
## If you need functions from both plyr and dplyr, please load plyr first, then dplyr:
## library(plyr); library(dplyr)
```

```
## -------------------------------------------------------------------------
```

```
## 
## Attaching package: 'plyr'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
```

```r
aggcombined <- aggregate(. ~subjectid + activity, combined, mean)
aggcombined <- aggcombined[order(aggcombined$subjectid,aggcombined$activity),]
write.table(aggcombined, file = "data/tidybodymotionmean.txt",row.names=FALSE)
head(aggcombined, 12)
```

```
##     subjectid           activity activityid timebodyaccelmeanx
## 1           1            WALKING          1          0.2773308
## 31          1   WALKING_UPSTAIRS          2          0.2554617
## 61          1 WALKING_DOWNSTAIRS          3          0.2891883
## 91          1            SITTING          4          0.2612376
## 121         1           STANDING          5          0.2789176
## 151         1             LAYING          6          0.2215982
## 2           2            WALKING          1          0.2764266
## 32          2   WALKING_UPSTAIRS          2          0.2471648
## 62          2 WALKING_DOWNSTAIRS          3          0.2776153
## 92          2            SITTING          4          0.2770874
## 122         2           STANDING          5          0.2779115
## 152         2             LAYING          6          0.2813734
##     timebodyaccelmeany timebodyaccelmeanz timebodyaccelstdx
## 1         -0.017383819         -0.1111481       -0.28374026
## 31        -0.023953149         -0.0973020       -0.35470803
## 61        -0.009918505         -0.1075662        0.03003534
## 91        -0.001308288         -0.1045442       -0.97722901
## 121       -0.016137590         -0.1106018       -0.99575990
## 151       -0.040513953         -0.1132036       -0.92805647
## 2         -0.018594920         -0.1055004       -0.42364284
## 32        -0.021412113         -0.1525139       -0.30437641
## 62        -0.022661416         -0.1168129        0.04636668
## 92        -0.015687994         -0.1092183       -0.98682228
## 122       -0.018420827         -0.1059085       -0.98727189
## 152       -0.018158740         -0.1072456       -0.97405946
##     timebodyaccelstdy timebodyaccelstdz timegravityaccelmeanx
## 1         0.114461337       -0.26002790             0.9352232
## 31       -0.002320265       -0.01947924             0.8933511
## 61       -0.031935943       -0.23043421             0.9318744
## 91       -0.922618642       -0.93958629             0.8315099
## 121      -0.973190056       -0.97977588             0.9429520
## 151      -0.836827406       -0.82606140            -0.2488818
## 2        -0.078091253       -0.42525752             0.9130173
## 32        0.108027280       -0.11212102             0.7907174
## 62        0.262881789       -0.10283791             0.8618313
## 92       -0.950704499       -0.95982817             0.9404773
## 122      -0.957304989       -0.94974185             0.8969286
## 152      -0.980277399       -0.98423330            -0.5097542
##     timegravityaccelmeany timegravityaccelmeanz timegravityaccelstdx
## 1              -0.2821650           -0.06810286           -0.9766096
## 31             -0.3621534           -0.07540294           -0.9563670
## 61             -0.2666103           -0.06211996           -0.9505598
## 91              0.2044116            0.33204370           -0.9684571
## 121            -0.2729838            0.01349058           -0.9937630
## 151             0.7055498            0.44581772           -0.8968300
## 2              -0.3466071            0.08472709           -0.9726932
## 32             -0.4162149           -0.19588824           -0.9344077
## 62             -0.3257801           -0.04388902           -0.9403618
## 92             -0.1056300            0.19872677           -0.9799888
## 122            -0.3700627            0.12974716           -0.9866858
## 152             0.7525366            0.64683488           -0.9590144
##     timegravityaccelstdy timegravityaccelstdz timebodyacceljerkmeanx
## 1             -0.9713060           -0.9477172             0.07404163
## 31            -0.9528492           -0.9123794             0.10137273
## 61            -0.9370187           -0.8959397             0.05415532
## 91            -0.9355171           -0.9490409             0.07748252
## 121           -0.9812260           -0.9763241             0.07537665
## 151           -0.9077200           -0.8523663             0.08108653
## 2             -0.9721169           -0.9720728             0.06180807
## 32            -0.9237675           -0.8780041             0.07445078
## 62            -0.9400685           -0.9314383             0.11004062
## 92            -0.9567503           -0.9544159             0.07225644
## 122           -0.9741944           -0.9459271             0.07475886
## 152           -0.9882119           -0.9842304             0.08259725
##     timebodyacceljerkmeany timebodyacceljerkmeanz timebodyacceljerkstdx
## 1             0.0282721096           -0.004168406           -0.11361560
## 31            0.0194863076           -0.045562545           -0.44684389
## 61            0.0296504490           -0.010971973           -0.01228386
## 91           -0.0006191028           -0.003367792           -0.98643071
## 121           0.0079757309           -0.003685250           -0.99460454
## 151           0.0038382040            0.010834236           -0.95848211
## 2             0.0182492679            0.007895337           -0.27753046
## 32           -0.0097098551            0.019481439           -0.27612189
## 62           -0.0032795908           -0.020935168            0.14724914
## 92            0.0116954511            0.007605469           -0.98805585
## 122           0.0103291775           -0.008371588           -0.98108572
## 152           0.0122547885           -0.001802649           -0.98587217
##     timebodyacceljerkstdy timebodyacceljerkstdz timebodygyromeanx
## 1              0.06700250            -0.5026998       -0.04183096
## 31            -0.37827443            -0.7065935        0.05054938
## 61            -0.10160139            -0.3457350       -0.03507819
## 91            -0.98137197            -0.9879108       -0.04535006
## 121           -0.98564873            -0.9922512       -0.02398773
## 151           -0.92414927            -0.9548551       -0.01655309
## 2             -0.01660224            -0.5860904       -0.05302582
## 32            -0.18564895            -0.5737464       -0.05769126
## 62             0.12682801            -0.3401220       -0.11594735
## 92            -0.97798396            -0.9875182       -0.04547066
## 122           -0.97105944            -0.9828414       -0.02386239
## 152           -0.98317254            -0.9884420       -0.01847661
##     timebodygyromeany timebodygyromeanz timebodygyrostdx timebodygyrostdy
## 1        -0.069530046        0.08494482       -0.4735355     -0.054607769
## 31       -0.166170015        0.05835955       -0.5448711      0.004105184
## 61       -0.090937129        0.09008501       -0.4580305     -0.126349195
## 91       -0.091924155        0.06293138       -0.9772113     -0.966473895
## 121      -0.059397221        0.07480075       -0.9871919     -0.987734440
## 151      -0.064486124        0.14868944       -0.8735439     -0.951090440
## 2        -0.048238232        0.08283366       -0.5615503     -0.538453668
## 32       -0.032088310        0.06883740       -0.4392531     -0.466298337
## 62       -0.004823292        0.09717381       -0.3207892     -0.415739145
## 92       -0.059928680        0.04122775       -0.9857420     -0.978919527
## 122      -0.082039658        0.08783517       -0.9729986     -0.971441996
## 152      -0.111800825        0.14488285       -0.9882752     -0.982291609
##     timebodygyrostdz timebodygyrojerkmeanx timebodygyrojerkmeany
## 1         -0.3442666           -0.08999754           -0.03984287
## 31        -0.5071687           -0.12223277           -0.04214859
## 61        -0.1247025           -0.07395920           -0.04399028
## 91        -0.9414259           -0.09367938           -0.04021181
## 121       -0.9806456           -0.09960921           -0.04406279
## 151       -0.9082847           -0.10727095           -0.04151729
## 2         -0.4810855           -0.08188334           -0.05382994
## 32        -0.1639958           -0.08288580           -0.04240537
## 62        -0.2794184           -0.05810385           -0.04214703
## 92        -0.9598037           -0.09363284           -0.04156020
## 122       -0.9648567           -0.10556216           -0.04224195
## 152       -0.9603066           -0.10197413           -0.03585902
##     timebodygyrojerkmeanz timebodygyrojerkstdx timebodygyrojerkstdy
## 1             -0.04613093           -0.2074219           -0.3044685
## 31            -0.04071255           -0.6147865           -0.6016967
## 61            -0.02704611           -0.4870273           -0.2388248
## 91            -0.04670263           -0.9917316           -0.9895181
## 121           -0.04895055           -0.9929451           -0.9951379
## 151           -0.07405012           -0.9186085           -0.9679072
## 2             -0.05149392           -0.3895498           -0.6341404
## 32            -0.04451575           -0.4648544           -0.6454913
## 62            -0.07102298           -0.2439406           -0.4693967
## 92            -0.04358510           -0.9897090           -0.9908896
## 122           -0.05465395           -0.9793240           -0.9834473
## 152           -0.07017830           -0.9932358           -0.9895675
##     timebodygyrojerkstdz timebodyaccelmagmean timebodyaccelmagstd
## 1             -0.4042555          -0.13697118         -0.21968865
## 31            -0.6063320          -0.12992763         -0.32497093
## 61            -0.2687615           0.02718829          0.01988435
## 91            -0.9879358          -0.94853679         -0.92707842
## 121           -0.9921085          -0.98427821         -0.98194293
## 151           -0.9577902          -0.84192915         -0.79514486
## 2             -0.4354927          -0.29040759         -0.42254417
## 32            -0.4675960          -0.10732268         -0.20597705
## 62            -0.2182663           0.08995112          0.21558633
## 92            -0.9855423          -0.96789362         -0.95308144
## 122           -0.9736101          -0.96587518         -0.95787497
## 152           -0.9880358          -0.97743549         -0.97287391
##     timegravityaccelmagmean timegravityaccelmagstd
## 1               -0.13697118            -0.21968865
## 31              -0.12992763            -0.32497093
## 61               0.02718829             0.01988435
## 91              -0.94853679            -0.92707842
## 121             -0.98427821            -0.98194293
## 151             -0.84192915            -0.79514486
## 2               -0.29040759            -0.42254417
## 32              -0.10732268            -0.20597705
## 62               0.08995112             0.21558633
## 92              -0.96789362            -0.95308144
## 122             -0.96587518            -0.95787497
## 152             -0.97743549            -0.97287391
##     timebodyacceljerkmagmean timebodyacceljerkmagstd timebodygyromagmean
## 1               -0.141428809             -0.07447175         -0.16097955
## 31              -0.466503446             -0.47899162         -0.12673559
## 61              -0.089447481             -0.02578772         -0.07574125
## 91              -0.987364196             -0.98412002         -0.93089249
## 121             -0.992367791             -0.99309621         -0.97649379
## 151             -0.954396265             -0.92824563         -0.87475955
## 2               -0.281424154             -0.16415099         -0.44654909
## 32              -0.321268911             -0.21738939         -0.21971347
## 62               0.005655163              0.22961719         -0.16218859
## 92              -0.986774713             -0.98447587         -0.94603509
## 122             -0.980489077             -0.97667528         -0.96346634
## 152             -0.987741696             -0.98551808         -0.95001157
##     timebodygyromagstd timebodygyrojerkmagmean timebodygyrojerkmagstd
## 1           -0.1869784              -0.2987037             -0.3253249
## 31          -0.1486193              -0.5948829             -0.6485530
## 61          -0.2257244              -0.2954638             -0.3065106
## 91          -0.9345318              -0.9919763             -0.9883087
## 121         -0.9786900              -0.9949668             -0.9947332
## 151         -0.8190102              -0.9634610             -0.9358410
## 2           -0.5530199              -0.5479120             -0.5577982
## 32          -0.3775322              -0.5728164             -0.5972917
## 62          -0.2748441              -0.4108727             -0.3431879
## 92          -0.9613136              -0.9910815             -0.9895949
## 122         -0.9539434              -0.9839519             -0.9772044
## 152         -0.9611641              -0.9917671             -0.9897181
##     freqbodyaccelmeanx freqbodyaccelmeany freqbodyaccelmeanz
## 1          -0.20279431        0.089712726         -0.3315601
## 31         -0.40432178       -0.190976721         -0.4333497
## 61          0.03822918        0.001549908         -0.2255745
## 91         -0.97964124       -0.944084550         -0.9591849
## 121        -0.99524993       -0.977070848         -0.9852971
## 151        -0.93909905       -0.867065205         -0.8826669
## 2          -0.34604816       -0.021904810         -0.4538064
## 32         -0.26672093        0.009924459         -0.2810020
## 62          0.11284116        0.278345042         -0.1312908
## 92         -0.98580384       -0.957343498         -0.9701622
## 122        -0.98394674       -0.959871697         -0.9624712
## 152        -0.97672506       -0.979800878         -0.9843810
##     freqbodyaccelstdx freqbodyaccelstdy freqbodyaccelstdz
## 1         -0.31913472        0.05604001       -0.27968675
## 31        -0.33742819        0.02176951        0.08595655
## 61         0.02433084       -0.11296374       -0.29792789
## 91        -0.97641231       -0.91727501       -0.93446956
## 121       -0.99602835       -0.97229310       -0.97793726
## 151       -0.92443743       -0.83362556       -0.81289156
## 2         -0.45765138       -0.16921969       -0.45522215
## 32        -0.32058241        0.08488028       -0.09454498
## 62         0.01610462        0.17197397       -0.16203289
## 92        -0.98736209       -0.95007375       -0.95686286
## 122       -0.98905647       -0.95790884       -0.94643358
## 152       -0.97324648       -0.98102511       -0.98479218
##     freqbodyacceljerkmeanx freqbodyacceljerkmeany freqbodyacceljerkmeanz
## 1              -0.17054696            -0.03522552             -0.4689992
## 31             -0.47987525            -0.41344459             -0.6854744
## 61             -0.02766387            -0.12866716             -0.2883347
## 91             -0.98659702            -0.98157947             -0.9860531
## 121            -0.99463080            -0.98541870             -0.9907522
## 151            -0.95707388            -0.92246261             -0.9480609
## 2              -0.30461532            -0.07876408             -0.5549567
## 32             -0.25863944            -0.18784213             -0.5227281
## 62              0.13812068             0.09620916             -0.2714987
## 92             -0.98784879            -0.97713970             -0.9851291
## 122            -0.98097324            -0.97085134             -0.9797752
## 152            -0.98581363            -0.98276825             -0.9861971
##     freqbodyacceljerkstdx freqbodyacceljerkstdy freqbodyacceljerkstdz
## 1             -0.13358661            0.10673986            -0.5347134
## 31            -0.46190703           -0.38177707            -0.7260402
## 61            -0.08632790           -0.13458001            -0.4017215
## 91            -0.98749299           -0.98251391            -0.9883392
## 121           -0.99507376           -0.98701823            -0.9923498
## 151           -0.96416071           -0.93221787            -0.9605870
## 2             -0.31431306           -0.01533295            -0.6158982
## 32            -0.36541544           -0.24355415            -0.6250910
## 62             0.04995906            0.08083335            -0.4082274
## 92            -0.98945911           -0.98080423            -0.9885708
## 122           -0.98300792           -0.97352024            -0.9845999
## 152           -0.98725026           -0.98498739            -0.9893454
##     freqbodygyromeanx freqbodygyromeany freqbodygyromeanz freqbodygyrostdx
## 1          -0.3390322       -0.10305942       -0.25594094       -0.5166919
## 31         -0.4926117       -0.31947461       -0.45359721       -0.5658925
## 61         -0.3524496       -0.05570225       -0.03186943       -0.4954225
## 91         -0.9761615       -0.97583859       -0.95131554       -0.9779042
## 121        -0.9863868       -0.98898446       -0.98077312       -0.9874971
## 151        -0.8502492       -0.95219149       -0.90930272       -0.8822965
## 2          -0.4297135       -0.55477211       -0.39665991       -0.6040530
## 32         -0.3316436       -0.48808612       -0.24860112       -0.4763588
## 62         -0.1457760       -0.36191382       -0.08749447       -0.3794367
## 92         -0.9826214       -0.98210092       -0.95981482       -0.9868085
## 122        -0.9670371       -0.97257615       -0.96062770       -0.9749881
## 152        -0.9864311       -0.98332164       -0.96267189       -0.9888607
##     freqbodygyrostdy freqbodygyrostdz freqbodyaccelmagmean
## 1        -0.03350816       -0.4365622          -0.12862345
## 31        0.15153891       -0.5717078          -0.35239594
## 61       -0.18141473       -0.2384436           0.09658453
## 91       -0.96234504       -0.9439178          -0.94778292
## 121      -0.98710773       -0.9823453          -0.98535636
## 151      -0.95123205       -0.9165825          -0.86176765
## 2        -0.53304695       -0.5598566          -0.32428943
## 32       -0.45975849       -0.2180725          -0.14531854
## 62       -0.45873275       -0.4229877           0.29342483
## 92       -0.97735619       -0.9635227          -0.96127375
## 122      -0.97103605       -0.9697543          -0.96405217
## 152      -0.98191062       -0.9631742          -0.97511020
##     freqbodyaccelmagstd freqbodyacceljerkmagmean freqbodyacceljerkmagstd
## 1           -0.39803259              -0.05711940              -0.1034924
## 31          -0.41626010              -0.44265216              -0.5330599
## 61          -0.18653030               0.02621849              -0.1040523
## 91          -0.92844480              -0.98526213              -0.9816062
## 121         -0.98231380              -0.99254248              -0.9925360
## 151         -0.79830094              -0.93330036              -0.9218040
## 2           -0.57710521              -0.16906435              -0.1640920
## 32          -0.36672824              -0.18951114              -0.2604238
## 62          -0.02147879               0.22224741               0.2274807
## 92          -0.95557560              -0.98387470              -0.9841242
## 122         -0.96051938              -0.97706530              -0.9751605
## 152         -0.97512139              -0.98537411              -0.9845685
##     freqbodygyromagmean freqbodygyromagstd freqbodygyrojerkmagmean
## 1            -0.1992526         -0.3210180              -0.3193086
## 31           -0.3259615         -0.1829855              -0.6346651
## 61           -0.1857203         -0.3983504              -0.2819634
## 91           -0.9584356         -0.9321984              -0.9897975
## 121          -0.9846176         -0.9784661              -0.9948154
## 151          -0.8621902         -0.8243194              -0.9423669
## 2            -0.5307048         -0.6517928              -0.5832493
## 32           -0.4506122         -0.4386204              -0.6007985
## 62           -0.3208385         -0.3725768              -0.3801753
## 92           -0.9718406         -0.9613857              -0.9898620
## 122          -0.9617759         -0.9567887              -0.9778498
## 152          -0.9721130         -0.9610984              -0.9902487
##     freqbodygyrojerkmagstd
## 1               -0.3816019
## 31              -0.6939305
## 61              -0.3919199
## 91              -0.9870496
## 121             -0.9946711
## 151             -0.9326607
## 2               -0.5581046
## 32              -0.6218202
## 62              -0.3436990
## 92              -0.9896329
## 122             -0.9777543
## 152             -0.9894927
```

```r
tail(aggcombined, 12)
```

```
##     subjectid           activity activityid timebodyaccelmeanx
## 29         29            WALKING          1          0.2719999
## 59         29   WALKING_UPSTAIRS          2          0.2654231
## 89         29 WALKING_DOWNSTAIRS          3          0.2931404
## 119        29            SITTING          4          0.2771800
## 149        29           STANDING          5          0.2779651
## 179        29             LAYING          6          0.2872952
## 30         30            WALKING          1          0.2764068
## 60         30   WALKING_UPSTAIRS          2          0.2714156
## 90         30 WALKING_DOWNSTAIRS          3          0.2831906
## 120        30            SITTING          4          0.2683361
## 150        30           STANDING          5          0.2771127
## 180        30             LAYING          6          0.2810339
##     timebodyaccelmeany timebodyaccelmeanz timebodyaccelstdx
## 29        -0.016291560        -0.10663243       -0.17433794
## 59        -0.029946531        -0.11800059       -0.08677156
## 89        -0.014941215        -0.09813400        0.16738360
## 119       -0.016630680        -0.11041182       -0.99074502
## 149       -0.017260587        -0.10865907       -0.99606864
## 179       -0.017196548        -0.10946207       -0.98421956
## 30        -0.017588039        -0.09862471       -0.34639428
## 60        -0.025331170        -0.12469749       -0.35050448
## 90        -0.017438390        -0.09997814       -0.05777032
## 120       -0.008047313        -0.09951545       -0.98362274
## 150       -0.017016389        -0.10875621       -0.97755943
## 180       -0.019449410        -0.10365815       -0.97636252
##     timebodyaccelstdy timebodyaccelstdz timegravityaccelmeanx
## 29        -0.09175406       -0.24282804             0.9623744
## 59        -0.12212829        0.09954435             0.9292590
## 89        -0.12246347       -0.22317800             0.9484862
## 119       -0.96322250       -0.96806388             0.8915638
## 149       -0.96929572       -0.98020749             0.9745087
## 179       -0.99024095       -0.98725515            -0.3467898
## 30        -0.17355002       -0.12047678             0.9652176
## 60        -0.12731116        0.02494680             0.9318298
## 90        -0.02726281       -0.21727569             0.9580005
## 120       -0.93785700       -0.95065404             0.8254738
## 150       -0.89165453       -0.91285060             0.9685567
## 180       -0.95420182       -0.96704424            -0.3447378
##     timegravityaccelmeany timegravityaccelmeanz timegravityaccelstdx
## 29            -0.12731808           0.095579214           -0.9782535
## 59            -0.22712013           0.044378601           -0.9541890
## 89            -0.07609630           0.091965045           -0.9417362
## 119            0.15565946           0.286256064           -0.9846792
## 149           -0.05848715           0.031614585           -0.9967642
## 179            0.80753537           0.590452224           -0.9729399
## 30            -0.15767382          -0.003925564           -0.9797525
## 60            -0.22664729          -0.022140110           -0.9540336
## 90            -0.12671037           0.028808167           -0.9588904
## 120            0.11458839           0.344766020           -0.9783647
## 150           -0.10029680           0.024304436           -0.9964209
## 180            0.73266125           0.681459211           -0.9795639
##     timegravityaccelstdy timegravityaccelstdz timebodyacceljerkmeanx
## 29            -0.9752728           -0.9459814             0.08537433
## 59            -0.9230078           -0.8588495             0.10634519
## 89            -0.9139031           -0.8693009             0.06368720
## 119           -0.9736043           -0.9660320             0.07454381
## 149           -0.9851340           -0.9844645             0.07530525
## 179           -0.9942476           -0.9857782             0.07188612
## 30            -0.9701766           -0.9439584             0.06886900
## 60            -0.9149339           -0.8624028             0.05798404
## 90            -0.9186788           -0.8776671             0.08839330
## 120           -0.9593613           -0.9566357             0.07600577
## 150           -0.9581458           -0.9492074             0.07524145
## 180           -0.9889307           -0.9832745             0.07521967
##     timebodyacceljerkmeany timebodyacceljerkmeanz timebodyacceljerkstdx
## 29            0.0223870454           0.0094154730           -0.22143354
## 59           -0.0006890192          -0.0290713872           -0.18236582
## 89            0.0006210170          -0.0140642983           -0.02395257
## 119           0.0059853140           0.0031677010           -0.99352556
## 149           0.0115104979           0.0003328950           -0.99365282
## 179           0.0116912060           0.0024154278           -0.99200599
## 30            0.0219656545          -0.0073953424           -0.37440094
## 60           -0.0035871923           0.0161506199           -0.53542020
## 90           -0.0075611075          -0.0118301423           -0.22664390
## 120           0.0097569252          -0.0027816183           -0.98886458
## 150           0.0120860416           0.0019084146           -0.96843075
## 180           0.0107680190          -0.0003741897           -0.97746378
##     timebodyacceljerkstdy timebodyacceljerkstdz timebodygyromeanx
## 29            -0.08717464            -0.4617580      -0.007956682
## 59            -0.38862420            -0.6787638       0.093198946
## 89            -0.07734084            -0.4787642      -0.037412607
## 119           -0.98405510            -0.9901687      -0.037927111
## 149           -0.98333816            -0.9905939      -0.027607557
## 179           -0.98951357            -0.9932883      -0.025828100
## 30            -0.27070927            -0.5213519      -0.045950536
## 60            -0.58721454            -0.7619420      -0.003559746
## 90            -0.19465610            -0.4670702      -0.074559130
## 120           -0.98042093            -0.9881644      -0.035842648
## 150           -0.95731888            -0.9688973      -0.027613854
## 180           -0.97104978            -0.9795179      -0.026781222
##     timebodygyromeany timebodygyromeanz timebodygyrostdx timebodygyrostdy
## 29        -0.08196015        0.08568522       -0.5988687     -0.181802637
## 59        -0.15232811        0.08543181       -0.3239047      0.046110305
## 89        -0.08510459        0.08222441       -0.2820773     -0.390460138
## 119       -0.07557977        0.05804960       -0.9901787     -0.988334020
## 149       -0.07210607        0.08275838       -0.9779948     -0.990364876
## 179       -0.07618144        0.12741197       -0.9942766     -0.992750958
## 30        -0.06491709        0.08395682       -0.3879206      0.006002779
## 60        -0.07796065        0.08146993       -0.4938375     -0.084048151
## 90        -0.06931124        0.08957678       -0.2659232     -0.285392416
## 120       -0.07435356        0.07020026       -0.9881327     -0.976477562
## 150       -0.06703344        0.08025148       -0.9114085     -0.940705412
## 180       -0.07614764        0.09384722       -0.9736628     -0.966041673
##     timebodygyrostdz timebodygyrojerkmeanx timebodygyrojerkmeany
## 29        -0.4302324           -0.10688830           -0.04798981
## 59        -0.3748151           -0.13042907           -0.05110351
## 89        -0.3111226           -0.07439865           -0.06714823
## 119       -0.9712280           -0.09536370           -0.04000184
## 149       -0.9833686           -0.09887015           -0.04051106
## 179       -0.9749946           -0.09953399           -0.03867683
## 30        -0.1825697           -0.08738399           -0.06170289
## 60        -0.2115736           -0.10841426           -0.01411134
## 90        -0.2953704           -0.06159546           -0.04968076
## 120       -0.9550532           -0.09527077           -0.04079306
## 150       -0.9308347           -0.09971602           -0.04377597
## 180       -0.9688892           -0.10227736           -0.03848759
##     timebodygyrojerkmeanz timebodygyrojerkstdx timebodygyrojerkstdy
## 29            -0.03923690           -0.3959096           -0.5879443
## 59            -0.06809388           -0.4749326           -0.7342252
## 89            -0.03596484           -0.3478076           -0.6934690
## 119           -0.04700090           -0.9933220           -0.9953192
## 149           -0.05449263           -0.9832931           -0.9955331
## 179           -0.06744697           -0.9965425           -0.9970816
## 30            -0.04460072           -0.4603454           -0.4976218
## 60            -0.03641578           -0.7427495           -0.7433370
## 90            -0.05435952           -0.5427645           -0.6137963
## 120           -0.04882046           -0.9938685           -0.9924913
## 150           -0.05203072           -0.9601191           -0.9681350
## 180           -0.05957368           -0.9837758           -0.9803571
##     timebodygyrojerkstdz timebodyaccelmagmean timebodyaccelmagstd
## 29            -0.5041301         -0.095521339         -0.26269506
## 59            -0.5584170          0.008343603         -0.04146961
## 89            -0.3797694          0.103705166          0.13448115
## 119           -0.9928338         -0.978017022         -0.96929032
## 149           -0.9906857         -0.984745319         -0.98174571
## 179           -0.9953808         -0.986493197         -0.98157215
## 30            -0.4762088         -0.195140033         -0.35987341
## 60            -0.6651506         -0.137627857         -0.32741082
## 90            -0.4988829         -0.037390112         -0.01357712
## 120           -0.9881245         -0.957487221         -0.94290147
## 150           -0.9708457         -0.930573575         -0.91657044
## 180           -0.9807689         -0.969829984         -0.96016791
##     timegravityaccelmagmean timegravityaccelmagstd
## 29             -0.095521339            -0.26269506
## 59              0.008343603            -0.04146961
## 89              0.103705166             0.13448115
## 119            -0.978017022            -0.96929032
## 149            -0.984745319            -0.98174571
## 179            -0.986493197            -0.98157215
## 30             -0.195140033            -0.35987341
## 60             -0.137627857            -0.32741082
## 90             -0.037390112            -0.01357712
## 120            -0.957487221            -0.94290147
## 150            -0.930573575            -0.91657044
## 180            -0.969829984            -0.96016791
##     timebodyacceljerkmagmean timebodyacceljerkmagstd timebodygyromagmean
## 29                -0.2402317             -0.13303627         -0.28057327
## 59                -0.3443248             -0.25448518          0.04396277
## 89                -0.1386376             -0.03076934         -0.12296811
## 119               -0.9907198             -0.99053173         -0.96237733
## 149               -0.9907854             -0.99049569         -0.98065734
## 179               -0.9927254             -0.99464692         -0.97192362
## 30                -0.3521117             -0.35375102         -0.02296408
## 60                -0.5966001             -0.56183771         -0.11360837
## 90                -0.2937388             -0.12528318         -0.09553732
## 120               -0.9877991             -0.98605764         -0.95584732
## 150               -0.9712252             -0.95076227         -0.91389056
## 180               -0.9792328             -0.96964229         -0.96228492
##     timebodygyromagstd timebodygyrojerkmagmean timebodygyrojerkmagstd
## 29         -0.35881410              -0.5062421             -0.6122229
## 59         -0.08004762              -0.6173408             -0.7128463
## 89         -0.26740980              -0.5391745             -0.5970570
## 119        -0.97157802              -0.9953923             -0.9949053
## 149        -0.97535867              -0.9921447             -0.9914536
## 179        -0.97704009              -0.9973225             -0.9976661
## 30         -0.26684573              -0.4720687             -0.5469773
## 60         -0.16929353              -0.7187803             -0.7744391
## 90         -0.20826754              -0.5743370             -0.6176621
## 120        -0.96064129              -0.9937374             -0.9912802
## 150        -0.88724764              -0.9729953             -0.9559957
## 180        -0.95126444              -0.9850864             -0.9761771
##     freqbodyaccelmeanx freqbodyaccelmeany freqbodyaccelmeanz
## 29          -0.1358195        -0.03496423         -0.2797348
## 59          -0.1097935        -0.19601150         -0.3204879
## 89           0.1106632        -0.02122937         -0.2666922
## 119         -0.9910940        -0.96960950         -0.9756230
## 149         -0.9950240        -0.97334577         -0.9840960
## 179         -0.9866270        -0.98903430         -0.9894739
## 30          -0.3514029        -0.19385666         -0.3095589
## 60          -0.4204028        -0.29781377         -0.3675198
## 90          -0.1069670        -0.02166371         -0.2580674
## 120         -0.9850088        -0.95407604         -0.9662741
## 150         -0.9720141        -0.91947512         -0.9380898
## 180         -0.9747900        -0.95997427         -0.9703220
##     freqbodyaccelstdx freqbodyaccelstdy freqbodyaccelstdz
## 29        -0.19035598       -0.18206854       -0.28334810
## 59        -0.07906253       -0.14125807        0.20305784
## 89         0.18743862       -0.23934905       -0.26207324
## 119       -0.99061752       -0.96169395       -0.96580097
## 149       -0.99660457       -0.96827855       -0.97880297
## 179       -0.98343231       -0.99068040       -0.98637878
## 30        -0.34492811       -0.21563432       -0.09314476
## 60        -0.32626036       -0.10429918        0.12144741
## 90        -0.04052571       -0.09346826       -0.25739337
## 120       -0.98323101       -0.93399258       -0.94620382
## 150       -0.98042658       -0.88557278       -0.90728679
## 180       -0.97704526       -0.95355840       -0.96718820
##     freqbodyacceljerkmeanx freqbodyacceljerkmeany freqbodyacceljerkmeanz
## 29             -0.21046989            -0.08802134             -0.3948778
## 59             -0.22506777            -0.40888661             -0.6461986
## 89             -0.03824582            -0.09778507             -0.4111735
## 119            -0.99344576            -0.98388319             -0.9884702
## 149            -0.99373691            -0.98319498             -0.9885416
## 179            -0.99215398            -0.98939882             -0.9920184
## 30             -0.38959563            -0.29952534             -0.4670307
## 60             -0.55067842            -0.59291944             -0.7378039
## 90             -0.23492315            -0.22499278             -0.3996887
## 120            -0.98877544            -0.98040572             -0.9859783
## 150            -0.96785759            -0.95743489             -0.9628926
## 180            -0.97688790            -0.97169628             -0.9756324
##     freqbodyacceljerkstdx freqbodyacceljerkstdy freqbodyacceljerkstdz
## 29            -0.30733667            -0.1550207            -0.5290349
## 59            -0.21138540            -0.4086489            -0.7101166
## 89            -0.09863792            -0.1203815            -0.5473209
## 119           -0.99422018            -0.9854933            -0.9904459
## 149           -0.99412342            -0.9847828            -0.9913164
## 179           -0.99254348            -0.9904681            -0.9931078
## 30            -0.41513540            -0.2894661            -0.5754103
## 60            -0.56156521            -0.6108266            -0.7847539
## 90            -0.28980273            -0.2174320            -0.5355150
## 120           -0.99001756            -0.9819021            -0.9889712
## 150           -0.97221673            -0.9604424            -0.9739543
## 180           -0.98035075            -0.9724342            -0.9822816
##     freqbodygyromeanx freqbodygyromeany freqbodygyromeanz freqbodygyrostdx
## 29         -0.4314900        -0.3622323        -0.3972775       -0.6543136
## 59         -0.2605193        -0.3940453        -0.3417001       -0.3503382
## 89         -0.1894180        -0.4631250        -0.1992259       -0.3191231
## 119        -0.9883936        -0.9903292        -0.9739336       -0.9907278
## 149        -0.9744854        -0.9915867        -0.9836547       -0.9791626
## 179        -0.9931226        -0.9936963        -0.9761843       -0.9946522
## 30         -0.3744403        -0.1759009        -0.2473503       -0.3990323
## 60         -0.4880390        -0.3660584        -0.3189370       -0.5034842
## 90         -0.2630616        -0.3480651        -0.2637208       -0.2783866
## 120        -0.9870346        -0.9820059        -0.9611771       -0.9884848
## 150        -0.9157429        -0.9456288        -0.9377981       -0.9117182
## 180        -0.9717891        -0.9681703        -0.9675774       -0.9744884
##     freqbodygyrostdy freqbodygyrostdz freqbodyaccelmagmean
## 29       -0.09413597       -0.4941175          -0.23568331
## 59        0.23434678       -0.4441531          -0.10830640
## 89       -0.35487269       -0.4161658           0.11597397
## 119      -0.98725981       -0.9729125          -0.97334653
## 149      -0.98964372       -0.9847142          -0.98454809
## 179      -0.99224079       -0.9768590          -0.98680065
## 30        0.09554560       -0.2379415          -0.34236377
## 60        0.04495455       -0.2534271          -0.40058835
## 90       -0.25573205       -0.3715415           0.00410151
## 120      -0.97380495       -0.9573087          -0.95992339
## 150      -0.93946977       -0.9351769          -0.93204745
## 180      -0.96513415       -0.9721992          -0.96284082
##     freqbodyaccelmagstd freqbodyacceljerkmagmean freqbodyacceljerkmagstd
## 29          -0.39325751            -0.1089782065             -0.16950650
## 59          -0.15599376            -0.2391080467             -0.28058356
## 89          -0.03308681             0.0004488963             -0.07977143
## 119         -0.97121802            -0.9900937038             -0.98982291
## 149         -0.98224772            -0.9897938926             -0.99032793
## 179         -0.98159978            -0.9939982758             -0.99436667
## 30          -0.46985279            -0.3471801347             -0.36653742
## 60          -0.39450808            -0.5497848906             -0.58087813
## 90          -0.17853517            -0.1259614004             -0.13312430
## 120         -0.94354373            -0.9858263310             -0.98529496
## 150         -0.92173323            -0.9533576159             -0.94663985
## 180         -0.96405181            -0.9699492696             -0.96808778
##     freqbodygyromagmean freqbodygyromagstd freqbodygyrojerkmagmean
## 29           -0.4168179        -0.42915683              -0.6285011
## 59           -0.3572139        -0.07433147              -0.6974546
## 89           -0.3814599        -0.32302458              -0.5965786
## 119          -0.9802694        -0.97101137              -0.9950630
## 149          -0.9808797        -0.97593873              -0.9916721
## 179          -0.9840013        -0.97667905              -0.9976174
## 30           -0.3583444        -0.33154174              -0.5476218
## 60           -0.4491507        -0.15147228              -0.7739745
## 90           -0.3567723        -0.25236188              -0.6175788
## 120          -0.9738763        -0.95951394              -0.9917507
## 150          -0.9174494        -0.88887223              -0.9592422
## 180          -0.9620012        -0.95264445              -0.9778213
##     freqbodygyrojerkmagstd
## 29              -0.6186677
## 59              -0.7564642
## 89              -0.6266760
## 119             -0.9947420
## 149             -0.9915168
## 179             -0.9975852
## 30              -0.5785800
## 60              -0.7913494
## 90              -0.6455039
## 120             -0.9909464
## 150             -0.9550086
## 180             -0.9754815
```

## Read it in with the following... 
*read.table("data/tidybodymotionmean.txt", header = TRUE)*



