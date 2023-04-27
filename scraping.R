library(tidyverse)
library(rvest)
library(httr)
library(jsonlite)

### Step 01: get all the record pages you want
url_index <- c("http://gaceta.diputados.gob.mx/Gaceta/Votaciones/64/vot64_a1primero.html",
               "http://gaceta.diputados.gob.mx/Gaceta/Votaciones/64/vot64_a1extra1.html")

### Step 02: keep the vote-related pages
# you should write a for loop here since you will have many RECORD pages
# for simplifying I directly get one url only

html_index <- url_index[1] %>% read_html()
url_all <- html_index %>% html_nodes("a") %>% html_attr("href")
url_vote <- url_all[str_detect(url_all, "Votaciones") & !is.na(url_all)]

### Step 03: go to the table pages and get arguments for further POST requests
# you should write a for loop here since you will have many VOTING pages
# for simplifying I directly get one url only
html_vote <- str_c("http://gaceta.diputados.gob.mx", url_vote[1]) %>% read_html()
node_input <- html_vote %>% html_nodes("input")

# there are three arguments needed when dealing with PHP
# evento, nomtit, lola[number]
node_input_keep <- node_input %>% as.character() %>% `[`(1:3)
value_evento <- node_input_keep[1] %>% str_extract_all('".*?"')
value_evento <- value_evento[[1]][3] %>% str_remove_all('"')

value_nomtit <- node_input_keep[2] %>% str_extract_all('".*?"')
value_nomtit <- value_nomtit[[1]][3] %>% str_remove_all('"')

value_lola_order <- node_input_keep[3] %>% str_extract_all('".*?"')
value_lola_value <- value_lola_order[[1]][3] %>% str_remove_all('"')
value_lola_order <- value_lola_order[[1]][2] %>% str_remove_all('"')

# put them in a list
list_vote <- list()
list_vote$evento <- value_evento
list_vote$nomtit <- value_nomtit
list_vote$abc <- value_lola_value
names(list_vote)[3] <- value_lola_order

### Step 04: using POST request to get details
html_post <- httr::POST("http://gaceta.diputados.gob.mx/voto64/ordi11/lanordi11.php3", 
                        body = list_vote)
# here's an example in case the POST request above is too complicated
# html_post <- httr::POST("http://gaceta.diputados.gob.mx/voto64/ordi11/lanordi11.php3", 
#                         body = list(evento = 3, 
#                                     nomtit = 
#                                       "Iniciativa con proyecto de decreto, para que se inscriba con letras de oro en el Muro de Honor de la Cámara de Diputados del Congreso de la Unión la frase 'Al Movimiento Estudiantil de 1968' (en lo general y en lo particular). &lt;p&gt; 20 de septiembre de 2018",
#                                     `lola[11]` = 453))
table_detail <- html_post %>% read_html() %>% html_table();table_detail
# here comes the result, get what you want
table_detai
table_detail[[1]]
table_detail[[2]]
table_detail[[3]]

# problems needed solved：how to get corresponding urls from VOTING PAGES
# VOTING：http://gaceta.diputados.gob.mx/Gaceta/Votaciones/64/tabla3or2-3.php3
# DETAIL：http://gaceta.diputados.gob.mx/voto64/ordi32/lanordi32.php3
# VOTING：http://gaceta.diputados.gob.mx/voto64/ordi11/lanordi11.php3
# DETAIL：http://gaceta.diputados.gob.mx/Gaceta/Votaciones/64/tabla1or1-3.php3


