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
upload_basecalled_data2IRIDA () {
   	# Uploads fastqs to the IRIDA server projects specified in the SampleSheet.csv file
   	# Inputs: ${1} is the run_folder name that will be used to upload samples
   	echo "Make sure that you have IRIDA uploader config file (irida-uploader-config.conf) in the running directory"
   	echo "You are now located in $(pwd) directory"
   	echo "Upload details are written to Log_IridaUpload_$(date +"%m-%d-%Y").log file. Check for any errors."
   	logfilename="Log_IridaUpload_$(date +"%m-%d-%Y").log" && touch  ${logfilename}
   	runid=$(sbatch -c 1 --mem=2G -p "NMLResearch" -J "NextSeqDataUpload" --time=24:00:00 -o "${logfilename}" --wrap="source activate irida-uploader && irida-uploader --config ./irida-uploader-config.conf -f ${1}"| grep -oE  "[0-9]+")
   	echo "Started upload job ${runid}"
   	bcstatus=1 #basecalling not yet completed
	while [ $bcstatus != 0 ];do
	  bcstatus=$(squeue | awk '{print $1}'| grep -w ${runid} | wc -l)
	  echo "$(date +"%T"): IRIDA Uploader is uploading samples according to SampleSheet.csv. Will check back on job ${runid} in 1 min ..."
	  tail ${logfilename}
	  sleep 60
	done
} 

echo "###################################################"
echo "# Welcome to the NextSeq Post-Run Processor v2.0  #"
echo "###################################################"
echo ""

read -p "Re-upload previously basecalled samples for a given project? (Y/N)" user_response
if [ $user_response == "Y" ];then
	echo "Current directoy: $(pwd)"
	echo "Available projects: $(ls -d */ | sed -e 's/\///g')"
	read -p "Enter Run Name Folder (e.g. 190329_NB551633_0004_AHGCNCAFXY): "  runfolder
	upload_basecalled_data2IRIDA $runfolder
	exit 0
else
	echo ""
fi

latest_runfolder=($(ls -St | grep -E [0-9]+.*_.*[A-Z]+))
latest_runfolder=${latest_runfolder[0]}
echo "Current directoy: $(pwd)"
echo "The latest run folder name is \"${latest_runfolder}\""
read -p "Run basecalling and automatic IRIDA upload on \"${latest_runfolder}\" folder? (Y/N) " user_response
if [ $user_response == "Y" ]; then
	runfolder=${latest_runfolder}
else
	echo "Manually enter folder name to run basecalling and automatic upload"
	echo "Available projects: $(ls -d */ | sed -e 's/\///g')"
	read -p "Enter Run Name Folder (e.g. 190329_NB551633_0004_AHGCNCAFXY): "  runfolder
fi



if [ -d "$runfolder" ]; then
  	echo "Folder ${runfolder} exists"
	echo "Starting basecalling ... Should be done in 15 min if server load is low ..."
	basecall_log_file="Log_NextSeqPostRunDataProcessor_$(date +"%m-%d-%Y").log"
	runid=$(sbatch -c 16 --mem=32G  --time=24:00:00 -p "NMLResearch" -J "NextSeqBasecalling" -o "${basecall_log_file}" --wrap="source activate illumina && cd ${runfolder} && bcl2fastq --no-lane-splitting --sample-sheet SampleSheet.csv" | grep -oE  "[0-9]+")


	bcstatus=1 #basecalling not yet completed
	while [ $bcstatus != 0 ];do
	  bcstatus=$(sq | awk '{print $1}'| grep -w ${runid} | wc -l)
	  echo "$(date +"%T"): NextSeq basecalling is still runing as jobid ${runid}. Will check back in 1 min ..."
	  sleep 60
	done

	echo "$(date +"%T"): Gathering location of the basecalled FASTQ files ..."
	fastqs=($(grep "Created FASTQ file" ${basecall_log_file} | awk '{print $8}' | sed -e "s/[\"|\']//g"))
	destination_dir=$(echo ${fastqs[0]} | grep -oE ".*BaseCalls")

	if [ ${#fastqs[@]} -eq 0 ] || [ ${#destination_dir} -eq 0 ];then
		echo "$(date +"%T"): Basecaller failed or generated 0 FASTQ files. Aborting ..."
		exit 1
	else
		echo "$(date +"%T"): Basecaller generated fastq files"
		for fastq in ${fastqs[@]};do
			mv ${fastq} ${destination_dir} 2>/dev/null
		done
		echo "$(date +"%T"): FASTQ files were moved to ${destination_dir}"

		#rename files to a new pattern with "_L001_" added to the file name (pools all samples from the 4 lanes)
		cd $destination_dir
		echo "Renaming files to *_L001_R1_* or  *_L001_R2_* pattern as per irida-uploader requirements (*.L\d{3}_R(\d+)_\S+\.fastq.*)"
		for file in *.gz;do
			file_new=$(echo $file | sed -e 's/\(_R[12]_\)/_L001\1/g')
			mv $file $file_new 
		done	

		printf '=%.0s' {1..100} &&  echo ""
		echo "$(date +"%T"): Basecall run with jobid ${runid} completed generating a total of $(ls ${destination_dir}/*.fastq.gz  | wc -l) fastq.gz files"
		
		echo "Running automatic sample upload to IRIDA server in 10s. "
		sleep 10
		upload_basecalled_data2IRIDA ${runfolder} #upload data to IRIDA automatically
		
	fi
	echo "------------Run completed-----------------"
	

	


else
  echo "The ${runfolder} run folder does not exist at current location $(pwd)"
  echo "Following directories are available at the current location: $(ls -d */)"
  echo "Check that this script is located at the root of the NextSeq data storage (e.g. /Drives/L/GuelphNextSeq/BCL/)"
  exit 1
fi

