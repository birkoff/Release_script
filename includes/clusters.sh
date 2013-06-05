## Created by Hector Reyes Aleman 2013

# Declaring associative array
typeset -A CLUSTERS

CLUSTERS["PRODUCTION"]="members1,members2,members3,nco1,nco2,nco3,cache1,cache2";
CLUSTERS["PRODMEMNCO"]="members1,members2,members3,nco1,nco2,nco3";
CLUSTERS["PRODMEMBERS"]="members1,members2,members3";
CLUSTERS["PRODNCO"]="nco1,nco2,nco3";
CLUSTERS["PRODCACHE"]="cache1,cache2";
CLUSTERS["QA"]="qamembers1,qamembers2,qanco1,qanco2,qacache1,qacache2";
CLUSTERS["QAMEMBERS"]="qamembers1,qamembers2";
CLUSTERS["QANCO"]="qanco1,qanco2";
CLUSTERS["QACACHE"]="qacache1,qacache2";
CLUSTERS["DEV"]="hector,dan,dave,patrick";
CLUSTERS["QASINGLE"]="qamembers1,qanco1,qacache1";
CLUSTERS["DEVTEST"]="hector";
