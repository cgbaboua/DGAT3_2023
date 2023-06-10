import sys
import os
#Definition de la fonction qui permet de donner l'url de telechargement des genomes des lors ou on indique leur numero d'accession et leur nom complet 
def download_url_genome(accession_id,assembly,scientific_name=None) :
	#liste qui contiendra dans l'odre souhaite les informations necessaires pour le fichier genomes.txt
	container = []
	assembly = assembly.replace(" ","_")
	url = "https://ftp.ncbi.nlm.nih.gov/genomes/all/"
	url = url + accession_id[0:3] + "/" + accession_id[4:7]+ "/" + accession_id[7:10] + "/" + accession_id[10:13] + "/" + accession_id + "_" + assembly + "/" + accession_id + "_" + assembly + "_protein.faa.gz"
	if scientific_name!=None :
		container.append(scientific_name.replace(" ","_"))
	else :
		container.append(assembly)
	container.append(accession_id)
	container.append(accession_id + "_"+ assembly+ "_protein.faa")
	#le taxon_id sera remplace par 0 etant donne qu'il n'a pas d'importance pour les etapes du workflow
	container.append(0)
	container.append(url)
	return container

# Vérification du nb d'arguments
if len(sys.argv)!=3 :
	sys.exit("Erreur : il faut deux arguments")
if os.path.exists(sys.argv[2]) :
	sys.exit(f"Erreur : le fichier {sys.argv[2]} existe déjà")
else :
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
						data = download_url_genome(line[0],line[1],line[2])
						for element in data :
							outfile.write(f"{element}\t")
						outfile.write(f"\n")
					elif len(line)==2 :
						data = download_url_genome(line[0],line[1])
						for element in data :
							outfile.write(f"{element}\t")
						outfile.write(f"\n")
					else :
						sys.exit("Erreur : le format du fichier tsv est incorrect, il faut 2 ou 3 colonnes")
	else :
		sys.exit(f"Erreur : le fichier {sys.argv[1]} n'existe pas")
