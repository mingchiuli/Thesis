if (system.file(package = "stringr") == '') {
  install.packages("stringr")
}

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
  purrr::map(\\(pkg) {
    if (system.file(package = pkg) == '') {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  })
showtext_auto()
twData <- read_csv('data/data.csv')
```"
 
header <- '---
title: "戒急用忍：台湾地区的南向政策"
author:
  - 李鸣玖
header-includes:
  - \\usepackage{lscape}
  - \\usepackage{ctex}
papersize: "a4"
geometry: "margin=1.5in"
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
---'
 
rmd <- list.files(pattern = '*.Rmd', recursive = T)
chunk <- stringr::str_c(header, "\n", init, "\n")
chunks <- stringr::str_c("```{r child = '", rmd, "'}\n```" ,"\n\n", "\\newpage", "\n")
chunks <- c(chunk, chunks, "# 参考文献 \n")
writeLines(chunks, "out.rmd")
rmarkdown::render("out.rmd")
# file.remove('out.rmd', 'out.log')
# system2("open",'out.pdf')
