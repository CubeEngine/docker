#!/bin/bash

version_info_json="$(curl -v "https://dl-api.spongepowered.org/v1/org.spongepowered/spongeforge/downloads?type=${SPONGE_TYPE}&minecraft=${MINECRAFT_VERSION}")"

# Install Minecraft Forge
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

# Install SpongeForge
install_sponge() {
	echo "Sponge version: $(echo ${version_info_json} | jq '.[0] | .version')"
	
	sponge_url="$(echo ${version_info_json} | jq --raw-output '.[0] | .artifacts | ."" | .url')"
	
	echo "Download sponge from ${sponge_url}"
	curl -vo "${SPONGE_FILE}" "${sponge_url}"
}

# Install CE-Plugins
install_ce() {
	pushd "${MINECRAFT_CE_PLUGINS_DIR}"
		while read artifact; do
		  mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:copy -Dartifact=$(echo ${artifact} | xargs) -DoutputDirectory="./"
		  artifact_id=$(echo ${artifact} | grep -oP ':\K[^:]+' | head -n 1)
		  mv -v ${artifact_id}* ${artifact_id}.jar
		done <"${SCRIPT_DIR}/CE_PLUGINS"
	popd
}

create_empty_json_for_root() {
	local filename=$1

	local root_file=${MINECRAFT_DIR}/${filename}
	local root_dir_file=${MINECRAFT_ROOT_STUFF_DIR}/${filename}
	
	echo "[]" > "${root_dir_file}"
	
	ln -s "${root_dir_file}" "${root_file}"
}

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
