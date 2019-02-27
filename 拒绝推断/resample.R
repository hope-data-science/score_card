

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

# save.image("in_re.RData")

# establish model using data of Jan.
step_lr$model %>% 
  str_remove("_woe") -> main_features

raw12 %>% 
  filter(month == 1) %>% 
  select(label,main_features) -> raw1

woebin(raw1, y = "label") -> raw1_bins
woebin_ply(raw1,bins = raw1_bins) -> raw1_woe

##########resample start from here#############
library(pacman)
p_load(scorecard,dplyr,data.table,
       lubridate,tibble,rio,caret,bigstep)

load("in_re.RData")

# build models

?train

raw1_woe %>% 
  as_tibble %>% 
  mutate(label = ifelse(label == 1,"bad","good")) -> raw1_woe

#validation
raw12 %>% 
  filter(month == 2) %>% 
  select(label,main_features) -> raw2

woebin_ply(raw2,bins = raw1_bins) %>% 
  mutate(label = ifelse(label == 1,"bad","good"))-> raw2_woe

train(label~.,data = raw1_woe,
      method = "glm",metric = "ROC",
      trControl = trainControl(method = "none",
                               summaryFunction = twoClassSummary,
                               classProbs = T)) -> raw1_model

# glm(label~.,data = raw1_woe,family = binomial()) -> raw1_model



raw1_model %>% 
  predict(raw2_woe) -> predY

raw2_woe$label %>% as.factor()-> realY

confusionMatrix(predY, realY,positive = "bad")

############################








