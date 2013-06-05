########### Tag Version ################
echo " "
echo "List of Files in (/home/user/releases/)....."
echo " "
ls /home/user/releases/ | sed -e 's|^v||' | grep -v zip | grep '^[0-9]'
printf "Tag version ex. 3_1_21 Please DO NOT include the v: "
read tag

if [ -z $tag ]; then
    echo "Exiting on user Command"
    exit
fi

echo " "
