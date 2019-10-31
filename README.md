# Docker time2backup server

# Build time2backup server
1. Download the latest version of [time2backup server](https://github.com/time2backup/server/releases).
2. Move the sources folder `time2backup-server` in the current directory.

# Server configuration
1. Create a file `config/ssh_keys` and put your clients SSH public keys inside
2. (optionnal) You can also create authentication file `config/auth.conf` to secure time2backup server access with couples `user:password` like this:
```
user1:password1
user2:password2
```

# Client configuration
1. Generate a SSH key: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_t2bserver`
2. Edit your SSH config file `~/.ssh/config` and add the following lines:
```
Host myt2bserver
   Hostname <HOSTNAME|IPADRESS>
   Port 9922
   User t2b
   IdentityFile ~/.ssh/id_t2bserver
```
3. Edit your time2backup client config `time2backup.conf` and set destination:
```
destination = ssh://myt2bserver
```
4. Copy your SSH public key and add it to the server config file `config/ssh_keys` (see above)
5. (optionnal) If you have set passwords to the server (see above), set it in your time2backup client config:
```
t2bserver_pwd = "<USER>:<PASSWORD>"
```

# Advanced server configuration
You can change some advanced server configuration:
- To change backup/config paths, ssh port or restart behaviour, edit `docker-compose.yml` file. You have to reinstall the server to make your changes work (see below).
- To set debug mode, sudo mode or other, edit `config/time2backup-server.conf` file. You have to restart the server to make your changes work (see below).

# Install and run time2backup server
## Using docker-compose
1. Build image: `docker-compose build`
2. Run server: `docker-compose up -d`

## Using docker command
1. Build image: `docker build -t time2backup/t2bserver .`
2. Run server: `docker run -d --env-file config.env --restart unless-stopped --name t2bserver -p 9922:22 -v /path/to/backups:/backups -v /path/to/config:/config time2backup/t2bserver`

# Start/Stop/Restart time2backup server
- Using docker-compose: `docker-compose start|stop|restart`
- Using docker command: `docker start|stop|restart t2bserver`

# Uninstall time2backup server
- Using docker-compose: `docker-compose down`
- Using docker command: `docker rm -f t2bserver`

## License
time2backup server is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for the full license text.

## Credits
Author: Jean Prunneaux https://jean.prunneaux.com

Source code: https://github.com/time2backup/docker-server
