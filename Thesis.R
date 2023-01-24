
if (system.file(package = "stringr") == '') {
  install.packages("stringr")
}
library(stringr)

init <- "```{r, include=FALSE}
lapply(c('tidyverse', 'stargazer', 'plm', 'sandwich', 'lmtest', 'ggpubr', 'showtext', 'rticles'), function(pkg) {
   if (system.file(package = pkg) == '') {
     install.packages(pkg)
   }
   library(pkg, character.only = TRUE)
 })
 showtext_auto()
 twData <- read_csv('data.csv')
```"
 
title <- '---
title: "戒急用忍：台湾地区的南向经济"
author:
  - 李鸣玖
documentclass: ctexart
keywords:
  - 南向政策
  - 台湾经贸
output:
  rticles::ctex:
    fig_caption: yes
    number_sections: yes
    toc: yes
bibliography: bibliography.bib
---'
 
rmd <- list.files(pattern = '*.Rmd', recursive = T)

chunk <- str_c(title, "\n", init, "\n")
chunks <- str_c("```{r child = '", rmd, "'}\n```" ,"\n", "\\newpage")

chunks <- c(chunk, chunks, "# 参考文献\n")

writeLines(chunks, "out.rmd")

rmarkdown::render("out.rmd")
