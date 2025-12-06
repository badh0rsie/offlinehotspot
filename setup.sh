# Install packages
apt install docker-compose docker.io -y

# Create the directory structure for content
mkdir -p /media

# Mount the NAS
mkdir /mnt/vault
sudo mount -t cifs //vault/flats /mnt/vault -o username=andy

# Copy content from the NAS
sudo rsync -av --progress /mnt/vault/offline/media/ /media/

# Run Docker Compose
docker compose up -d

