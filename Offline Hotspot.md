Offline Hotspot is a portable, low power personal server designed for offline and emergency scenarios. It consists of a Raspberry Pi 5, 1TB SD card, and a custom 3D printed enclosure. It's entirely self-contained and needs no Internet access. It runs its own wifi access point and exposes the following applications through your browser:

- **Wikipedia**: A snapshot of the entirety of Wikipedia from August 2025
- **Open Street Maps:** World maps as of November 2025
- **Audiobookshelf**: A collection of podcasts and audiobooks
- **Emby**: A collection of movies
- **Kiwix**: An archive of websites related to software development, prepping, medicine, and self-sufficiency.  
- Stash: For... videos.

**How to Use**
- Connect the USB-C port to power and wait 2 minutes for it to boot
- From a phone, tablet, or computer, join the "Offline Hotspot" wifi network.
- Open a browser and navigate to http://192.168.1.235. (Alternatively, there is an RFID chip on the device, which you can scan with your phone.)

**How to Update**
- **OS and App updates:** You'll need the Ethernet to be connected to your network. Then, SSH in. Run update.sh to update the OS, firmware, and packages. All apps are Dockerized. Edit /root/docker-compose.yml and then rerun Docker with the command: "docker compose up -d"
- **AudioBooks**: Add media under /media/audiobooks/
- **Homepage:** See the docs for GetHomepage. Configs are located under /root/homepage.
- **Kiwix**: You can add additional zim files under /media/zim.
- **Maps**: You can get updated .mbtiles from openfreemap.org. On their Github page (https://github.com/hyperknot/openfreemap), look for instructions under the "Full Planet Downloads" section. Place the .mbfiles under /media/maps/.
- **Movies:** Copy kids movies to /media/movies/kids/. Copy standup shows to /media/movies/comedy/. Otherwise, copy movies to /media/movies/movies/. Then in Emby, click the gear icon -> Library -> Scan Library Files to rebuild the index.
- **Stash**: Add media under /media/x/media/
