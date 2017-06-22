FROM openjdk:8-jre-alpine
MAINTAINER info@cubeengine.org

ENV MINECRAFT_DIR="/opt/minecraft" \
	MINECRAFT_VERSION=1.12 \
	# "bleeding" or "stable"
	SPONGE_TYPE="bleeding"

ENV SERVER_JAR="${MINECRAFT_DIR}/server.jar" \
	MINECRAFT_MODS_DIR="${MINECRAFT_DIR}/mods" \
	MINECRAFT_STATIC_MODS_DIR="${MINECRAFT_DIR}/static_mods" \
	MINECRAFT_CONFIG_DIR="${MINECRAFT_DIR}/config" \
	MINECRAFT_WORLD_DIR="${MINECRAFT_DIR}/world" \
	SCRIPT_DIR="/scripts"
	
ENV SPONGE_FILE="${MINECRAFT_STATIC_MODS_DIR}/sponge.jar"

# Upgrading system and install some software
RUN apk update && \
	apk upgrade && \
	apk --update add curl ca-certificates grep coreutils jq bash

# Install server
COPY scripts/ ${SCRIPT_DIR}
RUN bash ${SCRIPT_DIR}/install.sh

EXPOSE 25565/tcp
VOLUME ["${MINECRAFT_MODS_DIR}", "${MINECRAFT_CONFIG_DIR}", "${MINECRAFT_WORLD_DIR}"]
WORKDIR ${MINECRAFT_DIR}
ENTRYPOINT java -jar "${SERVER_JAR}" --mods "./$(realpath --relative-to="${MINECRAFT_DIR}" "${SPONGE_FILE}")" ${JAVA_VM_ARGS}
