#load the libraries
library(feseR)
library(caret)

# load the data
# Please read the paper, 
# https://www.ncbi.nlm.nih.gov/pubmed/25892236 
# for details about TNBC data
data(TNBC) 

# keep a backup
TNBC_orig <- TNBC

# retrive features
features <- TNBC[ , -ncol(TNBC)]

# retrive class variables (expected last column)
class <- TNBC[ , ncol(TNBC)]

# getting only those features (i.e. gene/protein expression values) with values for all instances (i.e. samples)
features <- features[ , colSums(is.na(features)) == 0]

# Scale data features
features <- scale(features, center=TRUE, scale=TRUE)

# FS workflow: X2-MC-RFE-RF)
#cat("FS WOrkflow: X2-MC-RFE-RF", "\n")

# Hyperparameters
# mincorr ; 0.20 
# maxcorr ; 0.80
# number.cv ; 5 
# extfolds ; 20 

set.seed(1234)
resultsCORR <- combineFS(features = features, 
                          class = class,
                          univariate = 'corr', 
                          mincorr = hyperparams[["mincorr"]],
                          multivariate = 'mcorr', 
                          maxcorr = hyperparams[["maxcorr"]],
                          wrapper = 'rfe.rf',
                          number.cv = hyperparams[["number_cv"]],
                          group.sizes = seq(1,100, 1),
                          extfolds = hyperparams[["extfolds"]],
                          verbose = TRUE)

cat("Max accuracy results for X2-CM-RFE-RF workflow", "\n")
max.acc.testing.resultsCORR <- max(resultsCORR$best.model$results$Kappa)
max.acc.testing.resultsCORR

val_to_return <- max.acc.testing.resultsCORR
