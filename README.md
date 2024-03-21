# MQTT-Stress-Test

1.	Procedere all’installazione del sistema operativo sulla Raspberry (o sul dispositivo che si utilizzerà per l’istanza di K3s). 
2.	Ricordare di abilitare il protocollo SSH, in quanto ne necessita per comunicare tramite altri dispositivi.
3.	Una volta installato, accedere alla raspberry tramite SSH e procedere a modificare alcune configurazioni. Nel file situato nella directory “/boot/cmdline.txt”, accedendo tramite “sudo nano /boot/cmdline.txt” inserire il testo alla fine del documento “cgroup_memory=1 cgroup_enable=memory”
4.	Avviare il kernel nella modalità 64-bit, andando nella directory “/boot/config.txt”, utilizzando il comando sopracitato ma cambiando la directory e modificando la parte di testo in “arm_64bit=1”. Salvare ed uscire.
5.	Modificare l’indirizzamento IP, andando nel file situato nella directory “/etc/dhcpcd.conf” e inserendo il seguente testo:

interface wlan0
static ip_address=10.0.0.100
static routers=10.0.0.1
static domain_name_servers=8.8.8.8


Ricordare di assegnare un indirizzo IP statico anche sul router.

6.	Installare le tavole IP (IP Tables), con i comandi “sudo iptables –F”. Nel caso il comando non viene riconosciuto bisogna installare il comando “iptables” con il comando “sudo apt install iptables” e successivamente avviare nuovamente il comando “sudo iptables –F” e successivamente “sudo update-alternatives –set ip6tables /usr/sbin/ip6tables-legacy”
7.	Cambiare l’hostname con il comando “sudo vi /etc/hostname”  e modificare l’hostname con quello desiderato e aggiungerlo anche nel comando “sudo vi /etc/host”. Aggiungere l’hostname desiderato in “localhost” e in basso, in fondo al documento dove c’è l’IP 127.0.1.1 
8.	Avviare l’aggiornamento con i comandi “sudo apt update && sudo apt upgrade” e attendere il completamento.
9.	Riavviare la raspberry in modo da rendere effettive le modifiche effettuate dall’aggiornamento.
10.	Disabilitare Swapoff con comando “ sudo swapoff –a”. Successivamente aprire il file “dphys-swapfile” andando nella directory e usando il comando “sudo nano /etc/dphys-swapfile” e modificare il testo “CONF_SWAPSIZE=0”. Salvare e uscire.
11.	Procedere all’installazione di k3s con il comando “curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable=traefik --write-kubeconfig-mode=644" sh -s - “
12.	Completata l’installazione, verificare la corretta esecuzione del Master Node Kubernetes con il comando “Kubectl get nodes” o “sudo k3s kubectl get node”
13.	Installare il broker MQTT “Mosquitto” con il comando “sudo apt-get install mosquitto”. Una volta installato possiamo verificare l’effettiva installazione e funzionamento con il comando “sudo service mosquitto status”. Se nella sezione “Active” troviamo in verde “Active, running” allora significa che il nostro broker MQTT funziona correttamente.
14.	Installare Grafana. Per prima cosa importiamo i pacchetti contenenti i file di installazione del     plugin, con i comandi “sudo mkdir -p /etc/apt/keyrings/” e il comando “wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null”. Successivamente importare la repository, la directory, di Grafana con il comando “echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list”. Ora possiamo procedere ad installare Grafana sul nostro dispositivo, utilizzando i comandi “sudo apt-get update” e “sudo apt-get install -y grafana”. 
Una volta completata l’installazione, procediamo ad abilitare il server Grafana con il comando “sudo /bin/systemctl enable grafana-server” e avviamolo con “sudo /bin/systemctl start grafana-server”. Per accedere alla GUI di Grafana, ora basta andare sul nostro browser, digitare l’indirizzo IP del nostro dispositivo, in questo caso della Raspberry e digitare “http://<ip address>:3000”

## CASO D'USO
Il caso di studio consiste nel simulare l’invio di un determinato numero di messaggi MQTT al nostro Nodo Kubernetes, che utilizzerà una versione “light” di Kubernetes, K3s. Così facendo, verrà valutata la resilienza e l’affidabilità di questo Nodo. Tutti i dati inviati dal simulatore (Nome simulatore) verranno poi analizzati e fatto un report dal plugin Telegraf. Così facendo, avremo modo di vedere l’efficienza di questo nodo Kubernetes in edge. L’hardware che utilizzeremo sarà una Raspberry Pi 4 Model B da 4GB di RAM. 

Hardware utilizzato: Raspberry Pi 4 – Memory Card da 16 GB.
 
Innanzitutto, andremo ad installare sulla Memory Card che utilizzeremo all’interno della Raspberry il sistema operativo, basato su Linux, chiamato Pi OS, sistema operativo dedicato alle Raspberry. Naturalmente diamo un nome “host” e una password alla nostra Raspberry e abilitiamo l’accesso tramite SSH, cosi da poterci collegare tramite terminale da altri dispositivi. Una volta completata l’installazione, procediamo a collegare la memory card alla Raspberry. Effettuiamo il primo accesso tramite SSH , utilizzando un qualunque terminale, in questo progetto verrà utilizzato Termius, accedendo con nome “host” e password che abbiamo assegnato precedentemente.

Ora avremo accesso alla nostra Raspberry, avremo questo testo su schermo: “nomedispositivo”@”nomeutente”:~ $

Una volta fatto l’accesso tramite SSH, procediamo subito ad apportare delle modifiche importanti. Innanzitutto andremo a modificare il file “cmdline.txt” presente nella cartella “boot” e aggiungendo alla fine del testo di questo documento la seguente stringa: 

cgroup_memory=1 cgroup_enable=memory

Salviamo e chiudiamo il file. Così facendo abiliteremo i “Cgroups”; essi rappresentano un elemento fondamentale del kernel che supporta la tecnologia di containerizzazione, consentendo ai processi di operare in isolamento con un insieme definito di risorse allocate per ciascuno di essi.
Successivamente andremo ad abilitare il kernel del dispositivo in modalità 64-bit. 
Andremo nel file “config.txt”, situato sempre nella cartella “boot” e andremo a modificare la parte di testo già esistente nel file “arm_64bit=” aggiungendo subito dopo il segno uguale, il numero 1.
Così facendo abiliteremo il kernel nella modalità 64-bit.
Passo successivo, sarà quello di assegnare al nostro dispositivo un indirizzamento IP statico nella nostra rete interna. Andremo a modificare il file “dhcpcd.conf” situato nella cartella “etc” e andremo a scrivere nel seguendo file:

interface lan0
static ip_address=192.168.1.70
static routers=192.168.1.254
static domain_name_servers=8.8.8.8

interface: sarà la nostra interfaccia con cui il nostro dispositivo sarà connesso alla rete, nel nostro caso è collegato via cavo quindi utilizzeremo “lan”.
Static ip address: Sarà l’indirizzo IP del nostro dispositivo sulla nostra rete.
Static routers: Sarà l’indirizzo IP del nostro router invece.
Static domain_name_servers: Sarà l’indirizzo del nostro server DNS, in questo caso utilizzeremo quello di Google.

Una volta completato, salviamo il file e chiudiamo.

Se si desidera, si può cambiare l’hostname con il comando “sudo vi /etc/hostname”  e modificare l’hostname con quello desiderato e aggiungerlo anche nel file seguente, utilizzando il comando “sudo vi /etc/host”. Aggiungere l’hostname desiderato in “localhost” e in basso, in fondo al documento dove c’è l’IP 127.0.1.1
Successivamente, andremo ad installare il comando “iptables” che ci servirà per assegnare i vari IP durante la fase di funzionamento del nostro Nodo. Useremo il comando “sudo install apt iptables”. Una volta completata l’installazione, andremo ad assegnare questa tavola degli indirizzi, con il comando “install iptables –F” e successivamente “sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy”.
Ora, procederemo ad aggiornare alcuni file che saranno importanti per il nostro progetto. Utilizzeremo il comando “sudo apt update && sudo apt upgrade” e attenderemo il completamento dell’aggiornamento.
Una volta completato quest’ultimo passaggio, riavvieremo la Raspberry per rendere effettive tutte le modifiche apportate dagli aggiornamenti effettuati, con il comando “sudo reboot”.

Ora avremo il sistema aggiornato. Ultimo passaggio prima dell’effettiva installazione del Master Node di Kubernetes è quello di disabilitare lo Swap.

Quando si installa Kubernetes su Linux, è consigliabile disattivare lo swap a causa del suo impatto sulla gestione delle risorse da parte di Kubernetes. Utilizzeremo il comando “sudo swapoff –a” e successivamente andremo a modificiare il file “dphys-swapfile” situato in “/etc/dphys-swapfile” e modificare il testo “CONF_SWAPSIZE=100”, sostituendo “100” con “0”. Salvare e uscire. 

Ora possiamo procedere ad installare il Master Node di Kubernetes, con il comando: 

“curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable=traefik --write-kubeconfig-mode=644" sh -s --“

Una volta completata l’installazione, si avvierà in automatico il server K3s. Per verificare la corretta esecuzione, basterà utilizzare il comando “Kubectl get nodes”.

Una volta completata l’installazione del nodo Kubernetes, procederemo ad installare i vari plugin che utilizzeremo. Iniziamo dal broker MQTT, Mosquitto. Utilizziamo il comando “sudo apt-get install mosquitto” per installare il nostro broker MQTT. Una volta installato possiamo verificare l’effettiva installazione e funzionamento con il comando “sudo service mosquitto status”. Se nella sezione “Active” troviamo in verde “Active, running” allora significa che il nostro broker MQTT funziona correttamente.


## TOOLS

- mosquitto
- telegraf
- timescaleDB
- grafana


### prerequisiti

Installazione Helm (versione >= 3.14.3) sulla macchina:
```
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
```