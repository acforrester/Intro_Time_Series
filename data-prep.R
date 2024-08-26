#
#
#
# ************************************************


pacman::p_load(
  tidyverse,
  tseries,
  forecast,
  caret,
  randomForest,
  xgboost)


df_hsg_dates <- read_csv(
  file = "data-raw/RESCONST-mf.csv",
  skip = 36,
  n_max = 792,
  col_types = "dc")



df_hsg_starts <- read_csv(
  file = "data-raw/RESCONST-mf.csv",
  skip = 840)%>% 
  filter(cat_idx == 5,
         dt_idx ==1,
         is_adj == 0,
         et_idx == 0,
         geo_idx %in% 1:4,
         per_idx %in% 505:792) %>% 
  
  mutate(region = case_when(
    geo_idx == 1 ~ "Northeast",
    geo_idx == 2 ~ "Midwest",
    geo_idx == 3 ~ "South",
    geo_idx == 4 ~ "West"),
    geo_idx = NULL) %>% 
  
  pivot_wider(names_from = "region",
              values_from = "val") %>% 
  
  # Join the dates
  left_join(df_hsg_dates, by = join_by(per_idx)) %>% 
  
  # Fix date column
  mutate(date = as.Date(paste0("01-", per_name), "%d-%B-%Y")) %>% 
  
  # Subset data
  select(date, Northeast:West) %>% 
  
  # keep 2000's 
  filter(date >= "2000-01-01")



# Time Series Plots ----

df_hsg_starts %>% 
  
  # 
  pivot_longer(cols = Northeast:West,
               names_to = "region",
               values_to = "starts") %>% 
  
  ggplot(data = ., aes(x = date, y = starts)) +
  
  geom_line(linewidth = 1, color = "darkred") +
  
  theme_minimal() +
  labs(y = "Housing Starts (000s)")
  
  facet_wrap(~region, scales = "free_y")
  

save(list = "df_hsg_starts",
     file = "data_housing.Rda")


# Let's look at seasonal plots ----


df_hsg_starts %>% 
  
  mutate(month = format(date, "%b")) %>% 
  
  reframe(.by = month, across(Northeast:West, mean)) %>% 
  
  # 
  pivot_longer(cols = Northeast:West,
               names_to = "region",
               values_to = "seas_avg") %>% 
  
  mutate(.by = region,
         uncond_avg = mean(seas_avg),
         month = factor(month, levels = month.abb)) %>% 

  ggplot(data = ., aes(x = month, y = seas_avg, group = 1)) +
  
  geom_line(linewidth = 1, color = "darkred") +
  
  geom_point(size = 1.5, color = "darkred") +
  
  #geom_hline(yintercept = uncond_avg, 
  #           linetype = "dashed",
  #           linewidth = 1) + 
  
  labs(y = "Seasonal Averages",
       x = element_blank()) +
  
  facet_wrap(~region, scales = "free_y") + 
  theme_classic()











# Stationarity Tests ----


tseries::adf.test(df_hsg_starts$West, k = 12)

