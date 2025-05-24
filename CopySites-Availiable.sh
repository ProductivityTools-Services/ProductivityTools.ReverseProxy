#!/bin/bash

function bashWrite {
  GLOBAL_VERBOSE_LEVEL=$1
  LOCAL_VERBOSE=$2
  TEXT=$3
  if [[ $GLOBAL_VERBOSE_LEVEL -ge $LOCAL_VERBOSE ]]
  then
  echo $TEXT
  fi
}

function writeSuccess {
 SUCCESSTEXT=$1
 if [[ $SUCCESSTEXT =~ "Congratulations! You have successfully enabled HTTPS on" ]];then 
  echo "Congratulations! You have successfully enabled HTTPS on file above"
 else
 echo "ERROR!!!!!"
 fi
 
 
}

function processFile {
 fullpath=$1
 echo "FullPath:"
 echo $fullpath
 bashWrite $VERBOSE_LEVEL 1 "VERBOSE: --------------"
 bashWrite $VERBOSE_LEVEL 1 "VERBOSE: processing file: $fullpath"
 bashWrite $VERBOSE_LEVEL 2 "VERBOSE: copy $fullpath to sites-available"
 cp $fullpath /etc/nginx/sites-available/
 FILENAME=$(basename $fullpath)
 bashWrite $VERBOSE_LEVEL 2 "VERBOSE: only filename: $FILENAME"
 bashWrite $VERBOSE_LEVEL 2 "VERBOSE: creating ln for $FILENAME"

 SITEENABLEDPATH="/etc/nginx/sites-availiable/$FILENAME"
 bashWrite $VERBOSE_LEVEL 2 "VERBOSE: site enabled path:$SITEENABLEDPATH"
 SIMLINKPATH="/etc/nginx/sites-enabled/$FILENAME"
 bashWrite $VERBOSE_LEVEL 2 "VERBOSE: simlink path: $SIMLINKPATH"
 if [[ -e $SIMLINKPATH ]]; then
  bashWrite $VERBOSE_LEVEL 2 "VERBOSE: simlink already  exists"
 else
  bashWrite $VERBOSE_LEVEL 2 "VERBOSE: File does not exist, creating simlink"
  ln -s "/etc/nginx/sites-available/$FILENAME" /etc/nginx/sites-enabled
 fi 
  echo "Last x"
  a=$(sudo certbot --nginx -d $FILENAME --reinstall 2>&1)
  echo $a
  writeSuccess "$a"
}

VERBOSE_LEVEL=1
echo $#
if [ $# -ge 1 ];
  then
    VERBOSE_LEVEL=$1
fi
echo "Verbose level: $VERBOSE_LEVEL"

FILE_TO_PROCESS=''
if [ $# -eq 2 ]
  then
    FILE_TO_PROCESS=$2
    echo "File to process $FILE_TO_PROCESS"
    filePath="./sites-available/$FILE_TO_PROCESS"
    echo "File Path: $filePath"
    processFile $filePath
  else
  FILES="./sites-available/*"
  echo "$FILES"

  for fullpath in $FILES;
  do
   echo $fullpath
    processFile $fullpath
  done
fi





a=$(sudo nginx -t 2>&1)
bashWrite VERVBOSE_LEVEL 2 $a

a=$(sudo nginx -s reload 2>&1)
bashWrite VERBSOE_LEVEL 2 $a
bashWrite VERBOSE_LEVEL 2 "VERBOSE: /etc/nginx/sites-enabled/ content:"


#cp -R ./sites-available/.  /etc/nginx/sites-available/


