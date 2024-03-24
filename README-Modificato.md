Guida installazione k3s sulla Raspberry utilizzata per il caso di studio.

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

N.B. In questo caso di studio, utilizzeremo la porta LAN integrata sul dispositivo, quindi utilizzeremo l'interfaccia "lan0" ma essendo che il dispositivo ha a disposizione anche un'interfaccia Wifi, si può utilizzare l'interfaccia "wlan0".

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
