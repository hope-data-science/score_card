

library(pacman)
p_load(scorecard,dplyr,data.table,
       lubridate,tibble,rio,caret,bigstep)

import("/home/tyHuang/rejection_inference/reject_inference.fst")%>% as_tibble -> raw

raw %>% 
  as.data.table %>% 
  .[,month:=month(loan_dt),] %>% 
  .[month == 1 | month == 2,
    .SD,
    .SDcols = c("label","month",
                names(raw)[startsWith(names(raw),"f")])] %>% 
  .[!is.na(label)] %>% 
  as_tibble()-> raw12

raw12 %>% 
  as.data.table() %>% 
  .[,lapply(.SD,is.na)] %>% 
  .[,lapply(.SD,mean)] %>% 
  t() %>% 
  data.frame(missing_rate = .) %>% 
  rownames_to_column(var = "variable") %>% 
  as_tibble()-> raw_ms
  
raw_ms %>% 
  filter(missing_rate == 0) %>% 
  pull(variable) %>% 
  as.data.table(raw12)[,.SD,.SDcols = .] %>% 
  as_tibble() -> raw12_complete

raw12_complete %>% 
  filter(month == 1) %>% 
  select(-month) %>% 
  var_filter(y = "label") %>% 
  as_tibble() -> raw1_filter

#reduce collinearity
p_load(caret)

raw1_filter %>% 
  select(-label) -> without_y 

without_y %>% 
  cor(.) %>% 
  findCorrelation(.,cutoff = .75) -> to_be_removed

without_y %>% 
  select(-to_be_removed) %>% 
  bind_cols(raw1_filter %>% select(label),.) -> raw1_washed
 
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
  fast_forward() -> step_lr

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

