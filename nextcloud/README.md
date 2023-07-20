 # Nexcloud

 - [Stock Compose](https://github.com/nextcloud/all-in-one/blob/main/compose.yaml)
 - [Rootless](https://github.com/nextcloud/all-in-one/blob/main/docker-rootless.md)


 ## Rootless Requirements

 #### Changes:

    environment:
      WATCHTOWER_DOCKER_SOCKET_PATH=$XDG_RUNTIME_DIR/docker.sock
    volumes:
      $XDG_RUNTIME_DIR/docker.sock: /var/run/docker.sock:ro
