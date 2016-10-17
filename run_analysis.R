# ---------------------------------------------------------------------------------------
# tidy data script
# Get and unzip the data
# 1. get data and store in subdirectory ../data/UCI HAR Dataset.
# 
library(dplyr) 
if(!file.exists("./data")){dir.create("./data")}
dataurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataurl,destfile="./data/bodymotion.zip",method="curl")

unzip(zipfile="./data/bodymotion.zip",exdir="./data")
# Overview: 
# We don't create the combined file first, but rather process each test and training 
# set separately, then combine them for each type of data, X, y, and subject. 
# Finally, we combine them all together. 
# Note: during the combining, we always put the training datasets first. 
# 
# Start: 
# Read the features descriptions dataset so we can create a logical vector of the columns 
# we need to keep for this assignment. As the instructions state: 
# "Extract only the measurements on the mean and standard deviation for each measurement." 
# That means, from my reading, that any of the recorded variables which had mean or 
# std functions applied to them. 
# So, the only columns we need to keep are the ones that have -mean() or -std() in them. 
# We'll use grep to identify them.
# ---------------------------------------------------------------------------------------
features <- read.table("data/UCI HAR Dataset/features.txt", header = FALSE)

# Create the subset of features containing only -mean() and -std()
# This features data frame is named with prefix 'sub' 

subsettedfeatures <- grep("-mean\\(\\)|-std\\(\\)", features$V2)

# now we have the subset of features vector that we can use to select out 
# our columns of interest from the test and train datasets.

train <- read.table("data/UCI HAR Dataset/train/X_train.txt")
subfeattrain <- train[,subsettedfeatures]
test <- read.table("data/UCI HAR Dataset/test/X_test.txt")
subfeattest <- test[,subsettedfeatures]

namestotransform <- features[subsettedfeatures,2]

# now tidy up the subset of column names in namestotransform
# removing -, (),
# changing BodyBody to Body
# t to time
# f to freq
# acc to accel to make it more like accelerometer but nnot quite so long.
# make name all lowercase letters
namestotransform <- gsub("-","", namestotransform)
namestotransform <- gsub("\\(\\)","", namestotransform)
namestotransform <- gsub("BodyBody","Body", namestotransform)
namestotransform <- gsub("^t", "time",namestotransform)
namestotransform <- gsub("^f", "freq", namestotransform)
namestotransform <- gsub("Acc", "Accel", namestotransform)
namestotransform <- tolower(namestotransform)

# assign the transformed, expanded and cleaned up names to be the colnames of each 
# subsetted features dataset. 

colnames(subfeattest) <- namestotransform
colnames(subfeattrain) <- namestotransform

# now lets change the movement actions identifiers to be more descriptive 
# these next steps read the activity labels and then relabels the activity numbers
# so that they are readable character strings.

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
head(activitiestest)
# combine the y datasets
combinedactivity <- rbind(activitiestrain, activitiestest)
nrow(activitiestrain)
nrow(activitiestest)
nrow(combinedactivity)
str(combinedactivity)
combinedsubfeat <- rbind(subfeattrain, subfeattest)
nrow(subfeattrain)
nrow(subfeattest)
nrow(combinedsubfeat)
str(combinedsubfeat)
# now put proper column names to the subject id files. 
subjecttrain <- read.table("data/UCI HAR Dataset/train/subject_train.txt")
subjecttest  <- read.table("data/UCI HAR Dataset/test/subject_test.txt")
colnames(subjecttrain) <- "subjectid"
colnames(subjecttest) <- "subjectid"

head(subjecttrain)
tail(subjecttest)

combinedsubject <- rbind(subjecttrain, subjecttest)
head(combinedsubject)
tail(combinedsubject)

# finally, combine all the combined training and test files into the final combined file. 

combined <- cbind(combinedsubject, combinedactivity, combinedsubfeat)

str(combined)
head(combined)
summary(combined)

# and save it to the name tidybodymotion.txt

write.table(combined, file="data/tidybodymotion.txt", row.names=FALSE)

# read it in with the following... 
# read.table("data/tidybodymotion.txt", header = TRUE)

library(plyr)
aggcombined <- aggregate(. ~subjectid + activity, combined, mean)
aggcombined <- aggcombined[order(aggcombined$subjectid,aggcombined$activity),]
write.table(aggcombined, file = "data/tidybodymotionmean.txt",row.names=FALSE)
head(aggcombined)
tail(aggcombined)
# read it in with the following... 
# read.table("data/tidybodymotionmean.txt", header = TRUE)


