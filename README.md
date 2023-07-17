# My Notes And Explorations On Docker
*I don't know what I'm doing, don't consider any of this to be good.*

This is a summary of my experience with setting up Docker containers for 
services I've ended up running. Different aspects of this will be broken out
into different documents based you can find here:

 - Main Concepts: [README.md](README.md)
 - Docker Rootless Installation: [INSTALL-DOCKER.md](INSTALL-DOCKER.md)
 - Reverse Proxy Hosting: [WIREGUARD-NGINX.md](WIREGUARD-NGINX.md)
 - Services:
 	 - MediaWiki: [README.md](mediawiki/README.md)

## Main Concepts for Docker

### Rootless - Security Layer
*https://docs.docker.com/engine/security/rootless/*
By default Docker runs as `root` on a linux system. While generally fine this 
leaves the small risk of high level privileges being available to a successful
container escape attack. Running "Docker Rootless" puts it in userspace and 
moves its `systemd` control to that user. Docker itself will not be installed 
system wide. These notes will be written assuming Docker Rootless is being used.

### Portainer - Management Interface
*https://www.portainer.io/*
A web GUI for managing deployment and configuration of Docker containers. Eases
some aspects such as importing configurations from a git repo (such as this one)
to make version tracking of different aspects more maintainable.

The GUI also gives console access to the containers making it a security risk
itself. But it makes it easier to maintain systems without remembering the long
argument strings the `docker` command needs to do the same.

### Images - How Software is Distributed
A core concept to Docker is the idea of software `images`, these are intended
to be isolated immutable implementations of a single software stack. They are
typically distributed based on the version of the primary application but will
also contain other supporting software. For example, the Portainer container
will also have an HTTP server and SQL database included with it so the 
primary application can start immediately.

The general idea is that you never need to modify the contents of an image when
running the software. This all abstracts you away from the particular instance 
of the software and makes updating plug-and-play, assuming no API changes. This 
also means the images and software within them should be treated not only as 
immutable, but ephemeral as well. 

### Compose Scripts - Configuration
The specific images being ephemeral means that any instance is unimportant, but
the instructions for *creating* that instance are important. Additionally, not
all images *should* contain all supporting software, and as such you need to 
make sure a container that needs a database has one when available when 
deploying it. **Compose Scripts** are the tool for handling all this.

You can pre-define the configuration of images, what dependencies are needed,
and how they interact. When a compose script is loaded the images are downloaded
and deployed automatically based on the already defined settings.

### Volumes - Permanent Storage
If the software images are ephemeral, then the data and software configurations 
can't be kept in the containers. You "export" parts of the virtual filesystem as
a **Volume** outside of the container to make it persistent and more accessible
for maintenance.

Volumes can either be managed by Docker or pointed to a specific location on the
host. Consider this example of a compose script:

	services:
	  imagehost:
	    image: website
	    volumes:
	      - /home/docker/services/imagehost/images:/var/www/html/images
	      - thumb:/var/www/html/thumbnails
	volumes:
	  thumb:

Here the `images` folder would be bound to a specific location in the filesystem
allowing for easy backups and management. The `thumbnails` folder would be 
stored in Dockers volume folder where it manages other container data. Both
would be persistent through a redeployment, but you would have less need to 
access or backup thumbnails and may be better off letting docker handle them.
Only volumes handled by Docker need to be declared in the `volumes:` section
of a compose script.

### Environment Variables - Private Configuration Data
The compose scripts have to contain passwords and other private type information
to configure the software for you. These are set as **Environment Variables**
when you define each service. These can be hard coded into the compose script
and examples will likely do this. But in practice you would create variable 
substitution points and set the values during deployment.

This is especially helpful when also publishing a compose script publicly 
somewhere like a git repo. And Portainer supports deploying directly from git.
It also has an option to load a file of environment variables when deploying
that makes it easy to substitute in private config data.

