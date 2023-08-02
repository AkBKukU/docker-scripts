 # Nexcloud

 **OEM Docs:**
 - [Stock Compose](https://github.com/nextcloud/all-in-one/blob/main/compose.yaml)
 - [Rootless](https://github.com/nextcloud/all-in-one/blob/main/docker-rootless.md)
 - [Reverse Proxy](https://github.com/nextcloud/all-in-one/blob/main/reverse-proxy.md)

 NextCloud is mostly straightforward because it is a nested container
 that launches a bunch of it's own containers internally. I'm not exactly
 sure how you would do "proper" backups of some of its data, I'm going to
 go with making sure nothing in it is stored somewhere I can't access
 without the software running. I'm just treating it as a front end
 to my already existing data.

 When you first set up Nextcloud it will print a password made of a bunch
 of words, do future you a favor and email that to yourself the instant you
 see it. You won't be able to change it for a bit and getting it back won't
 be easy.


 ## Rootless Requirements

 It can run rootless without any issues including mounting local folders.
 Make sure to keep your perms set right though.

 ### Changes:

    environment:
      - WATCHTOWER_DOCKER_SOCKET_PATH=$XDG_RUNTIME_DIR/docker.sock
    volumes:
      $XDG_RUNTIME_DIR/docker.sock: /var/run/docker.sock:ro

*Note: for me $XDG_RUNTIME_DIR was not set and I just created an environment
variable with it set to what the terminal said it was for the docker user*

## Reverse Proxy Weridness

This software runs two web services, one is the actual NextCloud instance
and the other is the AIO controller. The standard port exposed is actually
for AIO. The real web interface and port are set with:

    environment:
      - APACHE_PORT=${MAP_PORT}
      - APACHE_IP_BINDING=${MAP_INTERFACE}

It's also pretty weird about the reverse proxy configuration. I've included
a sanitized version of my [NGINX conf file](./nextcloud-nginx.conf) that worked
for me.

## Sensible Configurations

There are some dumb defaults for nextcloud. Here are some things to change
when first setting it up:

### Public Share Talk

By default, publically shared files have conversation and call channels
available to them and *guest* accounts can join. Anyone with the link
can spam the server.

With an admin account change the following setting to disable this:
Administration Settings>Talk>Allow conversations on public shares for files

### External Storage

By default Nextcloud can only manage data created through its own means.
You can add external data sources to it to incorperate existing datasets.
While it can access local directories, I would advice against it as it
creates a file ownership isssue when writing new files. Using a network
share on the host to the Nextcloud server can map UID/GID more easily
to maintain proper file ownership.

You can enable external storage with an admin account here:
Apps>External storage support>Enable

## Issues

### Files missing from upload
There is some kind of problem that can happen when a large number of files are
added at once that can cause them not to be uploaded. I'm still not 100% what
the cause is, but I think it may be related to [this issue](https://github.com/nextcloud/desktop/issues/5094)
I have seen a process names `exe` on the server get stuck at high usage at
some points, but haven't seen it after changing the `config.php` file.

**WARNING**: *I changed this file **inside** the container and it will be
reset eventually. The AIO structure is weird and I'm not sure how to
bind this file out to preserve the change.*

### Always signed out on client launch

When launching the desktop client you are always signed out initially
and must re-auth. Apparently, the linux client [only uses a keyring](https://github.com/nextcloud/desktop/issues/2260#issuecomment-673332437)
for login storage.

I hate keyrings, I will be re-authing through the web.

### Reverse Proxy Addition

I lost the link to this one and removed it from my setup, but there may be
an additional `301` error and redirect URI you need to add to solve a
prblem with the clients. It didn't fix the issue I was having, but it may
help something else.
