#!/bin/bash
#title           :NextSeqPostRunDataProcessor.sh
#description     :This script will basecall raw NextSeq Illumina data and rename resulting FASTQ files for IRIDA Uploader.
#author		 :Kyrylo Bessonov
#date            :04 April 2019
#version         :1.0    
#usage		 :bash NextSeqPostRunDataProcessor.sh
#notes           :Tested on Linux system with illumina conda environment containing bcl2fastq basecaller
#bash_version    :4.2.46(2)-release
#==============================================================================

echo "###################################################"
echo "# Welcome to the NextSeq Post-Run Processor v1.0  #"
echo "###################################################"

echo "Current directoy: $(pwd)"
echo "Available projects: $(ls -d */ | sed -e 's/\///g')"
echo ""

read -p "Enter Run Name Folder (e.g. 190329_NB551633_0004_AHGCNCAFXY): "  runfolder
if [ -d "$runfolder" ]; then
  echo "Folder ${runfolder} exists. Activating illumina environment."
  source activate illumina
  cd ${runfolder}
else
  echo "The ${runfolder} run folder does not exist at current location $(pwd)"
  echo "Following directories are available at the current location: $(ls -d */)"
  echo "Check that this script is located at the root of the NextSeq data storage (e.g. /Drives/L/GuelphNextSeq/BCL/)"
  exit 1
fi

echo "Starting basecalling ...."
runid=$(sbatch -c 16 --mem=32G -p "NMLResearch" -J "NextSeqBasecalling" -o "NextSeqBasecallingLog_${runfolder}.txt" --wrap="bcl2fastq --no-lane-splitting" | grep -oE  "[0-9]+")
#runid=$(sbatch -c 1 --mem=1G -J "NextSeqBasecalling" -o "NextSeqBasecallingLog_${runfolder}.txt" --wrap="find . -name "*.gz" | grep -oE  "[0-9]+")


bcstatus=1 #basecalling not yet completed
while [ $bcstatus != 0 ];do
  bcstatus=$(sq | awk '{print $1}'| grep -w ${runid} | wc -l)
  echo "$(date +"%T"): NextSeq basecalling is still runing as jobid ${runid}. Will check back in 1 min ..."
  sleep 60
done

echo "$(date +"%T"): Gathering location of the basecalled FASTQ files ..."
fastqs=($(grep "Created FASTQ file" NextSeqBasecallingLog_${runfolder}.txt | awk '{print $8}' | sed -e "s/[\"|\']//g"))
destination_dir=$(echo ${fastqs[0]} | grep -oE ".*BaseCalls/")

if [ ${#fastqs[@]} -eq 0 ] || [ ${#destination_dir} -eq 0 ];then
	echo "$(date +"%T"): Basecaller failed or generated 0 FASTQ files. Aborting ..."
	exit 1
else
	echo "$(date +"%T"): Basecaller generated ${#fastqs[@]} fastq files"
fi


for fastq in ${fastqs[@]};do
	mv ${fastq} ${destination_dir} 2>/dev/null
done

echo "$(date +"%T"): FASTQ files were moved to ${destination_dir}"

#rename files to a new pattern with "_L001_" added to the file name (pools all samples from the 4 lanes)
cd $destination_dir
for file in *.gz;do
	file_new=$(echo $file | sed -e 's/\(_R[12]_\)/_L001\1/g')
	mv $file $file_new 
done	

printf '=%.0s' {1..100} &&  echo ""
echo "$(date +"%T"): Basecall run# ${runid} completed generating a total of $(ls ${destination_dir}/*.fastq.gz  | wc -l)"
echo "Run IRIDA uploader on the ${destination_dir} directory and upload files to IRIDA (http://ngs-archive.corefacility.ca/irida/)"
