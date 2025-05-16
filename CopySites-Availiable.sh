#!/bin/bash

if [ $# -eq 0 ]
  then
    VERBOSE_LEVEL=1
    else
    VERBOSE_LEVEL=$1
fi


function bashWrite {
  GLOBAL_VERBOSE_LEVEL=$1
  LOCAL_VERBOSE=$2
  TEXT=$3
  if [[ $GLOBAL_VERBOSE_LEVEL -eq $LOCAL_VERBOSE ]]
  then
  echo $TEXT
  fi
}

function writeSuccess {
 SUCCESSTEXT=$1
 if [[ $SUCCESSTEXT == *"Congratulations! You have successfully enabled HTTPS on"* ]];then 
  echo "Congratulations! You have successfully enabled HTTPS on file above"
 fi
}

FILES="./sites-available/*"
echo "$FILES"

for fullpath in $FILES;
do
 bashWrite VERBOSE_LEVEL 1 "VERBOSE: --------------"
 bashWrite VERBOSE_LEVEL 1 "VERBOSE: processing file: $fullpath"
 bashWrite VERBOSE_LEVEL 2 "VERBOSE: copy $fullpath to sites-available"
 cp $fullpath /etc/nginx/sites-available/
 FILENAME=$(basename $fullpath)
 bashWrite VERBOSE_LEVEL 2 "VERBOSE: only filename: $FILENAME"
 bashWrite VERBOSE_LEVEL 2 "VERBOSE: creating ln for $FILENAME"

 SITEENABLEDPATH="/etc/nginx/sites-availiable/$FILENAME"
 bashWrite VERBOSE_LEVEL 2 "VERBOSE: site enabled path:$SITEENABLEDPATH"
 SIMLINKPATH="/etc/nginx/sites-enabled/$FILENAME"
 bashWrite VERBOSE_LEVEL 2 "VERBOSE: simlink path: $SIMLINKPATH"
 if [[ -e $SIMLINKPATH ]]; then
  bashWrite VERBOSE_LEVEL 2 "VERBOSE: simlink already  exists"
 else
  bashWrite VERBOSE_LEVEL 2 "VERBOSE: File does not exist, creating simlink"
  ln -s "/etc/nginx/sites-available/$FILENAME" /etc/nginx/sites-enabled
fi 
  a=$(sudo certbot --nginx -d $FILENAME --reinstall 2>&1)
 # echo $a
  writeSuccess "$a"
done



a=$(sudo nginx -t 2>&1)
bashWrite VERVBOSE_LEVEL 2 $a

a=$(sudo nginx -s reload 2>&1)
bashWrite VERBSOE_LEVEL 2 $a
bashWrite VERBOSE_LEVEL 2 "VERBOSE: /etc/nginx/sites-enabled/ content:"


#cp -R ./sites-available/.  /etc/nginx/sites-available/


