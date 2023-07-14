
# Notes
*I don't know what I'm doing, don't consider any of this to be good.*

## Rootless
*https://docs.docker.com/engine/security/rootless/*
Run docker rootless to further restrict container escaping attacks. The docker
user can also be responsible for managing volume data.

## Portainer
I don't really want to learn how to use Docker, so I'm going to be using 
Portainer to both do stuff for me and hand hold me through setup.

## Compose Scripts
Using compose scripts(portainer calls them "stacks", *\*groans\**), the 
configuration of the docker containers is saved. The idea is that the software 
is ephemeral and the directions to implement it have the real value. (*this is 
probably for one of those fancy load balancing things to start/stop containers
on a whim based on demand.*) If done correctly, this would also make updates
basically hot swapable by just changing out the container with the newer one.

## Volumes
If the software is ephemeral, then the data and configurations can't be kept 
with them. You "export" parts of the filesystem as "volume" outside of the 
container to preserve it. 

## Git, Portainer, ENV Files
The compose scripts have to contain passwords and other private type information
to configure the software for you. Putting those in a public git repo is,"A Bad
Idea TM", so as a work around portainer allows you to augment the compose 
scripts with an ENV file that contains more values you can add in. The ENV file
is intended to be loaded in beside the YML file with the compose script. This 
isn't an option for a publicly hosted repo. So the native ENV file support isn't
used, but a template file is provided. This file and be loaded manually into the
portainer GUI and accessed as normal variables from the compose script

You could also use docker secrets, but for me sucking at docker reasons, ENV 
files sound more appealing.
