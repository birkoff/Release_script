Created by Hector Reyes Aleman - 2012
   To run this script follow the next steps:

     - Configure the ~/.ssh.config entries for the instances to release (Instances must have root access)
       example:
             Host pord-1
             HostName prod-1.example.com
             User ec2-user
             IdentityFile /home/user/ec2keys/keyfile.pem

    Setup options for these scripts:
    -- machines: comma separated list of instances where this will be executed (members1,members2,nco1,nco2) no spaces
    -- local: local path if the directory with the code so sync
    -- remote: remote path where that directory will be placed
    -- tag: tag of the release (3_1_21)

  ##################################################################

  ./release.sh (tag the release, rsync the files to the machines, create symlinks for the next version)
  ./swich_versions.sh (switches the versions from live to past and next to live)

 ######################################################################

    Default values for:
      -local /home/nimbit/releases/v$tag
      -remote /home/nrp/versions

    if is a patch the script will ask at the beginning fo the execution

