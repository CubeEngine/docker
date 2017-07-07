#!/bin/bash
#IFS=$'\x20'


server_properties="${MINECRAFT_DIR}/server.properties"


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

	echo "The property '${property}' will be set to '${value}'."
	sed -i "/${property}\s*=/ c ${property}=${value}" "${server_properties}"
}

initialize_server_properties() {
	cp -v "${SCRIPT_DIR}/config/server.properties" "${server_properties}"

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

if [ ! -f "${server_properties}" ]
then
	echo "initialize server.properties..."
	initialize_server_properties
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
