#!/bin/bash
awk -F ' ' -v output_folder=$1 'BEGIN{
	if(output_folder == "" || system("[ ! -d " output_folder " ]") == 0){
		print "ERROR: output_folder_path argument ($1) is not provided or is not a valid folder\n Usage : create_clustal_file.sh output_folder_path";
        exit 1;
	}
	prt = 0;
	i=0;
	ligne="";
	cluster_id="";
	file_out="";
}{
	if(i==0){
		ligne = ligne "\n" $0;
	}else if($1 == "" && prt == 0 ){
		ligne = ligne "\n" $0;
	}else if($1 != "" && prt == 0 ){
		cluster_id=$1;
		file_out= output_folder "/" cluster_id ".clustalo";
		ligne = ligne "\n" $0;
		prt = 1;
		print ligne > file_out ;
	}else {
		print $0 > file_out ;
	}
	i++;
}'



