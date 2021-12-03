# Retail-Revenue-Prediction

This Problem is hosted as an in-class kaggle competition for course Intelligent Data Analytics 
during my masters in Data Science and Analytics at University of Oklahoma.

## Problem Description :
In many businesses, identifying which customers will make a purchase and how much will they spend, is a critical exercise. This is true for both brick-and-mortar outlets and online stores. The data provided in this challenge is website traffic data acquired from an online retailer.

## The challenge: Predict total sales
The data provides information on customer's website site visit behavior. Customers may visit the store multiple times, on multiple days, with or without making a purchase. Your goal is to predict how much sales revenue can be expected from each customer. The variable  lists the amount of money that a customer spends on a given visit. Your goal is to predict how much money a customer will spend, in total, across all visits to the site, during the allotted one-year time frame, August 2016 to August 2017.

More specifically, I had to predict a transformation of the aggregrate customer-level sales value based on the natural log. That is, if a customer has multiple revenue transactions, then I computed the sum of all the revenue generated across all of the transactions and transform the resulting sum.


## Challenge instructions
Predictive model is evaluated using Root Mean Squared Error (RMSE).

In the data section, train.csv is used to develop my model. Additionally, a test data file is available which does not include the  variable. I applied my model to this data and uploaded the predicted transformed revenues to test my model on new data; the Kaggle platform automatically evaluated the RMSE value on the new data.

Approximately 30% of the test data is used to calculate a public RMSE value. The remaining 70% of the test data is used to evaluate  private competition score. The final quantitative ranking of my model performance was be based on this 70% holdout data set.

## Data Fields
* sessionId: unique identifier for the record, i.e., a combination of customer and visit number
* custId: unique identifier for each customer
* visitNumber: session number for this customer; if this is the first session, then this is set to 1.
* date: date of the session in YYYY-MM-DD format
* channelGrouping: the channel via which the user came to the online store
* visitStartTime: timestamp
* timeSinceLastVisit: time in seconds since most recent known visit to online store
* browser: browser used, e.g., "Chrome" or "Firefox"
* operatingSystem: version of the operating system
* isMobile: if user is on a mobile device, this value is 1 if true and 0 if false.
* deviceCategory: type of device, e.g., mobile, tablet, desktop
* continent: continent from which sessions originated, based on IP address
* subContinent: sub-continent from which sessions originated, based on IP address
* country: country from which sessions originated, based on IP address
* region: region from which sessions originate, derived from IP addresses, note: in the U.S., a region is a state
* metro: Designated Market Area from which sessions originate
* city: city from which sessions originated, based on IP address
* networkDomain: domain name of user's ISP, derived from the domain name registered to the ISP's IP address
* campaign: the campaign value
* source: origin of your traffic, such as a search engine, e.g., Google; or a domain e.g., example.com
* medium: general category of source, e.g., organic search "organic", cost-per-click paid search "cpc", web referral "referral"
* keyword: keyword of the traffic source, usually set when the trafficSource.medium is "organic" or "cpc"
* isTrueDirect: True, value =1, if the source of the session was Direct meaning the user typed the name of your website URL into the browser or came to your site via a bookmark
* referralPath: if trafficSource.medium is "referral", then this is set to the path of the referrer. The host name of the referrer is in trafficSource.source.
* adContent: ad content of the traffic source
* adwordsClickInfo.page: page number in search results where the ad was shown
* adwordsClickInfo.slot: position of the ad. Takes one of the following values:{“RHS", "Top"}
* adwordsClickInfo.gclId: Google Click ID
* adwordsClickInfo.adNetworkType: takes one of the following values: {"Google Search", "Search partners", "unknown"}
* adwordsClickInfo.isVideoAd: True if it is a Trueview video ad.
* pageviews: total number of pageviews within the session; a pageview is an instance of a page being loaded or reloaded in a browser
* bounces: for a bounced session, the value is 1, otherwise it is null; a bounce is when the visitor leaves the website from the landing page without browsing any further
* newVisits: if this is the first visit for the customer, this value is 1, otherwise it is null.
* revenue: total transaction revenue for the session -- Note! This is the outcome variable of interest

## File descriptions
* train.csv - the training set
* test.csv - the test set

Code for this problem can be found here [Revenue Prediction](./Revenue-Prediction.R)

Web Link to the Kaggle competition(Team Name: **Team Test Data-5** and Rankings can be found here [Kaggle](https://www.kaggle.com/c/2021-5103-hw6/leaderboard)
