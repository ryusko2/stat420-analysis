#this script will create a data frame from the comma seaparted values
#  file and adjust the column types

#R will raise a warning when importing due to column 1 not having a name
#  -the first column is an artifact from exporting data to .csv, and will be
#   removed next
flight_edges = readr::read_csv("flight_edges.csv", col_types = "icccccccccclliiiiiiicii")

#the following line was used when importing the initial .tsv file to add column names
#colnames(flight_edges) = c("origin_ICAO", "dest_ICAO", "origin_cty", "origin_state", "origin_regn", "origin_subr", "dest_cty", "dest_state", "dest_regn", "dest_subr", "intra_regn", "intra_subr", "passengers", "seats", "flights", "dist", "date", "origin_pop", "dest_pop")

#remove first column
flight_edges = flight_edges[,2:ncol(flight_edges)]

#set up factor variables
flight_edges$origin_state = as.factor(flight_edges$origin_state)
flight_edges$dest_state = as.factor(flight_edges$dest_state)
flight_edges$origin_regn = as.factor(flight_edges$origin_regn)
flight_edges$origin_subr = as.factor(flight_edges$origin_subr)
flight_edges$dest_regn = as.factor(flight_edges$dest_regn)
flight_edges$dest_subr = as.factor(flight_edges$dest_subr)
flight_edges$intra_regn = as.factor(flight_edges$intra_regn)
flight_edges$intra_subr = as.factor(flight_edges$intra_subr)
flight_edges$month.chr = as.factor(flight_edges$month.chr)

#Some months have flights flown, but no seats.  These could represent private or military
#flights.  In either case, from an airline perspective, we are not interested in
#these flights.  They represent ~ 10% of the data.  
flight_data = subset(flight_edges, flight_edges$seats > 0)

#pp ~ positive passenger values
flight_data_pp = subset(flight_data, flight_data$passengers > 0)

#simple sampling
#subset all flights from January 2000 (>13K observations)
#flight_sub_200001 = subset(flight_data_pp, flight_data_pp$date == 200001)

#sample 500 of the January 2000 flights 
#flight_sub_500 = flight_sub_200001[sample(1:nrow(flight_sub_200001), 500),]

#full 3.2M observations currently stored in `flight_data`
sub_obs = 10000
flight_sub = flight_data_pp[sample(1:nrow(flight_data_pp), sub_obs), -c(1:3, 7, 17)]
