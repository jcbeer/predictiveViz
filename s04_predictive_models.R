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
set.seed(1)
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
# save estimated coefficients and predicted y
# for 120 tuning parameter combinations
# first row is alpha squence
# second row is lambda sequence
# first column of predicted_y is actual y
coefs <- matrix(nrow=(dim(df)[2] + 2), ncol=alpha_sequence_length*lambda_sequence_length)
coefs[1,] <- alpha_sequence
coefs[2,] <- lambda_sequence
predicted_y <- matrix(nrow=(length(y_test) + 2), ncol=(alpha_sequence_length*lambda_sequence_length + 1))
predicted_y[1,2:dim(predicted_y)[2]] <- alpha_sequence
predicted_y[2,2:dim(predicted_y)[2]] <- lambda_sequence
predicted_y[3:dim(predicted_y)[1], 1] <- y_test
# we want to add some metrics to the predicted y
# pearson correlation
# MSE
# MAE
# regression coefficients ..?
# or maybe Nate's code can do it automatically...
# put numeric placeholders for missing values
predicted_y[1,1] <- 9999
predicted_y[2,1] <- 9999
# loop over the alpha values and store data
for (a in 1:length(alpha)){
  fit <- glmnet(X_train_std, y_train_centered, standardize=FALSE, intercept=FALSE, lambda=lambda, family='gaussian', alpha=a)
  
}




regr = ElasticNet(random_state=1)
regr.fit(X_train_std, y_train_centered)
ElasticNet(alpha=1, copy_X=True, fit_intercept=False, l1_ratio=0.25,
           max_iter=10000, normalize=True, positive=False, precompute=False,
           random_state=1, selection='random', tol=0.0001, warm_start=False)

print(regr.coef_) 
print(regr.intercept_) 
print(regr.predict(X_test)) 

# calculate prediction error
pred_y_test = regr.predict(X_test)
print(y_test)
print(pred_y_test + y_train_mean)
np.subtract(pred_y_test, y_test_centered)