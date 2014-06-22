require(RCurl)
setwd("~/Google Drive/Data Science Certificate/GatheringData/")
download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="~/Google Drive/Data Science Certificate/GatheringData/data.zip")
unzip(zipfile="data.zip",exdir="~/Google Drive/Data Science Certificate/GatheringData/")

SubjectTest <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/test/subject_test.txt", quote="\"")
TestLabels <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/test/y_test.txt", quote="\"")
TestSet <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/test/X_test.txt", quote="\"")
SubjectTrain <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/train/subject_train.txt", quote="\"")
TrainLabels <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/train/y_train.txt", quote="\"")
TrainSet <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/train/X_train.txt", quote="\"")
featuresofset <- read.table("~/Google Drive/Data Science Certificate/GatheringData/UCI HAR Dataset/features.txt", quote="\"")

Test <- cbind(SubjectTest,TestLabels,TestSet)
Train <- cbind(SubjectTrain,TrainLabels,TrainSet)

Dataset <- rbind(Test,Train)

colnames(Test)[1:2] <- c("Subject","ActivityCode")
colnames(Test)[3:563] <- as.vector(featuresofset[,2])

means <- Dataset[,grep("mean",colnames(Dataset))]
std <- <- Dataset[,grep("std",colnames(Dataset))]
NewDataset <- cbind(Dataset$Subject,Dataset$ActivityCode,means,std)

activity_labels <- read.table(file="activity_labels.txt")
colnames(activity_labels)[1:2] <- c("ActivityCode","Activity")
Full_Dataset_w_activity_names <- merge(activity_labels,NewDataset,by="ActivityCode")

# Mean Freq os a weogjted average of the freq components, producing a mean freq
mean_std_data <- Full_Dataset_w_activity_names[, -(grep(paste0("meanFreq()"), colnames(Full_Dataset_w_activity_names), perl=T))]

# dim(mean_std_data)                                                                            #   10299    68
#
# Finally, construction of a "Tidy Dataset"
# Rows = 30 subjects BY 6 activities = 180 records, AND Columns =  subject + activity + 66 AVERAGES
library(reshape)
md <- melt(mean_std_data, id=(c("subject", "activity")))
dim(md)                                           # 679734      4       NOTE: 679,734 = 10,299 ROWS * 66 Variable Columns
tidy_averages <- cast(md, subject + activity ~ variable, fun.aggregate = mean)
dim(tidy_averages)                        #      [1] 180  68

require(plyr)
tidy_averages[ ,2] <- as.factor(tidy_averages[ ,2])
tidy_averages[ ,2] <- revalue(tidy_averages[ ,2], c("1"="walk", "2"="walk_up_stairs", "3"="walk_down_stairs", "4"="sit", "5"="stand", "6"="lay"))
tidy_averages[sample(1:180, 5), 1:5]              # Testing all is well by randomly sampling 5 rows, displaying first 5 columns
# write.table(tidy_averages, "tidy_averages.txt")               ### UGLY FORMAT
options(max.print=999999)
capture.output( print(tidy_averages, print.gap=3), file="UCI.HAR.JP.tidy.averages.txt")
#
require(knitr)
# Open ReadMe.txt in a text editor and save it as ReadMe.md. 
# For markdown formatting you will want an extra blank line between paragraphs, 
# but it does mean you can take advantage of all the markdown formatting options.knit("ReadMe.rmd","Readme.md")
# knit("ReadMe.rmd","Readme.md")
# knit("codebook.rmd","codebook.md")
