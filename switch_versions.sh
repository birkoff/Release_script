#!/bin/bash
## Created by Hector Reyes Aleman 2012
## before run: execute ec2up (script to give permissions to clear the cache in each instance)
## to run: ./swich_version.sh -tag 3_1_22 -prev 3_1_21 -remote /media/volume/temp  -machines dave,stage,patrick,dan
## do I need to explain this? if yes(sorry I won't) if not(great)

typeset -A CLUSTERS



########### Tag Version ################
echo " "
echo "List of Files in (/home/user/releases/)....."
echo " "
ls /home/user/releases/
printf "Tag version ex. 3_1_21 Please DO NOT include the v: "
read tag

if [ -z $tag ]; then
    echo "Exiting on user Command"
    exit
fi

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
echo ""
echo " "
printf "Remote Path [/home/user/versions]: "
read DEST_PATH

if [ -z $DEST_PATH ]; then
    DEST_PATH=/home/user/versions
fi

echo " "
echo " "
printf "Cluster name (...): "
read CLUSTER

if [ -z $CLUSTER ]; then

  printf "Machines (...): "
  read $MACHINES
  if [ -z $MACHINES ]; then
      echo "Exiting on user Command"
      exit
  fi
else
  MACHINES=${CLUSTERS[${CLUSTER}]}
fi

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
  ssh $m "cd $DEST_PATH; rm -f live; ln -s v$tag live; rm -f previous; ln -s v$previous previous; rm next; \
          cd /var/www/cache/; rm -f *.css *.js *.nrcgz;

  ssh $m "/etc/init.d/apachectl restart"
  echo "/etc/init.d/apachectl restart"
done
