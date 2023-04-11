library(tidyverse)
library(StatsBombR)
library(ggsoccer)
library(stringr)
library(dplyr)

# Retreive all available competition
Comp <- FreeCompetitions()

# # Filter the competition
fifa_2022_wc <- Comp %>%
  filter(competition_id==43 & season_name=="2022")


# Retrieve all available matches
matches <- FreeMatches(fifa_2022_wc)


# Retrieve the event data of the wc final
final_df <- get.matchFree(matches[7,])

# Process the data
cleaned_df <- allclean(final_df)


all_types<-  cleaned_df %>%
  group_by(type.name) %>% 
  summarise(count = n())


# Passmap

messi_pass <- cleaned_df %>%
  filter(str_detect(player.name, "Messi")) %>%
  filter(type.name == 'Pass')


ggplot(messi_pass) +
  annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') + 
  geom_segment(aes(x=location.x, y=location.y, xend=pass.end_location.x, yend=pass.end_location.y),
               colour = "#D5B048",
               arrow = arrow(length = unit(0.15, "cm"),
                             type = "closed")) +
  labs(title="Messi's Passing Map",
       subtitle="Fifa World Cup Final 2022",
       caption="Data Source: StatsBomb") + 
  theme(
    plot.background = element_rect(fill='#43A1D5', color='#43A1D5'),
    panel.background = element_rect(fill='#43A1D5', color='#43A1D5'),
    plot.title = element_text(hjust=0.5, vjust=0, size=14),
    plot.subtitle = element_text(hjust=0.5, vjust=0, size=8),
    plot.caption = element_text(hjust=0.5),
    text = element_text(family="Geneva", color='white'),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank()
  )

# The pass arrows looks quite long, lets check what the average pass length was
cleaned_df %>%
  filter(str_detect(player.name, "Messi")) %>%
  filter(type.name == 'Pass') %>%
  summarize(average_pass_dist = mean(pass.length))


# How hard did France defend Messi?
num_of_press <- messi_pass %>%
  filter(type.name == "Pass") %>%
  summarise(num_press = sum(under_pressure == TRUE, na.rm = TRUE))

total_passes <- messi_pass %>%
  filter(type.name == "Pass") %>%
  nrow()

# Percentage of his passes where Messi was pressured
num_of_press/total_passes


# Messi heatmap

messi_heat <- cleaned_df %>%
  filter(str_detect(player.name, "Messi")) %>%
  filter(type.name == "Carry" | type.name == "Ball Receipt*")


ggplot(messi_heat) +
  annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') +
  geom_density2d_filled(aes(location.x, location.y, fill=..level..), alpha=0.4, contour_var='ndensity') +
  scale_x_continuous(c(0, 120)) +
  scale_y_continuous(c(0, 80)) +
  labs(title="Messi's Heat Map",
       subtitle="Fifa World Cup Final 2022",
       caption="Data Source: StatsBomb") + 
  theme_minimal() +
  theme(
    plot.background = element_rect(fill='#43A1D5', color='#43A1D5'),
    panel.background = element_rect(fill='#43A1D5', color='#43A1D5'),
    plot.title = element_text(hjust=0.5, vjust=0, size=14),
    plot.subtitle = element_text(hjust=0.5, vjust=0, size=8),
    plot.caption = element_text(hjust=0.5),
    text = element_text(family="Geneva", color='white'),
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    legend.position = "none"
  )

ball_lost <- cleaned_df %>% 
  filter(team.name == "Argentina" & type.name == "Dispossessed")

ggplot()