# CourseraGetDataProject
this is a description of what the run_analysis.R script does to the data in the UCI_HAR_Dataset directory

## R packpages reqired
These are loaded at the beginning of the script. User is expected to have these packages installed already. 
1. dplyr
2. tidyr
3. stringr
4. sqldf

## Data Files required
A data frame object is created for each of the following file in the UCI_HAR_Dataset directory
1. test/X_test.txt
2. test/Y_test.txt
3. test/subject_test.txt
4. train/X_train.txt
5. train/Y_train.txt
6. train/subject_train.txt
7. features.txt
8. activity_labels.txt

## 1. Merging the training and test set together
With respect to the above list, the file 1, 4 are joined together to form the *x_joined* data frame. The file 2, 5 are joined together to form the *y_joined* data frame. And the file 3, 6 above are joined together to form the *subject_joined* data frame.

## 2. Extract only the measurements on the mean and standard deviation (sd) for each measurement
In order to extract the mean and sd measures, *x_joined* is labelled with the column names equal to the data set from the file 7 above.

Some columns in x_joined are duplicated, so the duplicates are filtered out first. Then we use select from the dplyr package to extract just the _mean()_ and _std()_ columns. The resulting data frame is called *x_slim

## 3. Use descriptive activity names to name the activities in the data set
To do this we merge file 8 above with the *x_slim* data frame and name the newly added column activity. At the same time, we also cbind *y_joined* and *subject_joined*. The resulting data frame is called *x_complete*.

## 4. Appropriately label the data set with descriptive variable names
All the data in the *x_complete* data frame has the appropriate column names.

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
To make the data tidy, the script creates the *x_tidy* data set by doing the following to the *x_complete* data set:
..1. Have each observative form a row, by transposing the various features measured for each subject and activity pair (originally in columns) into a rows.
..2. Have each variable forms a column by having a column each for the mean and standard deviation (i.e. each feature for each subject-and-activity pair has a mean and standard deviation).

Lastly, to form the summary data set *x_summary*, we group the *x_tidy* data set by _feature_, _activity_, and _subject_ before running the *dplyr* package function _summarize_. 