#need a lot of swap to load quantize models on cpu memory
sudo swapoff /swapfile
sudo fallocate -l 48G /swapfile
sudo mkswap /swapfile
sudo mkswap /swapfile
echo free -h

