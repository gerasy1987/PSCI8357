################################################################################
################# This R Script Does the Following: ############################
### This script runs the replication exercise in Breznau et al. 2022 for
### STAT II Reciation Period. It performs analysis of the research question
### `Does greater immigration reduces support for social policies among the
### public?`. Make sure to comment your code!
################################################################################
### Set working directory, load packages, and load data
# Working Directory
setwd("/Users/alexdean/Documents/replication/")
options(scipen = 999)

# Packages (I like to load packages this way, but do what you prefer)
if (!require(tidyverse)) install.packages("tidyverse")

pacman::p_load(tidyverse)

# Load data
data <- read.csv("cri_macro.csv")
######## Cleaning, analysis, etc. ##############################################

################################################################################