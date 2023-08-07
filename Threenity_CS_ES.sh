#!/bin/bash
#FUNCTIONS
#RESOURCE GROUP
#Crear grupo de recursos
create_RG() {
    echo "Has seleccionado crear un grupo de recursos"
    echo "Introduce el nombre del primer Grupo de Recursos."
    read rg1
    echo "Introduce la region de ambos grupos de recursos."
    read location
    az group create -l $location -n $rg1
}
#Borrar grupo de recursos
delete_RG() {
    echo "Has seleccionado borrar un grupo de recursos"
    echo "CUIDADO! Este script borra el grupo de recursos y todo su contenido!"
    echo "Introduce el nombre del grupo de recursos"
    read rg1
    az group delete --name $rg1 --no-wait --yes
}
#NETWORKING
#Create single_vlan
create_single_vlan(){
    echo "Has seleccionado crear una VLAN"
    echo "Creacion de VLAN"
    echo "Introduce GR ya existente"
    read rg1
    echo "Introduce nombre de VLAN"
    read nombre_vlan
    echo "Introduce direccion IP de red con mascara (SINTAX x.x.x.x/x)"
    read red_ip
    az network vnet create -g $rg1 -n $nombre_vlan --address-prefixes $red_ip
}
#Crear un grupo de recursos y una vlan asociada.
create_vlan_GR(){
    echo "Has seleccionado crear un grupo de recursos y una VLAN asociada"
    echo "Creacion de grupo de recursos y VLAN"
    echo "Primer paso: Creacion de grupo de Recursos"
    echo "Introduzca la localizacion del grupo de recursos"
    read location
    echo "Introduzca nombre de grupo de recursos"
    read rg1
    az group create -l $location -n $rg1
    echo "Segundo paso: Creacion de VLAN"
    echo "Introduce nombre de VLAN"
    read nombre_vlan
    echo "Introduce direccion IP de red con mascara (SINTAX x.x.x.x/x)"
    read red_ip
    az network vnet create -g $rg1 -n $nombre_vlan --address-prefixes $red_ip
}
#Crear una subred.
create_subred(){
    echo "Has seleccionado crear una subred"
    echo "Creacion de Subredes"
    echo "Introduzca nombre de grupo de recursos"
    read rg1
    echo "Introduce nombre de VLAN a la que quieras asignar la subred"
    read nombre_vlan
    echo "Introduce nombre de subred"
    read nombre_subred
    echo "Introduce direccion IP de subred con mascara (SINTAX x.x.x.x/x)"
    read subred_ip
    az network vnet subnet create -g $rg1 --vnet-name $nombre_vlan -n $nombre_subred --address-prefixes $subred_ip
}
#VIRTUAL MACHINES
#Crear Maquina virtual
create_VM() {
    echo "Has seleccionado crear una máquina virtual"
#Crear NSG
    echo "Primer paso: creacion de NSG"
    echo "Introduce GR"
    read rg1
    echo "Introduce nombre de NSG"
    read NSG_name
    az network nsg create --resource-group $rg1 --name $NSG_name
    #Creamos una NIC y lo asociamos a vlan
    echo "Segundo paso: crear NIC"
    echo "Introduce nombre de NIC"
    read nic1
    echo "Introduce nombre de Vlan"
    read vlan
    echo "Introduce nombre de subred"
    read subred
    az network nic create --resource-group $rg1 --name $nic1 --vnet-name $vlan --subnet $subred --network-security-group $NSG_name
    #Creamos Maquina virtual
    echo "Tercer paso: crear VM"
    echo "Introduce el nombre de la maquina"
    read VM_name
    echo "Introduce imagen (https://az-vm-image.info/)"
    read imagen
    echo "Introduce el size"
    read size
    echo "Introduce usuario"
    read user
    az vm create --resource-group $rg1 --name $VM_name --image $imagen --size $size --admin-username $user --generate-ssh-keys --nics $nic1
}
#Abrir puerto en VM
port_opener(){
    echo "Has seleccionado abrir un puerto de una máquina virtual"
    echo "Introduzca el puerto"
    read port
    echo "Introduzca el nombre del grupo de recursos"
    read rg1
    echo "Introduzca nombre de la maquina"
    read VM_name
    #Abrir puerto indicado
    az vm open-port --port $port --resource-group $rg1 --name $VM_name
}
#Ejecutar comando en VM linux
command_lin(){
    echo "Has seleccionado introducir un comando en una máquina virtual LINUX"
    echo "Introduce grupo de recursos"
    read rg1
    echo "Introduce nombre de maquina virtual"
    read VM_NAME
    echo "Introduce comando/script"
    read comando
    echo "Introduce nombre del servicio"
    read name_service
    az vm run-command invoke --resource-group $rg1 --name $VM_NAME --command-id RunShellScript --scripts $comando -name $name_service -IncludeManagementTools
}
#Ejecutar comando en VM Windows
command_win(){
    echo "Has seleccionado introducir un comando en una máquina virtual WINDOWS"
    echo "Introduce grupo de recursos"
    read rg1
    echo "Introduce nombre de maquina virtual"
    read VM_NAME
    echo "Introduce comando/script"
    read comando
    az vm run-command invoke -g $rg1 -n $VM_NAME --command-id RunShellScript --scripts $comando
}
#INICIO / CABECERA
echo "
\__    ___/|  |_________   ____   ____   ____ |__|/  |_ ___.__.)/_____    __     __
  |    |   |  |  \_  __ \_/ __ \_/ __ \ /    \|  \   __<   |  |/  ___/   /_/|   |\_\   
  |    |   |   Y  \  | \/\  ___/\  ___/|   |  \  ||  |  \___  |\___ \     |U|___|U|        
  |____|   |___|  /__|    \___  >\___  >___|  /__||__|  / ____/____  >    |       |       
                \/            \/     \/     \/          \/         \/     | ,   , |           
_________ .__                   .___              .__  __                (  = Y =  )         
\_   ___ \|  |   ____  __ __  __| _/   ________ __|__|/  |_  ____         |   v   |         
/    \  \/|  |  /  _ \|  |  \/ __ |   /  ___/  |  \  \   __\/ __ \       /|       |\        
\     \___|  |_(  <_> )  |  / /_/ |   \___ \|  |  /  ||  | \  ___/       \| |   | |/          
 \______  /____/\____/|____/\____ |  /____  >____/|__||__|  \___  >     (_|_|___|_|_)        
        \/                       \/       \/                    \/    
                            ようこそ フリニチ ʕ•ᴥ•ʔ

                              "ビビディバビデブー"
                             おまじないみたいなもんさ                                                                         
"
echo "Qué te gustaría hacer?"
echo "❤︎ Resource Groups"
echo "1) Crear grupo de recursos"
echo "2) Borrar grupo de recursos"
echo "❤︎ Networking"
echo "3) Crear VLAN"
echo "4) Crear VLAN y su grupo de recursos"
echo "5) Crear subred"
echo "❤︎ Virtual Machines"
echo "6) Crear máquina virtual (con NIC)"
echo "7) Abrir puerto en máquina virtual"
echo "8) Ejecutar comando en VM Linux"
echo "9) Ejecutar comando en VM Windows"
echo "❤︎ Usa Ctrl + C para salir"
read case;
case $case in
    1) create_RG;;
    2) delete_RG;;
    3) create_single_vlan;;
    4) create_vlan_GR;;
    5) create_subred;;
    6) create_VM;;
    7) port_opener;;
    8) command_lin;;
    9) command_win;;
esac
echo "Quieres hacer algo más? [yes/no]"
read input
while [ $input = "yes" ]
do
echo "Qué te gustaría hacer?"
echo "❤︎ Resource Groups"
echo "1) Crear grupo de recursos"
echo "2) Borrar grupo de recursos"
echo "❤︎ Networking"
echo "3) Crear VLAN"
echo "4) Crear VLAN y su grupo de recursos"
echo "5) Crear subred"
echo "❤︎ Virtual Machines"
echo "6) Crear máquina virtual (con NIC)"
echo "7) Abrir puerto en máquina virtual"
echo "8) Ejecutar comando en VM Linux"
echo "9) Ejecutar comando en VM Windows"
echo "❤︎ Usa Ctrl + C para salir"
read case;
case $case in
    1) create_RG;;
    2) delete_RG;;
    3) create_single_vlan;;
    4) create_vlan_GR;;
    5) create_subred;;
    6) create_VM;;
    7) port_opener;;
    8) command_lin;;
    9) command_win;;
esac
echo "Quieres hacer algo más? [yes/no]"
read input
done