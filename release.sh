#!/bin/bash
## Created by Hector Reyes Aleman 2012 - 2013

source $(dirname $0)/includes/clusters.sh

patch=0
clearcache=0
svnexporttag="No"
tagrelease="No"
clearcacheui="No"

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

source $(dirname $0)/includes/list_tag_versions.sh

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
      svn copy -m "Tagging the $tag release of the 'Travolta'" http://svn.example.com/projects/myproject/trunk http://svn.example.com/projects/myproject/tags/v$tag
      echo " "
      echo "Taging the release..."
      echo "svn copy -m \"Tagging the $tag release of the 'Travolta'\" http://svn.example.com/projects/myproject/trunk http://svn.example.com/projects/myproject/tags/v$tag" 
      svn export http://svn.example.com/projects/myproject/tags/v$tag $LOCAL_PATH
      echo " "
      echo "svn export http://svn.example.com/projects/myproject/tags/v$tag $LOCAL_PATH"
      
    else
      echo " "
      echo " "
      printf "Do you want SVN Export the release tag? (y/N): "
      read svnexporttag
      if [ "$svnexporttag" == "y" ]; then
        svn export http://svn.example.com/projects/myproject/tags/v$tag $LOCAL_PATH
        echo " "
        echo "svn export http://svn.example.com/projects/myproject/tags/v$tag $LOCAL_PATH"
      fi
    fi
else
  actionname="Patch"
  patch=1
  echo " "
  echo " "
  printf "Local Project SVN Path [/home/user/releases/projects/travolta]: "
  read LOCAL_PROJECT_PATH

  if [ -z $LOCAL_PROJECT_PATH ]; then
    LOCAL_PROJECT_PATH=/home/user/releases/projects/travolta
  fi

  echo " "
  echo " "
  patch_file='y'

  while [ $patch_file == "y" ]
  do
    printf "File Path (Include www/): "
    read file_path
    pushd projects/travolta/
    echo "svn update $file_path"
    svn update $file_path
    popd
    echo "Backing up the old file......"
    echo "cp $LOCAL_PATH/$file_path $LOCAL_PATH/$file_path.lastgood"
    cp -fv $LOCAL_PROJECT_PATH/$file_path $LOCAL_PATH/$file_path.lastgood
    echo "cp $LOCAL_PROJECT_PATH/$file_path $LOCAL_PATH/$file_path"
    cp -fv $LOCAL_PROJECT_PATH/$file_path $LOCAL_PATH/$file_path
    printf "Do you want to patch another file? (y/N): "
    read patch_file
  done
  
  printf ""
  printf "Do you want to clear the cache? (y/N): "
  read clearcacheui
  if [ "$clearcacheui" == "y" ]; then
    clearcache=1
  fi
fi

########## Local Path Validation ##############

if [ ! -d "$LOCAL_PATH" ]; then
    echo "Local Path ($LOCAL_PATH) not Found"
    exit
fi

############ Remote Path #############                                                                          
source $(dirname $0)/includes/set_remote_path.sh

source $(dirname $0)/includes/set_cluster.sh

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
    echo "pushd next/www/images;"
    echo "ln -s /data/images db;"
    echo "popd;"
    echo "cp  live/www/.htaccess next/www/;"
    echo "cp  live/www/includes/settings/statsd.ini next/www/includes/settings/statsd.ini;"
    echo "cp  live/www/includes/settings.ini* next/nrp/includes/;"
    echo "cp  live/www/includes/settings.js next/www/includes/;"
    echo "cp -f live/www/admin/.htaccess next/www/admin/.htaccess;"
    echo "cp -f live/www/editorial/.htaccess next/www/editorial/.htaccess\""
     
      rsync -v --compress --rsh=/usr/bin/ssh --recursive --times --perms --links --delete $LOCAL_PATH $m:$DEST_PATH
      ssh $m "cd $DEST_PATH; \
          ls; \ 
          ln -s v$tag next; \
          pushd next/www/images; \
          ln -s /data/images db; \
          popd; \
          cp  live/www/.htaccess next/www/; \
          cp  live/www/includes/settings/statsd.ini next/www/includes/settings/statsd.ini; \
          cp  live/www/includes/settings.ini* next/www/includes/; \
          cp  live/www/includes/settings.js next/www/includes/; \
          cp -f live/www/admin/.htaccess next/www/nrp/.htaccess; \
          cp -f live/www/editorial/.htaccess next/www/editorial/.htaccess"
       
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
