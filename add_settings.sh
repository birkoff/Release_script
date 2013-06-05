#!/bin/sh
## Created by Hector Reyes Aleman June 2013

#SETTINGS="PostToStatementUponOrder = true"

source $(dirname $0)/includes/clusters.sh

echo " "
echo "====== Welcome to the Nimbit Release Tool (Push Production Settings) ======"
echo "====== Created by: Hector  ======"
echo " "

echo " "
printf "What settings file you want to Update?..."
printf "Remote Settings Path [/home/user/versions/live/www/includes/settings.ini]: "
read CONFIG_FILE

if [ -z $SETTING_FILE ]; then
    SETTING_FILE=/home/user/versions/live/www/includes/settings.ini
fi

echo " "
printf "Under What section should I put these settings?: (Common) NOTE: ONLY INCLUDE LETTERS NO SPECIAL CHARS: "
read section

if [ -z $section ]; then
    echo "You need to provide a secction"
    exit
fi


add_setting='y'
i=-1
while [ $add_setting == "y" ]
do
  let i++
  printf "Setting Entry(PostToStatementUponOrder = true):"
  read setting_entry
  settings[$i]=$setting_entry
  printf "Do you want to add another setting? (y/N): "
  read add_setting
done

echo ""

## Set Cluster
source $(dirname $0)/includes/set_cluster.sh

echo " "
echo "== Parameters =="
echo "---> Setting File.... ${SETTING_FILE}"
echo "---> Section......... ${section}"
echo "---> Cluster......... ${CLUSTER}"
echo "---> Machines........ ${MACHINES}"
echo "---> Settings entries:"
for var in "${settings[@]}"
do
  echo "${var}"
done

echo ""

printf "Are all parameters ok? Do you want continue? (y/N): "
read continuerun
if [ "$continuerun" != "y" ]; then
  echo "Exiting on user Command"
  exit
fi

echo " "
echo "== Starting to push new settings to selected servers =="
echo " "

for m in $(echo $MACHINES | sed -n 1'p' | tr ',' '\n')
do
    echo "#######################################################"
    echo "############## Applying Settings to: ${m} #############"
    echo "#######################################################"
    ssh $m "cp $SETTING_FILE $SETTING_FILE.lastgood"
    for var in "${settings[@]}"
    do
        echo "sed -i.back -e '/$section/{:a;n;/^$/!ba;i\\$var' -e '}' $SETTING_FILE"
        ssh $m "sed -i.back -e '/$section/{:a;n;/^$/!ba;i\\$var' -e '}' $SETTING_FILE"
    done
done
