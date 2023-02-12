init <- "```{r, include=FALSE}
c('tidyverse', 
  'stargazer', 
  'plm', 
  'sandwich', 
  'lmtest', 
  'ggpubr', 
  'showtext', 
  'rticles', 
  'maps', 
  'see',
  'bookdown') |> 
  lapply(\\(pkg) {
    if (system.file(package = pkg) == '') {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  })
showtext_auto()
twData <- read_csv('data/data.csv')
ASEAN <- c('Malaysia', 'Indonesia', 'Thailand', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Laos', 'Myanmar', 'Cambodia')
```"
 
header <- "---
title: '戒急用忍：台湾地区的南向政策'
author:
  - 李鸣玖
header-includes:
  - \\usepackage{lscape}
  - \\usepackage{ctex}
papersize: 'a4'
geometry: 'margin=1.75in'
keywords:
  - 南向政策
  - 台湾经贸
indent: true  
output:
  bookdown::pdf_document2:
    latex_engine: xelatex
    fig_caption: yes
    number_sections: yes
    toc_depth: 2
    toc: yes
bibliography: bibliography.bib
---"

list.files(pattern = '*.Rmd', recursive = T) |> 
  lapply(\(file) paste("```{r child = '", file, "'}\n```\n\n\\newpage\n")) |> 
  as.character() |> 
  paste(collapse = '') |> 
  paste(header, '\n',init, '\n',arg = _, "# 参考文献 \n") |> 
  gsub(' ```', '```', x = _) |> 
  writeLines('out.rmd')

rmarkdown::render("out.rmd")
file.remove('out.rmd', 'out.log')
system2("open",'out.pdf')
