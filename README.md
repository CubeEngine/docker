# CubeEngine Forge Docker Image

- [Available on Docker-Hub](https://hub.docker.com/r/cubeengine/cubeengine-sponge/)
- [Available on GitHub](https://github.com/CubeEngine/docker)

The docker image `cubeengine/cubeengine-sponge` sets up a minecraft server containing [Sponge Vanilla](https://www.spongepowered.org/) together with [CubeEngine](http://cubeengine.org/) mods.

This documentation only describes how to set up the docker container. Have a look at the related GitHub projects to get more details about the actual functionality: 

- [CubeEngine Docs](http://cubeengine.org/)
- [CubeEngine Core](https://github.com/CubeEngine/core)
- [CubeEngine Main Modules](https://github.com/CubeEngine/modules-main)
- [CubeEngine Extra Modules](https://github.com/CubeEngine/modules-extra)


## Environment Variables

The container can be configured using environment variables. There are some variables which can be set for the image build process. They will be ignored at this point. This part only contains a description of the variables configuring the container.

One important mention is the `JAVA_VM_ARGS` environment variable. This helps you to specify additional arguments for the java process. By default it doesn't contain something. As a suggestion I advice you to set the Xmx variable, the maximum size of the memory allocation pool at least 1G or 2G. For this just write `JAVA_VM_ARGS=-Xmx2G`

### Choose Mods

By default the container will be started with every registered CubeEngine-Plugin. But actually you don't need all of them. To only start the server with a selection of plugins, you can specify the `CE_PLUGINS` environment variable. The value is only a list of lowercased plugin names which are separated with whitespace. For example `CE_PLUGINS="vanillaplus fun roles"`.

Get the names of the plugins together with additional information from the official [CubeEngine Documentation](http://cubeengine.org/).

### Database

Some of the CubeEngine plugins need a database connection. The database can be set up with the following variables. The list also shows the default values.

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

