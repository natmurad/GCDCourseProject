###Getting and Cleaning Data Course Project
###Author: Natália Faraj Murad

###Setting directiory and loading the packages
setwd("~/Desktop/GettingCleaningData")
library(data.table, reshape2)

###Getting the data
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

###Reading activity labels and features

activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)


###Loading train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

###Loading test datasets
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

###Merging data
datamerged <- rbind(train, test)

###Switching classLabels to activityName
datamerged[["Activity"]] <- factor(datamerged[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

datamerged[["SubjectNum"]] <- as.factor(datamerged[, SubjectNum])
datamerged <- melt(data = datamerged, id = c("SubjectNum", "Activity"))
datamerged <- dcast(data = datamerged, SubjectNum + Activity ~ variable, fun.aggregate = mean)

fwrite(x = datamerged, file = "tidyData.txt", quote = FALSE)