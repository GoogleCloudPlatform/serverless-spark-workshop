# About

This module will focus on setting up VM and install docker to be ready for making an image. 
<br><br>
                                   

#### 1. Setting up VM
Navigate to compute engine > VM instances. 
Select **CREATE INSTANCE**.
<kbd>
<img src=../images/compute_engine.png />
</kbd>

#### 2. Create VM
Feel free to give a name and change region/zone if need.
<br>
<kbd>
<img src=../images/vm_name.png />
</kbd>
<br><br>

We do want to increase the VM boot size. Select **CHANGE**
<br>
<kbd>
<img src=../images/boot_disk.png />
</kbd>
<br><br>

Next, we want to increase the size into 20 GB since making an image require huge memory space. Feel free to increase the size if you ran into the memory space issue. 
<br>
<kbd>
<img src=../images/increase_size_boot_disk.png />
</kbd>
<br><br>

Select the compute engine service account default or use other service account if need. Then, process to create VM
<br>
<kbd>
<img src=../images/vm_service_account.png />
</kbd>


#### 3. Connect to VM
Click SSH on the vm that you just made
<br>
<kbd>
<img src=../images/select_ssh.png />
</kbd>

#### 3. Installing package for docker inside VM
Since VM is a fresh state. We need to install package to be able to use docker.

## 1. Install docker package
In VM, need to install docker. Source: https://www.pascallandau.com/blog/gcp-compute-instance-vm-docker/#installing-docker-and-docker-compose
```
# install required tools
sudo apt-get update -yq && apt-get install -yq \
     ca-certificates \
     curl \
     gnupg \
     lsb-release

# add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# set up the stable repository
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
 $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install Docker Engine
sudo apt-get update -yq && sudo apt-get install -yq \
     docker-ce \
     docker-ce-cli \
     containerd.io \
     docker-compose-plugin
```

## 2. Get authority to use docker
Type this code to get authority to use docker. 
<br>

```
gcloud auth login
```
<br>
Create the docker group
<br>

```
sudo groupadd docker
```
<br>
Add your user to the docker group
<br>

```
sudo usermod -aG docker ${USER}
```
<br>
You will need to log out and log back in so that the group member will be re-evaluted or type this command. 
<br>

```
su -s ${USER}
```

## 3. Run docker
Verify that you can run docker command without sudo (feel free to run a different name)
<br>

```
docker run hello-world
```
