################################################################################
################# This R Script Does the Following: ############################
### Provides a basic implementation of the rdrobust package in R.
### (2011). This is one of several packages that can implement RDDs in R. This
### script is inspired by Brad Smith's practicum on RDDs in R from his previous
### Stat III class.
################################################################################
### Set working directory, load packages, and load data
# Working Directory

setwd("/Users/alexdean/Documents/Vanderbilt/Service/Spring 2025/Recitation/week_13")
options(scipen = 999)
set.seed(37212)

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(rdrobust)) install.packages("rdrobust")

pacman::p_load(tidyverse, rdrobust)

# Load data
data("rdrobust_RDsenate")

############ Pre-Analysis ######################################################
### What is this data?
# The included data are the Senate analogue of Lee's (2008) study of party incumbency
# advantage in US house elections. 

### Pre-analysis cleaning
# State-level vote share for Democrats in statewide Senate election at time t
vote <- rdrobust_RDsenate$vote

# Margin of victory for Democrat in same state in time t-1
margin <- rdrobust_RDsenate$margin

summary(vote)
summary(margin)

########## Analysis ############################################################
# First, the rdplot command allows us to make a simple RD plot. This should ALWAYS
# be the first step in your analysis! 

# The default command uses evenly spaced bins on each side of the cutoff, achieved
# through a "Mimicking Variance" approach that approximates the amount of
# variability in the raw data. Details in Calonico et al (2015)

plot1 <- rdplot(y = vote, x = margin, title = "RD Plot - Senate Elections Data",
                y.label = "Vote Share in Election at time t+1",
                x.label = "Vote Share in Election at time t")

summary(plot1)

# We can also force the plot to produce evenly-spaced bins across sides, which 
# is achieved through the "es" option for binselect.

# When this option is selected, an integrated MSE approach is used
# rather than a mimicking variance approach. 

plot2 <- rdplot(y = vote, x = margin, 
                binselect = "es",
                title = "RD Plot - Senate Elections Data",
                y.label = "Vote Share in Election at time t+1",
                x.label = "Vote Share in Election at time t")
summary(plot2)

# We can also "scale" up the number of bins using the optimal as a base. 
# For example, using scale = 5 results in 5 times as many bins. 
# Default for scale is 1
# Return to IMSE-optimal evenly spaced bins here

plot3 <- rdplot(y = vote, x = margin, 
                binselect = "es",
                scale = 5,
                title = "RD Plot - Senate Elections Data",
                y.label = "Vote Share in Election at time t+1",
                x.label = "Vote Share in Election at time t")
summary(plot3)


# There are very many options to estimate the ATT. First we'll use default options:

rd1 <- rdrobust(y = vote, x = margin)
summary(rd1)

# Using a uniform kernel:
rd2 <- rdrobust(y = vote, x = margin, kernel = "uniform")
summary(rd2)

# Mean squared error optimal bandwidth:
rd3 <- rdrobust(y = vote, x = margin, bwselect = "mserd")
summary(rd3)

# You can also have separate bandwidths:
rd4 <- rdrobust(y = vote, x = margin, bwselect = "msetwo")
summary(rd4)

# You can take a look at the help function to see that there are many more options
?rdrobust

# Also note the options for clustering if your data have a grouped structure

# Finally, suppose that you want to use some covariates. We don't have any here,
# so we'll randomly generate some random noise to show how to include them
covariates <- rnorm(length(vote), mean = 0, sd = 1)
rdc <- rdrobust(y = vote, x = margin, covs = covariates)
summary(rdc)


# Finally, if you are so inclined you can access the various optimal-bandwidths
# that rdrobust calculates
band <- rdbwselect(y = vote, x = margin, all = TRUE)
summary(band)
################################################################################