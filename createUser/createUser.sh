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
  #statements
  echo "Please answer Y or n."
}
function lowercase(){
  return `echo "${1,,}"`
}

DIR_LOG="/root/log/createUser"


read -p "Please enter new user name: " NEW_U
NEW_U=`lowercase $NEW_U`
F_NAME="`date +%y-%m-%d`_$NEW_U"
F_LOG="$DIR_LOG/$F_NAME"
touch $F_LOG

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
        echo "Check whether \"$NEW_U\" exists?...Yes";
        echo "Check whether \"$NEW_U\" exists?...Yes" >> $F_LOG;
        while true; do
          read -p "Do you want to reset $NEW_U's password? (Y/n): " yn
          case $yn in
            [Yy]* ) \
              #=====
              passwd $NEW_U;
              echo "Password is reset.";
              echo "Password is reset." >> $F_LOG;
              break;;
            [Nn]* ) echo "Password unchanged." >> $F_LOG; break;;
            * ) echo "Please answer (Y/n): ";;
          esac
        done;
      else
        echo "Check whether \"$NEW_U\" exists?...No";
        echo "Check whether \"$NEW_U\" exists?...No" >> $F_LOG;
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
                echo "Check whether \"$NEW_G\" exists?...Yes"
                echo "Check whether \"$NEW_G\" exists?...Yes" >> $F_LOG
                NEW_GID=`getent group $NEW_G | cut -d ':' -f 1`
                LEVER=false
              else
                echo "Check whether \"$NEW_G\" exists?...No"
                echo "Check whether \"$NEW_G\" exists?...No" >> $F_LOG
                LEVER=true
              fi; break;;
            [Nn]* ) \
              NEW_G=$NEW_U
              echo "$NEW_G is set to be equal $NEW_U";
              echo "$NEW_U is set to be equal $NEW_U" >> $F_LOG;
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
                    echo "$NEW_G is added with gid $NEW_GID on $HOSTNAME"
                    echo "$NEW_G is added with gid $NEW_GID on $HOSTNAME" >> $F_LOG
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
                echo "$NEW_G is added with gid $NEW_GID on $HOSTNAME"
                echo "$NEW_G is added with gid $NEW_GID on $HOSTNAME" >> $F_LOG
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
                  echo "$NEW_U is added with uid $NEW_UID and gid $NEW_GID on $HOSTNAME"
                  echo "$NEW_U is added with uid $NEW_UID and gid $NEW_GID on $HOSTNAME" >> $F_LOG
              else echo "User adding error."
              fi; break;;
            [Nn]* ) \
              adduser $NEW_U -g $NEW_GID;
              if [ $out -eq 0 ]; then
                  echo "$NEW_U is added gid $NEW_GID on $HOSTNAME"
                  echo "$NEW_U is added gid $NEW_GID on $HOSTNAME" >> $F_LOG
              else echo "User adding error.";
              fi; break;;
            * ) echoYN;;
          esac
        done;
        echo "Please enter first-time-login password.";
        #=====
        passwd $NEW_U;
        chage -d 0 $NEW_U;
        echo "First time password created." >> $F_LOG;
      fi; break;;
    [Nn]* ) exit;;
    * ) echo "Please answer Y or n.";;
  esac
done


while true; do
  read -p "Does\"$NEW_U\" need storage on Lustre? (Y/n): " yn
  case $yn in
    [Yy]* ) \
      echo "$NEW_U needs storage on Lustre" >> $F_LOG;
      ls /lustre/$NEW_U > /dev/null 2>&1;
      out=$?;
      if [ $out -eq 0 ]; then
        echo "Checking for existing directory /lustre/$NEW_U...Yes"
        echo "Checking for existing directory /lustre/$NEW_U...Yes" >> $F_LOG
        echo "If you want to wipe clean /lustre/$NEW_U, please do it later mannually."
      else
        echo "Checking for existing directory /lustre/$NEW_U...No"
        echo "Checking for existing directory /lustre/$NEW_U...No" >> $F_LOG
        #=====
        mkdir /lustre/$NEW_U
        echo "The directory /lustre/$NEW_U has been created."
        echo "The directory /lustre/$NEW_U has been created." >> $F_LOG
      fi;
      echo "Initating user access process...";
      #=====
      chown -R $NEW_U:`id -ng $NEW_U`;
      echo "--> Owner right is trasfered with chown...Yes";
      #=====
      scp /etc/shadow mds-0-1:/etc/shadow;
      scp /etc/shadow mds-0-2:/etc/shadow;
      echo "--> Transfer file to lustre client...shadow...Yes";
      #=====
      scp /etc/group mds-0-1:/etc/group;
      scp /etc/group mds-0-2:/etc/group;
      echo "--> Transfer file to lustre client...group...Yes";
      #=====
      scp /etc/passwd mds-0-1:/etc/passwd;
      scp /etc/passwd mds-0-2:/etc/passwd;
      echo "--> Transfer file to lustre client...passwd...Yes";
      echo "User access on lustre granted.";
      echo "User access on lustre granted.." >> $F_LOG;
      read -p "How many Terabyte on lustre \"$NEW_U\" needs: " SIZE;
      SIZE_KBYTE_H=`echo "scale=0; ($SIZE*1024*1024*1024)/1" | bc`;
      SIZE_KBYTE_S=`echo "scale=0; ($SIZE_KBYTE_H*0.9)/1" | bc`;
      #=====
      lfs setquota -u $NEW_U -b $SIZE_KBYTE_S -B $SIZE_KBYTE_H /lustre/$NEW_U;
      echo "Quota has been set with $SIZE TB hard limit.";
      echo "Quota has been set with $SIZE TB hard limit." >> $F_LOG;
      break;;
    [Nn]* ) break;;
    * ) echo "Please answer Y or n.";
  esac
done

echo "Log file has been created at $F_LOG"
