#!/bin/bash
interfaceFile=/etc/network/interfaces
interfaceBackup=./interfaces.backup
interfaceTemp=./interfaces.temp
read -p "Install LAMP on this server (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        sudo apt-get -y update && sudo apt-get -y upgrade
        #Install Apache2
        sudo apt-get -y install apache2
        #Install PHP
        sudo apt-get -y install php libapache2-mod-php php-mysql
        #Install MySQL
        sudo apt-get -y mysql-server
    ;;
    * )
        echo "Skipping LAMP Install"
    ;;
esac
read -p "Install PHPMyAdmin on this server (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        #Install LAMP if not already installed and
        #Install PHPmyadmin
        sudo apt-get -y update
        sudo apt-get -y install phpmyadmin php-mbstring php-gettext mysql-server php libapache2-mod-php php-mysql apache2
    ;;
    * )
        echo "Skipping PHPMyadmin Install"
    ;;
esac
read -p "Install Webmin on this server (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        sudo apt-get -y update && sudo apt-get -y upgrade
        #Install Webmin
        sudo echo 'deb https://download.webmin.com/download/repository sarge contrib' | sudo tee -a /etc/apt/sources.list.d/webmin.list
        wget http://www.webmin.com/jcameron-key.asc
        sudo apt-key add jcameron-key.asc
        sudo apt-get update
        sudo apt-get install apt-transport-https
        sudo apt-get install webmin
    ;;
    * )
        echo "Skipping Webmin Install"
    ;;
esac

read -p "Set Static IP Address (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        #find the current device to assign static IP address
        dev_name=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2}';`
        dev_name=`echo $dev_name | sed -e 's/^[ \t]*//'`
        echo "Altering device $dev_name"
        echo "Enter new ip address: "
        read ip
        echo "Enter new subnet mask: "
        read subnet
        echo "Enter new gateway address: "
        read gateway
        echo "Enter new broadcast address: "
        read broadcast
        echo "Enter new nameserver address: "
        read nameserver
        echo "----------------------------------"
        echo "Changing $dev_name to"
        sudo ifconfig $dev_name down
        sudo ifconfig $dev_name $ip
        sudo ifconfig $dev_name netmask $subnet
        sudo ifconfig $dev_name broadcast $broadcast
        sudo ifconfig $dev_name up
        sudo route add default gw $gateway
        cp $interfaceFile $interfaceTemp
        cp $interfaceFile $interfaceBackup
        sudo sed -i "s/iface $dev_name inet dhcp/iface $dev_name inet static/g" $interfaceTemp
        #echo "iface $dev_name inet static" >> interface.test
        sudo echo "address $ip" >> $interfaceTemp
        sudo echo "netmask $subnet" >> $interfaceTemp
        sudo echo "broadcast $broadcast" >> $interfaceTemp
        sudo echo "gateway $gateway" >> $interfaceTemp
        sudo echo "dns-nameservers $nameserver" >> $interfaceTemp
        sudo cp $interfaceTemp $interfaceFile
        #rm $interfaceTemp
    ;;
    * )
        echo "Skipping IP Assignment"
    ;;
esac


read -p "Change Hostname -- This requires a restart? " answer
case ${answer:0:1} in
    y|Y )
        #Assign existing hostname to $hostn
        hostn=$(cat /etc/hostname)

        #Display existing hostname
        echo "Existing hostname is $hostn"

        #Ask for new hostname $newhost
        echo "Enter new hostname: "
        read newhost

        #change hostname in /etc/hosts & /etc/hostname
        sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
        sudo sed -i "s/$hostn/$newhost/g" /etc/hostname

        #display new hostname
        echo "Your new hostname is $newhost"
        #Press a key to reboot
        read -s -n 1 -p "Press any key to reboot"
        sudo reboot
    ;;
    * )
        echo "Skipping Hostname Change"
    ;;
esac
