# Load ABIDE data
URL <- 'https://github.com/jcbeer/predictiveViz/raw/master/data/abide_5252.csv'
df <- read.csv(url(URL), header=FALSE)
# first column is ID
# second column is Social Responsiveness Scale Score
# remaining columns are voxel level data
head(df)[,1:10]

# reorganize data
subid <- df[,1]
y <- df[,2]
X <- df[,3:dim(df)[2]]

# randomly split into training and test
# set proportion that is test set
test_proportion <- 0.2
# set number that is test set
test_n <- ceiling(test_proportion*dim(df)[1])
test_n
# randomly select test set
# set random seed
set.seed(3)
# divide indicies into training and test
total_n <- dim(df)[1]
test_ids <- sample(1:total_n, test_n)
all_ids <- 1:total_n
train_ids <- all_ids[! all_ids %in% test_ids]
# divide data into training and test 
subid_train <- subid[train_ids]
subid_test <- subid[test_ids]
y_train <- y[train_ids]
y_test <- y[test_ids]
X_train <- X[train_ids,]
X_test <- X[test_ids,]

# center the y data
# based on training set mean
y_train_mean <- mean(y_train)
y_train_centered <- y_train - y_train_mean
y_test_centered <- y_test - y_train_mean
# standardize X data to have column mean zero and SD one
# based on training set column means and SD
X_train_mean <- colMeans(X_train)
X_train_sd <- apply(X_train, 2, sd)
X_train_std <- scale(X_train, center=X_train_mean, scale=X_train_sd)
X_test_std <- scale(X_test, center=X_train_mean, scale=X_train_sd)

# Elastic net
library(glmnet)
# SET UP TUNING PARAMETER SEQUENCE
alpha_sequence_min <- 0.2
alpha_sequence_max <- 1
alpha_sequence_length <- 6
alpha <- seq(alpha_sequence_min, alpha_sequence_max, length.out=alpha_sequence_length)
lambda_sequence_min <- -1
lambda_sequence_max <- 4
lambda_sequence_length <- 20
lambda <- rev(exp(seq(lambda_sequence_min, lambda_sequence_max, length.out=lambda_sequence_length)))
# save the sequences of alphas and lambdas in order
alpha_sequence <- rep(alpha, each=lambda_sequence_length)
lambda_sequence <- rep(lambda, alpha_sequence_length)
# SAVE ESTIMATED COEFFICIENTS
# for 120 tuning parameter combinations
coefs <- matrix(nrow=(dim(df)[2] - 2), ncol=alpha_sequence_length*lambda_sequence_length)
# loop over the alpha values and store data
for (i in 1:length(alpha)){
  fit <- glmnet(X_train_std, y_train_centered, standardize=FALSE, intercept=FALSE, lambda=lambda, family='gaussian', alpha=alpha[i])
  # store coefficients
  coef_first_index <- i*lambda_sequence_length - 19
  coef_last_index <- i*lambda_sequence_length
  coefs[, coef_first_index:coef_last_index] <- as.matrix(coef(fit))[-1,]
}
# CALCULATE PREDICTED Y
# predict the centered y
predy <- X_test_std %*% coefs
# add back the mean
predy_adj <- predy + y_train_mean
plot(y_test, predy_adj[,70])
# first column of predicted_y is actual y
predicted_y <- cbind(y_test, predy_adj)

# SAVE STATISTICS
# we want to add some metrics to the predicted y
# columns in order:
# 1. alpha squence
# 2. lambda sequence
# 3. pearson correlation
# 4. p-value
# 5. beta0 -- intercept
# 6. beta1 -- slope
# 7. RMSE
# 8. MAE
stats <- matrix(ncol=8, nrow=alpha_sequence_length*lambda_sequence_length)
stats[,1] <- alpha_sequence
stats[,2] <- lambda_sequence
stats[,3] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) cor.test(x, predicted_y[,1])$estimate)
stats[,4] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) cor.test(x, predicted_y[,1])$p.value)
stats[,5] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) coef(lm(x ~ predicted_y[,1]))[1])
stats[,6] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) coef(lm(x ~ predicted_y[,1]))[2])
stats[,7] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) sqrt(mean((x - predicted_y[,1])^2)))
stats[,8] <- apply(predicted_y[,2:dim(predicted_y)[2]], 2, function(x) mean(abs((x - predicted_y[,1]))))
# transpose
stats <- t(stats)

# SAVE DATA
column_names <- paste0('(', alpha_sequence, ', ', round(lambda_sequence, 2), ')')
colnames(coefs) <- column_names
colnames(stats) <- column_names
colnames(predicted_y) <- c('actual SRS', column_names)
write.table(coefs, '/Users/Psyche/neurohack2018/predictiveViz/data/coefficients.csv', row.names = FALSE, col.names = TRUE, sep=',', na='')
write.table(predicted_y, '/Users/Psyche/neurohack2018/predictiveViz/data/predicted_y.csv', row.names = FALSE, col.names = TRUE, sep=',', na='')
write.table(stats, '/Users/Psyche/neurohack2018/predictiveViz/data/stats.csv', row.names = FALSE, col.names = TRUE, sep=',', na='')