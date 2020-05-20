# COVID-ShinyApp
sample Shiny app, needs a lot of additional work, but something i put together in a couple hours.

Run COVID_script to pull data from COVID Tracking api. 

Install the ScheduleR package and then in RStudio browse to 'Tools'-->'Add Ins'-->'Browse Add Ins' and select Task ScheduleR to schedule the COVID_Script to automatically download and transform the COVID data from the CovidTracking API. 

The COVID data also feeds in a Tableau public dashboard I created: https://public.tableau.com/views/COVIDDashboard_15849984885860/COVIDDashboard?:display_count=y&publish=yes&:origin=viz_share_link

While the COVID script is automated and run daily, I would need access to a Tableau Server in order to automate a scheduled refresh to the Tableau dashboard. 
