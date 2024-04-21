# Clear the workspace and load necessary directories and parameters
rm(list = ls())
load("dir_parameters.R")
setwd(code_dir)

# Change the working directory to the results directory and load QC parameters
setwd(file.path(results_dir, "3.Matrices/output/"))
source(paste("../input/",Parameters,sep=""))

# Load cleaned matrices and phenotypes
load(cleaned_matrices)
phenotypes <- read.csv(pheno, header = TRUE, na.strings = "NA")
base_dir <- getwd()
fold_dir <- file.path(base_dir, trait.name)
dir.create(fold_dir)
setwd(fold_dir)
# Filter phenotypes with non-missing trait values
phenotypes <- phenotypes[!is.na(phenotypes[, trait.col]),]
phenotypes <- phenotypes[!is.na(phenotypes[, fixed.effects]),]
ids_common <- Reduce(intersect, list(rownames(O), rownames(X), as.character(phenotypes[, ID.col])))

# Subset matrices to include only common IDs
X <- X[rownames(X) %in% ids_common,]
O <- O[rownames(O) %in% ids_common,]
phenotypes <- phenotypes[phenotypes[, ID.col] %in% ids_common,]

# Ensure the phenotypes are in the same order as the genotype matrices
phenotypes <- phenotypes[order(phenotypes[, ID.col]),]
X <- X[order(rownames(X)),]
O <- O[order(rownames(O)),]

#### Gmatrix ####
X[ X == 0] <- -1
X[ X == 1] <- 0
X[ X == 2] <- 1
X[is.na(X)] <- rowMeans(X, na.rm = TRUE)[col(X)]
X2 <- X
for(i in 1:ncol(X)){X[,i]<-(X[,i]-mean(X[,i]))/sd(X[,i])}
# Calculate the genomic relationship matrix G
G <- tcrossprod(X) / ncol(X)
det(G)
# Assuming G is your genomic relationship matrix and lambda is your chosen bias value
lambda <- 0.15# for example, adjust based on your specific needs

# Add the bias to the diagonal of the G matrix
G_regularized <- G + lambda * diag(nrow(G))
det(G_regularized)
# Ensure the phenotype vector Y is in the same order as the columns of G
Y <- phenotypes[, trait.col]
names(Y) <- phenotypes[, ID.col]
save(phenotypes,Y,file='pheno.rda')
save(G_regularized,file='G.G.rda')

EVD.G <- eigen(G_regularized)
rownames(EVD.G$vectors) <-rownames(G_regularized)

save(EVD.G,file='EVD.G.rda')
save(X,file='X.rda')
# Check if the column names of G match the row names of EVD.G$vectors
if (!identical(colnames(G), rownames(EVD.G$vectors))) {
  stop("Order of individuals in G and EVD.G$vectors does not match.")
}

# Check if the column names of G match the names of Y
if (!identical(colnames(G), names(Y))) {
  stop("Order of individuals in G and Y does not match.")
}


#### Bmatrix ####

O[ O == 0] <- -1
O[ O == 1] <- 0
O[ O == 2] <- 1
O[is.na(O)] <- rowMeans(O, na.rm = TRUE)[col(O)]
O2 <- O
for(i in 1:ncol(O)){O[,i]<-(O[,i]-mean(O[,i]))/sd(O[,i])}
# Calculate the genomic relationship matrix G
B <- tcrossprod(O) / ncol(O)
det(B)
# Assuming B is your genomic relationship matrix and lambda is your chosen bias value
lambda <- 0.5 # for example, adjust based on your specific needs

# Add the bias to the diagonal of the G matrix
B_regularized <- B + lambda * diag(nrow(B))
det(B_regularized)


save(B_regularized,file='B.rda')

EVD.B<-eigen(B_regularized  )
rownames(EVD.B$vectors) <-rownames(B_regularized )

save(EVD.B,file='EVD.B.rda')
save(O,file='O.rda')

# Check if the column names of G match the column names of B
if (!identical(colnames(G), colnames(B))) {
  stop("Order of individuals in G and B does not match.")
}

# Check if the column names of B match the row names of EVD.B$vectors
if (!identical(colnames(B), rownames(EVD.B$vectors))) {
  stop("Order of individuals in B and EVD.B$vectors does not match.")
}

# Check if the column names of B (or row names of EVD.B$vectors, if they are confirmed to be identical) match the names of Y
if (!identical(colnames(B), names(Y))) {
  stop("Order of individuals in B and Y does not match.")
}


O_X <- O2*X2
#O_X <- O*X
O_X[is.na(O_X)] <- rowMeans(O_X, na.rm = TRUE)[col(O_X)]
for(i in 1:ncol(O_X )){O_X [,i]<-(O_X [,i]-mean(O_X [,i]))/sd(O_X[,i])}


Omega <- tcrossprod(O_X) / ncol(O_X)
det(Omega)
# Assuming is your genomic relationship matrix and lambda is your chosen bias value
lambda <- 0.15 # for example, adjust based on your specific needs

# Add the bias to the diagonal of the G matrix
Omega_regularized <- Omega + lambda * diag(nrow(Omega))
det(Omega_regularized)
EVD.O_X <- eigen(Omega_regularized)
rownames(EVD.O_X$vectors)<-rownames(Omega_regularized)
save(Omega_regularized,file='Omega.rda')
save(EVD.O_X ,file='EVD.Omega.rda')
save(O_X,file='O_X.rda')


# List of all elements to compare
elements <- list(colnames(G), colnames(B), colnames(Omega), 
                 rownames(EVD.G$vectors), rownames(EVD.B$vectors), 
                 rownames(EVD.O_X$vectors), names(Y), as.character(phenotypes[, ID.col]))

# Check if all elements have the same order
all_identical <- TRUE
for (i in seq_len(length(elements) - 1)) {
  if (!identical(elements[[i]], elements[[i + 1]])) {
    all_identical <- FALSE
    break
  }
}

# Stop if not all elements are identical
if (!all_identical) {
  stop("Order of individuals in ALL does not match.")
}

stats.log <-data.frame(Num_Ind = dim(X)[1], Number_Markers = dim(X)[2])
write.table(stats.log,"stats.log.txt")
setwd(code_dir)

