#!/bin/bash

if [ $# -eq 0 ]
  then
    VERBOSE_LEVEL=1
    else
    VERBOSE_LEVEL=$1
fi


function bashWrite {
  VERBOSE_LEVEL=$1
  LOCAL_VERBOSE=$2
  TEXT=$3
  if [[ $VERBOSE_LEVEL -eq $LOCAL_VERBOSE]]
  then
  echo $TEXT
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
 bashWrite  "VERBOSE: only filename: $FILENAME"
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
  sudo certbot --nginx -d $FILENAME --reinstall

done



sudo nginx -t
sudo nginx -s reload
bashWrite VERBOSE_LEVEL 2 "VERBOSE: /etc/nginx/sites-enabled/ content:"
ls -al /etc/nginx/sites-enabled/

#cp -R ./sites-available/.  /etc/nginx/sites-available/


