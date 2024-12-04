# Data Analysis Projects in R
This repository contains two R scripts developed to address practical problems related to financial data analysis and machine learning. The projects focus on key investment and credit decisions, leveraging quantitative techniques and predictive models.

## Available Scripts
### 1. Machine_Learning.R
This script focuses on credit decision-making, using machine learning to predict the likelihood of credit approval based on client characteristics. Key features:
- Data Preparation: Loading and transforming the bank.csv dataset.
- Modeling: Implementing a classification model using the Random Forest algorithm, with variables such as salary, age, and financial history.
- Performance Analysis: Evaluating the model with metrics like AUC and confusion matrix to measure precision and recall.
- Application: This model can be used by financial institutions to automate credit decisions, reducing costs and optimizing processes.

### 2. trabalho_data_analystics.R
This script explores investment decisions using quantitative techniques for Brazilian stock analysis. Key features:

- Data Collection: Using the BatchGetSymbols package to retrieve historical stock prices.
- Financial Indicators: Implementing backtests based on the RSI (Relative Strength Index) and variable moving averages, helping to identify optimal buy and sell points.
- Time Series Analysis: Detailed analysis of trends and volatility to assist investors in decision-making.
- Visualization and Performance: Creating graphs to showcase accumulated returns and strategy comparisons.

### Repository Structure
- Machine_Learning.R: A pipeline for credit decision-making using supervised learning.
- trabalho_data_analystics.R: Financial analysis and backtesting script focused on technical indicators.
- Sample Data: Example files (bank.csv, stock tickers) can be integrated to replicate the results.

### Practical Applications
- Credit Decision-Making: Supporting credit analysis and approval processes.
- Investment Strategies: Optimizing financial allocations and validating quantitative strategies through backtesting.

### Technologies Used
- R Packages: caret, randomForest, dplyr, BatchGetSymbols, TTR, quantmod, among others.
- Data Visualization: Graphs created with ggplot2 and other visualization packages.
