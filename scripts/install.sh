#!/bin/bash

version_info_json="$(curl -v "https://dl-api.spongepowered.org/v1/org.spongepowered/spongeforge/downloads?type=${SPONGE_TYPE}&minecraft=${MINECRAFT_VERSION}")"

ce_bootstrap_group="org.cubeengine"
ce_bootstrap_artifact="bootstrap"
ce_bootstrap_version="1.0.1-SNAPSHOT"

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

# Install CE Bootstrap Sponge-Module and CE-Plugins
install_ce() {
	pushd "${MINECRAFT_STATIC_MODS_DIR}"
		mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:copy -Dartifact=${ce_bootstrap_group}:${ce_bootstrap_artifact}:${ce_bootstrap_version} -DoutputDirectory="./"
		mv -v ${ce_bootstrap_artifact}* ${CUBE_ENGINE_FILE}
	popd
	
	pushd "${MINECRAFT_CE_PLUGINS_DIR}"
		while read artifact; do
		  mvn org.apache.maven.plugins:maven-dependency-plugin:3.0.1:copy -Dartifact=$(echo ${artifact} | xargs) -DoutputDirectory="./"
		  artifact_id=$(echo ${artifact} | grep -oP ':\K[^:]+' | head -n 1)
		  mv -v ${artifact_id}* ${artifact_id}.jar
		done <"${SCRIPT_DIR}/CE_PLUGINS"
	popd
}

echo "create directories..."
mkdir -p ${MINECRAFT_DIR}
mkdir -p ${MINECRAFT_STATIC_MODS_DIR}
mkdir -p ${MINECRAFT_CE_PLUGINS_DIR}

echo "install forge..."
install_forge

echo "install sponge..."
install_sponge

echo "install cubeengine..."
install_ce
