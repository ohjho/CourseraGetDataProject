library(dplyr)
library(tidyr)
library(stringr)
library(sqldf)
#Load the training and test data, this assumes
# that the source data is in an directory call
# UCI_HAR_Dataset in the same directory as this script
x_test <- read.table("UCI_HAR_Dataset/test/X_test.txt")
y_test <- read.table("UCI_HAR_Dataset/test/Y_test.txt")
subject_test<-read.table("UCI_HAR_Dataset/test/subject_test.txt")
x_train <- read.table("UCI_HAR_Dataset/train/X_train.txt")
y_train <- read.table("UCI_HAR_Dataset/train/Y_train.txt")
subject_train<-read.table("UCI_HAR_Dataset/train/subject_train.txt")
features_txt<-read.table("UCI_HAR_Dataset/features.txt")
activity_txt<-read.table("UCI_HAR_Dataset/activity_labels.txt")

#1. Merging the training and test set together
#   will add a subject column
x_joined <- rbind(x_test, x_train)
y_joined <- rbind(y_test, y_train)
subject_joined<- rbind(subject_test, subject_train)

#2. Extract only the measurements on the mean and sd for each measurement
# lets label the columns
colnames(x_joined)<- features_txt[,2]
colnames(y_joined)[1]<-"akey"
colnames(subject_joined)[1]<-"subject"
x_slim <- # remove duplicated columns first
          x_joined[,unique(colnames(x_joined))] %>% 
          # now only get the mean() and std() columns
          select(matches(".mean\\(\\).|.std\\(\\)."))
#3. Uses descriptive activity names to name the activities in the data set
colnames(activity_txt)<-c("akey","activity")
x_complete<-cbind(x_slim,y_joined,subject_joined) %>%
            merge(activity_txt,by="akey") %>%
            select(-akey)
#4. Appropriately labels the data set with descriptive variable names
# already done in step #2 above on line 23
message("Finished aggregating data.")

#5. From the data set in sept 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject
x_tidy <- gather(x_complete,variable_stat,value,-c(activity,subject))
          #separate(col=variable_stat,into=c("variable","stat")) %>%
          # mutate a new column for the stat type: mean/ sd
          #mutate(stat= str_match(variable_stat,"\\-(.+)\\-")[1,2]) %>%
          #x_tidy<- mutate(x_tidy1,
          #                stat= unlist(strsplit(as.character(variable_stat),"-"))[2])
# remove duplicates
x_tidy<-sqldf("select * from x_tidy group by subject, activity, variable_stat")
x_tidy<- mutate( x_tidy,
                 stat=unlist(lapply(strsplit(as.character(variable_stat),"\\-")
                              ,"[",2))
          )
 #print(unique(x_tidy$stat))
x_tidy<- mutate(x_tidy,
                variable=sub(variable_stat,pattern="\\-.+\\-", 
                              replacement="-")) %>%
          select(-variable_stat)
x_tidy<-  spread(x_tidy, stat,value)
names(x_tidy)[names(x_tidy)=="mean()"]<-"mean"
names(x_tidy)[names(x_tidy)=="std()"]<-"std"
          #rename(c("mean()"="mean","std()"="std"))
 #print(unique(x_tidy$variable))
message("Tidy dataset 'x_tidy' created.")

x_summary<-group_by(x_tidy,
                    variable,activity,subject) %>%
          summarize(avg_mean=mean(mean),avg_std=mean(std))
message("Summary data set 'x_summary' created.")