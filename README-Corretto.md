# CASO DI STUDIO

Hardware utilizzato: Raspberry Pi 4 – Memory Card da 16 GB.

Il caso di studio consiste nel simulare l’invio di un determinato numero di messaggi MQTT al nostro Nodo Kubernetes, che utilizzerà una versione “light” di Kubernetes, K3s. Così facendo, verrà valutata la resilienza e l’affidabilità di questo Nodo. Tutti i dati inviati dal simulatore verranno poi analizzati e fatto un report dal plugin Telegraf. Avremo modo così, di vedere l’efficienza di questo nodo Kubernetes in edge. L’hardware che utilizzeremo sarà una Raspberry Pi 4 Model B da 4GB di RAM. 

Innanzitutto, andremo ad installare sulla Memory Card che utilizzeremo all’interno della Raspberry il sistema operativo, basato su Linux, chiamato Pi OS, sistema operativo dedicato alle Raspberry, utilizzando il tool gratuito distribuito dal produttore del dispositivo. Naturalmente diamo un nome “host” e una password alla nostra Raspberry e abilitiamo l’accesso tramite SSH, cosi da poterci collegare tramite terminale da altri dispositivi. Una volta completata l’installazione, procediamo a collegare la memory card alla Raspberry. Effettuiamo il primo accesso tramite SSH , utilizzando un qualunque terminale, in questo progetto verrà utilizzato Termius, accedendo con nome “host” e password che abbiamo assegnato precedentemente.

Ora avremo accesso alla nostra Raspberry, avremo questo testo su schermo: “nomedispositivo”@”nomeutente”:~ $

Una volta fatto l’accesso tramite SSH, procediamo subito ad apportare delle modifiche importanti. Innanzitutto andremo a modificare il file **“cmdline.txt”** presente nella cartella “boot” e aggiungendo alla fine del testo di questo documento la seguente stringa: 
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

Come primo e più importante, andremo ad installare Helm, prerequisito importante per il funzionamento del nostro Nodo. Helm è uno strumento open-source per la gestione dei pacchetti e il deployment delle applicazioni Kubernetes. Consente di definire, installare e aggiornare facilmente le applicazioni Kubernetes utilizzando modelli chiamati "charts". I charts sono pacchetti preconfigurati contenenti tutte le risorse necessarie per eseguire un'applicazione su Kubernetes, inclusi deployment, service, ingress e altre risorse Kubernetes.

Utilizzeremo il comando:
```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

Completata l'installazione di Helm, procediamo al prossimo prerequisito, Influxdb.

InfluxDB è un database specializzato progettato per gestire dati di serie temporali in modo efficiente e scalabile. È ottimizzato per la raccolta, la memorizzazione e l'analisi di dati temporali ad alta frequenza, come metriche di monitoraggio, dati IoT e registrazioni di eventi. Le sue caratteristiche principali includono la scalabilità orizzontale, un linguaggio di query intuitivo, il supporto per il clustering e l'integrazione con altri strumenti di monitoraggio e automazione.

### installazione 

Avvieremo il comando di installazione dello script del database, entrando innanzitutto nella directory **"deployments/influxdb"** e avviando il comando:
``` 
    ./install.sh
```

Lo script installerà semplicemente un namespace che si chiamerà, appunto, "influxdb" e poi tramite il prerequisito precedentemente installato, Helm, andrà ad installare sul nostro sistema tutti i file e componenti necessari per il funzionamento del tool.


Completata l'installazione, procediamo al prossimo plugin.


### Ora andremo ad installare Grafana, dashboard per la visualizzazione dei dati raccolti.

Avvieremo i seguenti comandi: 

Creiamo la directory di installazione con:
```
     sudo mkdir -p /etc/apt/keyrings/
```
Importiamo il pacchetto di installazione del plugin con:
```
     wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
```
Importiamo la repository di Grafana con:
```
     echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
```
Aggiorniamo il sistema e installiamo Grafana con:
```
     sudo apt-get update
     sudo apt-get install -y grafana
```
Abilitiamo e avviamo il server Grafana con:
```
     sudo /bin/systemctl enable grafana-server
     sudo /bin/systemctl start grafana-server 
```

Verificare il corretto funzionamento aprendo il proprio browser, digitando "<ipaddress>:3000"
<ipaddress> sarebbe l'indirizzo IP che assume il dispositivo sulla rete.


Ora procederemo ad installare Mosquitto, broker MQTT che utilizzeremo per il caso di studio.

Andremo nella cartella presente sulla nostra Raspberry *deployments/mosquitto* e avviaremo il comando di installazione dello script:

```
./install.sh
```

Nel caso eseguendo i comandi vengono restituiti degli errori riguardanti dei permessi negati, avviare il comando per abilitarli:

```
sudo chmod +x ./install.sh
```

Anche in questo caso, lo script andrà ad installare un namespace che si chiamerà "mosquitto" e i file e i componenti necessari al funzionamento del nostro Tool.

Completata l'installazione, avremo installo il nostro broker MQTT.


Ora andremo a configurare la dashboard di Grafana, con il nostro broker MQTT.

Ci collegheremo all'interfaccia grafica di Grafana, raggiungibile tramite browser inserendo l'indirizzo IP della nostra Raspberry, nel nostro caso *192.168.1.70* seguito dalla porta di Grafana, cioè ":3000* .

Dopo aver configurato i dati di accesso di Grafana, la prima volta che ci collegheremo all'interfaccia, procederemo a creare la dashboard.

In alto cliccheremo sulla + e faremo click su "new dashboard", "add visualization", "configure a new data sources", "add new connection" e ricercheremo nel campo di ricerca "MQTT" e clicchiamo su di esso. Procediamo ad installare e ora possiamo ritornare alla schermata "add visualization" dove ora, nella lista dei "data sources" troveremo MQTT. Clicchiamo su di esso e procederemo a configurarlo.

Come indirizzo IP, applicheremo l'indirizzo del nostro k3s, che nel nostro caso è "10.42.0.90", che potremmo reperirlo tramite k9s, accessibile da terminale.
Mentre come porta di comunicazione, applicheremo la porta 8883 che è la porta di comunicazione di Mosquitto protetto da TLS.

Quindi il campo Indirizzo IP sarà: 10.42.0.90:8883.

Come "username" e "password" utilizzeremo quelli per accedere alla nostra Raspberry da terminale.

Inseriti i dati, faremo click su *"save e test"* e se i dati sono corretti, Grafana ci restituirà un messaggio di conferma.





# COMANDI UTILIZZATI PER L'INSTALLAZIONE

## Cgroups:
```
cgroup_memory=1 cgroup_enable=memory
```


## Abilitazione kernel in modalità 64-bit 
```
arm_64bit=1
```
## Modificare l'indirizzamento IP:


```
interface lan0
static ip_address=192.168.1.70
static routers=192.168.1.254
static domain_name_servers=8.8.8.8
```


## Installazione IP Tables:
```
sudo iptables –F
sudo apt install iptables
sudo iptables –F
sudo update-alternatives –set ip6tables /usr/sbin/ip6tables-legacy
```


## Cambio hostname:
```
sudo vi /etc/hostname
sudo vi /etc/hosts
```


## Aggiornamento del sistema operativo:

```
sudo apt update && sudo apt upgrade
```


## Riavvio della Raspberry per applicare le modifiche:
```
sudo reboot
```


## Disabilitazione swap:
```
sudo swapoff –a
```
Aprire il file "/etc/dphys-swapfile" e modificare 
```
CONF_SWAPSIZE=0
```


## Installazione K3s:
```
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable=traefik --write-kubeconfig-mode=644" sh -s -
```


## Verificare il corretto funzionamento del Master Node Kubernetes:
```
kubectl get nodes
```
oppure:
```
sudo k3s kubectl get node
```

# TOOLS

- Mosquitto
- Telegraf
- InfluxDB
- Grafana


## Prerequisiti

Installazione Helm (versione >= 3.14.3) sulla macchina:
```
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
```

## INSTALLAZIONE K9S

Dalla Raspberry, tramite terminale scarichiamo il file binario K9s per l'architettura ARM eseguendo il comando:
```
    wget https://github.com/derailed/k9s/releases/download/v0.32.4/k9s_Linux_arm64.tar.gz
```

Dopo aver scaricato il file tar.gz, estrailo utilizzando il comando:
Questo comando decomprimerà il file estraendone il contenuto nella directory corrente.
```
   tar -xzvf k9s_Linux_arm64.tar.gz
```

Successivamente sposteremo il binario K9s in una directory appropriata del sistema. Nel nostro caso, la sposteremo nella directory "/usr/local/bin", eseguendo il comando:
```
   sudo mv k9s /usr/local/bin/
```

Potrebbe essere necessario aggiungere i permessi di esecuzione al binario K9s. Possiamo farlo con il comando:
```
   sudo chmod +x /usr/local/bin/k9s
```

Ora che K9s è installato, possiamo avviarlo eseguendo il comando:
```
    k9s
```


### Grafana

Installare su Raspberry esterna al cluster come dashboard di monitoraggio.
```
     sudo mkdir -p /etc/apt/keyrings/

     wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

     echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

     sudo apt-get update

     sudo apt-get install -y grafana

     sudo /bin/systemctl enable grafana-server

     sudo /bin/systemctl start grafana-server
 
``` 
Verificare il corretto funzionamento aprendo il proprio browser, digitando "< ipaddress >:3000"
< ipaddress > sarebbe l'indirizzo IP che assume il dispositivo sulla rete.


### InfluxDB

Database noSQL timeseries. Entrare nella cartella *deployments/influxdb* ed eseguire i seguenti comandi:

Install command
``` 
    ./install.sh
```
Uninstall command
``` 
    ./install.sh rm
```

### MQTT Mosquitto

Open source MQTT broker. Progettato per il protocollo MQTT, un protocollo di messaggistica leggero per piccoli sensori e dispositivi mobili. Entrare nella cartella *deployments/mosquitto* presente nella nostra Raspberry, e avviare i seguenti comandi.

Per installare:

```
    ./install.sh
```

Per disinstallare:

```
    ./install.sh rm
```

N.B. Nel caso eseguendo i comandi vengono restituiti degli errori riguardanti dei permessi negati, avviare il comando per abilitare i permessi:

```
sudo chmod +x ./install.sh
```


# Fine
