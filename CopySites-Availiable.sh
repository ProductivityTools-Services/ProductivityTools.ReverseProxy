#!/bin/bash

FILES="./sites-available/*"
echo "$FILES"

for fullpath in $FILES;
do
 echo "VERBOSE: --------------"
 echo "VERBOSE: processing file: $fullpath"
 echo "VERBOSE: copy $fullpath to sites-available"
 cp $fullpath /etc/nginx/sites-available/
 FILENAME=$(basename $fullpath)
 echo "VERBOSE: only filename: $FILENAME"
 echo "VERBOSE: creating ln for $FILENAME"

 SITEENABLEDPATH="/etc/nginx/sites-availiable/$FILENAME"
 echo "VERBOSE: site enabled path:$SITEENABLEDPATH"

 SIMLINKPATH="/etc/nginx/sites-enabled/$FILENAME"
 echo "VERBOSE: simlink path: $SIMLINKPATH"
 
 if [[ -e $SIMLINKPATH ]]; then
  echo "VERBOSE: simlink already  exists"
 else
  echo "File does not exist"
  ln -s "/etc/nginx/sites-available/$FILENAME" /etc/nginx/sites-enable
fi 

done



sudo nginx -t
sudo nginx -s reload

ls /etc/nginx/sites-enabled/

#cp -R ./sites-available/.  /etc/nginx/sites-available/


