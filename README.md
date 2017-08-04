# Ansible-Playbooks-Bash-Script-CollectD
Automated configuration of CollectD on Server and Client nodes using Bash script and Ansible Playbooks

# About
This repository consist of the following:
1. __CollectD_Document:__ This is an introductory document where the read will learn about CollectD and it's plugins. It will also help in configuring CollectD server-client model.
2. __ansible_collectD:__ This is bash script which needs to be run for automation
3. __main.yml:__ Ansible Playbook for configuring CollectD server and client
4. __plugin.yml:__ Ansible Playbook for configuring Plugins at the clients.

# Getting Started

1. Clone the repository
2. Give special permission to ansible_collectd.sh script by executing the command: <code>$ chmod +x ansible_collectd.sh</code>
3. Execute the script: <code>$ ./ansible_collectd.sh</code>

__Note:__ The user should execute the script on the machine which will run in Server mode of CollectD

# Description

Once the script is executed, it will do the following:
1. Create a new user defined Ansible host group
2. It will ask for the number of clients, whose system statistics the user wish to collect, and their IP addresses
3. It will enable the CSV and RRD plugins of CollectD at the server
4. The scripts will call Ansible playbook <code>main.yml</code> to for downloading CollectD, configuring in Client mode, on  all the clients
5. Then it'll ask whether the user wants to enable more plugins at the clients. It it doesn't, it'll restart CollectD service at the server and exit. 
6. If the user wants to enable more plugins, the script will ask for their names, and then using <code>plugin.yml</code> enables them at the remote clients.
