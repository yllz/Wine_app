wine <- read.csv("./wine.csv", header=TRUE, sep=",")
library(tidyverse)
wine_filter <- wine %>% select(country, province, points, price, variety)
wine_nona <- na.omit(wine_filter)

top15Ctry <- wine_nona %>% 
  group_by(country) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) %>% 
  mutate(totpcnt = round(total/ sum(total), digits=7), accum = cumsum(totpcnt)) %>%
  head(15)

top15Ctry_wine <- wine_nona %>% filter(country %in% top15Ctry$country)

top15Variety <- top15Ctry_wine %>% 
  group_by(variety) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) %>% 
  mutate(totpcnt = round(total/ sum(total), digits=7), accum = cumsum(totpcnt)) %>%
  head(15)

wine_filtered <- top15Ctry_wine %>%
  filter(variety %in% top15Variety$variety)

write.csv(wine_filtered, file="wine_filtered.csv", row.names=FALSE)