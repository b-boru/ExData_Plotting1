
## read only the first row of the table
data <- read.table("data/household_power_consumption.txt",
                   header = TRUE,                               ## first line gives the column names
                   sep = ";",                                   ## field separator
                   dec = ".",                                   ## decimal point
                   comment.char = "",                           ## read.table says this makes reading faster
                   na.strings = "?",                            ## '?' in the file means 'NA'
                   colClasses=c( "character", "character",      ## date and time as characters
                                 "numeric", "numeric",          ## all other fields as numeric
                                 "numeric", "numeric",
                                 "numeric", "numeric",
                                 "numeric"),
                   nrows = 1)                                   ## read just one line, plus the name of the columns

## keep the column names
columnNames = names(data)

## get the date and time of the first item in the table
startTime <- strptime(paste(data[1, 1], data[1, 2]),
                      "%d/%m/%Y %H:%M:%S")                      ## get date and time in a single a POSIXlt

## calculate the number of rows to skip, and the number
## of rows to read, assuming that:
##  - the data file is sorted by date and time
##  - there is no missing row, i.e. there is 24*60 rows per day
## Note that we add +1 to the number of lines to skip,
## because of the file header on the first line
nbRowsToSkip <- difftime(as.POSIXct("2007-02-01 00:00:00"), startTime, units="mins") + 1
nbRowsToRead <- 2*24*60

## we may now read only the useful part of the CSV-formated file
data <- read.table("data/household_power_consumption.txt",
                   header = FALSE,                              ## we already have the column names
                   sep = ";",                                   ## field separator
                   dec = ".",                                   ## decimal point
                   comment.char = "",                           ## help for read.table says this makes reading faster
                   na.strings = "?",                            ## '?' in the file means 'NA'
                   col.names = columnNames,                     ## the name of the columns, as previously read
                   colClasses = c( "character", "character",    ## date and time as characters
                                   "numeric", "numeric",        ## all other fields as numeric
                                   "numeric", "numeric",
                                   "numeric", "numeric",
                                   "numeric"),
                   skip = nbRowsToSkip,
                   nrows = nbRowsToRead)                        ## number of rows to read

## it is unconvenient to have date and time on separate columns:
## combine them into one single POSIXlt value, and put this
## in a new column named 'DateAndTime'
data$DateAndTime <- strptime(paste(data$Date, data$Time), "%d/%m/%Y %H:%M:%S")



## open the output device
png(file = "plot3.png", width = 480, height = 480)              ## plot to a 480x480 PNG file

## as suggested in the discussion forum (https://class.coursera.org/exdata-015/forum/thread?thread_id=18),
## temporarily change the local for displaying the date and time
myLocale <- Sys.getlocale('LC_TIME')
Sys.setlocale('LC_TIME', 'English')

## plot the three sub-meterings wrt the time
colors <- c("black", "red", "blue")
plot(data$DateAndTime,                                          ## one X position per data row = per minute
     data$Sub_metering_1,                                       ## put Sub_metering_1 along the Y axis
     "l",                                                       ## display as connected lines
     col = colors[1],                                           ## use the first color
     xlab = "",                                                 ## no label along the X axis
     ylab="Energy sub metering")                                ## the label along the Y axis

## add lines with the other column data, using the other colors
lines(data$DateAndTime, data$Sub_metering_2, col = colors[2])
lines(data$DateAndTime, data$Sub_metering_3, col = colors[3])

## finally, add the legend
legend("topright", lty = 1, col = colors, legend = names(data)[7:9])

## get my locale back!
Sys.setlocale('LC_TIME', myLocale)

## properly close the output device
dev.off()

