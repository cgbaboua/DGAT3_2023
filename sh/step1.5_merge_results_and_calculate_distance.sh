#!/bin/bash

source ~/.bashrc;

# load project configuration
source ../conf/config.txt

# create versions folder (if needed)
mkdir -p $Results_versions

# check if pattern_dist is set to "yes"
if [ "$(echo $pattern_dist | tr '[:lower:]' '[:upper:]')" == "YES" ]
then

	#create a file for counter
	echo "1" > counter.txt
	
	# traverse the files to be processed
	for file in $fuzzPro_folder/*resume_fuzzpro.txt
	do
		awk -F '\t' -v vloc=$Results_versions -v gloc=$Genomes_folder -v shF=$sh_folder -v fuzloc=$fuzzPro_folder \
			    -v conf_patterns=$Conf_patterns -v global_pattern=$GlobalPattern \
					-v patterns_to_report=$patternsToReport  -v pattern_dist=$pattern_dist "BEGIN{
					i=1;
		}{	
			if(i==1){
				line = \"\"
				for (j = 1; j <= NF; j++){
						line = line \$j \"\t\"
						if (\$j == \"distance\"){
							distIndex = j;
						} else if (\$j == \"observed_pattern\"){
							indPattern = j; 
						# storage of colnames 
						}
						header[j]=\$j
					}
				cmd = \"cat counter.txt\"
				cmd | getline counter 
				close(cmd)
				# Print the header but only one time
				if(counter==1){
					print line;
					cmd = \"echo '0' > counter.txt \"
					system(cmd)
				}
			} else {
				if(\$distIndex ==\"xxx\"){
					line = \"\"
					\$distIndex = \"\"
					# Collect patterns and their positions
					pattern_positions = \"\" # Clear previous line data
					for (k = indPattern+1; k < distIndex; k++){
						if(\$k != \"\"){
							split(\$k, arr, \":|\\\\-\")
							position = arr[2]
							pattern_positions = pattern_positions \" \" position \":\" k
						}
					}
					# Sort patterns by their positions
					cmd = \"echo \"pattern_positions \" | tr ' ' '\\\\n' | sort -n -t ':' -k 1 | cut -d ':' -f 2 | tr '\\\\n' ' '\" 
					cmd | getline sorted_patterns 
					close(cmd)
					
					# Recovery of the number of patterns and create a new array of sorted_patterns index
					nb_patterns = split(sorted_patterns,tab,\" \")

					for(l=1;l <= nb_patterns;l++){
						split(\$tab[l], current_pattern_details, \":|-\")
						for(m=1; m <= nb_patterns-l; m++){
							split(\$tab[l+m], next_pattern_details, \":|-\")
							\$distIndex = \$distIndex header[tab[l]] \"-\" header[tab[l+m]] \":\" (next_pattern_details[2]-current_pattern_details[3]) \" | \"
						}
					}
					\$distIndex = substr(\$distIndex, 1, length(\$distIndex) - 2) 
					for(n=1;n <= NF; n++){
						line = line \$n \"\t\"
					}
					print line;
				} else {
					line = \"\"
					for(o=1;o <= NF; o++){
						line = line \$o \"\t\"
					}
					print line;
				}
				
		}i++;		    
	}" $file
	done 
	rm -f counter.txt
# create an outpout file in the results folder 	
fi > $Results_versions/all_results_${GlobalPattern}_v$(ls $Results_versions | wc -l).0.txt 

# if pattern_dist is set to "no" just merge the results
if [ "$(echo $pattern_dist | tr '[:lower:]' '[:upper:]')" == "NO" ]
then
# echo "launch awk command";
awk -F '\t' -v vloc=$Results_versions -v shF=$sh_folder -v fuzloc=$fuzzPro_folder -v global_pattern=$GlobalPattern "BEGIN{
		i=1;
}{
		# retrive header information in first line
		if(i==1){
			# test presence of mandatory File column
			if(\$3!=\"File\"){
				print \"ERROR: genome configuration file doesn't contain the mandatory File column\";
				exit 1;
		}
		}else{
			cmd = \"cd \"fuzloc \";\";
			cmd =  cmd \"head -n 1 \" \$1 \"_resume_fuzzpro.txt > all_results_\"global_pattern\"_version.txt\"\";\";
			cmd = cmd \"cat *resume_fuzzpro.txt|grep -v  'pattern' >> all_results_\"global_pattern\"_version.txt ;\";
			cmd = cmd \"mv all_results_\"global_pattern\"_version.txt \"vloc\";\";
			cmd = cmd \"cd \"vloc \";\";
			cmd = cmd \"mv all_results_\"global_pattern\"_version.txt all_results_\"global_pattern\"_v$(ls $Results_versions | wc -l).0.txt ; \";
			#print cmd;
			system(cmd);
			exit;
			}i++;
}" $Conf_genomes
fi
