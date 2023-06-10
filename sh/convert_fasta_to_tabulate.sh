#!/bin/bash

function usage()
{
    echo "This script converts an EMBOSS fasta sequences header to tsv file contaning informations"
    echo ""
    echo "./convert_genome_header_to_annotation_table.sh"
    echo -e "\t-h --help"
    echo -e "\t--input_file            genome fasta file from NCBI. [mandatory]"
    echo ""
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --input_file)
            INPUT=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ ! -f "$INPUT" ] 
then
    echo "Error: input_file parameter $INPUT does not exists."
    usage
    exit 1
fi

########################
##### MAIN #############
########################

echo -e "protein_id\tRaw annotation\tSequence" > ${INPUT}.annot.tsv ;

sed -E 's/\s/\t/' ${INPUT} \
| awk -F '\t' 'BEGIN{
	i=0;
}{
	if(i==0){
		header=$0;
	}else{
		if($0 ~ /^>/){
			print header "\t" seq ;
			header=$0;
			seq="";
		}else{
			seq = seq $0 ;
		}
	}
	i++;
}END{
	print header "\t" seq ;
}'  \
| sed -E 's/^>([^|]+\|)?//' >> ${INPUT}.annot.tsv

