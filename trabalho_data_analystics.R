# Instalando e carregando os pacotes necessários
install.packages(c("BatchGetSymbols", "TTR", "quantmod", "PerformanceAnalytics", "tidyverse"))
library(BatchGetSymbols)
library(TTR)
library(quantmod)
library(PerformanceAnalytics)
library(tidyverse)
library(dplyr)
library(tidyr)
library(xts)

# Definindo os tickers das ações (substitua pelos tickers desejados)
tickers <- c("PETR4.SA", "VALE3.SA", "ITUB4.SA", "ABEV3.SA", "BBDC4.SA")

# Definindo o período de análise
first.date <- as.Date("2020-01-01")
last.date <- Sys.Date()

# Coletando os dados históricos das ações
dados <- BatchGetSymbols(tickers = tickers,
                         first.date = first.date,
                         last.date = last.date)

# Extraindo os dados de preços
precos <- dados$df.tickers

# Função para calcular os indicadores técnicos e gerar sinais
gerar_sinais <- function(df) {
  df <- df[order(df$ref.date), ]  # Ordenando por ordem cronologica
  
  # Calculando a Média Móvel Simples de 20 dias
  df$SMA20 <- SMA(df$price.close, n = 20)
  
  # Calculando o RSI de 14 períodos
  df$RSI14 <- RSI(df$price.close, n = 14)
  
  # Gerando sinais de Buy, Hold ou Short
  df$Signal <- ifelse(df$price.close > df$SMA20 & df$RSI14 < 70, "Buy",
                      ifelse(df$price.close < df$SMA20 & df$RSI14 > 30, "Short", "Hold"))
  
  return(df)
}

# Aplicando a função para cada ticker
precos_sinais <- precos %>%
  group_by(ticker) %>%
  do(gerar_sinais(.))

# Removendo valores NA resultantes dos cálculos de indicadores
precos_sinais <- precos_sinais %>%
  filter(!is.na(SMA20) & !is.na(RSI14))

# Criando uma tabela onde cada coluna é um ticker e as linhas são os preços ajustados por data(formato wide)
precos_wide <- precos_sinais %>%
  select(ref.date, ticker, price.adjusted) %>%
  pivot_wider(names_from = ticker, values_from = price.adjusted)

# Convertendo para objeto xts
precos_xts <- xts(precos_wide[,-1], order.by = precos_wide$ref.date)

# Calculando retornos diários
retornos <- Return.calculate(precos_xts)
retornos <- na.omit(retornos)  # Removendo valores NA iniciais

# Convertendo retornos para formato long
# Passamos a ter uma coluna de data, uma de qual ticker é e uma do retorno
retornos_df <- data.frame(ref.date = index(retornos), coredata(retornos))
retornos_long <- retornos_df %>%
  pivot_longer(cols = -ref.date, names_to = "ticker", values_to = "Return")

# Combinando sinais e retornos
dados_backtest <- precos_sinais %>%
  left_join(retornos_long, by = c("ref.date", "ticker"))

# Removendo quaisquer linhas com NA em Return
dados_backtest <- dados_backtest %>%
  filter(!is.na(Return))

# Filtrando apenas os sinais de Buy
sinais_buy <- dados_backtest %>%
  filter(Signal == "Buy")

# Calculando o retorno acumulado da estratégia Buy and Hold
retorno_buy_hold <- Return.cumulative(retornos)
print("Retorno Buy and Hold:")
print(retorno_buy_hold)

# Calculando o retorno da estratégia baseada nos sinais
# Multiplicando o retorno diário pelo sinal (1 para Buy, 0 para Hold/Short)
dados_backtest <- dados_backtest %>%
  mutate(Position = ifelse(Signal == "Buy", 1, 0),
         Retorno_Estrategia = Return * Position)

# Calculando o retorno acumulado da estratégia
retorno_estrategia_acumulado <- Return.cumulative(dados_backtest$Retorno_Estrategia)
print("Retorno da Estratégia (acumulado):")
print(retorno_estrategia_acumulado)

# Preparando os retornos para plotagem
# Retorno total das ações (média dos retornos diários de todas as ações)
retornos$media_total <- rowMeans(retornos)

# Convertendo Retorno_Estrategia para objeto xts
retorno_estrategia_xts <- xts(dados_backtest$Retorno_Estrategia, order.by = dados_backtest$ref.date)

# Garantindo que as datas estão alinhadas
datas_comuns <- index(retornos$media_total)[index(retornos$media_total) %in% index(retorno_estrategia_xts)]
retornos_total_alinhado <- retornos$media_total[datas_comuns]
retorno_estrategia_alinhado <- retorno_estrategia_xts[datas_comuns]

# Combinando as séries
retornos_estrategia <- merge(retornos_total_alinhado, retorno_estrategia_alinhado, join = "inner")

# Mudando o nome das colunas
colnames(retornos_estrategia) <- c("Retorno Passivo", "Retorno Com Estrategia")

# Removendo valores NA, se houver
retornos_estrategia <- na.omit(retornos_estrategia)

# Plotando o resumo de desempenho
charts.PerformanceSummary(retornos_estrategia, legend.loc = "bottomright")
