################################################################################
################# This R Script Does the Following: ############################
### Provides a basic implementation of the Synth package in R from Abadie et al.
### (2011). This is one of many packages that can implement Synthetic Control 
### in R that recovers the ATT under certain assumptions.
################################################################################
### Set working directory, load packages, and load data
# Working Directory

setwd("/Users/alexdean/Documents/Vanderbilt/Service/Spring 2025/Recitation/week_13")
options(scipen = 999)
set.seed(37212)

# Packages
if (!require(tidyverse)) install.packages("tidyverse")
if (!require(Synth)) install.packages("Synth")

pacman::p_load(tidyverse, Synth)

# Load data
data("basque")

################################################################################
### Examining the data
view(basque)

### Pre-work for running synth package
# synth is somewhat strict about the object you use for input. Thus, this 
# first function lets us define our data object to feed to synth command. 
# País Vasco (Basque country) is region 17 and we need to specify this. 
# We also need to specify predictors and time periods. Look at the package
# manual for other implementation help
dataprep.out <- dataprep(
  foo = basque, # the df
  predictors = c("school.illit", "school.prim", "school.med", # Must be numeric
                 "school.high", "school.post.high", "invest"),
  predictors.op = "mean", # Method used on the predictor
  time.predictors.prior = 1964:1969, # Years with data for predictors
  special.predictors = list( # Additional predictors and years with data
    list("gdpcap", 1960:1969, "mean"),
    list("sec.agriculture", seq(1961, 1969, 2), "mean"),
    list("sec.energy", seq(1961,1969,2), "mean"),
    list("sec.industry", seq(1961,1969,2), "mean"),
    list("sec.construction", seq(1961,1969,2), "mean"),
    list("sec.services.venta", seq(1961,1969,2), "mean"),
    list("sec.services.nonventa", seq(1961,1969,2), "mean"),
    list("popdens", 1969, "mean")),
  dependent = "gdpcap", # DV 
  unit.variable = "regionno", # the unit of interest
  unit.names.variable = "regionname",
  time.variable = "year", # what defines each period
  treatment.identifier = 17, # what unit(s) are treated
  controls.identifier = c(2:16, 18),
  time.optimize.ssr = 1960:1969, # Periods of DV where loss function should be min
  time.plot = 1955:1997
)

### Running the synthetic control
# synth() implements the Synthetic control method through assigning a weighting
# optimally to construct a counterfactual
synth.out <- synth(data.prep.obj = dataprep.out, method = "BFGS")

### Looking at the weights
# We can look at the weights used with the synth.tab() package
synth.tables <- synth.tab(synth.res = synth.out,
                          dataprep.res = dataprep.out)
print(synth.tables)

### Visualization of the results:
### We can also visualize the results in at least two ways
# Compare the difference between unit and counterfactual over time
path.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "real per-capita GDP (1986 USD, thousand)", Xlab = "year",
          Ylim = c(0, 12), Legend = c("Basque country",
                                      "synthetic Basque country"), Legend.position = "bottomright")

# Comparing the normalized difference between unit and counterfactual over time
gaps.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = "gap in real per-capita GDP (1986 USD, thousand)")
