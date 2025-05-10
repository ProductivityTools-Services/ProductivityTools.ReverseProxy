#!/bin/bash

function bashWrite {
  echo $1
}

FILES="./sites-available/*"
echo "$FILES"

for fullpath in $FILES;
do
 bashWrite "VERBOSE: --------------"
 bashWrite "VERBOSE: processing file: $fullpath"
 bashWrite "VERBOSE: copy $fullpath to sites-available"
 cp $fullpath /etc/nginx/sites-available/
 FILENAME=$(basename $fullpath)
 bashWrite "VERBOSE: only filename: $FILENAME"
 bashWrite "VERBOSE: creating ln for $FILENAME"

 SITEENABLEDPATH="/etc/nginx/sites-availiable/$FILENAME"
 bashWrite "VERBOSE: site enabled path:$SITEENABLEDPATH"

 SIMLINKPATH="/etc/nginx/sites-enabled/$FILENAME"
 bashWrite "VERBOSE: simlink path: $SIMLINKPATH"
 
 if [[ -e $SIMLINKPATH ]]; then
  bashWrite "VERBOSE: simlink already  exists"
 else
  bashWrite "VERBOSE: File does not exist, creating simlink"
  ln -s "/etc/nginx/sites-available/$FILENAME" /etc/nginx/sites-enabled
fi 
  sudo certbot --nginx -d $FILENAME --reinstall

done



sudo nginx -t
sudo nginx -s reload
bashWrite "VERBOSE: /etc/nginx/sites-enabled/ content:"
ls -al /etc/nginx/sites-enabled/

#cp -R ./sites-available/.  /etc/nginx/sites-available/


