#region_helper.R
#helper script to create region variables (based on US Census) for states in flight data

#variables for coding subregion: NE: New England, Middle Atlantic, 
#                                MW: East North Central, West North Central
#                                 S: South Atlantic, East South Central, West South Central
#                                 W: Mountain, Pacific
NE = list(name = "NE", states = c("CT", "ME", "MA", "NH", "RI", "VT"))
MA = list(name = "MA", states = c("NJ", "NY", "PA"))
ENC = list(name = "ENC", states = c("IL", "IN", "MI", "OH", "WI"))
WNC = list(name = "WNC", states = c("IA", "KS", "MN", "MO", "NE", "ND", "SD"))
SA = list(name = "SA", states = c("DE", "DC", "FL", "GA", "MD", "NC", "SC", "VA", "WV"))
ESC = list(name = "ESC", states = c("AL", "KY", "MS", "TN"))
WSC = list(name = "WSC", states = c("AR", "LA", "OK", "TX"))
M = list(name = "M", states = c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY"))
P = list(name = "P", states = c("AK", "CA", "HI", "OR", "WA"))

#regions consist of subregions
region_NE = list(name = "NE", states = c(NE$states, MA$states))
region_MW = list(name = "MW", states = c(ENC$states, WNC$states))
region_S = list(name = "S", states = c(SA$states, ESC$states, WSC$states))
region_W = list(name = "W", states = c(M$states, P$states))

#make a list of the lists, for searching and coding based on state
regions = list(region_NE, region_MW, region_S, region_W)
subregions = list(NE, MA, ENC, WNC, SA, ESC, WSC, M, P)

#get_region returns the character representation of the region for the passed state
#  region can either be regions or subregions, defined above
get_region_chr = function(state, region) {
  for(sub in 1:length(region)) {
    if(sum(region[[sub]]$states == state) > 0) {
      return(region[[sub]]$name)
    }
  }
  return("UNK") #should not get here unless an invalid state is passed
}

#set up data holders for origin & destination region & subregion
orig_reg = rep("NA", times = nrow(flight_edges))
orig_sub = rep("NA", times = nrow(flight_edges))
dest_reg = rep("NA", times = nrow(flight_edges))
dest_sub = rep("NA", times = nrow(flight_edges))

#loop through and generate the region & subregion data
# CAREFUL - this loop took 1h15m to run on the full dataset!
for (ix in 1:nrow(flight_edges)) {
  orig_reg[ix] = get_region_chr(flight_edges[ix,]$origin_state, regions)
  orig_sub[ix] = get_region_chr(flight_edges[ix,]$origin_state, subregions)
  dest_reg[ix] = get_region_chr(flight_edges[ix,]$dest_state, regions)
  dest_sub[ix] = get_region_chr(flight_edges[ix,]$dest_state, subregions)
}

#check cleanliness; should be all zeros
c(sum(orig_reg == "UNK"), sum(orig_reg == "NA"), sum(orig_sub == "UNK"), sum(orig_sub == "NA"), sum(dest_reg == "UNK"), sum(dest_reg == "NA"), sum(dest_sub == "UNK"), sum(dest_sub == "NA"))

#add new columns for region & subregion
#preserve initial import `flight_edges` and create `new_flight`
new_flight = tibble::add_column(flight_edges, origin_regn = orig_reg, .after = 4)
new_flight = tibble::add_column(new_flight, origin_subr = orig_sub, .after = 5)
new_flight = tibble::add_column(new_flight, dest_regn = dest_reg, .after = 8)
new_flight = tibble::add_column(new_flight, dest_subr = dest_sub, .after = 9)

#calculate the intra region & subregion logicals, and add them as columns
intra_regn = (new_flight$origin_regn == new_flight$dest_regn)
intra_subr = (new_flight$origin_subr == new_flight$dest_subr)
new_flight = tibble::add_column(new_flight, intra_regn = intra_regn, .after = 10)
new_flight = tibble::add_column(new_flight, intra_subr = intra_subr, .after = 11)

#split date into year and month
month_chr = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
year = floor(flight_edges$date / 100)
month = flight_edges$date %% 100
month_chr = month_chr[month]

#add new columns
flight_edges = tibble::add_column(flight_edges, year = year, .after = 17)
flight_edges = tibble::add_column(flight_edges, month = month, .after = 18)
flight_edges = tibble::add_column(flight_edges, month.chr = month_chr, .after = 19)

#write the new_flight to a .csv
#write.csv(new_flight, file = "~/Desktop/flight_edges.csv")
write.csv(flight_edges, file = "~/Desktop/flight_edges.csv")

#get sample data
knitr::kable(flight_edges[runif(10, min = 1, max = nrow(flight_edges)),-c(3,7)])
