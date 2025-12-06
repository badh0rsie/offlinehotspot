
# OS Setup and Access Point Configuration
## Prerequisites

- Either network boot your Raspberry Pi 5 (hold shift) or run Raspberry Pi Imager on another machine. Install Raspberry Pi OS (Other)  -> Raspberry Pi Lite (64-bit) to your SD card or SSD.
- Boot. Optionally modify /etc/ssh/sshd_config to enable remote login from root

```
PermitRootLogin yes
PasswordAuthentication yes
```

## Step 1: Install Required Packages

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install hostapd dnsmasq -y
```

Stop the services while we configure them:
```bash
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
```


## Step 2: Unblock Wifi
Unblock wifi. Then setup a systemd service to unblock on boot.
```
sudo rfkill unblock wifi
sudo nano /etc/systemd/system/rfkill-unblock.service
```

```
[Unit]
Description=Unblock WiFi at boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/rfkill unblock all

[Install]
WantedBy=multi-user.target
```

```
sudo systemctl enable rfkill-unblock.service
```



## Step 3: Configure Static IP for wlan0

Edit the dhcpcd configuration:
````bash
sudo nano /etc/dhcpcd.conf
```

Add these lines at the end:
```
interface wlan0
    static ip_address=10.0.0.1/24
    nohook wpa_supplicant

interface eth0
    static ip_address=192.168.1.235/24
````

## Step 3: Configure dnsmasq

Backup the original configuration:
```bash
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```

Create a new configuration:
````bash
sudo nano /etc/dnsmasq.conf
```

Add the following:
```
interface=wlan0
dhcp-range=10.0.0.10,10.0.0.200,255.255.255.0,24h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
address=/#/10.0.0.1
````

## Step 4: Configure HostAPD

Create the hostapd configuration:
```
sudo nano /etc/hostapd/hostapd.conf


interface=wlan0
driver=nl80211
ssid=OfflineHotspot
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
````

Tell the system where to find the configuration:

````bash
sudo sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd
````

### Step 5: Unblock Wifi; Turn off Power Saving; Enable IP forwarding

````bash
sudo nano /etc/rc.local


#!/bin/bash
rfkill unblock wifi 
iw dev wlan0 set power_save off
ip addr add 10.0.0.1/24 dev wlan0
ip link set wlan0 up
sysctl -w net.ipv4.ip_forward=1

sudo sysctl -w net.ipv4.conf.all.rp_filter=0 
sudo sysctl -w net.ipv4.conf.eth0.rp_filter=0 
sudo sysctl -w net.ipv4.conf.wlan0.rp_filter=0

nmcli connection modify "Wired connection 1" ipv4.method manual
nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.1.235/24
nmcli connection modify "Wired connection 1" ipv4.gateway ""
nmcli connection modify "Wired connection 1" ipv4.dns ""
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
````

```
chmod +x /etc/rc.local
systemctl restart rc-local.service
systemctl status rc-local.service
```

## Step 7: Enable and Start Services

Enable services to start on boot:
```bash
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
```

## Step 8: Reboot
Reboot to apply all changes:
```bash
sudo reboot
```

## Verification
A bunch of commands to help validate that everything is working:
```
rfkill

ip addr show wlan0
ip addr show eth0
iw dev wlan0 info

# The wifi connection is not managed by Network Manager. It's expected that 
# there won't be a wifi connection and it'll be listed as disabled.
nmcli device status
nmcli device show
nmcli connection show
nmcli general

sudo systemctl status hostapd
journalctl -u hostapd -n 50

sudo systemctl status dnsmasq
journalctl -u dnsmasq -n 50
sudo ss -ulpn | grep dnsmasq
```




# Application Setup

```bash
cd ~/

# Pull down the scripts
git clone https://www.github.com/badh0rsie/offlinehotspot.git
cd offlinehotspot/

# Create the directory structure for content
mkdir /media
mkdir /media/movies
mkdir /media/maps
mkdir /media/audiobooks

# Mount the NAS
mkdir /mnt/vault

# Copy content from the NAS
# rsync

# Run Docker Compose
apt install docker-compose docker.io -y
docker compose up -d
```

