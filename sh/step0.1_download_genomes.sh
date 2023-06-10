#!/bin/bash

source ~/.bashrc;

# load project configuration
source ../conf/config.txt

# create genome folder (if needed)
mkdir -p $Genomes_folder

    # echo "launch awk command";
awk -F '\t' -v gloc=$Genomes_folder -v user=$userMail -v useClust=$use_cluster -v sgeQueue=$sgeQueue "BEGIN{
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
			# if we run on sge cluster 	
				if(toupper(useClust) == \"YES\"){
					cmd4= \"qsub -cwd -V -S /bin/bash -N fuzzpro_\" \$1 \"_\" j \" -m ea -b y -q \" sgeQueue \" -M \" user ;
					cmd4= cmd4 \" -o \" fuzloc \"/\" \$1 \"_vs_\" genomes[j] \".out\";
					cmd4= cmd4 \" -e \" fuzloc \"/\" \$1 \"_vs_\" genomes[j] \".err\";
					cmd4= \"source ~/.bashrc;\";
					cmd4= cmd4 \" cd \" gloc \";\";
					cmd4= cmd4 \" wget \" \$5 \";\";	
					cmd4= cmd4 \"gzip -d \" \$3 \".gz;\";
					print cmd4;
					#system(cmd4);
				}else{
					cmd4= \"source ~/.bashrc;\";
					cmd4= cmd4 \" cd \" gloc \";\";
					cmd4= cmd4 \" wget \" \$5 \";\";	
					cmd4= cmd4 \"gzip -d \" \$3 \".gz;\";	
					#print cmd4;
					system(cmd4);
				}
		}		
		i++;
	}" $Conf_genomes

