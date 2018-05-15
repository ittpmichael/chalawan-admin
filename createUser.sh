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

DIR_LOG="/root/log/createUser"


read -p "Please enter new user name: " NEW_U
NEW_U=`echo "${NEW_U,,}"`
F_NAME="`date +%y-%m-%d`_$NEW_U"
F_LOG="$DIR_LOG/$F_NAME"
touch $F_LOG

cat <<EOM >>$F_LOG
====================
EOM

while true; do
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
            * ) echo "Please answer (Y/n): ";
          esac
        done;
      else
        echo "Check whether \"$NEW_U\" exists?...No";
        echo "Check whether \"$NEW_U\" exists?...No" >> $F_LOG;
        #=====
        adduser $NEW_U;
        if [ $? -eq 0 ]; then
          echo "--> $NEW_U is added to $HOSTNAME."
          echo "--> $NEW_U is added to $HOSTNAME." >> $F_LOG
        fi;
        echo "Please enter first-time-login password.";
        #=====
        passwd $NEW_U;
        echo "First time password created." >> $F_LOG;
      fi;
      break;;
    [Nn]* ) exit;;
    * ) echo "Please answer Y or n.";; 
  esac
done 

while true; do
  read -p "Does $NEW_U need to be in a specific group? (Y/n): " yn
  case $yn in
    [Yy]* ) \
      read -p "Please enter a group name: " NEW_G;
      NEW_G=`echo "${NEW_G,,}"`;
      echo "$NEW_U need a specific group $NEW_G" >> $F_LOG;
      getent group $NEW_G > /dev/null 2>&1;
      out=$?
      echo "Call group result: $out";
      if [ $out -eq 0 ]; then
        echo "Check whether \"$NEW_G\" exists?...Yes"
        echo "Check whether \"$NEW_G\" exists?...Yes" >> $F_LOG
      else
        echo "Check whether \"$NEW_G\" exists?...No"
        echo "Check whether \"$NEW_G\" exists?...No" >> $F_LOG
        while true; do
          read -p "Group \"$NEW_G\" will be added to $HOSTNAME, proceed? (Y/n): " yn
          case $yn in
            [Yy]* )
              #=====
              groupadd $NEW_G;
              if [ $out -eq 0 ]; then
                echo "$NEW_G is now new group on $HOSTNAME"
                echo "$NEW_G is now new group on $HOSTNAME" >> $F_LOG
              else echo "Group addition error."
              fi;
              break;;
            [Nn]* )  echo "OK, Let's take a break for a while, type Y when you are ready...";;
            * ) echo "Please answer Y or n.";;
          esac
        done;
      fi;
      echo "Please select group assignment type...";
      pri_group="Primary Group"; sec_group="Secondary Group";
      select choice in "$pri_group" "$sec_group"; do
        case $choice in
          "$pri_group" ) \
              #=====
              usermod -g $NEW_G $NEW_U;
              echo "Assign \"$NEW_G\" as a primary group to $NEW_U";
              echo "Assign \"$NEW_G\" as a primary group to $NEW_U" >> $F_LOG;
              break;;
          "$sec_group" )
              #=====
              usermod -a -G $NEW_G $NEW_G;
              echo "Assign \"$NEW_G\" as a secondary group to $NEW_U";
              echo "Assign \"$NEW_G\" as a secondary group to $NEW_U" >> $F_LOG;
              break;;
          * ) echo "Please select 1 or 2.";;
        esac
      done; break;;
    [Nn]* ) \
       echo "$NEW_U is automatically assign to {`id -nG $NEW_U`}";
       echo "$NEW_U is automatically assign to {`id -nG $NEW_U`}" >> $F_LOG;
       break;;
    * ) echo "Please answer Y or n.";;
  esac
done

echo "Performing users synchronization..."
rocks sync users

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
