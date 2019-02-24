

library(pacman)
p_load(scorecard,dplyr,data.table,
       lubridate,tibble,rio,caret,bigstep)

import("/home/tyHuang/rejection_inference/reject_inference.fst")%>% as_tibble -> raw

#extract Jan. and Feb. data
raw %>% 
  as.data.table %>% 
  .[,month:=month(loan_dt),] %>% 
  .[month == 1 | month == 2,
    .SD,
    .SDcols = c("label","month",
                names(raw)[startsWith(names(raw),"f")])] %>% 
  .[!is.na(label)] %>% 
  as_tibble()-> raw12


#filter using data of Jan.
raw12 %>% 
  filter(month == 1) %>% 
  select(-month) %>% 
  var_filter(y = "label") %>% 
  as_tibble() -> raw1_filter

# woe binning
woebin(raw1_filter, y = "label") -> raw1_bins
woebin_ply(raw1_filter,bins = raw1_bins) -> raw1_woe

save("fff.RData")

#filter after woe binning
raw1_woe %>% 
  var_filter(y = "label") %>% 
  as_tibble() -> raw1_filter2

#reduce collinearity
p_load(caret)

raw1_filter2 %>% 
  select(-label) -> without_y 

without_y %>% 
  cor(.) %>%
  findCorrelation(.,cutoff = .75, names = T) -> to_be_removed

without_y %>% 
  select(-to_be_removed) %>% 
  bind_cols(raw1_filter2 %>% select(label),.) -> raw1_washed

#bigstep
p_load(bigstep)

raw1_washed %>% 
  pull(label) -> Y

raw1_washed %>% 
  select(-label) %>% 
  as.matrix() -> X

prepare_data(Y,X,type = "logistic") -> data

data %>% 
  reduce_matrix() %>% 
  fast_forward() %>% 
  multi_backward() -> step_lr

summary(step_lr)

#validation
#model extraction
raw1_washed %>% 
  select(label,step_lr$model) %>% 
  glm(label~.,data = .,family = binomial) -> lr_final_1


raw12_complete %>% 
  filter(month == 2) %>% 
  predict(lr_final_1,.) -> preY

ifelse(preY > 0.5, "bad", "good") %>% 
  as.factor()-> predY

raw12_complete %>% 
  filter(month == 2) %>% 
  pull(label) -> reaY

ifelse(reaY > 0.5, "bad", "good") %>% 
  as.factor()-> realY

confusionMatrix(predY, realY,positive = "bad")

