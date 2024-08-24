#process
examfiles <- list.files(path = "data/CMB-Exam",
                        recursive = T,
                        full.names = T)
examfiles <- examfiles[!grepl("hierarchy",examfiles)]

library(dplyr)
library(data.table)

json2df3 <- jsonlite::fromJSON(examfiles[3]) %>% 
  as.data.table()
json2df1 <- jsonlite::fromJSON(examfiles[1]) %>% 
  dplyr::left_join(dplyr::select(jsonlite::fromJSON("data/CMB-test-choice-answer.json"),
                                 all_of(c("id","answer"))),by = "id") %>% 
  as.data.table() %>% 
  dplyr::select(-id) %>% 
  dplyr::mutate(explanation = "NA") %>% 
  dplyr::select(all_of(colnames(json2df3))) 

json2df2 <- jsonlite::fromJSON(examfiles[2])  %>% 
  as.data.table() %>%
  dplyr::mutate(explanation = "NA")%>% 
  dplyr::select(all_of(colnames(json2df3)))
json2df <- rbind(json2df1,json2df2) %>% 
  rbind(.,json2df3)
saveRDS(json2df,"data/medexam_dataset.RDS")
exam_levels <- levels(factor(json2df$exam_class))
exam_levels_pinyin <- c("ZYXYZYZ", "ZYZH", "ZJZC", "LCYX", 
                        "ZZZYYS", "ZZJS", "ZZHS", "ZZYS", 
                        "CJZYS", "CJZYSh", "CJYS", "CJYSh", 
                        "YJS", "YJSh", "JCYX", "ZYZYSh", 
                        "ZYZLYSh", "ZYYSh", "ZYXYSh", "HSZYZZ", 
                        "HShZYZZ", "HLX", "KYZZ", "XYZZ", 
                        "GPJY","YFYX","GJHSh","GJZC")
exam_shortname_df <- data.frame(examleves = exam_levels,
                                exampinyin = exam_levels_pinyin)
saveRDS(exam_shortname_df,"data/exam_shortname_df.RDS")
saveRDS(exam_levels,"data/exam_levels.RDS")
for (i in 1:length(exam_levels)) {
  json_leveldf <- json2df %>% 
    dplyr::filter(exam_class %in% exam_levels[i]) %>%
    #dplyr::distinct(question,.keep_all = T) %>% 
    saveRDS(.,glue::glue("data/en/{exam_levels_pinyin[i]}.RDS"))
}
