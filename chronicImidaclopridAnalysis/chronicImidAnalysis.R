data <- read.csv('/Users/james/Dropbox/Work/Neonicotinoids/ChronicExposure/Data/TrackingData/summaryData.csv')

subDat <- subset(data, dayNumber == 4 & timeOfDay == 2 & validTrials > 1)

boxplot(porTimeNursing~treatment, data = subDat)

