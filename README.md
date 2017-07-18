# CubeEngine Forge Docker Image

- [Available on Docker-Hub](https://hub.docker.com/r/cubeengine/forge/)
- [Available on GitHub](https://github.com/CubeEngine/docker)

The docker image `cubeengine/forge` sets up a forge minecraft server containing the [sponge forge](https://www.spongepowered.org/) together with [CubeEngine](http://cubeengine.org/) mods. This allows you to play with friends or strangers and gives you a powerful set of tools.

This documentation only describes how to set up the docker container. Have a look at the related GitHub projects to get more details about the actual functionality: 

- [MinecraftForge](https://github.com/MinecraftForge/MinecraftForge)
- [SpongeAPI](https://github.com/SpongePowered/SpongeAPI)
- [CubeEngine Docs](http://cubeengine.org/)
- [CubeEngine Core](https://github.com/CubeEngine/core)
- [CubeEngine Main Modules](https://github.com/CubeEngine/modules-main)
- [CubeEngine Extra Modules](https://github.com/CubeEngine/modules-extra)

## Volumes

To persist the data you must mount a few volumes which are listed below:

- `/home/minecraft/server/root` - This directory only contains the files `banned-ips.json`, `banned-players.json`, `ops.json` and `whitelist.json` of the server root directory.
- `/home/minecraft/server/world` - This directory stores the heart of the server - the minecraft world(s).
- `/home/minecraft/server/config` - Here are the configuration files. You might edit them to set up your server correctly.
- `/home/minecraft/server/logs` - This directory contains the server logs.
- `/home/minecraft/server/mods` - This directory is your space to store any additional forge or sponge mods.

If you're using linux, you might struggle with accessing the files. By default the container uses a user with the user-id 4928 which was picked randomly. If you want to access the files, you should start the container with your own user- and/or group-id. Furthermore you must pay attention that the directories at your side - the mount endpoints - have the correct access rights two. If the directories don't exists already, docker will create it with root as owner and nobody can write to it. Therefore the container will result in an unstable state.
If you're using windows, you should have any trouble. 

## Environment Variables

The container can be configured using environment variables. There are some variables which can be set for the image build process. They will be ignored at this point. This part only contains a description of the variables configuring the container.

One important mention is the `JAVA_VM_ARGS` environment variable. This helps you to specify additional arguments for the java process. By default it doesn't contain something. As a suggestion I advice you to set the Xmx variable, the maximum size of the memory allocation pool at least 1G or 2G. For this just write `JAVA_VM_ARGS=-Xmx2G`

### Choose Mods

By default the container will be started with every registered CubeEngine-Plugin. But actually you don't need all of them. To only start the server with a selection of plugins, you can specify the `CE_PLUGINS` environment variable. The value is only a list of lowercased plugin names which are separated with whitespace. For example `CE_PLUGINS="vanillaplus fun roles"`.

Get the names of the plugins together with additional information from the official [CubeEngine Documentation](http://cubeengine.org/).

### Server Properties

You might have noticed that the root-volume doesn't contain the `server.properties` file. This file doesn't need to be persisted because it can be set up using environment variables. Below you'll find a list of the environment variable names. A description of them, supported values and default behaviours can be found on the [minecraft gamepedia site](http://minecraft.gamepedia.com/Server.properties).

- ALLOW_FLIGHT
- ALLOW_NETHER
- ANNOUNCE_PLAYER_ACHIEVEMENTS
- DIFFICULTY
- ENABLE_QUERY
- ENABLE_RCON
- ENABLE_COMMAND_BLOCK
- FORCE_GAMEMODE
- GAMEMODE
- GENERATE_STRUCTURES
- GENERATOR_SETTINGS
- HARDCORE
- LEVEL_NAME
- LEVEL_SEED
- LEVEL_TYPE
- MAX_BUILD_HEIGHT
- MAX_PLAYERS
- MAX_TICK_TIME
- MAX_WORLD_SIZE
- MOTD
- NETWORK_COMPRESSION_THRESHOLD
- ONLINE_MODE
- OP_PERMISSION_LEVEL
- PLAYER_IDLE_TIMEOUT
- PVP
- RCON_PASSWORD
- RESOURCE_PACK
- RESOURCE_PACK_HASH
- SNOOPER_ENABLED
- SPAWN_ANIMALS
- SPAWN_MONSTERS
- SPAWN_NPCS
- SPAWN_PROTECTION
- VIEW_DISTANCE
- WHITE_LIST

### Database

Some of the CubeEngine plugins need a database connection. The database can be set up with the following variables. The list also shows the default values.

- `DB_HOST=localhost` - The host of the database
- `DB_PORT=3306` - The port of the database
- `DB_USER=minecraft` - The database user
- `DB_PASSWORD=""` - The users password
- `DB_NAME=minecraft` - The name of the database
- `DB_TABLE_PREFIX=cube_` - The table prefix of the tables within the database
- `DB_LOG_DATABASE_QUERIES=false` - Whether database queries shall be logged

Note that the database config will be persisted with the config directory. Therefore the database config will only be created if it doesn't exist. So if you change the database connection values, don't forget the delete the configuration file `/home/minecraft/server/config/cubeengine/database.yml`. Otherwise it won't be regenerated.

### MongoDB

The bigdata plugin of CubeEngine needs a mongodb connection. The database can be set up with the following variables. The list also shows the default values.

- `MONGO_DB_HOST=localhost` - The host of the mongo database
- `MONGO_DB_PORT=27017` - The port of the mongo database 
- `MONGO_DB_USER=minecraft` - The database user
- `MONGO_DB_PASSWORD=""` - The users password
- `MONGO_DB_NAME=cubeengine` - The name of the database
- `MONGO_DB_CONNECTION_TIMEOUT=5000` - The timeout 

Note that the mongodb config will be persisted with the config directory. Therefore the mongodb config will only be created if it doesn't exist. So if you change the mongodb connection values, don't forget the delete the configuration file `/home/minecraft/server/config/cubeengine/modules/bigdata/config.yml`. Otherwise it won't be regenerated.

## Compose

The project provides a docker compose file. This files sets up the cubeengine/forge image together with a mysql and a mongo database. Here you only have to add additional environment variables or change the provided default values. Furthermore you could add a user and a group id to the forge service by specifying the `user` property.
