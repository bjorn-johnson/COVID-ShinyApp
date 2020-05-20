
library(tidyverse)
library(httr)
library(jsonlite)
library(data.table)
library(shiny)

startdate = format(Sys.Date()+1, "%m/%d/%Y")

path <- "https://covidtracking.com/api/states/daily"

request <- GET(url = path)

response <- content(request, as = "text", encoding = "UTF-8")

COVID_data <- fromJSON(response, flatten = TRUE) %>% 
  data.frame()

COVID_df <- COVID_data %>% 
  dplyr::mutate(year = substr(date,1,4)
                ,month = substr(date,5,6)
                ,day = substr(date,7,8)) %>% 
  dplyr::mutate(date_COVID = paste(year,month,day,sep="-")) %>% 
  dplyr::select(date_COVID,state,positive,negative,pending,hospitalized,death,total) %>% 
  dplyr::mutate(Date_lag = difftime(Sys.time(),date_COVID)
                ,Date_lag_min = min(Date_lag)
                ,Most_Recent_Date = ifelse(Date_lag == Date_lag_min,'Most_Recent','Old_Data')
                ,Data_asof = max(date_COVID)) %>% 
  #filter(Most_Recent_Date == 'Most_Recent') %>% 
  dplyr::select(date_COVID,state,positive,negative,pending,hospitalized,death,total,Most_Recent_Date,Data_asof)

fwrite(COVID_df,"C:/Users/bjorn.o.johnson/Documents/R_Task_Scheduler/COVID/COVID_DATA.csv")
