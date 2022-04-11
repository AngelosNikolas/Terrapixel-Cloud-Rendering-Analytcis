library("ProjectTemplate")
load.project()


#Which event type dominate task run times
Barchart1 = ggplot(data=EventsData, aes(x = reorder(Events, -EventsRuntime), y=EventsRuntime)) +
  geom_bar(stat="identity", fill="steelblue")+
  geom_text(aes(label=EventsRuntime), vjust=-0.3, size=3.5)+
  theme_minimal()

#What is the interplay between GPU temperature and performance?

#Summarize data
summary(GpuMeans)

# Histogram 2
p1 <- ggplot(GpuMeans, aes(x=TempAvg)) + 
  geom_histogram()
# Histogram 1
p2 <- ggplot(GpuMeans, aes(x=UtilAvg)) +
  geom_histogram() 

# plot two plots in a grid and label them as A and B
TempHist = plot_grid(p1, p2, labels = c('A', 'B'), label_size = 12)

#The interplay between increased power draw and render time
summary(HighPowerDraw)
summary(RenderPower)
# Percentage of high power draw
PowerPerc = 1157536/1543681*100

#The variation in computation requirements for a particular tile.
summary(GpuComp)

# Perfomance difference based on serial number.
summary(GpuPerfomance)
head(GpuPerfomance)
Scatter1 =  ggplot(GpuPerfomance, aes(x = TasksTotalTime , y = as.numeric(row.names(GpuPerfomance)))) +
  geom_point()
  
view(TaskAlloc)
# Efficiency of the task scheduling process 
  
View(TileTask)
