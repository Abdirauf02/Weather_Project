#install.packages("tidyverse")
#install.packages("devtools") 
#devtools::install_github("thomasp85/patchwork")
#install.packages("leaps")

require(tidyverse)
library(patchwork)
#library(leaps)
#library(MASS)



load("Weather_Forecast.RData")
head(weather_forecast)

#PART 1

#We can see that the Measure_of_Temp has 3 different variables "forecasr_hours_before",
#"observed_temp" and "forecast_temp". And each variaböe must have its own coloumn
#
#We can also see that the state and city are 2 variables but in the same coloumns
#State_City are separated by ":". Each variable must have its own colomnn.

weather_forecast %>% 
  pivot_wider(names_from = Measure_of_Temp, values_from = Temp) %>% 
  separate(State_City, c("State", "City"), ":") %>% 
  separate(date, c("Year", "Month", "Day"),"-")-> weather_forecast_tidy


#PART 2 

weather_forecast_tidy %>% 
   filter(!(possible_error != "none")) ->weather_forecast_tidy

weather_forecast_tidy %>% 
  filter((possible_error == "none")) ->weather_forecast_tidy

weather_forecast_tidy %>% 
  mutate(observed_precip=ifelse(is.na(observed_precip), 0.00, observed_precip))-> weather_forecast_tidy

 

#PART 3
#Mean and variance in base R 
mean(weather_forecast_tidy$observed_temp, na.rm = TRUE)
var(weather_forecast_tidy$observed_temp, na.rm = TRUE)
#Mean and variance in base tidyverse
weather_forecast_tidy %>% 
  summarise(mean(observed_temp, na.rm = TRUE))
weather_forecast_tidy %>% 
  summarise(var(observed_temp, na.rm = TRUE))
#Histogram using ggplot
ggplot(weather_forecast_tidy) +
  geom_histogram( aes(x= observed_temp),binwidth = 5, bins = 1000, colour= "white") + 
  labs(x= "Observed Temperature",title= "Histogram of observed temperature") 


#Corelation matrix of observes_precip, observed_temp and forecast_temp
my_corr_data <- weather_forecast_tidy[c(7,11,12)]
cor(my_corr_data,use="complete.obs", method= "spearman")

#Scatter plots
ggplot(weather_forecast_tidy)+
  geom_point(aes(observed_precip, forecast_temp))+ 
  labs(x= "Observed Precipition", y= "Forecasted Temperature")  -> p1 
ggplot(weather_forecast_tidy)+
  geom_point(aes(observed_precip, observed_temp))+
  labs(x= "Observed Precipition", y= "Observed Temperature")  ->p2
ggplot(weather_forecast_tidy)+
  geom_point(aes(forecast_temp, observed_temp))+
  labs(x= "Observed Temperature", y= "Forecasted Temperature") ->p3
layout <- "
AABB
#CC#
"
p1+p2+p3+plot_layout(design=layout)


#Mean and Standard Deviation of NY 
weather_forecast_tidy %>% 
  group_by(State) %>% 
  filter(State== "NY") %>% 
  summarise(Mean=mean(observed_precip), Standard_Deviation= sd(observed_precip))



#Average observed temperature in Years 
weather_forecast_tidy %>% 
  group_by(State,Year) %>% 
  filter(State=="NY"|State=="NJ"|State=="CT") %>% 
  mutate(mean1= mean(observed_temp, na.rm = TRUE)) %>% 
  ggplot(aes(Year, mean1, colour=State , group= State))+
  geom_point()+
  geom_line()+ 
  labs(x="Year",
       y="Average Observed Temperature",
       title = "Average Observed Temperature in NY NJ CT") ->p4
#Average observed temperature in Months in 2021  
weather_forecast_tidy %>% 
  group_by(State, Month) %>% 
  filter(State=="NY"|State=="NJ"|State=="CT" & Year == 2021) %>% 
  mutate(mean1= mean(observed_temp, na.rm = TRUE)) %>% 
  ggplot(aes(Month, mean1, colour=State , group= State))+
  geom_point()+
  geom_line()+ 
  labs(x="Months in 2021",
       y="Average Observed Temperature",
       title = "Average Observed Temperature in NY NJ CT") ->p5
  
#Average observed temperature in Months in 2022  
weather_forecast_tidy %>% 
  group_by(State, Month) %>% 
  filter(State=="NY"|State=="NJ"|State=="CT" & Year == 2022) %>% 
  mutate(mean1= mean(observed_temp, na.rm = TRUE)) %>% 
  ggplot(aes(Month, mean1, colour=State , group= State))+
  geom_point()+
  geom_line()+ 
  labs(x="Months in 2022",
       y="Average Observed Temperature",
       title = "Average Observed Temperature in NY NJ CT")->p6

layout1 <- "
#AA#
BBCC
"
p4+p5+p6+plot_layout(design=layout1)


#Weather summary function of function x
weather_summary <- function(x){
  

  mean_forecast_temp = mean(x$forecast_temp, na.rm = TRUE)
  mean_observed_temp = mean(x$observed_temp, na.rm = TRUE)
  
  date1 = min(x$Year)
  date2 = max(x$Year)
  
  time_interval = as.integer(date2) - as.integer(date1)
  if(time_interval < 1){
    warning("The interval of the year is not greater than 1.")
  }else{
  mean_forecast_temp_time = mean_forecast_temp / time_interval
  mean_observed_temp_time =  mean_observed_temp / time_interval
    
  list("Average observed temperature over time = " = mean_observed_temp_time, 
       "Average forecast temperature over time = " =mean_forecast_temp_time)
  }
}


#Test with full weather_forecast_tidy 
weather_summary(weather_forecast_tidy)

#Test with full wather_forecast_tidy in 2021 only.
Year_2021 <-weather_forecast_tidy[weather_forecast_tidy$Year == "2021",]
weather_summary(Year_2021)


##PART 4
#High = 1 and low = 0 
weather_forecast_tidy %>% 
  mutate(new_high_low = ifelse(high_or_low== "low", 0, 1 )) -> weather_forecast_tidy
# Full Model 
ot_lm<-lm(observed_temp ~ new_high_low+forecast_hours_before+observed_precip +forecast_temp +
           forecast_hours_before*new_high_low+observed_precip*new_high_low +forecast_temp*new_high_low, 
         data = weather_forecast_tidy)
summary(ot_lm)
#Anova Of model 
anova(ot_lm)
#TEst if slope coeffiecient = 1  for forecast_temp
t_star <- (0.9812159 - 1)/0.0006112

t_stat <- qt(1-0.025, 72183)



#Variable selection. 

#Comparision of M4, M3a vs m2a vs m2b
t_lm<-lm(observed_temp ~ new_high_low+forecast_hours_before+observed_precip +forecast_temp +
           forecast_hours_before*new_high_low+observed_precip*new_high_low +forecast_temp*new_high_low, 
         data = weather_forecast_tidy)
drop1(ot_lm, test = "F", scope = ~.)
#Drop forecast_hours_before*new_high_low observed_precip*new_high_low forecast_temp*new_high_low
#Since all are not significant 
#Model 4a is the full model 
#model 3a is  the model without the interation 
#model 2a is the model with the categorrical variable
#model 2b is the model with the independent varianle not including the the categorical variable 

#Comaprison of M2b vs M1
ot_lm1<-lm(observed_temp ~ forecast_hours_before+observed_precip +forecast_temp, 
          data = weather_forecast_tidy)
drop1(ot_lm1, test = "F", scope = ~.)
#Drop Nothing all significant better model is m2b is a better fit compared m2b




#stepwise Check
step(ot_lm1,test= "F" , scope= ~forecast_hours_before+observed_precip+forecast_temp,
     direction = "both")


#transformation of dependent 
#boxcox(ot_lm1, plotit = TRUE)

ot_lm1 <- lm(observed_temp ~ forecast_hours_before+observed_precip +forecast_temp, 
               data = weather_forecast_tidy)
par(mfrow= c(3,2))
plot(ot_lm1, which = 2) 
# Shows a short tails

plot(ot_lm1, which = 1)
#no clear pattern so constant vatiance and independence

#log transformation on dependent variable
ot_lm1a <- lm(log(observed_temp) ~ forecast_hours_before+observed_precip +forecast_temp, 
             data = weather_forecast_tidy)
par(mfrow= c(1,2))
plot(ot_lm1a, which = 2) 
plot(ot_lm1a, which = 1) 
# sqrt transformation on dependent variable
ot_lm1b <- lm(sqrt(observed_temp) ~ forecast_hours_before+observed_precip +forecast_temp, 
              data = weather_forecast_tidy)
plot(ot_lm1b, which = 2) 
plot(ot_lm1b, which = 1)

# sqyare transformation on dependent variable
ot_lm1c <- lm((observed_temp)^2 ~ forecast_hours_before+observed_precip +forecast_temp, 
              data = weather_forecast_tidy)
plot(ot_lm1c, which = 2) 
plot(ot_lm1c, which = 1)

# cubed transformation on dependent variable
ot_lm1d <- lm((observed_temp)^3 ~ forecast_hours_before+observed_precip +forecast_temp, 
              data = weather_forecast_tidy)
plot(ot_lm1d, which = 2) 
plot(ot_lm1d, which = 1)

# cubed transformation on dependent variable
ot_lm1e <- lm(sin(observed_temp) ~ forecast_hours_before+observed_precip +forecast_temp, 
              data = weather_forecast_tidy)
plot(ot_lm1e, which = 2) 
plot(ot_lm1e, which = 1)

# cosine transformation on dependent variable
ot_lm1f <- lm(cos(observed_temp) ~ forecast_hours_before+observed_precip +forecast_temp, 
              data = weather_forecast_tidy)
plot(ot_lm1f, which = 2) 
plot(ot_lm1f, which = 1)

#NONE Produce a better graph for the QQ plot and Residuals vs fitted.



#Transformation on independent variables mainly forecast temp 
new_otlm1 <- lm(observed_temp ~ forecast_hours_before, 
   data = weather_forecast_tidy)
plot(new_otlm1, which = 2)
plot(new_otlm1, which = 1)

new_otlm2 <- lm(observed_temp ~ observed_precip, 
                data = weather_forecast_tidy)
plot(new_otlm2, which = 2)
plot(new_otlm2, which = 1)

new_otlm3 <- lm(observed_temp ~ forecast_temp, 
                data = weather_forecast_tidy)
plot(new_otlm3, which = 2)
plot(new_otlm3, which = 1)

#Multicollinearlity vetween observed temp and forecast temp.
#square root transformation on dependent.
new_otlm3a <- lm(observed_temp ~ sqrt(forecast_temp), 
                data = weather_forecast_tidy)
plot(new_otlm3a, which = 2)
plot(new_otlm3a, which = 1)

#square transformation on dependent.
new_otlm3b <- lm(observed_temp ~ forecast_temp^2, 
                 data = weather_forecast_tidy)
plot(new_otlm3b, which = 2)
plot(new_otlm3b, which = 1)

#cube transformation on dependent.
new_otlm3c <- lm(observed_temp ~ forecast_temp^3, 
                 data = weather_forecast_tidy)
plot(new_otlm3c, which = 2)
plot(new_otlm3c, which = 1)


#cosine transformation on dependent.
new_otlm3d <- lm(observed_temp ~ cos(forecast_temp), 
                 data = weather_forecast_tidy)
plot(new_otlm3d, which = 2)
plot(new_otlm3d, which = 1)

#sine transformation on dependent.
new_otlm3e <- lm(observed_temp ~ sin(forecast_temp), 
                 data = weather_forecast_tidy)
plot(new_otlm3e, which = 2)
plot(new_otlm3e, which = 1)

#many trnasformations tried such as sine, cosine, powers of 2,3 and sqrts no change
#No transformation work stay with original after variable selection 


#PART 5

# Function that finds the PRESS, ADJr^2 and AIC between function 
Press_adjR2_AIC <- function(x){
  PRESS <- sum(x$resid^2/(1-hatvalues(x))^2)
  Summary1<- summary(x)$adj.r.squared
  AIC1<- AIC(x)
  
  list("PRESS"=PRESS, "AdjustedR2"=Summary1, "AIC"=AIC1)
  
}


#Comparision of full and final model 
Press_adjR2_AIC(ot_lm)
Press_adjR2_AIC(ot_lm1)
#comparision of other transformations
#dependent 
#Press_adjR2_AIC(ot_lm1b)
#Press_adjR2_AIC(ot_lm1c)
#Press_adjR2_AIC(ot_lm1d)
#Press_adjR2_AIC(ot_lm1e)
#Press_adjR2_AIC(ot_lm1f)

#comparision of other transformations
#independent 
#Press_adjR2_AIC(new_otlm3a)
#Press_adjR2_AIC(new_otlm3b)
#Press_adjR2_AIC(new_otlm3c)
#Press_adjR2_AIC(new_otlm3d)
#Press_adjR2_AIC(new_otlm3e)

#Shows intercepts.
ot_lm1
summary(ot_lm1)

#Confidence interval 95%
confint(ot_lm1)

#Predict expected observed forecast
predict(ot_lm1, newdata = data.frame(forecast_hours_before= 0, observed_precip = 0, forecast_temp= 40) ,
        interval = "predict", level = 0.95)

#Predict expected observed forecast
predict(ot_lm1, newdata = data.frame(forecast_hours_before= 0, observed_precip = 0.01, forecast_temp= 53) ,
        interval = "predict", level = 0.95)


