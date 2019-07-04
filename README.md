# NextSeqPostRunDataProcessor

This bash script automates NextSeq Illumina raw data processing by generating ready to upload FASTQ files. The FASTQ files are basecalled using [bcl2fastq Illumina software](https://support.illumina.com/sequencing/sequencing_software/bcl2fastq-conversion-software.html). The final raw sequences can be uploaded to NML IRIDA server via the [IRIDA Uploader](https://github.com/phac-nml/irida-miseq-uploader).

For more information please consult the [documentation website](https://kbessonov1984.github.io/NextSeqAutoBaseCallerAndUploader/)

Local Config
------------
Local configuration file to try out for the command line upload. It works if config file is structured correctly. See example config file [here](https://raw.githubusercontent.com/phac-nml/irida-uploader/a77521d440aa4c2ea5412714f855625edeaad91b/tests/config/example_config.conf).

Example run on waffles server and irida command line uploader

```
/Drives/P/conda_envs/irida-uploader-0.2.1) [kbessono@waffles Data]$ irida-uploader --config config-v2.conf -f 190329_NB551633_0004_AHGCNCAFXY/
2019-07-03 21:43:42 INFO     looking for run in 190329_NB551633_0004_AHGCNCAFXY/
2019-07-03 21:43:42 INFO     Adding log file to 190329_NB551633_0004_AHGCNCAFXY/
2019-07-03 21:43:42 INFO     ==================================================
2019-07-03 21:43:42 INFO     ---------------STARTING UPLOAD RUN----------------
2019-07-03 21:43:42 INFO     Uploader Version 0.2.1
2019-07-03 21:43:42 INFO     Logging to file in: /home/CSCScience.ca/kbessono/.cache/irida_uploader/log
2019-07-03 21:43:42 INFO     ==================================================
2019-07-03 21:43:42 INFO     Reading data from sample sheet 190329_NB551633_0004_AHGCNCAFXY/SampleSheet.csv
2019-07-03 21:43:43 INFO     Looking for files with pattern SA20190644n_S1_L\d{3}_R(\d+)_\S+\.fastq.*$
2019-07-03 21:43:43 INFO     Looking for files with pattern SA20191119n_S2_L\d{3}_R(\d+)_\S+\.fastq.*$
2019-07-03 21:43:43 INFO     Looking for files with pattern SA20191120n_S3_L\d{3}_R(\d+)_\S+\.fastq.*$
2019-07-03 21:43:49 INFO     Getting samples from project '938'
2019-07-03 21:44:00 INFO     Creating sample 'SA20190644n' for project '938' on IRIDA.
2019-07-03 21:44:11 INFO     Getting samples from project '938'
2019-07-03 21:44:24 INFO     Getting samples from project '938'
2019-07-03 21:44:24 INFO     Creating sample 'SA20191119n' for project '938' on IRIDA.
2019-07-03 21:44:36 INFO     Getting samples from project '938'
2019-07-03 21:44:49 INFO     Getting samples from project '938'
2019-07-03 21:44:49 INFO     Creating sample 'SA20191120n' for project '938' on IRIDA.

2019-07-03 21:45:13 INFO     *** Starting Upload ***
2019-07-03 21:45:18 INFO     Sequencing run id '2943' has been created for upload
2019-07-03 21:45:23 INFO     Uploading to Sample SA20190644n on Project 938
2019-07-03 21:45:34 INFO     Starting to send file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20190644n_S1_L001_R2_001.fastq.gz
Progress:  100.0 % Uploaded
2019-07-03 21:45:36 INFO     Finished sending file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20190644n_S1_L001_R2_001.fastq.gz
2019-07-03 21:45:36 INFO     Starting to send file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20190644n_S1_L001_R1_001.fastq.gz
Progress:  100.0 % Uploaded
2019-07-03 21:45:38 INFO     Finished sending file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20190644n_S1_L001_R1_001.fastq.gz
2019-07-03 21:45:40 INFO     Uploading to Sample SA20191119n on Project 938
2019-07-03 21:45:53 INFO     Starting to send file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20191119n_S2_L001_R2_001.fastq.gz
Progress:  100.0 % Uploaded
2019-07-03 21:45:56 INFO     Finished sending file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20191119n_S2_L001_R2_001.fastq.gz
2019-07-03 21:45:56 INFO     Starting to send file 190329_NB551633_0004_AHGCNCAFXY/Data/Intensities/BaseCalls/SA20191119n_S2_L001_R1_001.fastq.gz
Progress:  100.0 % Uploaded
2019-07-03 21:46:23 INFO     Samples in directory '190329_NB551633_0004_AHGCNCAFXY/' have finished uploading!
2019-07-03 21:46:23 INFO     ==================================================
2019-07-03 21:46:23 INFO     ----------------ENDING UPLOAD RUN-----------------
2019-07-03 21:46:23 INFO     ==================================================
2019-07-03 21:46:23 INFO     Stopped active logging to run directory
```


