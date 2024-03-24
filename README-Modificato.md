# CASO DI STUDIO

Il caso di studio consiste nel simulare l’invio di un determinato numero di messaggi MQTT al nostro Nodo Kubernetes, che utilizzerà una versione “light” di Kubernetes, K3s. Così facendo, verrà valutata la resilienza e l’affidabilità di questo Nodo. Tutti i dati inviati dal simulatore (Nome simulatore) verranno poi analizzati e fatto un report dal plugin Telegraf. Così facendo, avremo modo di vedere l’efficienza di questo nodo Kubernetes in edge. L’hardware che utilizzeremo sarà una Raspberry Pi 4 Model B da 4GB di RAM. 

Hardware utilizzato: Raspberry Pi 4 – Memory Card da 16 GB.
 
Innanzitutto, andremo ad installare sulla Memory Card che utilizzeremo all’interno della Raspberry il sistema operativo, basato su Linux, chiamato Pi OS, sistema operativo dedicato alle Raspberry. Naturalmente diamo un nome “host” e una password alla nostra Raspberry e abilitiamo l’accesso tramite SSH, cosi da poterci collegare tramite terminale da altri dispositivi. Una volta completata l’installazione, procediamo a collegare la memory card alla Raspberry. Effettuiamo il primo accesso tramite SSH , utilizzando un qualunque terminale, in questo progetto verrà utilizzato Termius, accedendo con nome “host” e password che abbiamo assegnato precedentemente.

Ora avremo accesso alla nostra Raspberry, avremo questo testo su schermo: “nomedispositivo”@”nomeutente”:~ $

Una volta fatto l’accesso tramite SSH, procediamo subito ad apportare delle modifiche importanti. Innanzitutto andremo a modificare il file “cmdline.txt” presente nella cartella “boot” e aggiungendo alla fine del testo di questo documento la seguente stringa: 
```
cgroup_memory=1 cgroup_enable=memory
```

Salviamo e chiudiamo il file. Così facendo abiliteremo i “Cgroups”; essi rappresentano un elemento fondamentale del kernel che supporta la tecnologia di containerizzazione, consentendo ai processi di operare in isolamento con un insieme definito di risorse allocate per ciascuno di essi.
Successivamente andremo ad abilitare il kernel del dispositivo in modalità 64-bit. 
Andremo nel file “config.txt”, situato sempre nella cartella “boot” e andremo a modificare la parte di testo già esistente nel file “arm_64bit=” aggiungendo subito dopo il segno uguale, il numero 1.
Così facendo abiliteremo il kernel nella modalità 64-bit.
Passo successivo, sarà quello di assegnare al nostro dispositivo un indirizzamento IP statico nella nostra rete interna. Andremo a modificare il file “dhcpcd.conf” situato nella cartella “etc” e andremo a scrivere nel seguendo file:
```
interface lan0
static ip_address=192.168.1.70
static routers=192.168.1.254
static domain_name_servers=8.8.8.8
```

interface: sarà la nostra interfaccia con cui il nostro dispositivo sarà connesso alla rete, nel nostro caso è collegato via cavo quindi utilizzeremo “lan”.
Static ip address: Sarà l’indirizzo IP del nostro dispositivo sulla nostra rete.
Static routers: Sarà l’indirizzo IP del nostro router invece.
Static domain_name_servers: Sarà l’indirizzo del nostro server DNS, in questo caso utilizzeremo quello di Google.

Una volta completato, salviamo il file e chiudiamo.

Se si desidera, si può cambiare l’hostname con il comando “sudo vi /etc/hostname”  e modificare l’hostname con quello desiderato e aggiungerlo anche nel file seguente, utilizzando il comando 
```
sudo vi /etc/host
```

Aggiungere l’hostname desiderato in “localhost” e in basso, in fondo al documento dove c’è l’IP 127.0.1.1
Successivamente, andremo ad installare il comando “iptables” che ci servirà per assegnare i vari IP durante la fase di funzionamento del nostro Nodo. Useremo il comando 
```
sudo install apt iptables
```

Una volta completata l’installazione, andremo ad assegnare questa tavola degli indirizzi, con il comando 
```
install iptables –F
```
e successivamente 
```
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
```

Ora, procederemo ad aggiornare alcuni file che saranno importanti per il nostro progetto. Utilizzeremo il comando 
```
sudo apt update && sudo apt upgrade
```
e attenderemo il completamento dell’aggiornamento.
Una volta completato quest’ultimo passaggio, riavvieremo la Raspberry per rendere effettive tutte le modifiche apportate dagli aggiornamenti effettuati, con il comando 
```
sudo reboot.
```

Ora avremo il sistema aggiornato. Ultimo passaggio prima dell’effettiva installazione del Master Node di Kubernetes è quello di disabilitare lo Swap.

Quando si installa Kubernetes su Linux, è consigliabile disattivare lo swap a causa del suo impatto sulla gestione delle risorse da parte di Kubernetes. Utilizzeremo il comando 
```
sudo swapoff –a
```
e successivamente andremo a modificare il file “dphys-swapfile” situato in “/etc/dphys-swapfile” e modificare il testo “CONF_SWAPSIZE=100”, sostituendo “100” con “0”. Salvare e uscire. 

Ora possiamo procedere ad installare il Master Node di Kubernetes, con il comando: 
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable=traefik --write-kubeconfig-mode=644" sh -s --
```

Una volta completata l’installazione, si avvierà in automatico il server K3s. Per verificare la corretta esecuzione, basterà utilizzare il comando 
```
kubectl get nodes
```

Una volta completata l’installazione del nodo Kubernetes, procederemo ad installare i vari plugin che utilizzeremo.

# GUIDA INSTALLAZIONE k3s SULLA RASPBERRY UTILIZZATA PER IL CASO DI STUDIO.

1. Effettuare l'installazione del sistema operativo sulla Raspberry, utilizzando il tool gratuito Raspberry Pi Imager offerto dal produttore del dispositivo.
2. Ricordarsi di abilitare il protocollo SSH, in quanto necessario per la comunicazione con altri dispositivi.
3. Dopo l'installazione, accedere alla Raspberry tramite SSH e apportare le seguenti modifiche di configurazione:
4. Aggiungere il testo 
```
cgroup_memory=1 cgroup_enable=memory
```
alla fine del file "/boot/cmdline.txt" utilizzando il comando 
```
sudo nano /boot/cmdline.txt.
```
5. Avviare il kernel in modalità 64-bit modificando il testo "arm_64bit=1" nel file "/boot/config.txt" mediante il comando sudo nano 
```
/boot/config.txt
```
6. Modificare l'indirizzamento IP inserendo il seguente testo nel file /etc/dhcpcd.conf:

```
interface lan0
static ip_address=10.0.0.100
static routers=10.0.0.1
static domain_name_servers=8.8.8.8
```
Assicurarsi di assegnare un indirizzo IP statico anche sul router.

### N.B. In questo caso di studio, utilizzeremo la porta LAN integrata sul dispositivo, quindi utilizzeremo l'interfaccia "lan0" ma essendo che il dispositivo ha a disposizione anche un'interfaccia Wifi, si può utilizzare l'interfaccia "wlan0".

7. Installare le tavole IP (IP Tables) con i comandi:
```
sudo iptables –F
sudo apt install iptables
sudo iptables –F
sudo update-alternatives –set ip6tables /usr/sbin/ip6tables-legacy
```

8. Cambiare l'hostname con i seguenti comandi:
```
sudo vi /etc/hostname
sudo vi /etc/hosts
```
Modificare l'hostname con quello desiderato e aggiungerlo anche nel file /etc/hosts.

9. Avviare l'aggiornamento del sistema operativo con i comandi:

```
sudo apt update && sudo apt upgrade
```

10. Riavviare la Raspberry per applicare le modifiche.

11. Disabilitare lo swap con il comando:
```
sudo swapoff –a
```

Aprire il file "/etc/dphys-swapfile" e modificare 
```
CONF_SWAPSIZE=0
```

12. Procedere con l'installazione di K3s eseguendo il comando:
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable=traefik --write-kubeconfig-mode=644" sh -s -
```

13. Verificare il corretto funzionamento del Master Node Kubernetes con il comando:
```
kubectl get nodes
```
oppure:
```
sudo k3s kubectl get node
```

Se eseguendo il comando, sono presenti nodi kubernetes attivi allora significa che i'installazione è andata a buon fine.
