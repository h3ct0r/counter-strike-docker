![Half-Life Logo](http://files.gamebanana.com/img/ico/sprays/51f5acee815f0.png)

# Docker image for Half-Life Dedicated Server (Counter Strike 1.6 + podbot + display_damage + maps)

### Build an image:

```
 $ git clone https://github.com/h3ct0r/counter-strike-docker
 $ make build
```

### Create a server token with your steam user

Login and create a token at:  https://steamcommunity.com/dev/managegameservers
This token is not *mandatory*, but using it will enable adding your server to the Steam server list so others can join and play without too much hazzle.

### Port forwarding (If going to play outside of your LAN using internet)

- **UDP/TCP 27015** - Main connection port (MUST). This is the port and protocol used by the server browser, allows clients to connect. TCP is used for in-game RCON
- **UDP 27020** - SourceTV (if enabled). You can disable this port by adding "-nohltv" to the start up command.
- **UDP 27005** - This is an outgoing connection used by clients. Typically you would not need to open this port in your firewall because this is for OUTBOUND connections.

### Create and start new Counter-Strike 1.6 server:

```
$ docker run -d -p 27005-27020:27005-27020/udp -p 27005-27020:27005-27020 -e MAXPLAYERS=16 -e START_MAP=de_dust2 -e ADMIN_STEAM={YOUR_STEAM_ID} -e SERVER_NAME="{YOUR_GAME_SERVER_NAME}" --name cs counter_strike_16:latest +sv_setsteamaccount {YOUR_SERVER_TOKEN} +sv_password {YOUR_GAME_PASSWORD} +rcon_password {YOUR_REMOTE_COMMAND_PASSWORD} +sv_lan 0
```

- **MAXPLAYERS** : maximum number of players for this game session.
- **START_MAP** : the map that will be used when game starts.
- **ADMIN_STEAM** : your steam_id. This setting will allow the user of the defined steam_id to control the server. The steam_id can be found using the comand `status` in the game console. Add this id without the 'STEAM_' part. Example: '0:1:22545666'.
- **SERVER_NAME** : the name of game the server displayed to the players.
- **+sv_setsteamaccount** : the token from the developer server account. This in theory allows this server to be displayed into the server list in Steam. It is recommended from the Steam tutorial, but dont know if this is obligatory.
- **+sv_password** : the password of your game session. The users will need to set this password to enter the game.
- **+rcon_password** : the remote administrator password for this game instance. The RCON command list can be seen in https://github.com/h3ct0r/counter-strike-docker/wiki/RCON-Commands
- **+sv_lan**: allow remote conections outside your LAN

### Stop the server:

```
 docker stop cs
```

### Start existing (stopped) server:

```
 docker start cs
```

### Remove the server:

```
 docker rm cs
```

### How clients can connect to this server?

From the Counter Strike console (press ')
```
connect 127.0.0.1:27015; password server_password
```

### PodBot administration

From the console (inside the game press ') set the environment variable _pbadminpw:

```
setinfo _pbadminpw "your_password"
```

Then activate the podbot menu:

```
pb menu
```

### Use image from [Docker Hub](https://hub.docker.com/r/h3ct0rxxx/counter_strike_16):

```
 $ docker run -d -p 27005-27020:27005-27020/udp -p 27005-27020:27005-27020 -e MAXPLAYERS=16 -e START_MAP=de_dust2 -e ADMIN_STEAM=YOUR_ADMIN_STEAM_ID -e SERVER_NAME="TEST SERVER DE_DUST2 ROLF" --name cs h3ct0rxxx/counter_strike_16:latest +sv_setsteamaccount YOUR_STEAM_TOKEN_ID +sv_password YOUR_GAME_PASSWORD +rcon_password YOUR_RCON_PASSWORD +sv_lan 0 +log 
```

### Todos

 - Write MORE Tests
 - Add more interesting plugins
 - Add sounds?!
 - Add fast server for game assets

License
----

Apache2


**Free Software, Hell Yeah!**
