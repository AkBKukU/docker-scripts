# Reverse Proxy Over Wireguard with NGINX

Using an inexpensive VPS you can mask an IP to a more powerful server in a 
location you cannot or do not want to expose to the public internet. One method
for this is creating a Wireguard VPN connection and reverse proxying HTTP 
traffic with NGINX. This setup would allow you to do something like host a
web site from a residential internet connection with an abusive ISP that blocks
ports like 80 and 443.

The setups here are more of a guideline for setting this up as it will depend on
your setup for how you want to expose your system and route your sites. This
will be an example using distinct domains routed to distinct ports. For the 
purposes of documentation, the public facing system will be called the 
`Proxy Server` and the VPN tunneled system the `Content Server`.

## Connecting Systems with Wireguard

These steps will establish a VPN interface for the `Proxy Server` and `Content
Server` to communicate through. No additional features are added such as 
internet proxying. The IP of the `Content Server` will not be restricted in the
event that it looses reservation and it changes.

Before beginning, ensure Wireguard is installed on both systems:

	sudo apt install wireguard


### 1: Create Keys

Each system will need a public and private key. These do not technically need to
be stored as files, but you may wish to for recreating the connection later if 
needed. To generate them, for now I'm going to assume you are working in an 
empty directory (eg `~/wg/`) and will save the keys there.

Keys will look something like this as an example:
	
	GP1TPTUfOq531BJ4IH9dWv8uzNdSr8YKnca0Dy6aK0Y=

Create and save your keys by running the following command on both systems:

	wg genkey | tee privatekey | wg pubkey > publickey

### 2: Setup Proxy Server Endpoint Interface

On the `Proxy Server` create a file in `/etc/wiregaurd/` for the interface. It
is convention to name the files `wg#.conf` with a number for identification, 
but any filename ending in `.conf` is acceptable. We'll use `wg1.conf` here.

At this point you should decide on the IPs for the VPN connection you want to 
use. Something like `10.0.100.1` and `10.0.100.2` would be acceptable and will
be used here.

Setup the interface in the file (`/etc/wireguard/wg1.conf`) as such:

	[interface]
	# Proxy Server
	Address = 10.0.100.1/24
	ListenPort = 51820
	PrivateKey = $PROXY_SERVER_PRIVATEKEY
	SaveConfig = true

	[Peer]
	# Content Server
	PublicKey = $CONTENT_SERVER_PUBLICKEY
	AllowedIPs = 10.0.100.2/32

*Note: you may change the port if desired*

You can now bring up the interface with:

	sudo wg-quick up wg1

You can see that it is running with

	sudo wg


### 3: Setup Content Server Interface

Create another interface file on the `Content Server` in `/etc/wireguard/`. The
names do not need to match but it may be helpful for maintenance.

When setting up the connection details for the `Proxy Server` you will need to
provide an IP or domain name to reach it at. 

Setup the interface in the file (`/etc/wireguard/wg1.conf`) as such:

	[Interface]
	# Content Server
	Address = 10.0.100.2/24
	PrivateKey = $CONTENT_SERVER_PRIVATEKEY

	[Peer]
	# Proxy Server
	PublicKey = $PROXY_SERVER_PUBLICKEY
	Endpoint = $PROXY_SERVER_IP:51820
	AllowedIPs = 10.0.100.1/32
	PersistentKeepalive = 21

You can now bring up the interface like before with:

	sudo wg-quick up wg1

You can verify the connection by attempting to ping the `Proxy Server` with its
Wireguard interface IP.

	ping 10.0.100.1


### 4: Make Persistent

Once you have confirmed the connection works you can make it persistent and
autostart by running this on both systems:

	sudo systemctl enable wg-quick@wg1.service


## NGINX Reverse Proxy

Now that you have a VPN IP you can redirect to, you can setup NGINX on the 
`Proxy Server`to forward traffic through it back to your `Content Server`.

To make this easier to set up, this example is assuming your are pointing the
domain `example.com` at the IP of your `Proxy Server` and you are running an
HTTP server on port `8080` on your `Content Server`

Once you have your domain and port, you can create virtual host file in 
`/etc/nginx/sites-available/` for your site using the following as a template:

	server {
	    server_name example.com;
	    listen [::]:80;
	    listen 80;

	    location / {
		proxy_pass http://10.0.100.2:8080/;
		proxy_redirect off;
		proxy_set_header Host $host;
	    }
	}

Symlink with `ln -s` this new file from `/etc/nginx/sites-available/` to 
`/etc/nginx/sites-enabled/` so NGINX will start the proxy. Then reload NGINX to 
make it active:

	sudo systemctl reload nginx.service

You should now see your web page from the `Content Server` when you browse to 
your domain. The virtual host file you made can also be modified by 
`letsencrypt` automatically to provide SSL over port 443 as well.


## Bonus: Docker Port Mapping

When setting up a Docker compose script you can specify an IP for an interface
on the system to receive traffic through wen mapping ports. For the above 
example the `Content Server` could be running a Docker container with this port
mapping:

    ports:
      - "10.0.100.2:8080:80"

This would make the container's web server running on port 80 available over
port 8080 on the Wireguard interface. This lets you redirect from the `Proxy
Server` directly into Docker containers.
