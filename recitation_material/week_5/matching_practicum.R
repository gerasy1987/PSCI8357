################################################################################
################# This R Script Does the Following: ############################
### Provides a stylized example of implementing matching techniques for causal
### inference using the `Matching` package in R. It uses built-in base R data.
### This script is inspired from a similar exercise from Brad Smith and the
### Sekhon's (2009) package manual for the package.
################################################################################
### Load packages and load data
# Packages
if (!require(Matching)) install.packages("Matching")
if (!require(rbounds)) install.packages("rbounds")

pacman::p_load(Matching, rbounds)

# Load data
data("lalonde")
attach(lalonde)

####### Let's examine the data first ###########################################
# Saving two primary paramteres of interest: outcome and treatmnt
outcome <- lalonde$re78
treatment <- lalonde$treat

# Finding the naïve difference-in-means
naive_dim <- mean(lalonde$re78[lalonde$treat == 1]) - mean(lalonde$re78[lalonde$treat == 0])
print(paste("Naïve Difference-in-Means Estimate:", naive_dim))

####### Calculating propoensity score ##########################################
### Creating the propoensity scores using a glm regression with a binomial 
### (logit) distribution
make_prop_score  <- glm(treat ~
                          age + 
                          educ + 
                          black +
                          hisp + 
                          married + 
                          nodegr + 
                          re74 + 
                          re75, 
                        family = binomial,
                        data = lalonde)

# Let's take a detour and check family objects available for glm models
? family

# Creating the propensity scores (how do we know the code "worked"?)
pscores <- make_prop_score$fitted
head(pscores)

####### Running Match package ##################################################
### Plugging in the defaults so you can see how you can vary your matching
estimate <- Match(Y = outcome, # outcome var
                  Tr= treatment, #treatment var
                  X=pscores, # covariates for matching
                  estimand = "ATT", # estimand you're using (ATE, ATC, ATT)
                  M=1, # Scalar for no. matches per unit (default is 1)
                  ties = TRUE, # How ties in prop. score should be handled, see package manual
                  replace = TRUE) # Matching done with replacement?

summary(estimate)
# As you can see, we have an estimate, along with a t statistic and corresponding p-value
# However, the Match function has many other options! 

### Altering tbe basics:
# We can alter these, and you can see how matching WITHOUT replacement changes
# your estimation:
estimate1 <- Match(Y = outcome,
                   Tr = treatment,
                   X = pscores,
                   estimand = "ATT",
                   M=1,
                   ties = TRUE,
                  replace = FALSE)

summary(estimate)
summary(estimate1)

####### A Note About Balance ###################################################
### How to see balance with Match package:
# The function MatchBalance allows us 
MatchBalance(treatment ~ age,
             match.out = estimate1, # Your outcome from Match
             nboots = 1000, # How many times you bootstrap
             data = lalonde)


# Does matching always improve balance?
# Let's check real earnings in 1974 to see for two of our matching estimates:
MatchBalance(treatment ~ age + 
               educ + 
               black +
               hisp + 
               married + 
               nodegr + 
               re74 + 
               re75,
             match.out = estimate,
             nboots = 1000,
             data = lalonde)

MatchBalance(treatment ~ age + 
               educ + 
               black +
               hisp + 
               married + 
               nodegr + 
               re74 + 
               re75,
             match.out = estimate1,
             nboots = 1000,
             data = lalonde)


# You can also check balance on functions of the covariates that aren't 
# in the propensity score:
MatchBalance(treatment ~ I(age^2),
             match.out = estimate1,
             nboots = 1000,
             data = lalonde)

###### Sensitivity Analysis ####################################################
### How sensitivte are our results? We can use the rbounds package to obtain an
### estimate of this!
# First we need to extract the treatment and control estimates
matched_treated <- outcome[estimate$index.treated]
matched_control <- outcome[estimate$index.control] 

matched1_treated <- outcome[estimate1$index.treated]
matched1_control <- outcome[estimate1$index.control] 

# Make the sensitivity check
sensitivity_check_matched <- rbounds::psens(matched_treated, matched_control)
sensitivity_check_matched1 <- rbounds::psens(matched1_treated, matched1_control)

# Gamma is "Odds of Differential Assignment To Treatment Due to Unobserved
# Factors" which represents the likelihood that an individual receiving treatment
# due to an unobserved confounder compared to a control individual. This suggests
# that even if there is two times the likelihood of an individual receiving
# the treatment due to an unobserved confounder, the data is VERY sensitive
# to this change.
################################################################################