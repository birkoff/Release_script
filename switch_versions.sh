#!/bin/bash
## Created by Hector Reyes Aleman


source $(dirname $0)/includes/clusters.sh

source $(dirname $0)/includes/list_tag_versions.sh

########### previous Tag Version ################
echo " "
echo "List of Files in (/home/user/releases/)....."
echo " "
ls /home/user/releases/ | sed -e 's|^v||' | grep -v zip | grep '^[0-9]'
printf "PREVIOUS Tag version ex. 3_1_20 Please DO NOT include the v: "
read previous

if [ -z $previous ]; then
    echo "Exiting on user Command"
    exit
fi


############ Remote Path #############                                                                          

source $(dirname $0)/includes/set_remote_path.sh

source $(dirname $0)/includes/set_cluster.sh

echo " "
echo " "
echo "machines: ${MACHINES}"
echo "previous: ${previous}"
echo "remote: ${DEST_PATH}"
echo "tag: ${tag}"
echo " "
echo " "
printf "Are all parameters ok? Do you want continue? (y/N): "
read continuerun
if [ "$continuerun" != "y" ]; then
  echo "Exiting on user Command"
  exit
fi


for m in $(echo $MACHINES | sed -n 1'p' | tr ',' '\n')
do
  ssh $m "cd $DEST_PATH; rm -f live; ln -sv v$tag live; rm -f previous; ln -sv v$previous previous; rm next; \
          cd /var/www/cache/; rm -f *.css *.js *.nrcgz; \
     
  ssh $m "/etc/init.d/apachectl restart"
  echo "/etc/init.d/apachectl restart"
done
                                                            
