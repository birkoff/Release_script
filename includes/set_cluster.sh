echo " "
printf "Cluster name (PRODUCTION, PRODMEMNCO, PRODMEMBERS, PRODNCO, PRODCACHE, QA, QAMEMBERS, QANCO, QACACHE, DEV, DEVTEST): "
read CLUSTER

if [ -z $CLUSTER ]; then

  printf "Machines (members1,members2,nco1,nco2,qamembers1,qamembers2,qanco1,qanco2): "
  read MACHINES
  if [ -z $MACHINES ]; then
      echo "Exiting on user Command"
      exit
  fi
else
  MACHINES=${CLUSTERS[${CLUSTER}]}
fi
