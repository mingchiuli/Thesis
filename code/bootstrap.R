header <- "---
title: '“戒急用忍”卷土重来——台湾“南向政策”与“新南向政策”效果评估'
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
    toc_depth: 2
    toc: yes
    keep_tex: true
bibliography: ref/ref.bib
csl: ref/chinese-gb7714-2015-numeric.csl
---"

init <- "```{r, include=FALSE}
c('tidyverse', 'stargazer', 'plm', 
  'sandwich', 'lmtest', 'ggpubr', 
  'showtext', 'rticles','maps', 
  'see','bookdown','sf','rlang', 
  'car') |> 
  lapply(function(pkg) {
    if (system.file(package = pkg) == '') {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  })
showtext_auto()

fn_state <- c('China', 'India', 'Pakistan', 'Bangladesh', 'Nepal', 'Sri Lanka', 'Maldives', 'Bhutan', 'Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand', 'Papua New Guinea', 'Palau', 'Kiribati', 'Maldives', 'Nauru', 'New Caledonia', 'Vanuatu', 'Samoa', 'Marshall Islands', 'Thailand', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Japan', 'South Korea', 'Hong Kong', 'USA', 'Macao', 'UK', 'France', 'Germany', 'Spain', 'Italy', 'Canada', 'Netherlands', 'Panama', 'Bahamas', 'Guatemala', 'Honduras')
fn_first_state <- c('Thailand','Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei')
fn_second_state <- c('Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand')
EURO <- c('UK', 'Austria', 'Bulgaria', 'Croatia', 'Czech Republic', 'Belgium', 'Cyprus', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden')
NAFTA <- c('USA', 'Canada', 'Mexico')
ASEAN <- c('Malaysia', 'Indonesia', 'Thailand', 'Philippines', 'Singapore', 'Vietnam', 'Brunei', 'Laos', 'Myanmar', 'Cambodia')
NSBP <- c('India', 'Pakistan', 'Bangladesh', 'Nepal', 'Sri Lanka', 'Bhutan', 'Laos', 'Myanmar', 'Cambodia', 'Australia', 'New Zealand', 'Thailand', 'Malaysia', 'Indonesia', 'Philippines', 'Singapore', 'Vietnam', 'Brunei')
NSBP_core <- c('Philippines', 'Vietnam', 'Malaysia', 'Indonesia', 'Thailand', 'India')

tw_data <- read_csv('data/data.csv', show_col_types = FALSE) |> 
  group_by(Year) |> 
  mutate(双边占比 = (Export + Import) / sum(Export + Import, na.rm = TRUE), 进口占比 = Import / sum(Import, na.rm = TRUE), 出口占比 = Export / sum(Export, na.rm = TRUE), 投资占比 = FDI / sum(FDI, na.rm = TRUE), 对台投资 = to_tw_invest / sum(to_tw_invest, na.rm = TRUE), 生产总值 = log(GDP), 人口 = log(Pop)) |> 
  ungroup() |> 
  rename(政策干预 = Treat, 外交关系 = Diplomatic, 外交持续 = duDiplomatic, 世贸组织 = WTO_Y_IN_TW_IN, 亚太经合 = APEC, 开放度 = Openness, 实际汇率 = Reer3, 自贸协定 = FTA, 两岸协议 = ECFA) |> 
  mutate(一次核心 = if_else(State %in% fn_first_state, 1, 0),  一次非核心 = if_else(State %in% fn_second_state, 1, 0), 二次核心 = if_else(State %in% NSBP_core, 1, 0), 二次非核心 = if_else(!State %in% NSBP_core & State %in% NSBP, 1, 0)) |> 
  mutate(一次核心干预 = 政策干预 * 一次核心, 一次非核心干预 = 政策干预 * 一次非核心, 二次核心干预 = 政策干预 * 二次核心, 二次非核心干预 = 政策干预 * 二次非核心)
  
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

gene_fig <- function(reg, title, subtitle, seq_1, seq_2, seq_3) {
  coef <- as.data.frame(coeftest(reg, vcov.=plm::vcovHC(reg, type = 'HC0', cluster = 'group', method = 'arellano'))[seq_1, 1 : 2])
  coef_heter_1 <- as.data.frame(coeftest(reg, vcov.=plm::vcovHC(reg, type = 'HC0', method = 'white1'))[seq_1, 1 : 2])
  coef_homo <- as.data.frame(coeftest(reg)[seq_1, 1 : 2])
  
  coef[['up_homo']] <- NA
  coef[['low_homo']] <- NA
  coef[['up_heter_1']] <- NA
  coef[['low_heter_1']] <- NA
  coef[['up']] <- NA
  coef[['low']] <- NA
  coef[['t']] <- NA
  coef[['up']] <- coef[['Estimate']] + 1.96 * coef[['Std. Error']]
  coef[['low']] <- coef[['Estimate']] - 1.96 * coef[['Std. Error']]
  
  coef[['up_heter_1']] <- coef_heter_1[['Estimate']] + 1.96 * coef_heter_1[['Std. Error']]
  coef[['low_heter_1']] <- coef_heter_1[['Estimate']] - 1.96 * coef_heter_1[['Std. Error']]
  
  coef[['up_homo']] <- coef_homo[['Estimate']] + 1.96 * coef_homo[['Std. Error']]
  coef[['low_homo']] <- coef_homo[['Estimate']] - 1.96 * coef_homo[['Std. Error']]
  
  coef[['t']] <- seq_2
  p <- ggplot(coef, aes(t, Estimate)) +
    geom_hline(yintercept = 0, linewidth = 1, col = 'white') +
    geom_point() +
    geom_point(aes(x=-1, y=0), col='red') +
    geom_errorbar(aes(ymin = low, ymax = up, col = '聚类稳健标准误'), width = 0.2) +
    geom_errorbar(aes(ymin = low_heter_1, ymax = up_heter_1, col = '异方差稳健标准误'), linetype = 'dashed', width = 0.2, position = 'jitter') +
    geom_errorbar(aes(ymin = low_homo, ymax = up_homo, col = '普通标准误'), linetype = 'dotdash', width = 0.2, position = 'jitter') +
    ylab('系数') +
    xlab('年份') +
    scale_x_continuous(breaks = seq_3) +
    scale_color_manual(values = c('blue', 'red', 'black')) +
    geom_vline(xintercept = -1, linetype = 'dashed') +
    labs(col = '类别')
  
  if (!is.na(title)) {
    p <- p + labs(title = title, subtitle = subtitle) 
  } else {
    p <- p + labs(subtitle = subtitle) 
  }
  return(p)
}

ccp_world <- st_read('data/21ESRI/21ESRI.shp') |> 
  mutate(State = gene_state(CNTRY_NAME)) |> 
  filter(State != 'Antarctica')

fn_data_homo <- tw_data |> 
  filter(Year < 2003, Year >= 1990, State %in% fn_state) |> 
  mutate(fn_d = if_else(State %in% fn_first_state, Year - 1994, if_else(State %in% fn_second_state, Year - 1997, NA)))
  
fn_data_heter <- tw_data |> 
  filter(Year < 2003, Year >= 1990, State %in% fn_state) |> 
  mutate(fn_d = if_else(State %in% fn_first_state, Year - 1994, NA))
  
NSBP_data_homo <- tw_data |> 
  filter(Year >= 2008) |> 
  mutate(nsbp_d = if_else(State %in% NSBP, Year - 2016, NA))
  
NSBP_data_heter <- tw_data |> 
  filter(Year >= 2008) |> 
  mutate(nsbp_d = if_else(State %in% NSBP_core, Year - 2016, NA))  
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

