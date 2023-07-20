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
