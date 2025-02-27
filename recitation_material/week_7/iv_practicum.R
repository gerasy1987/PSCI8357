################################################################################
################# This R Script Does the Following: ############################
### Provides a stylized example of implementing an IV regression for causal
### inference using the `AER` package in R. It uses built-in base R data.
### This script is inspired from a similar exercise from Brad Smith in his
### former STAT III class.
################################################################################
### Load packages and load data
# Packages
if (!require(AER)) install.packages("AER")
if (!require(foreign)) install.packages("foreign")

pacman::p_load(AER, foreign)
load("Nunn_Wantchekon_pruned.RData")

# We'll use data from Nunn and Wantchekon's study of the effect of 
# slave trade on current trust as measured in the Afrobarometer survey. 
# Their analysis is only partially replicated for brevity. 

########### OLS Regression #####################################################
### OLS Estimates
ols_bivariate <- lm(intra_group_trust ~ ln_export_area, data = nw)
summary(ols_bivariate)

### OLS Estimates with controls
# For brevity, we won't add every single control used
ols_controls <- lm(intra_group_trust ~ ln_export_area + 
              age + 
              age2 +
              education +
              district_ethnic_frac +
              railway_contact,
            data=nw)
summary(ols_controls)

####### Instrumental Variable Regression #######################################
### IV "by hand"
# We'll use distance from the sea as an instrument for slave exports per area.
# Like the instrument used by Nunn and Wantchekon

X <- model.matrix(~ ln_export_area + age + age2+ education + 
                    district_ethnic_frac +railway_contact,
                  data = nw)

Z <- model.matrix(~ age + age2 + education + district_ethnic_frac + 
                    railway_contact + 
                    distsea, data = nw)

Y <- nw$intra_group_trust

first <- lm(X~Z)
Xhat <- fitted(first)
head(Xhat)

# Now, we will extract the coefficient Xhat from the regression
second <- lm(Y~Xhat)
manual_second <- coef(second)[3]

### IV with AER
# This uses the tsls function. Everything before the | is the second
# stage, and everything after it is instruments and exogenous regressors
two_stage <- ivreg(intra_group_trust ~ ln_export_area + age + age2+ education + 
                district_ethnic_frac +railway_contact  |
                age + age2 + education + district_ethnic_frac + railway_contact + 
                distsea, 
              data = nw)

summary(two_stage)
summary(ols_bivariate)

# If you want heteroskedasticity consistent standard errors, you'll use vcov
# to replace the variance covariance matrix with the appropriate correction

summary(two_stage, vcov = vcovHC(two_stage, type = "HC1"))
summary(two_stage, vcov = vcovHC(two_stage, type = "HC3"))

################################################################################