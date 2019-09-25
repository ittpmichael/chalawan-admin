# !/bin/sh

echo "\
*************************************************
*      USER CREATION SCRIPT FOR CHALAWAN        *
*       WRITTEN BY ITTIPAT PROMNORAKID          *
*************************************************
This script will do these following procedures:
  1. Create USER and create first-time-login PASSWORD and assign
     GROUP to user.
  2. SYNCRONIZE user with \"rocks sync users\"
  3. Create DIRECTORY on LUSTRE and limit QUOTA
  4. Transfer OWNER's right of /lustre/user to USER or GROUP
  5. COPY permission file to mds nodes.
"

# Functions are defined here.
function echoBreak() {
  #statements
  echo "OK, Let's take a break for a while, type Y when you are ready."
  echo "Or, type ctrl+c to cancel..."
}
function echoYN() {
  echo "Please answer Y or n."
}

DIR_LOG="/root/log/createUser"

echo "Log file has been created at $F_LOG"

read -p "Please enter new user name: " NEW_U
NEW_U=`echo "${NEW_U,,}"`
F_NAME="`date +%y-%m-%d`_$NEW_U"
F_LOG="$DIR_LOG/$F_NAME"
touch $F_LOG

function echoLog() {
  echo $1
  echo $1 >> $F_LOG
}

cat <<EOM >>$F_LOG
====================
EOM
# The begining of every thing
while true; do
  # make sure you want to add that user to the system. If not, exit shell.
  read -p "\"$NEW_U\" will be added to $HOSTNAME, proceed? (Y/n): " yn
  case $yn in
    [Yy]* ) \
      id -u $NEW_U > /dev/null 2>&1;
      out=$?;
      if [ $out -eq 0 ]; then
        echoLog "Check whether \"$NEW_U\" exists?...Yes";
        while true; do
          read -p "Do you want to reset $NEW_U's password? (Y/n): " yn
          case $yn in
            [Yy]* ) \
              #=====
              passwd $NEW_U;
              echoLog "Password is reset.";
              break;;
            [Nn]* ) echo "Password unchanged." >> $F_LOG; break;;
            * ) echo "Please answer (Y/n): ";;
          esac
        done;
      else
        echoLog "Check whether \"$NEW_U\" exists?...No";
        # Ask for specific primary group
        while true; do
          read -p "Does $NEW_U need to be in a specific primary group? (Y/n): " yn
          case $yn in
            [Yy]* ) \
              # Ask for group name
              read -p "Please enter a group name: " NEW_G;
              NEW_G=`echo "${NEW_G,,}"`;
              echo "$NEW_U need a specific primary group $NEW_G" >> $F_LOG;
              # check if the group exists. If yes, assign that group to the user
              # If no, ask for a group name and a group ID
              getent group $NEW_G > /dev/null 2>&1;
              out=$?
              echo "Call group result: $out";
              if [ $out -eq 0 ]; then
                echoLog "Check whether \"$NEW_G\" exists?...Yes"
                NEW_GID=`getent group $NEW_G | cut -d ':' -f 1`
                LEVER=false
              else
                echoLog "Check whether \"$NEW_G\" exists?...No"
                LEVER=true
              fi; break;;
            [Nn]* ) \
              NEW_G=$NEW_U
              echoLog "$NEW_G is set to be equal $NEW_U";
              LEVER=true
              break;;
            * ) echo "Please answer Y or n.";;
          esac
        done
        # Ask for custom gid
        while $LEVER; do
          read -p "Does $NEW_G need custom gid? (Y/n)?: " yn
          case $yn in
            [Yy]* ) \
              #=====
              read -p "Please provide gid: " NEW_GID;
              read -p "The group $NEW_G will be created with gid $NEW_GID, proceed?: " yn
              case $yn in
                [Yy]* ) \
                  groupadd $NEW_G -g $NEW_GID;
                  if [ $out -eq 0 ]; then
                    echoLog "$NEW_G is added with gid $NEW_GID on $HOSTNAME"
                  else echo "Group adding error."
                  fi; break;;
                [Nn]* ) echoBreak;;
                * ) echoYN;;
              esac; break;;
            [Nn]* ) \
              #=====
              groupadd $NEW_G;
              NEW_GID=`getent group $NEW_G| cut -d ':' -f 1`
              if [ $out -eq 0 ]; then
                echoLog "$NEW_G is added with gid $NEW_GID on $HOSTNAME"
              else echo "Group adding error."
              fi; break;;
            * ) echoYN;;
          esac
        done;
        # Ask for specific uid
        while true; do
          read -p "Does $NEW_U need specific uid? (Y/n): " yn
          case $yn in
            [Yy]* ) \
              read -p "Please provide uid: " NEW_UID;
              adduser $NEW_U -u $NEW_UID -g $NEW_GID;
              if [ $out -eq 0 ]; then
                  echoLog "$NEW_U is added with uid $NEW_UID and gid $NEW_GID on $HOSTNAME"
              else echo "User adding error."
              fi; break;;
            [Nn]* ) \
              adduser $NEW_U -g $NEW_GID;
              if [ $out -eq 0 ]; then
                  echoLog "$NEW_U is added gid $NEW_GID on $HOSTNAME"
              else echo "User adding error.";
              fi; break;;
            * ) echoYN;;
          esac
        done;
        echo "Please enter first-time-login password.";
        passwd $NEW_U;
        chage -d 0 $NEW_U;
        echo "First time password created." >> $F_LOG;
      fi; break;;
    [Nn]* ) exit;;
    * ) echo "Please answer Y or n.";;
  esac
done

# set up the user quota by copying the quota policy from the existing user to
# the new user
edquota -p ittipat $NEW_U
echoLog "/home quota for $NEW_U has been set to 4.5(5.0)GB block"
echoLog "and 311296(327680) inodes"

while true; do
  read -p "Does\"$NEW_U\" need storage on Lustre filesystem? (Y/n): " yn
  case $yn in
    [Yy]* ) \
      echoLog "$NEW_U needs storage on Lustre" >> $F_LOG;
      # TODO Neeed for group or personal?
      echo "Does \"$NEW_U\" need a shared directory or a personal directory?"
      choice1="Shared_directory"; choice2="Personal_directory";
      choice3="Other_secondary_group_(enter_it_mannually)";
      select choice in ${choice1} ${choice2} ${choice3}; do
        case $choice in
          ${choice1} ) \
            echoLog "\"$choice1\" is selected";
            export NEW_LDIR=$NEW_G; break;;
          ${choice2} ) \
            echoLog "\"$choice2\" is selected";
            export NEW_LDIR=$NEW_U; break;;
          ${choice3} ) \
            echoLog "\"$choice3\" is selected";
            echo "Please enter group name from: "
            # TODO: What if admin enter wrong group name?
            # 1st method: ask for confirmation
            # 2nd method: check if the given name is in the group list
            read -p "\"`groups $NEW_U | cut -d' ' -f3-`\"" NEW_LDIR
        esac
      done
      ls /lustre/$NEW_LDIR > /dev/null 2>&1;
      out=$?;
      if [ $out -eq 0 ]; then
        echoLog "Checking for existing directory /lustre/$NEW_LDIR...Yes"
        echo "If you want to adjust the quota, please do it later mannually."
      else
        echoLog "Checking for existing directory /lustre/$NEW_LDIR...No"
        #=====
        mkdir /lustre/$NEW_LDIR
        echoLog "The directory /lustre/$NEW_LDIR has been created."
        # Transfer ownership
        chown -R $NEW_U:$NEW_LDIR /lustre/$NEW_LDIR;
        # Add attr project
        chattr +P /lustre/$NEW_LDIR;
        # Assign project id = gid
        PID=`getent group $NEW_LDIR | cut -d':' -f3`
        chattr -p $PID /lustre/$NEW_LDIR;
        read -p "How many Terabyte on lustre \"$NEW_U\" needs: " SIZE_H;
        # calculate soft limit block size and inode sizes
        SIZE_S=`echo "scale=0; ($SIZE_H*0.9)/1" | bc`;
        INODE_H=`echo "scale=0; $SIZE_H*100000" | bc`;
        INODE_S=`echo "scale=0; $SIZE_S*100000" | bc`;
      fi;
      #=====
      lfs setquota -p $PID -b ${SIZE_S}T -B ${SIZE_H}T -i $INODE_S \
        -I $INODE_H /lustre/$NEW_LDIR;
      echoLog "The quota has been set with $SIZE_S($SIZE_H) TB";
      echoLog "and inode $INODE_S($INODE_H) files";
      break;;
    [Nn]* ) echoLog "$NEW_U doesn't need a storage on the lustre"; break;;
    * ) echoYN;
  esac
done
