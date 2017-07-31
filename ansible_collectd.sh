#!/bin/bash

#Installing CollectD on the Host Machine (i.e. the server)
sudo apt-get install collectd collectd-utils

#Adding localhost to the ansible hosts file
echo Adding localhost to the ansible hosts file...
echo "localhost ansible_connection=local" | sudo tee --append /etc/ansible/hosts

#Creating a new host group in ansible
echo Enter the name of new host group for ansible: 
read group
echo Adding host group $group to ansible host file...
echo "[$group]" | sudo tee --append /etc/ansible/hosts

#Asking user to enter the IP addresses of the client VMs of collectD
echo How many clients are there?
read clients

for((i=1; i<=$clients; i++))
{
	echo Enter the IP address of Client $i
	read IP
	sudo echo "$IP ansible_connection=ssh" | sudo tee --append /etc/ansible/hosts
	echo Client with IP address $IP added to the host group $group
}

#Configuring server to listen to clients
echo Configuring server to listen to clients...
sudo sed -i '/Listen "ff18::efc0:4a42"/s/^# *//' /etc/collectd/collectd.conf  #Uncommenting "Listen" command
sudo sed -i 's/Listen.*/Listen "0.0.0.0" "25826"/g' /etc/collectd/collectd.conf     #Server starts listening to 0.0.0.0 .i.e. all clients

#Configuring server to store data received from clients
echo Configuring server to store data received from clients...
sudo sed -i '/LoadPlugin rrdtool/s/^# *//' /etc/collectd/collectd.conf
sudo sed -i '/LoadPlugin csv/s/^# *//' /etc/collectd/collectd.conf 

#Using Ansible, configuring all the clients
echo Configuring all clients to send data to the server...
ansible-playbook --ask-su-pass -s --extra-vars "plugins=network group=$group" main.yml

#Asking User to enable more plugins
echo Do you want to enable more plugins? y/n
read option

if [ "$option" == "y" ]; then
	echo Enter the plugin you wish to enable:
	while read x
	do
        	plugins=("${plugins[@]}" $x)
        	echo Enter more? y/n
        	read x
        	if [ "$x" == "y" ]; then
                	echo Enter the plugin you wish to enable:
                	continue
        	else
                	break
        	fi
	done
        for i in "${plugins[@]}"
        {
                echo "Enabling $i plugin..."
                ansible-playbook --ask-su-pass -s --extra-vars "plugins=$i group=$group" plugin.yml
                echo "$i plugin enabled"
		continue
        }
else
	echo No plugins will be enabled

fi

#Restart CollectD service on the server
echo Restarting CollectD service on the server...
sudo service collectd restart
