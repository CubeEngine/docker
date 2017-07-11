#!/bin/bash
#IFS=$'\x20'

server_properties="${MINECRAFT_DIR}/server.properties"
database_conf="${MINECRAFT_CONFIG_DIR}/cubeengine/database.yml"
mongo_database_conf="${MINECRAFT_CONFIG_DIR}/cubeengine/modules/bigdata/config.yml"

#######################################
# Returns the relative path of the specified file from the
# directory specified with the ${MINECRAFT_DIR} property.
# Globals:
#   - MINECRAFT_DIR
# Arguments:
#   - The absolute path to the file.
# Returns:
#   The relative path
#######################################
relativize_file() {
	echo "./$(realpath --relative-to="${MINECRAFT_DIR}" "$1")"
}

#######################################
# Creates a classpath out of all existing .jar files within
# the directory specified with the ${MINECRAFT_CE_PLUGINS_DIR} property.
# Globals:
#   - MINECRAFT_CE_PLUGINS_DIR
# Arguments:
#   None
# Returns:
#   The created classpath
#######################################
create_complete_ce_classpath() {
	local classpath

	for filename in ${MINECRAFT_CE_PLUGINS_DIR}/*.jar; do
		if [ -z "${classpath}" ]
		then
			classpath=$(echo $(relativize_file $filename))
		else
			classpath=$(echo ${classpath},$(relativize_file $filename))
		fi
	done

	echo ${classpath}
}

#######################################
# Creates a classpath out of all plugins specified in the
# ${CE_PLUGINS[@]} property. The plugins must be seperated
# with a space. This method simply creates the classpath.
# It doesn't ensures that a plugin really exists.
# Globals:
#   - MINECRAFT_CE_PLUGINS_DIR
#	- CE_PLUGINS
# Arguments:
#   None
# Returns:
#   The created classpath
#######################################
create_include_ce_classpath() {
	local classpath=$(echo $(relativize_file "${MINECRAFT_CE_PLUGINS_DIR}/libcube.jar"))

	for plugin in ${CE_PLUGINS[@]}; do
		classpath=$(echo ${classpath},$(relativize_file "${MINECRAFT_CE_PLUGINS_DIR}/${plugin}.jar"))
	done

	echo ${classpath}
}

#######################################
# Sets a property within the server.properties file of the
# minecraft server.
# Globals:
#   - server_properties
# Arguments:
#   - The property which shall be set.
#	- The value of the property.
# Returns:
#   None
#######################################
set_server_property() {
	local property=$1
	local value=$2

	echo "Sets server property '${property}' to '${value}'."
	echo "${property}=${value}" >> "${server_properties}"
}

#######################################
# Initializes the server properties file.
# Arguments:
#   None
# Returns:
#   None
#######################################
initialize_server_properties() {
	set_server_property "allow-flight" "${ALLOW_FLIGHT}"
	set_server_property "allow-nether" "${ALLOW_NETHER}"
	set_server_property "announce-player-achievements" "${ANNOUNCE_PLAYER_ACHIEVEMENTS}"
	set_server_property "difficulty" "${DIFFICULTY}"
	set_server_property "enable-query" "${ENABLE_QUERY}"
	set_server_property "enable-rcon" "${ENABLE_RCON}"
	set_server_property "enable-command-block" "${ENABLE_COMMAND_BLOCK}"
	set_server_property "force-gamemode" "${FORCE_GAMEMODE}"
	set_server_property "gamemode" "${GAMEMODE}"
	set_server_property "generate-structures" "${GENERATE_STRUCTURES}"
	set_server_property "generator-settings" "${GENERATOR_SETTINGS}"
	set_server_property "hardcore" "${HARDCORE}"
	set_server_property "level-name" "${LEVEL_NAME}"
	set_server_property "level-seed" "${LEVEL_SEED}"
	set_server_property "level-type" "${LEVEL_TYPE}"
	set_server_property "max-build-height" "${MAX_BUILD_HEIGHT}"
	set_server_property "max-players" "${MAX_PLAYERS}"
	set_server_property "max-tick-time" "${MAX_TICK_TIME}"
	set_server_property "max-world-size" "${MAX_WORLD_SIZE}"
	set_server_property "motd" "${MOTD}"
	set_server_property "network-compression-threshold" "${NETWORK_COMPRESSION_THRESHOLD}"
	set_server_property "online-mode" "${ONLINE_MODE}"
	set_server_property "op-permission-level" "${OP_PERMISSION_LEVEL}"
	set_server_property "player-idle-timeout" "${PLAYER_IDLE_TIMEOUT}"
	set_server_property "pvp" "${PVP}"
	set_server_property "query.port" "25565"
	set_server_property "rcon.password" "${RCON_PASSWORD}"
	set_server_property "rcon.port" "25575"
	set_server_property "resource-pack" "${RESOURCE_PACK}"
	set_server_property "resource-pack-hash" "${RESOURCE_PACK_HASH}"
	set_server_property "server-ip" ""
	set_server_property "server-port" "25565"
	set_server_property "snooper-enabled" "${SNOOPER_ENABLED}"
	set_server_property "spawn-animals" "${SPAWN_ANIMALS}"
	set_server_property "spawn-monsters" "${SPAWN_MONSTERS}"
	set_server_property "spawn-npcs" "${SPAWN_NPCS}"
	set_server_property "spawn-protection" "${SPAWN_PROTECTION}"
	set_server_property "view-distance" "${VIEW_DISTANCE}"
	set_server_property "white-list" "${WHITE_LIST}"
}

#######################################
# Sets a yaml property within a specified file.
# Indentation isn't respected by this method.
# This can be done with spaces in the beginning of the property name.
# Arguments:
#   - The file to add the property to.
#   - The actual property
#   - The value of the property. Is optional and doesn't have to be set.
# Returns:
#   None
#######################################
set_yml_property() {
	local file=$1
	local property=$2
	local value=$3

	if [ "${3+set}" = set ]
	then
		echo "Sets the json property '${property}' to '${value}' in file '{$file}'."
		echo "${property}: '${value}'" >> "${file}"
	else
	    echo "Sets the json property '${property}' in file '{$file}' without value."
		echo "${property}:" >> "${file}"
	fi
}

#######################################
# Initializes the database configuration.
# Arguments:
#   None
# Returns:
#   None
#######################################
initialize_database_config() {
	mkdir -p "$(dirname ${database_conf})"

	set_yml_property "${database_conf}" "host" "${DB_HOST}"
	set_yml_property "${database_conf}" "port" "${DB_PORT}"
	set_yml_property "${database_conf}" "user" "${DB_USER}"
	set_yml_property "${database_conf}" "password" "${DB_PASSWORD}"
	set_yml_property "${database_conf}" "database" "${DB_NAME}"
	set_yml_property "${database_conf}" "table-prefix" "${DB_TABLE_PREFIX}"
	set_yml_property "${database_conf}" "log-database-queries" "${DB_LOG_DATABASE_QUERIES}"
}

#######################################
# Initializes the mongodb configuration.
# Arguments:
#   None
# Returns:
#   None
#######################################
initialize_mongo_database_config() {
	mkdir -p "$(dirname ${mongo_database_conf})"

	set_yml_property "${mongo_database_conf}" "host" "${MONGO_DB_HOST}"
	set_yml_property "${mongo_database_conf}" "port" "${MONGO_DB_PORT}"
	set_yml_property "${mongo_database_conf}" "connection-timeout" "${MONGO_DB_CONNECTION_TIMEOUT}"
	set_yml_property "${mongo_database_conf}" "authentication"
	set_yml_property "${mongo_database_conf}" "  database" "${MONGO_DB_NAME}"
	set_yml_property "${mongo_database_conf}" "  username" "${MONGO_DB_USER}"
	set_yml_property "${mongo_database_conf}" "  password" "${MONGO_DB_PASSWORD}"
}

if [ ! -f "${server_properties}" ]
then
	echo "initialize server.properties..."
	initialize_server_properties
fi

if [ ! -f "${database_conf}" ]
then
	echo "initialize database config..."
	initialize_database_config
fi

if [ ! -f "${mongo_database_conf}" ]
then
	echo "initialize mongo database config..."
	initialize_mongo_database_config
fi

echo "create the ce classpath..."
if [ -z "${CE_PLUGINS}" ]
then
	echo "Loads all CE Plugins..."
	ce_classpath=$(echo $(create_complete_ce_classpath))
else
	echo "Loads CE Plugins with include strategy..."
	echo "Plugins to include: ${CE_PLUGINS}"
	ce_classpath=$(echo $(create_include_ce_classpath))
fi
echo "Created CE Plugin Classpath is '${ce_classpath}'"

echo "-------------------------------"
echo "start the server..."

java ${JAVA_VM_ARGS} -jar "${SERVER_JAR}" --mods "${ce_classpath},$(relativize_file ${SPONGE_FILE})"
