# Docker Rootless Installation for Portainer

*Based on: https://www.portainer.io/blog/portainer-and-rootless-docker*

Setting up Docker without root can offer an additional small layer of protection
to container escape attacks by limiting the permissions of the user it runs 
under. Personally, I also like the way it makes it easier to manage container
data by moving it into an isolated space away from system files.

This document is a simplified set of steps to install rootless Docker and 
Portainer. It is going to be presented with the assumption you are not logged in
as root yourself on the host system.

## 1: Dependencies 

There are only two packages required before we start:

	sudo apt-get install uidmap curl

## 2: Docker User Creation

Create a user for rootless Docker to run as with sudo permissions:

	sudo adduser docker
	sudo usermod -aG sudo docker

Optionally, add your system user to the `docker` group for working with the 
files:

	sudo usermod -aG docker $USER

To continue setup you **must** now SSH to the new `docker` user or you will
encounter an [XDG_RUNTIME_DIR error](https://github.com/docker/docs/issues/14491):

	ssh docker@localhost

## 3: Rootless Docker Installation

As the `docker` user download, save, and run the installation script:

	wget https://get.docker.com/rootless  
 	sh rootless

The script should unpack all of the Docker files into the user's `~/bin` folder.
After running it will present you with lines to add to your `~/.bashrc` file,
if they are the same that I saw you can add them with these commands:

	echo "export PATH=/home/$USER/bin:\$PATH" >> ~/.bashrc
	echo "export DOCKER_HOST=unix:///run/user/$UID/docker.sock" >> ~/.bashrc

Enable support for ports less than 1024:

	sudo setcap cap_net_bind_service=ep $HOME/bin/rootlesskit

Set Docker to start as a `systemd` user service and set it to autostart:

	systemctl --user start docker
	systemctl --user enable docker
	sudo loginctl enable-linger $USER

Docker should now be running and can be verified by running  `docker info`.

## 4. Portainer Installation

Install Portainer as a docker service as the `docker` user:

	docker run -d -p 8000:8000 -p 9000:9000 --name=portainer \
	--restart=always -v /$XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock \
	-v ~/.local/share/docker/volumes:/var/lib/docker/volumes \
	-v portainer_data:/data portainer/portainer-ce

You should be able to access the web console on the local machine at 
[http://0.0.0.0:9000](http://0.0.0.0:9000)

With the level of access you have to the system and containers through Portainer
it would be inadvisable to publish it's port directly to an interface for
remote access. A simple option to manage it remotely is possible with `ssh` 
tunneling. The following command will create a temporary tunnel to your server
and allow you to view the Portainer web interface through an encrypted 
connection.

	ssh -L 9000:0.0.0.0:9000 $user_at_ip_of_server

You should then be able to access [http://0.0.0.0:9000](http://0.0.0.0:9000) on
your remote machine from a web browser.

When you are finished, just disconnect from the SSH session to close the tunnel.
