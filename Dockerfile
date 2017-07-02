FROM maven:3-jdk-8-alpine
MAINTAINER info@cubeengine.org

ENV MINECRAFT_DIR="/opt/minecraft" \
	MINECRAFT_VERSION=1.12 \
	# "bleeding" or "stable"
	SPONGE_TYPE="bleeding" \
	# lists the plugins which shall be activated. an empty or unset string results in a server containing all plugins
	# example "roles worlds vanillaplus fun fly"
	CE_PLUGINS=""

ENV SERVER_JAR="${MINECRAFT_DIR}/server.jar" \
	MINECRAFT_MODS_DIR="${MINECRAFT_DIR}/mods" \
	MINECRAFT_STATIC_MODS_DIR="${MINECRAFT_DIR}/static_mods" \
	MINECRAFT_CE_PLUGINS_DIR="${MINECRAFT_DIR}/ce-plugins" \
	MINECRAFT_CONFIG_DIR="${MINECRAFT_DIR}/config" \
	MINECRAFT_WORLD_DIR="${MINECRAFT_DIR}/world" \
	MINECRAFT_LOGS_DIR="${MINECRAFT_DIR}/logs" \
	MINECRAFT_STUFF_DIR="${MINECRAFT_DIR}/stuff" \
	SCRIPT_DIR="/scripts"

ENV SPONGE_FILE="${MINECRAFT_STATIC_MODS_DIR}/sponge.jar" \
	CUBE_ENGINE_FILE="${MINECRAFT_STATIC_MODS_DIR}/CubeEngine.jar"

# Upgrading system and install some software
RUN apk update && \
	apk upgrade && \
	apk --update add curl ca-certificates grep coreutils jq bash

# Install server
COPY maven/settings.xml /usr/share/maven/conf/settings.xml
COPY scripts/ ${SCRIPT_DIR}
RUN bash ${SCRIPT_DIR}/install.sh

EXPOSE 25565/tcp 25575/tcp
VOLUME ["${MINECRAFT_MODS_DIR}", "${MINECRAFT_CONFIG_DIR}", "${MINECRAFT_WORLD_DIR}", "${MINECRAFT_LOGS_DIR}", "${MINECRAFT_STUFF_DIR}"]
WORKDIR ${MINECRAFT_DIR}
ENTRYPOINT bash ${SCRIPT_DIR}/entrypoint.sh
