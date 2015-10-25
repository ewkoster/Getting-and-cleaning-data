#Create one R script called run_analysis.R that does the following. 
#1. Merges the training and the test sets to create one data set.
#2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names. 
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library("data.table")
library("reshape2")



# Read activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Read data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# read test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# read train data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

X_combined <- rbind(X_train, X_test)
y_combined <- rbind(y_train, y_test)
subject_combined <- rbind(subject_train, subject_test)
names(X_combined) = features


# Identify only the features with a mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)


# Extract only the measurements on the mean and standard deviation for each measurement.
X_combined = X_combined[,extract_features]

# Load activity labels
y_combined[,2] = activity_labels[y_combined[,1]]
names(y_combined) = c("Activity_ID", "Activity_Label")
names(subject_combined) = "subject"

# combined subject, y and x data
all_data <- cbind(as.data.table(subject_combined), y_combined, X_combined)


id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(all_data), id_labels)
melt_data      = melt(all_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt")