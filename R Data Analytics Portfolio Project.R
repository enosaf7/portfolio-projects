## Install the packages

# install.packages("readr")
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("maps")
# install.packages("mapdata")
# install.packages("corrplot")


# Importing Libraries
library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(maps)
library(mapdata)
library(corrplot)




## Data Exploration and Preprocessing

# Load Dataset
data <- read.csv("D:/data analysis/Data_Analytics_BootCamp 1.0/Dataset.csv")

# View 10 rowa of the dataset
head(data, 10)


# Explore the dataset to indentify the number of rows and columns
cat('Number of rows: ', nrow(data), '\n')
cat('Number of columns: ', ncol(data))



# Check for missing values in each column and handle them accordingly

# Check for missing values
missing_values <- sum(is.na(data))

# check for empty values
empty_values <- sum(data == "")


cat('Missing values count: ', missing_values, '\n')
cat('Empty values count: ', empty_values)


# checking which columns have the empty values
col_empty_values_count <- colSums(data == '')
cat('Empty values count:\n')
print(col_empty_values_count)


# Drop empty values in the Cuisines column

data <- data[!(data$Cuisines == ''), , drop = FALSE]


# check for empty values
empty_values <- sum(data == "")
cat('Empty values count: ', empty_values)


# Check for duplicate
dup <- sum(duplicated(data))
cat('Number of duplicate rows: ', dup)


# Display basic information about the dataset to check various data types
str(data)


# Analyse the distribution of the target variable ("Aggregate rating") and identify any class imbalances
check_for_balance <- summary(data$Aggregate.rating)
print(check_for_balance)


# check if the distribution is balance
target_counts <- table(data$Aggregate.rating)

is_balanced <- all(target_counts >= mean(target_counts))
if(is_balanced){
  print('The distribution of the target variable is balanced.')
} else {
  print('The distribution of the target variable is imbalanced.')
}






## Descriptive Analysis

# Calculate basic statistical measures (mean, median, standard deviation, etc.) for numerical columns


# Select numerical columns
numerical_columns <- data[, sapply(data, is.numeric)]

# Calculate basic statistical measures
summary_stats <- summary(numerical_columns)
print(summary_stats)

# Calculate the standard deviation for the numerical columns
sds <- sapply(data[, sapply(data, is.numeric)], sd)
print(sds)


# The distribution of categorical variables like Country Code, City, and Cuisines

# Create a count plot for country code
ggplot(data, aes(x = factor(Country.Code))) +
  geom_bar(fill = 'skyblue') +
  labs(
    title = 'Distribution of Restaurant by Country Codes',
    x = 'Country Codes',
    y = 'Number of Restaurants'
  )


# create a subset of the data containing the top 10 cities
top_10_cities <- head(names(sort(table(data$City), decreasing = TRUE)), 10)
data_top_10_cities <- data[data$City %in% top_10_cities, ]


# Create count plot for the top 10 cities
ggplot(data = data_top_10_cities, aes(y = factor(City, levels = rev(top_10_cities)))) +
  geom_bar(fill = 'steelblue', width = 0.5, stat = 'count') +
  labs(
    title = 'Top 10 Cities with Highest Number of Restaurants',
    x = 'Number of Restaurants',
    y = 'Name of Cities'
  )




# create a subset of the data containing the top 10 cuisines
top_10_cuisines <- head(names(sort(table(data$Cuisines), decreasing = TRUE)), 10)
data_top_10_cuisines <- data[data$Cuisines %in% top_10_cuisines, ]


# Create count plot for the top 10 cities
ggplot(data = data_top_10_cuisines, aes(y = factor(Cuisines, levels = rev(top_10_cuisines)))) +
  geom_bar(fill = 'steelblue', width = 0.5, stat = 'count') +
  labs(
    title = 'Top 10 Cuisines with Highest Number of Restaurants',
    x = 'Number of Restaurants',
    y = 'Name of Cuisines'
  )




# The top cuisines and cities with the highest number of restaurants

# Identify the top 10 cuisines and their count
top_cuisines <- head(sort(table(data$Cuisines), descreasing = TRUE), 10)

# Create a DataFrame with the top 10 cuisine names and count
top_cuisines_df <- data.frame(Cuisines = names(top_cuisines), Count = as.numeric(top_cuisines))
print('Top 10 Cuisines with the Highest Number of Restaurants:')
print(top_cuisines_df)



# Identify the top 10 city and their count
top_city <- head(sort(table(data$City), descreasing = TRUE), 10)

# Create a DataFrame with the top 10 city names and count
top_city_df <- data.frame(City = names(top_city), Count = as.numeric(top_city))
print('Top 10 City with the Highest Number of Restaurants:')
print(top_city_df)




## Geospatial Analysis

# Visualize the locations of restaurants on a map using latitude and longitude information

#create a map of the world
world_map <- map_data('world')

# plot restaurant locations on map
ggplot() +
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), fill = 'lightgrey', color = 'black') +
  geom_point(data = data, aes(x = Longitude, y = Latitude, color = 'Restaurants'), size = 2) +
  scale_color_manual(name = 'Legend', values = c(Restaurants = 'red')) +
  labs(
    title = 'Restaurants Locations on Map',
    x = 'Longtitude',
    y = 'Latitude'
  )


# Analyse the distribution of restaurants across different cities or countries


# create a subset of the data containing the top 10 cities
top_10_cities <- head(names(sort(table(data$City), decreasing = TRUE)), 10)
data_top_10_cities <- data[data$City %in% top_10_cities, ]


# Create a plot of restaurant across cities
ggplot(data = data_top_10_cities, aes(y = factor(City, levels = rev(top_10_cities)))) +
  geom_bar(fill = 'steelblue', width = 0.5, stat = 'count') +
  labs(
    title = 'Distribution of Restaurant Across Coities',
    x = 'Number of Restaurants',
    y = 'Name of Cities'
  )


# Determine if there is any correlation between the restaurant's location and its rating

# Calculate the correlation
cor_matrix <- cor(data[c('Longitude', 'Latitude', 'Aggregate.rating')])

# create heatmap to visualize the correlation
corrplot(cor_matrix, method = 'color', col = colorRampPalette(c('blue', 'white', 'red'))(20),
         type = 'upper', order = 'hclust', tl.col = 'black', tl.srt = 45,
         title = "Correlation Between Restaurant's Location and Rating",
         mar = c(0, 0, 3, 1)
         )







