# Make a figure of model predictions with data

source("header.R")

dat <- read_rds("dat.rds")
fit <- read_rds("fit.rds")

# Make data for plotting ----
df <- fit$draws("beta") %>%
  as_draws_df() %>%
  mutate(
    log_asv_abundance_1 = `beta[1,1]`,
    log_sample_count_1 = `beta[2,1]`,
    log_asv_abundance_2 = `beta[1,1]` + `beta[1,2]`,
    log_sample_count_2 = `beta[2,1]` + `beta[2,2]`,
    log_asv_abundance_3 = `beta[1,1]` + `beta[1,3]`,
    log_sample_count_3 = `beta[2,1]` + `beta[2,3]`
    # log_asv_abundance_4 = `beta[1,1]` + `beta[1,2]` + `beta[1,3]` + `beta[1,4]`,
    # log_sample_count_4 = `beta[2,1]` + `beta[2,2]` + `beta[2,3]` + `beta[2,4]`
  ) %>%
  select(starts_with("log")) %>%
  pivot_longer(everything(), values_to = "estimate") %>%
  group_by(name) %>%
  point_interval() %>%
  mutate(
    group = str_extract(name, "[1-4]{1}$"),
    name = str_remove(name, "_[1-4]{1}$")
  ) %>%
  pivot_wider(values_from = c(estimate, .lower, .upper)) 

## Make figure ----
ggplot(df, aes(
  x = estimate_log_sample_count, y = estimate_log_asv_abundance,
  xmin = .lower_log_sample_count, ymin = .lower_log_asv_abundance,
  xmax = .upper_log_sample_count, ymax = .upper_log_asv_abundance,
  color = as.factor(group)
)) +
  facet_grid(group ~ ., labeller = labeller(
    group = c(
      `1` = "others",
      `2` = "soil-host core",
      `3` = "unique core"
    ))) +
  geom_point(
    data = dat,
    mapping = aes(x = log_sample_count, y = log_asv_abundance,
                  color = as.factor(group)), 
    inherit.aes = FALSE, alpha = 0.2
  ) +
  geom_linerange(orientation = "x", size = 2) +
  geom_linerange(orientation = "y", size = 2) +
  geom_point(size = 5, shape = 21, fill = "white") +
  scale_color_manual(values = c("black", "darkgoldenrod1", "slateblue1")) +
  xlab("log(sample_count)") +
  ylab("log(asv_abundance)") +
  theme_cowplot() +
  theme(legend.position = "none")

## Save figure ----
ggsave("results.pdf", width = 6, height = 6)
