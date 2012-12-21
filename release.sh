#!/bin/bash
## Created by Hector Reyes Aleman


typeset -A CLUSTERS

#MACHINES="app_prod_1,app_prod_2,app_prod_3";

CLUSTERS["PRODUCTION"]="app_prod_1,app_prod_2,app_prod_3";
CLUSTERS["QA"]="app_qa_1,app_qa_2,app_qa_3";
CLUSTERS["DEV"]="app_dev_1,app_dev_2,app_dev_3";

patch=0 
clearcache=0
svnexporttag="No"
tagrelease="No"
clearcacheui="No"
svnurl="http://fake.url.com/projects/coolproject"

echo " "
echo "====== Welcome to the Release Tool ======"
echo "====== Created by: Hector  ======"
echo " "

########### Action Release/Patch ###############
printf "Release or Patch (r/p): "
read action

if [[ "$action" != "r" && "$action" != "p" ]]; then
    echo "Exiting on user Command"
    exit
fi

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

echo " "
echo " "
printf "Local Path [/home/user/releases/v$tag]: "
read LOCAL_PATH 

if [ -z $LOCAL_PATH ]; then
    LOCAL_PATH=/home/user/releases/v$tag
fi



########## SVN TAG/EXPORT ##########
if [ "$action" == "r" ]; then
    actionname="Release"
    echo " "
    echo " "
    printf "Do you want to Tag the release (This will autocatically svn export the tag)? (y/N): "
    read tagrelease

    if [ "$tagrelease" == "y" ]; then
      svn copy -m "Tagging the $tag release of the 'Project'" $svnurl/trunk $svnurl/tags/v$tag
      echo " "
      echo "Taging the release..."
      echo "svn copy -m \"Tagging the $tag release of the 'Project'\" $svnurl/trunk $svnurl/tags/v$tag" 
      svn export $svnurl/tags/v$tag $LOCAL_PATH
      echo " "
      echo "svn export $svnurl/tags/v$tag $LOCAL_PATH"
      
    else
      echo " "
      echo " "
      printf "Do you want SVN Export the release tag? (y/N): "
      read svnexporttag
      if [ "$svnexporttag" == "y" ]; then
        svn export $svnurl/tags/v$tag $LOCAL_PATH
        echo " "
        echo "svn export $svnurl/tags/v$tag $LOCAL_PATH"
      fi
    fi
fi

########## Local Path Validation ##############

if [ ! -d "$LOCAL_PATH" ]; then
    echo "Local Path ($LOCAL_PATH) not Found"
    exit
fi

########### If Patch ###############
if [ "$action" == "p" ]; then
  actionname="Patch"
  patch=1
  echo " "
  echo " "
  printf "Do you want to clear the cache? (y/N): "
  read clearcacheui
  if [ "$clearcacheui" == "y" ]; then
    clearcache=1
  fi
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
printf "Cluster name (PRODUCTION, QA, DEV): "
read CLUSTER

if [ -z $CLUSTER ]; then
  
  printf "Machines (app_prod_1,app_prod_2,app_prod_3): "
  read MACHINES
  if [ -z $MACHINES ]; then
      echo "Exiting on user Command"
      exit
  fi
else
  MACHINES=${CLUSTERS[${CLUSTER}]}
fi


echo " "
echo "== Parameters =="
echo "---> Action.......... ${actionname}"
echo "---> Tag............. ${tag}"
echo "---> Tag release..... ${tagrelease}"
echo "---> SVN Export Tag.. ${svnexporttag}"
echo "---> Clear cache..... ${clearcacheui}"
echo "---> Local........... ${LOCAL_PATH}"
echo "---> Remote.......... ${DEST_PATH}"
echo "---> Cluster......... ${CLUSTER}"
echo "---> Machines........ ${MACHINES}"
echo " "
echo " "
printf "Are all parameters ok? Do you want continue? (y/N): "
read continuerun
if [ "$continuerun" != "y" ]; then
  echo "Exiting on user Command"
  exit
fi

echo " "
echo "== Starting RSYNC to selected servers =="
echo " "

for m in $(echo $MACHINES | sed -n 1'p' | tr ',' '\n')
do
  if [ $patch -eq 0 ]; then #release
    echo "#######################################################"
    echo "############### Releasing Code to: ${m} ###############"
    echo "#######################################################" 
    echo "rsync -v --compress --rsh=/usr/bin/ssh --recursive --times --perms --links --delete $LOCAL_PATH $m:$DEST_PATH"
    echo "ssh $m \"cd $DEST_PATH;"
    echo "ls;"
    echo "ln -s v$tag next;"
    echo "cp  live/www/.htaccess next/www/;"
     
      rsync -v --compress --rsh=/usr/bin/ssh --recursive --times --perms --links --delete $LOCAL_PATH $m:$DEST_PATH
      ssh $m "cd $DEST_PATH; \
          ls; \ 
          ln -s v$tag next; \
          cp  live/www/.htaccess next/www/;"
       
  else #patch
    echo "#######################################################"
    echo "############### Patching Code to: ${m} ################"
    echo "#######################################################"
    echo "rsync -v --compress --rsh=/usr/bin/ssh --recursive --update  --times --perms --links $LOCAL_PATH $m:$DEST_PATH"
    rsync -v --compress --rsh=/usr/bin/ssh --recursive --update  --times --perms --links $LOCAL_PATH $m:$DEST_PATH
    if [ $clearcache -eq 1 ]; then
       echo "Clear Cache............Yes"
       ssh $m "cd /var/www/cache/; rm -f *.css *.js *.nrcgz"
       ssh $m "/etc/init.d/apachectl restart"
       echo "/etc/init.d/apachectl restart"
    fi
  fi
done
