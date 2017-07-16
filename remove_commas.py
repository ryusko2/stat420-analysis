#input = raw data
in_file = open("flight_edges.tsv")

#output
out_file = open("flight_edges_mod.tsv", 'w')

#iterate through file, replacing commas with tabs
for line in in_file:
  out_file.write(line.replace(',','\t'))
  
#and, close it out
out_file.close()
