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
	forge_version="$(echo "${MINECRAFT_VERSION}-$(echo ${version_info_json} | jq --raw-output '.[0] | .dependencies | .forge')")"
	echo "forge version: ${forge_version}"

	pushd "${MINECRAFT_DIR}"
		curl -vo ./installer.jar "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${forge_version}/forge-${forge_version}-installer.jar"
		java -jar ./installer.jar --installServer
		rm ./installer.jar
		mv -v "./forge-${forge_version}-universal.jar" "${SERVER_JAR}"
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
}

#######################################
# Installs the CubeEngine Plugins from the CE_PLUGINS file.
# The file must specify the complete plugin maven identifier
# to download the jar file with maven.
# Arguments:
#   None
# Returns:
#   None
#######################################
install_ce() {
	pushd "${MINECRAFT_CE_PLUGINS_DIR}"
		while read artifact; do
		    local artifact_id=$(echo ${artifact} | grep -oP ':\K[^:]+' | head -n 1)
            download_maven_artifact "${artifact}" "${artifact_id}" 0
		done <"${SCRIPT_DIR}/CE_PLUGINS"
	popd
}

download_maven_artifact() {
    local artifact=$1
    local artifact_id=$2
    local retry=$3

    if [ ${retry} -gt 2 ]
    then
        echo "The maven artifact ${artifact} couldn't be downloaded."
        exit 1
    fi

    local additional_params=""
    if [ ${retry} -gt 0 ]
    then
        local additional_params="-U"
    fi

    local retry=$(expr ${retry} + 1)

    echo "Downloads maven artifact ${artifact}. ${retry}. try..."
    mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:copy -Dartifact=$(echo ${artifact} | xargs) -DoutputDirectory="./" ${additional_params}

    mv -v ${artifact_id}* ${artifact_id}.jar
    if [ $? -ne 0 ]
    then
        download_maven_artifact "${artifact}" "${artifact_id}" ${retry}
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

echo "install cubeengine..."
install_ce
