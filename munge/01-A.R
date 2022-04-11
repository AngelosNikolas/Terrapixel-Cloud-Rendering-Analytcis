library(lubridate)
library(dplyr)
library(ggplot2)
library(cowplot)
#changing date formats in all data sets
gpu = mutate(gpu, timestamp = as.POSIXct(timestamp, format = "%Y-%m-%dT%H:%M:%S"))
application.checkpoints = mutate(application.checkpoints, timestamp = as.POSIXct(timestamp, format = "%Y-%m-%dT%H:%M:%S"))

#Remove 2 columns from the application checpoints dataset
AppCheckClean = select(application.checkpoints, -hostname, -jobId)

# Filtering the tiling event
TilingStart = filter(AppCheckClean, eventName == "Tiling" & eventType == "START")
TilingStop =  filter(AppCheckClean, eventName == "Tiling" & eventType == "STOP")

#Merging based on taskID
Tiling = left_join(TilingStart,TilingStop, by ='taskId')

#Checking the  date time difference
TilingRutime= difftime(Tiling$timestamp.y,Tiling$timestamp.x, units = "secs")
mean(TilingRutime)
TillingMean = 0.97


### Filtering the rendering event
RenderStart = filter(AppCheckClean, eventName == "Render" & eventType == "START")
RenderStop =  filter(AppCheckClean, eventName == "Render" & eventType == "STOP")

#Merging based on taskID
Rendering = left_join(RenderStart,RenderStop, by ='taskId')

#Changing the date format
Rendering = mutate(Rendering, timestamp.x = as.POSIXct(timestamp.x, format = "%Y-%m-%dT%H:%M:%S"))
Rendering = mutate(Rendering, timestamp.y = as.POSIXct(timestamp.y, format = "%Y-%m-%dT%H:%M:%S"))

#Checking the  date time difference
RenderingRutime= difftime(Rendering$timestamp.y,Rendering$timestamp.x, units = "secs")
mean(RenderingRutime)
RenderingMean = 41.2


### Filtering the saving event
SavingStart = filter(AppCheckClean, eventName == "Saving Config" & eventType == "START")
SavingStop =  filter(AppCheckClean, eventName == "Saving Config" & eventType == "STOP")

#Merging based on taskID
Saving = left_join(SavingStart,SavingStop, by ='taskId')


#Checking the  date time difference
SavingRutime= difftime(Saving$timestamp.y,Saving$timestamp.x, units = "secs")
mean(SavingRutime)
SavingMean = 0.0024


### Filtering the total render event
TotalRenderStart = filter(AppCheckClean, eventName == "TotalRender" & eventType == "START")
TotalRenderStop =  filter(AppCheckClean, eventName == "TotalRender" & eventType == "STOP")

#Merging based on taskID
TotalRendering = left_join(TotalRenderStart,TotalRenderStop, by ='taskId')


#Checking the  date time difference
TotalRenderingRutime= difftime(TotalRendering$timestamp.y,TotalRendering$timestamp.x, units = "secs")
mean(TotalRenderingRutime)
TotalRenderMean = 42.6


### Filtering the uploading event
UploadingStart = filter(AppCheckClean, eventName == "Uploading" & eventType == "START")
UploadingStop =  filter(AppCheckClean, eventName == "Uploading" & eventType == "STOP")

#Merging based on taskID
Uploading = left_join(UploadingStart,UploadingStop, by ='taskId')


#Checking the  date time difference
UploadingRutime= difftime(Uploading$timestamp.y,Uploading$timestamp.x, units = "secs")
mean(UploadingRutime)
UploadMean = 1.3

#creation of Events run time vector
EventsRuntime = c(TillingMean,RenderingMean,SavingMean,UploadMean)
Events = c('Tiling', 'Render', 'Saving' ,'Upload')
EventsData = as.data.frame(EventsRuntime,Events)
summary(gpu)

##########################################################################################################
#Interplay between GPU temperature and performance

# Remove rows that wont be needed
GpuClean = select(gpu, -hostname, -timestamp, -gpuUUID, -powerDrawWatt,-gpuMemUtilPerc)

#Getting the temp means by serial ID
TempMeans <- GpuClean %>%
  group_by(gpuSerial) %>%
  summarise(TempAvg = mean(gpuTempC))

#Getting the util means by serial ID
UtiliMeans <- GpuClean %>%
  group_by(gpuSerial) %>%
  summarise(UtilAvg = mean(gpuUtilPerc))

#Merge the means in one data frame
GpuMeans = left_join(TempMeans, UtiliMeans, by ='gpuSerial')
##########################################################################################################
#Interplay between Power draw and render time

#Cleaning the gpu data set
GpuClean2 = select(gpu, -gpuSerial, -gpuUUID, -gpuTempC,-gpuMemUtilPerc, -gpuUtilPerc)

#Checking for power draw quartiles
summary(GpuClean2)

#Grouping by hostname and extracting means
HighPowerDraw <- GpuClean2 %>%
  group_by(hostname) %>%
  summarise(PowerDrawMeans = mean(powerDrawWatt))
  
RenderPower = filter(gpu, powerDrawWatt > 44.99 )
summary(RenderPower)

####################################################################################################
#Variation in computation requirements for particular tiles

#Filter by specific tile
TileComp = filter(application.checkpoints, taskId == "00004e77-304c-4fbd-88a1-1346ef947567")

#Filter by hostname
GpuComp = filter(gpu, hostname == "0745914f4de046078517041d70b22fe7000001")

#Filter by the specific time the tile events took place
GpuComp = filter(GpuComp, timestamp > "2018-11-08 08:06:39" & timestamp < "2018-11-08 08:07:10")

####################################################################################################
#Performance difference for gpu's

# Subset by max and min timestamp for each hostname
TimeMax = aggregate(application.checkpoints$timestamp, by = list(application.checkpoints$hostname), FUN = max)
TimeMin = aggregate(application.checkpoints$timestamp, by = list(application.checkpoints$hostname), FUN = min)

#Merge the 2 subsets 
SpeedCheck = left_join(TimeMax,TimeMin, by = 'Group.1')

# Calculate the difference in minutes
SpeedCheck$TasksTotalTime = difftime(SpeedCheck$x.x, SpeedCheck$x.y, units ="mins")

#Rename the group.1 column to hostname
SpeedCheck = rename(SpeedCheck, hostname = Group.1)

#Removing columns 
GpuSerial = select(gpu, -gpuTempC, -timestamp, -gpuUUID, -powerDrawWatt,-gpuMemUtilPerc, -gpuUtilPerc)

#Sub-setting by distinct
GpuSerial = distinct(GpuSerial)

#Merging the gpu id with the performance data set.
GpuPerfomance = left_join(GpuSerial,SpeedCheck, by = "hostname")

#setting the minutes as numeric
GpuPerfomance$TasksTotalTime= as.numeric(GpuPerfomance$TasksTotalTime)

#Ommiting columns for the analysis
GpuPerfomance = select( GpuPerfomance, -hostname, -x.x, -x.y)

####################################################################################################
# Task scheduling exploration

#Checking the number of gpus
unique(gpu$gpuSerial)

#Tasks allocated to each gpu *** 4 gpus have double the tasks allocated to them and but are able to finish it at the same time as the others
TaskAlloc <- application.checkpoints %>%
  group_by(hostname) %>%
  count()

#Sub-setting for a specific fast gpu
TileTask = filter(application.checkpoints, hostname == "0d56a730076643d585f77e00d2d8521a000000")

# Merging to check what tiles are created by the above gpu *** Seems that tile coordinates are 
#consistent and not spread out indicating that each card renders a specific region of the image***
TileTask = left_join(TileTask,task.x.y, by = 'taskId')
TileTask = select(TileTask, -timestamp, -hostname, -eventName,- eventType, -jobId.x, -jobId.y)
