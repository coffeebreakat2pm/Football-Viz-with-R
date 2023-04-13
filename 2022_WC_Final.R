library(tidyverse)
library(StatsBombR)
library(ggsoccer)
library(stringr)
library(dplyr)
library(lubridate)
library(cowplot)




# Line up


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

# Retrieving line ups
arg_lineup <- cleaned_df[[24]][[1]] %>% 
  select(jersey_number, player.name, position.name)

fre_lineup <- cleaned_df[[24]][[2]] %>%
  select(jersey_number, player.name, position.name)

arg_lineup
fre_lineup



suppressMessages(zero_to_42 <- cleaned_df %>%
                   filter(minute >= 0 & minute <= 42) %>%
                   group_by(team.name, type.name) %>%
                   summarise(count = n()))

zero_to_42_team_summary <- zero_to_42 %>%
  pivot_wider(names_from = team.name, values_from = count, values_fill = 0) %>%
  mutate(Total = Argentina + France)

zero_to_42_team_summary_sorted <- zero_to_42_team_summary %>%
  arrange(desc(Total))

zero_to_42_team_summary_sorted


france_pressure <- cleaned_df %>% 
  filter(minute >= 0 & minute <= 42) %>% 
  filter(team.name == "France") %>% 
  filter(type.name == "Pressure")

argentina_pass <- cleaned_df %>% 
  filter(minute >= 0 & minute <= 42) %>% 
  filter(team.name == "Argentina") %>% 
  filter(type.name == "Pass")


suppressMessages(ggplot(france_pressure) +
                   annotate_pitch(dimensions = pitch_statsbomb, fill='#021e3f', colour='#DDDDDD') +
                   geom_density2d_filled(aes(location.x, location.y, fill=..level..), alpha=0.4, contour_var='ndensity') +
                   scale_x_continuous(c(0, 120)) +
                   scale_y_continuous(c(0, 80)) +
                   labs(title="France's Pressure Heat Map (Min 0 to 42)",
                        subtitle="FIFA 2022 World Cup",
                        caption="Data Source: StatsBomb") + 
                   theme_minimal() +
                   theme(
                     plot.background = element_rect(fill='#021e3f', color='#021e3f'),
                     panel.background = element_rect(fill='#021e3f', color='#021e3f'),
                     plot.title = element_text(hjust=0.5, vjust=0, size=14),
                     plot.subtitle = element_text(hjust=0.5, vjust=0, size=8),
                     plot.caption = element_text(hjust=0.5),
                     text = element_text(family="Geneva", color='white'),
                     panel.grid = element_blank(),
                     axis.title = element_blank(),
                     axis.text = element_blank(),
                     legend.position = "none"
                   )
)

suppressMessages(ggplot(argentina_pass) +
                   annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') +
                   geom_density2d_filled(aes(location.x, location.y, fill=..level..), alpha=0.4, contour_var='ndensity') +
                   scale_x_continuous(c(0, 120)) +
                   scale_y_continuous(c(0, 80)) +
                   labs(title="Argentina's Passing Heat Map (Min 0 to 42)",
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
)


argentina_receive <- cleaned_df %>% 
  filter(minute >= 0 & minute <= 42) %>% 
  filter(team.name == "Argentina") %>% 
  filter(type.name == "Ball Receipt*")

suppressMessages(ggplot(argentina_receive) +
                   annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') +
                   geom_density2d_filled(aes(location.x, location.y, fill=..level..), alpha=0.4, contour_var='ndensity') +
                   scale_x_continuous(c(0, 120)) +
                   scale_y_continuous(c(0, 80)) +
                   labs(title="Argentina's Pass Reception Heat Map (Minute 0 - 42)",
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
)

arg_type <- cleaned_df %>% 
  filter(minute >= 0 & minute <= 42) %>% 
  filter(team.name == "Argentina") %>% 
  select(player.name, type.name)

arg_summary <- arg_type %>%
  group_by(player.name, type.name) %>%
  summarize(count = n()) %>%
  pivot_wider(names_from = type.name, values_from = count, values_fill = 0)

argentina_dribbles <- arg_summary %>%
  select(player.name, "Dribble", "Dribbled Past") %>% 
  arrange(desc(Dribble))

suppressMessages(argentina_dribbles)



messi_pass <- cleaned_df %>%
  filter(minute >= 0 & minute <= 42) %>% 
  filter(str_detect(player.name, "Messi")) %>%
  filter(type.name == 'Pass')


ggplot(messi_pass) +
  annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') + 
  geom_segment(aes(x=location.x, y=location.y, xend=pass.end_location.x, yend=pass.end_location.y),
               colour = "#D5B048",
               arrow = arrow(length = unit(0.15, "cm"),
                             type = "closed")) +
  labs(title="Messi's Passing Map (Min 0 to 42)",
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


messi_heat <- cleaned_df %>%
  filter(minute >= 0 & minute <= 42) %>% 
  filter(str_detect(player.name, "Messi")) %>%
  filter(type.name == "Carry" | type.name == "Ball Receipt*" | type.name == "Dribble" | type.name == "Pass" |type.name == "Shot")


ggplot(messi_heat) +
  annotate_pitch(dimensions = pitch_statsbomb, fill='#43A1D5', colour='#DDDDDD') +
  geom_density2d_filled(aes(location.x, location.y, fill=..level..), alpha=0.4, contour_var='ndensity') +
  scale_x_continuous(c(0, 120)) +
  scale_y_continuous(c(0, 80)) +
  labs(title="Messi's Heat Map (Min 0 to 42)",
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

