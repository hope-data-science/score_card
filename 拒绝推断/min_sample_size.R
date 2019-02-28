

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

##########min_sample start from here#############
library(pacman)
p_load(scorecard,dplyr,data.table,
       lubridate,tibble,caret,tidyr,purrr)

load("in_re.RData")

raw1_woe %>% 
  mutate_at(vars(matches("f_")),funs(scale)) -> raw1_test

bsts::GeometricSequence(length = 7, initial.value = 50, discount.factor = 2) %>% 
  enframe %>% 
  transmute(sample_size = value) -> sample_size

seq(500,5000,by = 500) %>% 
  enframe %>% 
  transmute(sample_size = value) -> sample_size

get_sd = function(sample_size){
  
  tibble() -> all_this
  for(i in 1:10){
    raw1_test %>% 
      sample_n(sample_size) -> dat
    
    glm(label~.,data = dat,family = binomial) %>% 
      broom::tidy() %>% 
      dplyr::select(term,estimate) %>% 
      tidyr::spread(term,estimate) %>% 
      dplyr::select(-1)  -> this
    
    all_this %>% bind_rows(this) -> all_this
  }
  
  all_this %>% summarise_all(funs(sd))
  
}

sample_size %>% 
  mutate(sd_list = purrr::map(sample_size,get_sd)) %>% 
  unnest() %>%
  gather(key = "feature",value = "value",-sample_size) -> test_table

readr::write_csv(test_table,"t.csv")

###windows
read_csv("E:/t.csv") -> for_plot

for_plot %>% 
  ggplot(aes(sample_size,value,colour = feature)) +
  geom_line() + ylab("sd. of estimation") +
  scale_y_log10()



