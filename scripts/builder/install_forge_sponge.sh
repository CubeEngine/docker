#!/bin/bash

version_info_json="$(curl -v "https://dl-api.spongepowered.org/v1/org.spongepowered/spongeforge/downloads?type=${SPONGE_TYPE}&minecraft=${MINECRAFT_VERSION}")"

#######################################
# Installs the actual Minecraft Forge server.
# Arguments:
#   None
# Returns:
#   None
#######################################
install_forge() {
	if [ "$LATEST_FORGE" = true ] 
	then
		forge_version_info_json="$(curl -v "https://files.minecraftforge.net/maven/net/minecraftforge/forge/promotions_slim.json")"
		forge_version="$(echo "${MINECRAFT_VERSION}-$(echo ${forge_version_info_json} | jq --raw-output '.promos | ."'"${MINECRAFT_VERSION}-latest"'"')")"
	else
		forge_version="$(echo "${MINECRAFT_VERSION}-$(echo ${version_info_json} | jq --raw-output '.[0] | .dependencies | .forge')")"
	fi		

	# TODO forge had a bug fixed in this version ; can be removed once "latest" is actually latest
	forge_version="1.12.2-14.23.4.2760"
    
	echo "forge version: ${forge_version}"

	pushd "${MINECRAFT_DIR}"
		curl -vo ./installer.jar "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${forge_version}/forge-${forge_version}-installer.jar"

		java -jar ./installer.jar --installServer
		rm ./installer.jar
		mv -v "./forge-${forge_version}-universal.jar" "${SERVER_JAR}"
		if [ $? -ne 0 ]
		then
			echo "Forge couldn't be installed."
			exit 1
		fi

		echo "eula=true" > ./eula.txt
	popd
}

#######################################
# Installs the forge plugin SpongeForge.
# Arguments:
#   None
# Returns:
#   None
#######################################
install_sponge() {
	echo "Sponge version: $(echo ${version_info_json} | jq '.[0] | .version')"

	sponge_url="$(echo ${version_info_json} | jq --raw-output '.[0] | .artifacts | ."" | .url')"

	echo "Download sponge from ${sponge_url}"
	curl -vo "${SPONGE_FILE}" "${sponge_url}"
	if [ $? -ne 0 ]
	then
		echo "Sponge couldn't be downloaded."
		exit 1
	fi
}

#######################################
# Creates a file containing an empty json array. This file will be
# created into a directory named root within the minecraft server
# directory. Furthermore a link to it will be created at the minecraft
# server directory.
# Arguments:
#   - The name of the file to create
# Returns:
#   None
#######################################
create_empty_json_for_root() {
	local filename=$1

	local root_file=${MINECRAFT_DIR}/${filename}
	local root_dir_file=${MINECRAFT_ROOT_STUFF_DIR}/${filename}

	echo "[]" > "${root_dir_file}"

	ln -s "${root_dir_file}" "${root_file}"
}

#######################################
# Creates all the files from the root directory of the minecraft
# server which must be persisted, creates them in a special folder
# and adds links to the root directory.
# Arguments:
#   None
# Returns:
#   None
#######################################
register_root_stuff() {
	create_empty_json_for_root "banned-ips.json"
	create_empty_json_for_root "banned-players.json"
	create_empty_json_for_root "ops.json"
	create_empty_json_for_root "whitelist.json"
}

echo "create directories..."
mkdir -p ${MINECRAFT_DIR}
mkdir -p ${MINECRAFT_STATIC_MODS_DIR}
mkdir -p ${MINECRAFT_CE_PLUGINS_DIR}
mkdir -p ${MINECRAFT_ROOT_STUFF_DIR}

echo "install forge..."
install_forge

echo "copying and setting up the root stuff directory..."
register_root_stuff

echo "install sponge..."
install_sponge
