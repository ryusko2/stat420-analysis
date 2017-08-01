##STAT-420 Data Analysis Project
##*Oh! The agony of an airline statistician*
###8/4/2017

This [repository](https://github.com/ryusko2/stat420-analysis) contains working files shared by UIUC graduate students in the MCS-DS program for the STAT-420 Applied Statistics with R taught by Dr. David Dalpiaz, Summer 2017.

* dakline2@illinois.edu ~ Doug Kline
* anushav3@illinois.edu ~ Anusha Varadharajan
* ryusko2@illinois.edu  ~ Ryan Yusko

We have selected a dataset representing all US domestic flights from 1990 to 2009:

[http://academictorrents.com/details/a2ccf94bbb4af222bf8e69dad60a68a29f310d9a](http://academictorrents.com/details/a2ccf94bbb4af222bf8e69dad60a68a29f310d9a)

A summary of the raw data is presented here:
  
| Short Name             | Type    | Description                                                                                              |
|------------------------|---------|----------------------------------------------------------------------------------------------------------|
| Origin                 | String  | Three letter airport code of the origin airport                                                          |
| Destination            | String  | Three letter airport code of the destination airport                                                     |
| Origin City            | String  | Origin city name                                                                                         |
| Destination City       | String  | Destination city name                                                                                    |
| Passengers             | Integer | Number of passengers transported from origin to destination                                              |
| Seats                  | Integer | Number of seats available on flights from origin to destination                                          |
| Flights                | Integer | Number of flights between origin and destination (multiple records for one month, many with flights > 1) |
| Distance               | Integer | Distance (to nearest mile) flown between origin and destination                                          |
| Fly Date               | Integer | The date (yyyymm) of flight                                                                              |
| Origin Population      | Integer | Origin city's population as reported by US Census                                                        |
| Destination Population | Integer | Destination city's population as reported by US Census                                                   |

We hope to explore interactions and possibly model predictions for the response variable(s) `Passengers`, `Seats`, and/or `Flights`.  We have already observed high correlation between `Flights` and both `Seats` and `Passengers`, so we may not need all three of these variables in our model.  This correlation is expected because, as more flights are flown between destinations, there are more seats available, and only a certain number of passengers may fly in those seats.

We have also considered confirming busy travel months by analyzing the response to `date`. 

##Data selection requirements
* 200 Observations, minimum
    - The flight data contains over 3.6M observations of 13 variables
    - Our cleaned data contains over 3.2M observations of 22 variables
* Has a numeric response variable
    - `Passengers`, `Seats`, and `Flights` are all numeric variables we intend to use as potential responses
* At least one categorical predictor
    - To help with limiting our sample size, and to explore possible interactions, we are introducing categorical variables representing regions as well as subregions of the United States, according to the [U.S. Census Bureau](https://www2.census.gov/geo/pdfs/maps-data/maps/reference/us_regdiv.pdf), for both origin and destination cities.
    - This dataset is also broken down by month, which is another categorical predictor
* At least two numerical predictors
    - There are three other numerical predictors to work with: `Distance`, `Origin Population`, and `Destination Population`
    
##Subregion Breakdown

The following subregions will be coded as categorical predictors alongside raw data:

| Subregion (code)         | States Included*                    |
|--------------------------|-------------------------------------|
| New England (NE)         | CT, ME, MA, NH, RI, VT              |
| Middle Atlantic (MA)     | NJ, NY, PA                          |
| East North Central (ENC) | IL, IN, MI, OH, WI                  |
| West North Central (WNC) | IA, KS, MN, MO, NE, ND, SD          |
| South Atlantic (SA)      | DE, DC*, FL, GA, MD, NC, SC, VA, WV |
| East South Central (ESC) | AL, KY, MS, TN                      |
| West South Central (WSC) | AR, LA, OK, TX                      |
| Mountain (M)             | AZ, CO, ID, MT, NV, NM, UT, WY      |
| Pacific (P)              | AK, CA, HI, OR, WA                  |

\*Although Washington DC is not technically a state, it is home to two airports included in this dataset: DCA (Ronald Reagan Washington National), and IAD (Washington Dulles International).  Washington DC is in the *South Atlantic* subregion of the *South* region.

##Region Breakdown

The following regions will be coded as categorical predictors alongside raw data:

| Region (code)  | Subregions Included                                    |
|----------------|--------------------------------------------------------|
| Northeast (NE) | New England, Middle Atlantic                           |
| Midwest (MW)   | East North Central, West North Central                 |
| South (S)      | South Atlantic, East South Central, West South Central |
| West (W)       | Mountain, Pacific                                      |

##Other Notes

* To aid in analysis (and ease computation), we have also coded variables `intra_regn` and `intra_subr` that represent whether a flight flies *within* or *leaves* the region or subregion that it originated from.
* `date` has been split out into `year <int>` and `month <Factor>`
* It was recently discovered that some of observations contained a `seats` value of 0, but a `flights` value > 0.  This could be explained by private, cargo (UPS/FedEx), or military flights that were logged, or simply erroneous data.  In either case, running `env_setup.R` will remove these observations that amount to just under 10% of all observations.  New dataset size is 3.2M.
* Coding all 3.6M [raw] regions & subregions took 1h15m processing time
* We welcome feedback on how to optimize (or vectorize) the `get_region_chr` function starting at line 28 in `region_helper.R`, as this is the function that, we believe, caused much of the processing "delay" (who's really complaining) since it had to iterate over all 3.6M raw data points.

##Cleaned Data

The cleaned data (494MB) is not maintained in the repository due to size and bandwidth restrictions on github, but can be downloaded [here](https://ryusko2.web.engr.illinois.edu/files/flight_edges.csv).  **Please right-click and save as to prevent opening in your browser.**

A random sample is displayed below:

|origin_ICAO |dest_ICAO |origin_state |origin_regn |origin_subr |dest_state |dest_regn |dest_subr |intra_regn |intra_subr | passengers| seats| flights| dist|   date| year|month | origin_pop| dest_pop|
|:-----------|:---------|:------------|:-----------|:-----------|:----------|:---------|:---------|:----------|:----------|----------:|-----:|-------:|----:|------:|----:|:-----|----------:|--------:|
|CRP         |DFW       |TX           |S           |WSC         |TX         |S         |WSC       |TRUE       |TRUE       |       3379|  9523|      89|  354| 199101| 1991|Jan   |     374065|  8182938|
|CLT         |LIT       |NC           |S           |SA          |AR         |S         |WSC       |TRUE       |FALSE      |       1801|  4488|      66|  642| 199301| 1993|Jan   |    1086132|   554606|
|DTW         |ROA       |MI           |MW          |ENC         |VA         |S         |SA        |FALSE      |FALSE      |       1433|  2642|      58|  382| 200601| 2006|Jan   |    8969084|   294767|
|GSO         |LGA       |NC           |S           |SA          |NY         |NE        |MA        |FALSE      |FALSE      |        182|   206|       2|  461| 199312| 1993|Dec   |     561098| 34026518|
|JAN         |ATL       |MS           |S           |ESC         |GA         |S         |SA        |TRUE       |FALSE      |       2502|  3100|      62|  341| 200208| 2002|Aug   |     504423|  4555490|
|IAH         |DFW       |TX           |S           |WSC         |TX         |S         |WSC       |TRUE       |TRUE       |       3300|  4368|      42|  224| 199612| 1996|Dec   |    4268132|  8994450|
|LAX         |HNL       |CA           |W           |P           |HI         |W         |P         |TRUE       |TRUE       |          0|     0|      26| 2556| 200608| 2006|Aug   |   25427320|   903467|
|HNL         |SEA       |HI           |W           |P           |WA         |W         |P         |TRUE       |TRUE       |       8535|  9420|      60| 2677| 200911| 2009|Nov   |     907574|  6815696|
|ROA         |MEM       |VA           |S           |SA          |TN         |S         |ESC       |TRUE       |FALSE      |          0|     0|       3|  580| 200507| 2005|Jul   |     292054|  1261429|
|ANC         |ORD       |AK           |W           |P           |IL         |MW        |ENC       |FALSE      |FALSE      |          0|     0|      19| 2846| 200706| 2007|Jun   |     360908| 18903872|