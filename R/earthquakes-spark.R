SparkR::sparkR.session()

library(sparklyr)
library(tidyverse)
library(lubridate)
library(plotly)

sc <- spark_connect(method = "databricks")
quakes = read_csv('https://raw.githubusercontent.com/plotly/datasets/master/earthquakes-23k.csv')

quakes <- quakes %>%
  mutate(
    Date = parse_date_time(Date, orders = "%m/%d/%Y"),
    Year = year(Date)
  ) %>%
  sparklyr::copy_to(sc, ., overwrite = TRUE)

head(quakes)

fig = quakes %>%
  collect() %>%
  plot_ly(
    type = 'densitymapbox',
    lat = ~ Latitude,
    lon = ~ Longitude,
    coloraxis = 'coloraxis',
    radius = 5
  )

fig %>%
  layout(
    mapbox = list(
      style = "stamen-terrain",
      center = list(lon = 180)), coloraxis = list(colorscale = "Viridis")
  )

yearly = quakes |>
  group_by(Year) |>
  summarize(n = n())

yearly |>
  collect() %>%
  plotly::plot_ly(type = "bar",
                  x = ~ Year,
                  y = ~ n)

yearly_mag = quakes |>
  group_by(Year, Magnitude) |>
  summarize(n = n())

yearly_mag |>
  collect() %>%
  plot_ly(
    type = "scatter",
    x = ~ Year,
    y = ~ n,
    color = ~ Magnitude,
    mode = "markers"
  )
