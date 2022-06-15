library(tidyverse)
library(MASS)
library(caret)
library(gbm)
# Get Train Data
train.data <- read.csv("Train.csv",stringsAsFactors = F )

#plotting data w.r.t session ID for outlier removal 
ggplot(train.data)+geom_point(mapping = aes(y=revenue, x=sessionId))


#removing outlier observation that is greater than 15000 in a single session
train.data <- subset(train.data,!revenue>15000)


#Get Test Data
test.data <- read.csv("Test.csv",stringsAsFactors = F)

# Get mode of the value list 
MaxTable <- function(x){
  dd <- unique(x)
  dd[which.max(tabulate(match(x,dd)))]
}


# Get features for each customer ID across transactions 
getFeatures <- function(train.data, istrain=TRUE){
  tr1 <- train.data %>% group_by(custId) %>%dplyr::summarize(
    channelGrouping = MaxTable(channelGrouping),
    
    max_visit_Number = max(visitNumber),
    mean_visit_Number = mean(visitNumber),
    median_visit_Number = median(visitNumber),
    sd_visit_Number = sd(visitNumber,na.rm = T),
    
    mean_timeSinceLastVisit = mean(timeSinceLastVisit),
    range_timeSinceLastVisit = max(timeSinceLastVisit)-min(timeSinceLastVisit),
    sd_timeSinceLastVisit = sd(timeSinceLastVisit, na.rm=T),
    median_timeSinceLastVisit = median(timeSinceLastVisit,na.rm = T),
    
    mean_isMobile = mean(isMobile),
    median_isMobile = median(isMobile),
    sd_isMobile = sd(isMobile),
    
    mean_isTrueDirect = mean(isTrueDirect),
    median_isTrueDirect = median(isTrueDirect),
    sd_isTrueDirect = sd(isTrueDirect),
    
    
    
    
    browser = MaxTable(browser),
    operatingSystem = MaxTable(operatingSystem),
    deviceCategory = MaxTable(deviceCategory),
    continent = MaxTable(continent),
    subContinent = MaxTable(subContinent),
    country = MaxTable(country),
    region= MaxTable(region),
    metro=MaxTable(metro),
    city=MaxTable(city),
    
    
    networkDomain = MaxTable(networkDomain),
    topLevelDomain = MaxTable(topLevelDomain),
    campaign=MaxTable(campaign),
    source=MaxTable(source),
    medium = MaxTable(medium),
    keyword=MaxTable(keyword),
    referralPath= MaxTable(referralPath),
    
    
    adwordspage = sum(adwordsClickInfo.page,na.rm = T),
    adwordsslot = MaxTable(adwordsClickInfo.slot),
    gclicks = sum(ifelse(adwordsClickInfo.gclId != "", 1 , 0)),
    pageviews_sum = sum(pageviews,na.rm=T),
    pageviews_mean = mean(pageviews,na.rm=T),
    pageviews_median = median(pageviews,na.rm=T),
    pageviews_sd = sd(pageviews, na.rm = TRUE),
    
    bounce_sessions = sum(ifelse(is.na(bounces) == TRUE, 0, 1)),
    newVisits = sum(newVisits,na.rm=T),
    networkType = MaxTable(adwordsClickInfo.adNetworkType),
    totalRevenue = ifelse(istrain==TRUE,log(sum(revenue)+1), NA)
    
  )
  return(tr1)
}


tr1 <- getFeatures(train.data,istrain = TRUE)
ts1 <- getFeatures(test.data, istrain=FALSE)


full_data <- rbind(tr1,ts1)
full_data <- full_data %>% mutate_if(is.character,~fct_lump(.x,n=7))

fit.model <- "SVM"

if(fit.model=="OLS"){
  full_data <- full_data %>% select_if(negate(is.factor))
}


ts1 <- full_data[is.na(full_data$totalRevenue),]
tr1 <- full_data[!is.na(full_data$totalRevenue),]

ts1$totalRevenue <- NULL

tr1[is.na(tr1)] <-0
ts1[is.na(ts1)] <- 0


#plotting features for Data visualization
plot_features <- function(tr1){
  p <- ggplot(tr1)
  plot.channel <- p+geom_point(mapping = aes(y=channelGrouping,x=totalRevenue))
  plot.tsl <- p+geom_point(mapping=aes(y=timeSinceLastVisit,x=totalRevenue))
  plot.browser <- p+geom_point(mapping=aes(y=browser,x=totalRevenue))
  plot.os <- p+geom_point(mapping = aes(y=operatingSystem,x=totalRevenue))
  plot.continent <- p+geom_point(mapping = aes(x=totalRevenue,y=continent))
  plot.subcontinent <- p+geom_point(mapping = aes(x=totalRevenue,y=subContinent))
  plot.country <- p+geom_point(mapping = aes(x=totalRevenue,y=country))
  plot.region <- p+geom_point(mapping=aes(x=totalRevenue,y=region))
  plot.metro <- p+geom_point(mapping=aes(x=totalRevenue,y=metro))
  plot.medium <- p+geom_point(mapping = aes(y=medium,x=totalRevenue))
  plot.deskct <- p+geom_point(mapping = aes(y=deviceCategory,x=totalRevenue))
  plot.tld <- p+geom_point(mapping = aes(y=topLevelDomain,x=totalRevenue))
  plot.nd <- p+geom_point(mapping = aes(y=networkDomain,x=totalRevenue))
  plot.campaign <- p+geom_point(mapping = aes(y=campaign,x=totalRevenue))
  plot.keyword <- p+geom_point(mapping = aes(y=keyword,x=totalRevenue))
  plot.source <- p+geom_point(mapping = aes(y=source,x=totalRevenue))
  plot.bounce_sessions <- p+geom_point(mapping = aes(y=bounce_sessions,x=totalRevenue))
  plot.direct <- p+geom_point(mapping = aes(y=isTrueDirect,x=totalRevenue))
  plot.mobile <- p+geom_point(mapping = aes(y=isMobile,x=totalRevenue))
  plot.page_median <- p+geom_point(mapping=aes(y = pageviews_median,x = totalRevenue))
}


plot_features(tr1)

set.seed(1000)

if(fit.model=="OLS"){
  
  fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 3)
  
  fit.ols <- train(totalRevenue ~.-custId, data = tr1,
                   method = "lm", trControl=fitControl)
  
  preds <- fit.ols %>% predict(ts1)
  
}

if(fit.model=="ELASTICNET"){
  
  fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 3)
  
  fit.elnet <- train(totalRevenue ~.-custId, data = tr1,
                   method = "glmnet", trControl=fitControl)
  
  preds <- fit.elnet %>% predict(ts1)
  
}


if(fit.model == "MARS"){
  fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 3)
  
  fit.mars <- train(totalRevenue ~.-custId, data = tr1,
                   method = "earth", trControl=fitControl)
  
  preds <- fit.mars %>% predict(ts1)
}

if(fit.model=="GBM"){
  
  gbm.gbm <- gbm(totalRevenue ~ .-custId, data=tr1, distribution="gaussian", n.trees=700, interaction.depth=15,
                                n.minobsinnode=10, shrinkage=0.01, bag.fraction=0.75, cv.folds=10, verbose=FALSE)
               
  best.iter <- gbm.perf(gbm.gbm, method="cv")
  preds <- predict.gbm(object=gbm.gbm, newdata=ts1, 700)
}

if(fit.model=="SVM"){
  
  fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 3)
  
  fit.svm <- train(totalRevenue ~.-custId, data = tr1,
                    method = "svmPoly", trControl=fitControl)
  
  preds <- fit.svm %>% predict(ts1)
}


preds[preds<0] <- 0

results <- data.frame(custId=ts1$custId,predRevenue=preds )
write.csv(results,paste(fit.model,".csv"), row.names = FALSE, quote = FALSE)




