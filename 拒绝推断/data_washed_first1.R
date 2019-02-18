
library(pacman)
p_load(data.table,tidyverse,rio)

x = file.choose()


read_tsv("C:\\Users\\Hope\\Desktop\\拒绝推断\\first1\\first1\\train_1.txt") -> t1
col_names = colnames(t1)

read_tsv("C:\\Users\\Hope\\Desktop\\拒绝推断\\first1\\first1\\train_2.txt",col_names = col_names) -> t2
read_tsv("C:\\Users\\Hope\\Desktop\\拒绝推断\\first1\\first1\\train_3.txt",col_names = col_names) -> t3
read_tsv("C:\\Users\\Hope\\Desktop\\拒绝推断\\first1\\first1\\train_4.txt",col_names = col_names) -> t4
read_tsv("C:\\Users\\Hope\\Desktop\\拒绝推断\\first1\\first1\\train_5.txt",col_names = col_names) -> t5

bind_rows(t1,t2,t3,t4,t5) -> allt

allt %>% select(label,tag) %>% summary

allt %>% count(label)
allt %>% count(tag)

allt %>% filter(label == tag)

allt %>% object.size() %>% print(unit = "auto")

gdata::keep(allt,sure = T)

export(allt,"reject_inference.fst")

