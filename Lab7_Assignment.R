# Lab 7 Assignment: Difference in Means and ANOVA
# The University of Texas at San Antonio
# URP-5393: Urban Planning Methods II


#---- Instructions ----

# 1. [70 points] Open the R file "Lab7_Assignment.R" and answer the questions bellow
# 2. [30 points] Run a T-test and an ANOVA test in your data.


#---- Part 1. Open the R file "Lab7_Assignment.R" and answer the questions bellow

# 1.1 load the same household data used in the Lab7_Script.R file, create the object `HTS`
```r
library(data.table)
library(foreign)
HTS <- data.table(read.spss("datasets/HTS.household.10regions.sav",to.data.frame = T))
```
# 2. Recreate the same steps used in the lab to run a T-test, but instead, consider the following:
# 2.1 Run a T-Test to show if the household income means is statistically different between households living in single family residences or not (use the whole sample). Produce two pdfs, one with an histogram pdf plot, and another with the simulated hypothesis testing plot showing where the T-statistic falls. Provide a short interpretation of your results

library(ggplot2)
names(HTS)

HTS_clean <- HTS[!is.na(sf) & !is.na(hhincome), ]
ggplot(data=HTS_clean,aes(x=hhincome, y=sf))+
  geom_boxplot()

t_result<-t.test(hhincome ~ sf, data = HTS_clean)
print(t_result)


library(ggplot2)
ggplot(HTS_clean, aes(x = hhincome, fill = sf)) +
  geom_histogram(alpha = 0.6, bins = 30, position = "identity") +
  labs(title = "Household Income by Housing Type",
       x = "Household Income",
       y = "Number of Household",
       fill = "Housing Type") +
  theme_minimal()
ggsave("income_histogram.pdf", plot = last_plot(), width = 8, height = 5)


pdf("t_distribution_plot.pdf", width = 8, height = 5)
t_stat <- as.numeric(t_result$statistic)
df <- as.numeric(t_result$parameter)

curve(dt(x, df = df), from = -50, to = 50,
      main = "T-distribution with Observed T-statistic",
      xlab = "t value", ylab = "Density",
      col = "darkgreen", lwd = 2)

abline(h = 0, col = "blue")
points(x = t_stat, y = 0, col = "red", pch = 19, cex = 1.5)
legend("topright",
       legend = paste("t =", round(t_stat, 2)),
       col = "red", pch = 19)

dev.off()
```
# The test shows a t-statistic of -36.234 with 4353.4 degrees of freedom and a p-value less than 2.2e-16, indicating a highly statistically significant difference. The mean household income for those living in other housing types was $46.73, while for those in single family residences it was $75.38. The 95% confidence interval for the difference in means is from -30.20 to -27.10, which does not include zero, further confirming the result. 
#Therefore, we reject the null hypothesis and conclude that households in single family residences have significantly higher average incomes compared to those in other housing types.


# 2.2 Filter the sample to select only the region of San Antonio. Prepare an T-Test to show if the household vehicle miles traveled (in natural logs - lnvmt) is statistically different between households living in neighborhoods with a job-population index (variable `jobpop`) over and under the city median (of the `jobpop` variable of course)

HTS_SA<-HTS[region=="San Antonio, TX",]
median_jobpop <- median(HTS_SA$jobpop, na.rm = TRUE)
HTS_SA$jobpop_group <- ifelse(HTS_SA$jobpop > median_jobpop, "High Jobpop", "Low Jobpop")
HTS_SA$jobpop_group <- factor(HTS_SA$jobpop_group)
unique(HTS_SA$jobpop_group)
t_result_SA <- t.test(lnvmt ~ jobpop_group, data = HTS_SA)
print(t_result_SA)
t_stat_SA <- as.numeric(t_result_SA$statistic)
df_SA <- as.numeric(t_result_SA$parameter)

curve(dt(x, df = df), from = -5, to = 5,
      main = "T-distribution with Observed T-statistic",
      xlab = "t value", ylab = "Density",
      col = "darkgreen", lwd = 2)

abline(h = 0, col = "blue")
points(x = t_stat_SA, y = 0, col = "red", pch = 19, cex = 1.5)
legend("topright",
       legend = paste("t =", round(t_stat_SA, 2)),
       col = "red", pch = 19)

#The results show a statistically significant difference between the two groups (t = -2.21, df = 1512.2, p = 0.028). Households in high job-population areas had a lower average lnvmt (mean = 2.99) compared to those in low job-population areas (mean = 3.10). The 95% confidence interval for the difference in means is from -0.217 to -0.013, which does not include zero, indicating that the observed difference is unlikely due to chance. 
#These findings suggest that households living in neighborhoods with a high job-population index tend to travel fewer vehicle miles on average.

# 2.2 using the same data set (San Antonio sample), run an ANOVA test to see if there are significant differences 
#between income categories and vehicle miles traveled by household. Follow the same steps used in the ANOVA exercise done in class.
#Produce three pdfs: one checking the normality assumption of the dependent variable, a second one checking the presence of outliers, and a third one showing the Tukey (post hoc) T-tests plot.

#examine normality of the dependent varible

pdf("hist_lnvmt.pdf", width = 8, height = 5)
hist(HTS_SA$lnvmt,col = "lightblue", border = "white")
dev.off()
#Find the outliers
ggplot(data=HTS_SA, aes(x=income_cat, y= lnvmt))+
  geom_boxplot()
ggsave("outliers.pdf",plot=last_plot(),width=8,height=5)
HTS_SA_OUT<-boxplot(HTS_SA$lnvmt~HTS_SA$income_cat)
outliers <- boxplot.stats(HTS_SA$lnvmt)$out
HTS_SA[lnvmt%in%outliers,]#find outliers
HTS_SA2<-HTS_SA[!lnvmt%in%outliers,]

boxplot(HTS_SA$lnvmt~HTS_SA$income_cat)
boxplot(HTS_SA2$lnvmt~HTS_SA2$income_cat)

#Anova test
bartlett.test(lnvmt ~ income_cat, data=HTS_SA2)
fit<-aov(HTS_SA2$lnvmt~HTS_SA2$income_cat)
summary(fit)
#The test returned a highly significant result (F= 93.00, p < 0.001), indicating that mean lnVMT varies by income category. 

#post-hoc test
pdf("Tukey.pdf", width = 8, height = 10)
TukeyHSD(fit)

plot(TukeyHSD(fit))
dev.off()

#The Tukey post-hoc test shows that households in the low-income group differ significantly in lnVMT compared to both middle- and high-income groups. However, there is no statistically significant difference in lnVMT between the middle- and high-income households.

# 2. [30 points] Run a T-test and an ANOVA test in your data.
# T-test to explore whether mobility status is related to estimated home value

library(data.table)
san_mobility<-fread("D:/UTSA/digital-migration/discussion/2.11 data filter/san_antonio_bg.csv")
library(dplyr)
str(san_mobility)

clean_data <- san_mobility %>% filter(!is.na(LST))
t_test_result <- t.test(
  ESTMTD_HOME_VAL_DIV_1000 ~ move, 
  data = clean_data,
  var.equal = FALSE  
)
print(t_test_result)
#The t-test shows a significant difference in home values between movers and non-movers (t = 31.82, p < 0.001). This indicates that the mean estimated home values differ significantly based on mobility status.

# ANOVA to test whether home values differ by marital status
unique(clean_data$MARITAL_STATUS)
clean_data$MARITAL_STATUS <- as.factor(clean_data$MARITAL_STATUS)
bartlett.test(ESTMTD_HOME_VAL_DIV_1000 ~ MARITAL_STATUS, data=clean_data)
fit<-aov(clean_data$ESTMTD_HOME_VAL_DIV_1000~clean_data$MARITAL_STATUS)
summary(fit)
#The ANOVA test shows a significant difference in home values across marital status groups (F = 42,287, p < 0.001), indicating that marital status is associated with variation in estimated home value.

TukeyHSD(fit)

plot(TukeyHSD(fit))
#The Tukey post-hoc test shows that many pairwise comparisons between marital status groups have statistically significant differences in estimated home values. Most confidence intervals do not cross zero, indicating that household home values vary considerably across marital status categories.


# Bonus: [30 points] Provide an HTML file with your answers using R-Markdown.



