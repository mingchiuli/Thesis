header <- "---
title: '“戒急用忍”的卷土重来——台湾“南向政策”与“新南向政策”效果评估'
author:
  - 
header-includes:
  - \\usepackage{lscape}
  - \\usepackage{ctex}
papersize: 'a4'
geometry: 'margin=1in'
keywords:
  - 南向政策
  - 台湾经贸
indent: true
output:
  bookdown::pdf_document2:
    latex_engine: xelatex
    fig_caption: yes
    number_sections: yes
    toc_depth: 3
    toc: yes
    keep_tex: false
bibliography: ref/ref.bib
csl: ref/chinese-gb7714-2015-numeric.csl
---"

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
  'sf',
  'rlang') |> 
  lapply(function(pkg) {
    if (system.file(package = pkg) == '') {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  })
showtext_auto()
tw_data <- read_csv('data/data.csv', show_col_types = FALSE)
ASEAN <- c('Malaysia', 'Indonesia', 'Thailand', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Laos', 'Myanmar', 'Cambodia')
NSBP <- c('India', 'Pakistan', 'Bangladesh', 'Nepal', 'Sri Lanka', 'Bhutan', 'Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand', 'Thailand', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei')

gene_state <- Vectorize(function(cntry) {
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
  mutate(State = gene_state(CNTRY_NAME)) |> 
  filter(State != 'Antarctica')
  
fn_state <- c('China', 'India', 'Pakistan', 'Bangladesh', 'Nepal', 'Sri Lanka', 'Maldives', 'Bhutan', 'Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand', 'Papua New Guinea', 'Palau', 'Kiribati', 'Maldives', 'Nauru', 'New Caledonia', 'Vanuatu', 'Samoa', 'Marshall Islands', 'Thailand', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Japan', 'South Korea', 'Hong Kong', 'USA', 'Macao', 'UK', 'France', 'Germany', 'Spain', 'Italy', 'Canada', 'Netherlands')
fn_first_state <- c('Thailand','Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei')
fn_second_state <- c('Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand')

fn_data <- tw_data |> 
  filter(Year < 2003, Year >= 1990, State %in% fn_state) |> 
  rename(政策干预 = Treat, 出口占比 = ExpPerc, 进口占比 = ImpPerc, 投资占比 = FDIPerc, 外交关系 = Diplomatic, 外交持续 = duDiplomatic, 世贸组织 = WTO_Y_IN_TW_IN, 亚太经合 = APEC, 开放度 = Openness, 人口 = LPop, 生产总值 = LGDP) |> 
  mutate(fn_d = if_else(State %in% fn_first_state, Year - 1994, if_else(State %in% fn_second_state, Year - 1997, NA)))
  
NSBP_data <- tw_data |> 
  filter(Year >= 2008) |> 
  rename(政策干预 = Treat, 出口占比 = ExpPerc, 进口占比 = ImpPerc, 投资占比 = FDIPerc, 外交关系 = Diplomatic, 外交持续 = duDiplomatic, 世贸组织 = WTO_Y_IN_TW_IN, 两岸协议 = ECFA, 开放度 = Openness, 人口 = LPop, 生产总值 = LGDP, 自贸协定 = FTA) |> 
  mutate(nsbp_d = if_else(State %in% NSBP, Year - 2016, NA))  
  
EURO <- c('UK', 'Austria', 'Bulgaria', 'Croatia', 'Czech Republic', 'Belgium', 'Cyprus', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden')
NAFTA <- c('USA', 'Canada', 'Mexico')
```"

list.files(path = 'content', pattern = '*.Rmd', recursive = T) |> 
  lapply(function(file) paste("```{r child = 'content/", file, "'}\n```\n\\newpage\n", sep = '')) |> 
  as.character() |> 
  paste(collapse = '', sep = '') |> 
  paste(header, '\n', init, '\n', arg = _, '\n', '# 参考文献', sep = '') |> 
  writeLines('out.Rmd')

rmarkdown::render('out.Rmd')
file.remove('out.Rmd', 'out.log')
system2('open','out.pdf')

