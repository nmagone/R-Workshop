################################################################################
### R-WORKSHOP                                                               ###
### MODULE 3: Simple statistics and exploratory graphing                     ### 
################################################################################

## OBJECTIVE: To explore some simple statistics and analyses.
## We will generate summary statistics and exploratory graphics, 
## and implement linear regression models and analysis of variance.

## We'll use some fish data from Chuck Lee at WDFW for the Lower Spokane River.

################################################################################
### Preliminary: Reading the data                                            ###
################################################################################

## First we'll read in the data and get it ready to use.
## Make sure your working directory is set to R-Workshop/Data!
SpokaneFish <- read.csv(file="LowerSpokaneFish.csv", header=TRUE)
# Fix dates
SpokaneFish$Date <- as.Date(SpokaneFish$Date, "%m/%d/%Y")

# Have a look at the head and structure of SpokaneFish
head(SpokaneFish)
str(SpokaneFish)

################################################################################
### EXERCISE 1: Looking at frequencies                                       ###
################################################################################

# We often want to look at frequency data, for example, the numbers of each fish
# species in our samples.

# We use the table command to determine counts:
table(SpokaneFish$Species)  # Prints number of each species to the console

# TASK: Use the table function to create a table of captures at each sampling site.

# We can also store tables, as done here for fish species:
Species.freq <- table(SpokaneFish$Species)

# We can use this stored table to further characterize the data.
# For example, R can then calculate proportions:
prop.table(Species.freq)

# Don't think the data are quite that precise! Let's round to 2 decimal places:
round(prop.table(Species.freq), 2)

# QUESTION: Is this satisfactory? How might you modify the result?
# TASK: Sometimes we'll want to convert to percentages. Can you do that for this example?


################################################################################
### EXERCISE 2: Summary statistics                                           ###
################################################################################

# By a large margin Redband trout was the most common species.
# Let's focus on characterizing the size structure of the Redband trout population.

# First create a dataframe that only includes Redband trout.
Redband <- SpokaneFish[ which(SpokaneFish$Species=='RB' & is.na(SpokaneFish$ScaleAge)==F), ]   #This is one of several ways to subset data

# Descriptive statistics are useful for understanding data. The redband data include weights and lengths.
# We'll look at these 2 variables. The built in function summary is useful.
summary(Redband$Length)
summary(Redband$Weight)

# We can run the command for the entire data table, but some results may be meaningless.
summary(Redband)

# There are other descriptors in packages such as psych. This package will have to be installed.
# You only have to do this step the first time! After you've installed, go ahead a comment this line out.
install.packages("psych") 

# But we need to load the package at the beginning of each work session.
library(psych)

# Check out the describe function in the psych library.
describe(Redband$Length) 
describe(Redband$Weight)

# QUESTION: What is the median legnth of a Redband trout in the Lower Spokane?


################################################################################
### EXERCISE 3: Exploratory graphing                                         ###
################################################################################

# We gain a lot of understanding by graphing our data. 
# We'll start with some quick and simple plots. 

# We created several tables above, but now we'll save the species frequency table 
# in a dataframe called "speciesplot" 
speciesplot <- round(prop.table(Species.freq), 3) * 100

# A quick bargraph really highlights how common the Redband trout is!
barplot(speciesplot, xlab="Species", ylab="Percentage of total capture")

# Even though barplot is a quick and dirty way to visualize, you can still "dress it up" a lot.
# We can do this altering the input dataframe or specifying arguments in the function.
# For example, we can change the order of the bars and flip them horizontally. And keep on adding axes labels!
barplot(speciesplot[order(speciesplot)], 
horiz = TRUE,  
ylab="Species",
xlab="Percentage of total capture")  

# QUESTION: What would you type to see other argument options in the barplot function?


################################################################################
### EXERCISE 4: More flexible exploratory graphing with ggplot2              ###
################################################################################

# The previous function barplot makes one type of plot (a barplot!).
# The ggplot2 package provides a "quick plot" option that is very flexible.
# Changing the arguments in qplot can create many different types of graphs.

# First, load in the ggplot2 package.
library(ggplot2)

# Let's revisit the Redband dataframe to look at the relationship between length and weight in Spokane River redband.
# First, a simple scatterplot:
qplot(Length, Weight, data = Redband) 

# Note that we can also identify the dataset by using Redband$Length, etc. 

# This scatterplot shows a curvilinear relationship between weight and  length. 
# We can deal with this in several ways, but here we apply a log transformation to the data.
qplot(log(Length), log(Weight), data = Redband)

# That helps linerize the data. So now we'll create a linear regression line to fit the data.
qplot(log(Length), log(Weight), data = Redband, geom=c("smooth"),  method="lm", formula=y~x)

# And now combine both the linear regression line with the point data. 
qplot(log(Length), log(Weight), data = Redband, geom=c("point", "smooth"),  method="lm", formula=y~x)

# QUESTION: By comparing the arguments specified in the above three graphs, what do you think the 
# default option of geom=c() is?
# Check that you are right:
?qplot


################################################################################
### EXERCISE 5: Linear models                                                ###
################################################################################

# Our preliminary graphing indicates a positive relationship between log(length) and log(weight). 
# We could think of this as a simple linear model.
weightmodel1 <- lm(Weight~Length, data=Redband)
summary(weightmodel1)

## QUESTION: In weightmodel1, what is the explanatory variable? And what is the response variable?
## QUESTION: What proportion of the variance in weight is explained by length?

# What if that's not the whole story? Sometimes weight is a factor of both length and age.
# Let's first visualize how  weight and legnth relate as a fuction of scale age.
qplot(log(Length), log(Weight), data = Redband, color=factor(ScaleAge))

# We could think of this as a multiple regression model with one continuous and one categorical variable.
weightmodel2 <- lm(Weight~Length + factor(ScaleAge), data=Redband)
summary(weightmodel2)

## We can compare the these models using the anova function:
anova(weightmodel1, weightmodel2)

## QUESTION: Do the models significantly differ in the variance explained?

# This quick and dirty suggests that weight is explained by both scale age and length.
# But what if length is strongly associated with scale age as well? 
# Relating a continuous response variable with a categorical (>2 categories) explanatory variable suggests ANOVA.


################################################################################
### EXERCISE 6: Analysis of Variance                                         ###
################################################################################

# We'll start with a simple histogram. 
qplot(Redband$Length)

# QUESTION: Why did qplot default to a histogram? 

# The histogram of length suggests that there are at least 3 cohorts.  
# Let's look the length distribution within each age class.
qplot(Length, data=Redband) + facet_wrap(~ScaleAge)

# To me, it looks like ScaleAge might characterize these three different Length cohorts:
# 1) The short fish (ScaleAge = 0)
# 2) The mid-short fish (ScaleAge = 1)
# 3) All the longer fish (ScaleAge = 2-7)

# Lets plot the distribution of Length within each ScaleAge 
qplot(as.factor(ScaleAge), Length, fill=ScaleAge, data=Redband, geom=c("boxplot"))  

# Both density and boxplots plots for length show some clear separation between some 
# scale age classes and a degree of overlap for the older classes. We can examine this further with 
# analysis of variance (ANOVA). The question is whether the means of the groups differ.
aovout = aov(Redband$Length ~ factor(Redband$ScaleAge))
summary(aovout)
             
# This shows us that there are significant differences among the 8 scale age groups.
# Next we'll do a multiple comparisons test to see where the differences reside.
TukeyHSD(aovout, conf.level = 0.95)

# This test indicates that scale age groups 0, 1, 2, 3 and 4 are distinct. Groups 4 and 5 overlap
# and there is substantial overlap amongst the later age groups. 

# QUESTION: Does weight show the same pattern as length?

###################################################################################################

























