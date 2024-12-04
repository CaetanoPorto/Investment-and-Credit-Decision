# Instalar pacotes necessários
install.packages("caret")
install.packages("randomForest")
install.packages("dplyr")

# Carregar pacotes
library(caret)
library(randomForest)
library(dplyr)

# Carregar o dataset (por exemplo, já feito o download)
bank_data <- read.csv("bank.csv", sep = ";")

# Exibir as primeiras linhas para entender a estrutura
head(bank_data)
# colnames(bank_data)

# Transformando o target 'y' em fator (1 = sim, 0 = não)
bank_data$y <- as.factor(ifelse(bank_data$y == "yes", 1, 0))

# Dividir os dados em treino (80%) e teste (20%)
set.seed(123)
trainIndex <- createDataPartition(bank_data$y, p = 0.8, list = FALSE)
dataTrain <- bank_data[trainIndex, ]
dataTest <- bank_data[-trainIndex, ]

# Treinando um modelo Random Forest
# Utilizando todas as variaveis como preditoras("Y ~ .")
model_rf <- randomForest(y ~ ., data = dataTrain, ntree = 100)

# Previsões no conjunto de teste
predictions <- predict(model_rf, dataTest)

# Avaliar o modelo com a matriz de confusão
confusionMatrix(predictions, dataTest$y)

# Exibir a importância das variáveis
varImpPlot(model_rf)

# Calcular a curva ROC
library(ROCR)
prob_predictions <- predict(model_rf, dataTest, type = "prob")
pred <- prediction(prob_predictions[,2], dataTest$y)
perf <- performance(pred, "tpr", "fpr")
plot(perf, col = "blue", main = "Curva ROC - Random Forest")
abline(a = 0, b = 1, lty = 2, col = "red")

# Calcular a AUC
auc <- performance(pred, measure = "auc")
auc_value <- auc@y.values[[1]]
print(paste("AUC:", auc_value))
