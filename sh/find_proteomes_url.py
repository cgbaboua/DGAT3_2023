import sys
import subprocess
import os


def retrieve_TAXID_from_url(url):
    """
    rerieve TAXID contained in a file named README_{scientific_name]_realease_XXX
    in the url provided as parameter
    """
    # identify the exact README_ file name
    cmd1 = "curl -s " + url + "/ | grep 'README_' | perl -p -e 's/.*\\>(.+)\\<.*/\\1/'"
    ps1 = subprocess.run(cmd1,shell=True,stdout=subprocess.PIPE)
    filename = ps1.stdout.decode('utf-8').rstrip()
    
    # if the file README_{scientific_name]_realease_XXX exist 
    if filename != "" : 
        # extract TXID from file
        cmd2 = "curl -s " + url + "/" +  filename + " | grep 'TAXID' " + " | perl -p -e 's/^TAXID:\\s*(\\d+)\s*$/\\1/'"
        ps2 = subprocess.run(cmd2,shell=True,stdout=subprocess.PIPE)
        tax_id = ps2.stdout.decode('utf-8').rstrip()
        return tax_id
    else : 
        return 0
    
   
#Definition de la fonction qui permet de donner l'url de telechargement des genomes des lors ou on indique leur numero d'accession et leur nom complet 
def generate_genome_config_line(accession_id,assembly,scientific_name=None) :
    #liste qui contiendra dans l'odre souhaite les informations necessaires pour le fichier genomes.txt
    container = []
    assembly = assembly.replace(" ","_")
    url = "https://ftp.ncbi.nlm.nih.gov/genomes/all/"
    url = url + accession_id[0:3] + "/" + accession_id[4:7]+ "/" + accession_id[7:10] + "/" + accession_id[10:13] + "/" + accession_id + "_" + assembly
    genome_file_url = url +"/" + accession_id + "_" + assembly + "_protein.faa.gz"
    
    tax_id = retrieve_TAXID_from_url(url)
    
    if scientific_name!=None :
        container.append(scientific_name.replace(" ","_"))
    else :
        container.append(assembly)
    container.append(accession_id)
    container.append(accession_id + "_"+ assembly+ "_protein.faa")
    container.append(tax_id)
    container.append(genome_file_url)
    return container


# Vérification du nb d'arguments
if sys.argv[1] == '--help' :
    print("""
Usage: This Python script automatically generates download URLs for genome protein sequences based on their accession id and assembly. 
The output file obtained is a configuration file compatible with the COSP workflow.

INPUT       a TSV file should be downloaded from the NCBI and should at a minimum contain the GenBank accession id and the 'Assembly' (this should be the first column). It's also possible to include the 'Scientific Name' column.

OUTPUT      the name of the file where the results will be written. This file will be in the format required for the 'genomes.txt' file needed to launch COSP.

Example : 
            % python3 find_proteomes_url.py ncbi_dataset.tsv genomes.txt """)
    sys.exit()
if len(sys.argv)!=3 :
    sys.exit("Erreur : il faut deux arguments. Consultez --help pour plus d'infos.")
if os.path.exists(sys.argv[2]) :
    # delete file 
    ps4 = subprocess.run(['rm',sys.argv[2]],stdout=subprocess.PIPE)
if os.path.exists(sys.argv[1]) :
    with open(sys.argv[1], "r") as file, open(sys.argv[2],"a") as outfile:
        outfile.write(f"Name\tAccessionID\tFile\tTaxonID\tURL\n")
        for line in file :
            if line.startswith("Assembly") :
                next
            else :
                line = line.strip()
                line = line.split("\t")
                if len(line)==3 :
                    data = generate_genome_config_line(line[0],line[1],line[2])
                    for element in data :
                        outfile.write(f"{element}\t")
                    outfile.write(f"\n")
                elif len(line)==2 :
                    data = generate_genome_config_line(line[0],line[1])
                    for element in data :
                        outfile.write(f"{element}\t")
                    outfile.write(f"\n")
                else :
                    sys.exit("Erreur : le format du fichier tsv est incorrect, il faut 2 ou 3 colonnes. Consultez --help pour plus d'infos.")
else :
    sys.exit(f"Erreur : le fichier {sys.argv[1]} n'existe pas. Consultez --help pour plus d'infos.")

