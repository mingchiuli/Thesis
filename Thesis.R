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
  'bookdown',
  'sf') |> 
  lapply(\\(pkg) {
    if (system.file(package = pkg) == '') {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  })
showtext_auto()
tw_data <- read_csv('data/data.csv', show_col_types = FALSE)
ASEAN <- c('Malaysia', 'Indonesia', 'Thailand', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Laos', 'Myanmar', 'Cambodia')
NSBP <- c('India', 'Pakistan', 'Bangladesh', 'Nepal', 'Sri Lanka', 'Bhutan', 'Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand', 'Thailand', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei')

gene_state <- Vectorize(\\(cntry) {
  switch (cntry,
    'Trinidad & Tobago' = 'Trinidad',
    'St. Lucia' = 'Saint Lucia',
    'St. Vincent & the Grenadines' = 'Saint Vincent',
    'The Bahamas' = 'Bahamas',
    'Antigua & Barbuda' = 'Antigua',
    'St. Kitts & Nevis' = 'Saint Kitts',
    'United Kingdom' = 'UK',
    'Cote d\\'Ivoire' = 'Ivory Coast',
    'The Gambia' = 'Gambia',
    'Sao Tome & Principe' = 'Sao Tome and Principe',
    'Bosnia & Herzegovina' = 'Bosnia and Herzegovina',
    'North Macedonia' = 'Macedonia',
    'Vatican City' = 'Vatican',
    'Marshall Is.' = 'Marshall Islands',
    'United States' = 'USA',
    'Congo' = 'Republic of Congo',
    'Congo, DRC' = 'Democratic Republic of the Congo',
    cntry
  )
})

ccp_world <- st_read('data/21ESRI/21ESRI.shp') |> 
  mutate(State = gene_state(CNTRY_NAME))
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
  paste(header, '\n', init, '\n', arg = _, "# 参考文献 \n") |> 
  gsub(' ```', '```', x = _) |> 
  writeLines('out.rmd')

rmarkdown::render("out.rmd")
file.remove('out.rmd', 'out.log')
system2("open",'out.pdf')

