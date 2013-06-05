############ Remote Path #############                                                                          
echo ""
echo " "
printf "Remote Path [/home/user/versions]: "
read DEST_PATH

if [ -z $DEST_PATH ]; then
    DEST_PATH=/home/user/versions
fi

echo " "
