# Weather_Project
Data Management, Data Cleaning, Exploring the Data, Building the Model, Interpret the Model using R 

1. Background
weather forecast is a data set from the USA National Weather Service which tracked weather
from different cities in the USA between 30th January 2021 and 1st June 2022.
The variables included in the data are described below.
Column
number
Column name Description
1 date Date of observed weather (yyyy-mm-dd)
2 State City Code for State or Territory and City (separated by :)
3 high or low
Whether the forecast is for high temperature (high)
or low temperature (low)
4 Measure of Temp
Type of measure for temperature:
hours between forecasted and observed temperature
(forecast hours before),
the predicted temperature on the data (forecast temp),
the actual observed temperature on date (observed temp)
5 Temp Temperature measured for Measurement of Temp in Fahrenheit
6 observed precip The observed precipitation on data in inches.
7 forecast outlook An abbreviation for the general outlook of weather
8 possible error
Either:
none if the row contains no potential errors,
or the name of the variable that is the cause of the potential error

3. Getting Started
The weather forecast data are available to download from the MM923 Myplace page and are
stored in .RData format. To open the data in R, download and save the data, then set the working
directory to the data location and type the following:
load("Weather_Forecast.RData")
The data have now been loaded and are accessible in a data frame called weather forecast. You
can quickly visualise the data columns by printing the first few rows of data using the head()
function as follows:
head(weather_forecast)

Part 1: Data Management
The current data is not in tidy format. Complete the following steps to make the data tidy as well
as some other data management.
a) The data set provided is not in tidy format, explain why.
b) Recode the State City and Measure of Temp variables into tidy format.
c) It is of interest to separately analyse the year, month, and day to allow visualisation of yearly
and monthly trends. Create three new variables which contain the Year, Month, and Day of
measurement, respectively.
Part 2: Data Cleaning (5 marks)
a) Researchers are only interested in measurements which are reliable. Remove all observations
which may contain errors.
b) There are many missing observations within the observed precip variable. Data controllers
have informed that missing values in this variable mean that no rain was recorded on that
day. Write code to change all missing values in this variable to equal 0.00.

Part 3: Exploring the Data
a) Provide the mean and variance of the observed temperature in the data set and plot the
corresponding histogram.
b) Calculate the sample correlation coefficient between the observed precipitation and the forecasted
and observed temperatures. Use a single plot to summarise these.
c) Focussing on the state New York (NY), provide the mean and standard deviation of the
observed precipitation.
d) The USA has the tri-state area which contains the states New York (NY), New Jersey (NJ),
and Connecticut (CT). Provide the average observed temperature over time for each of these
states on the same plot.
e) Write a function called weather summary that takes the weather forecast data as an input
and returns a named list containing
– the average forecast temperature over time
– the average observed temperature over time
Test your function by running it for the following two cases:
– the full weather forecast data
– a version that has been filtered to contain only data from 2021

Part 4: Building a Model 
a) Fit a linear regression for the observed temperature based on the other weather variables (i.e.,
the variables high or low, forecast hours before, observed precip, and forecast temp.
(i) Provide a formatted ANOVA table for the model.
(iii) Test whether the slope coefficient for the forecasted temperature is equal to 1.
b) Using an appropriate variable selection technique, explore building an improved model for the
observed temperature.
c) Use your model from part b), check the regression assumptions using appropriate summary
plots, and comment on whether you think that these are valid.
d) Consider any transformations of the independent or dependent variables in your chosen model
from part c.
e) Compare the models for part d and part a. Comment on any improvements in the model fit.
Part 5: Interpreting the Model (10 marks)
Using your best model from Part 4, complete the following tasks.
a) Comment on the goodness of fit of the model.
b) Provide an interpretation of the model coefficients, including confidence intervals.
c) Find the expected temperature when the forecast temperature is 40◦F
d) Provide a range of plausible values for the temperature when the forecasted temperature 53◦F
and the observed precipitation is 0.01.


