#!bin/bash

# ==================================
#   COORD2RSID.SH
# ==================================
#  - RUNS COORD2RSID.R w/ 'Annotdir'
#  - ZIPs .CSVs (rsid.csv.zip)
#  - e-mails rsid.csv.zip & LOG txt
#
# ----------------------------------

echo STARTING SCRIPT...

#  SET DIRECTORIES
# =====================================================
Annotdir=~/Annotation
Scriptdir=~/SCRIPTS

cd $Scriptdir

dt=$(date +"%Y-%m-%d")
t0=$(date +"%Y-%m-%d_%H:%M")


#  RUN COORD2RSID.R
# =======================================================
Rscript --verbose coord2rsid.r $Annotdir

#  PACK UP OUTPUT
# =======================================================
cd $Annotdir/output

zip -r ./rsid.csv.zip ./*.csv
zip -r ./rsid.csv.zip ../coord2rsid.r.LOG_$dt*.txt

zip -r ./Rdata.zip ./*.Rdata
zip -r ./Rdata.zip ../coord2rsid.r.LOG_$dt*.txt

zipfiles=$(find $Annotdir/output -maxdepth 1 -type f -name '*zip')
logfile=$(find $Annotdir -maxdepth 1 -type f -name '*.txt' | sort -nr | head -n 1)

tf=$(date +"%Y-%m-%d_%H:%M")

FStot=$(du -B MB -c ./*.zip ../coord2rsid.r.LOG_$dt*.txt | tail -1 | tr -d -c '0-9')
# FScsvzip=stat -c%s rsid.csv.zip
# FSrdazip=stat -c%s all.output.zip
printf "%f" $FStot

#  UPLOAD OUTPUT TO DROPBOX & E-MAIL LINK
# =======================================================
~/dropbox_uploader.sh mkdir RMS-IGFoutput/$dt

l=$(echo "$logfile" | sed 's:.*/::')
~/dropbox_uploader.sh upload $logfile RMS-IGFoutput/$dt/$l

for f in $zipfiles
do
  a=$(echo "$f" | sed 's:.*/::')
  ~/dropbox_uploader.sh upload $f RMS-IGFoutput/$dt/$a
done


body=$(printf "  STARTED: %s\n" $t0)
body+=$(printf "COMPLETED: %s\n\n" $tf)

DBurl=$(cat ~/dropbox_uploader.sh share) 
body+=$(printf "Download Output at: %s\n\n" $DBurl)

mailx -A gmail \
  -s "[RMS-IGF@CCLS] coord2rsid.r ($dt)" \
  eugene.konagaya@gmail.com, xshao@berkeley.edu

echo " EXITING SCRIPT..."
echo "================================="
printf "  STARTED: %s\n" $t0
printf "COMPLETED: %s\n\n" $tf

exit 1;

