FROM openjdk:8-jre-alpine
MAINTAINER info@cubeengine.org

ENV MINECRAFT_DIR="/opt/minecraft" \
	MINECRAFT_VERSION=1.11.2 \
	# TODO read forge version from SPONGE_VERSION_URL!
	FORGE_BUILD=2282 \
	FORGE_VERSION_BASE=13.20.0 \
	FORGE_BASE_URL="http://files.minecraftforge.net/maven" \
	FORGE_PACKAGE="net/minecraftforge/forge" \
	# "bleeding" or "stable"
	SPONGE_TYPE="bleeding" 

ENV SERVER_JAR="${MINECRAFT_DIR}/server.jar" \
	MINECRAFT_MODS_DIR="${MINECRAFT_DIR}/mods" \
	MINECRAFT_STATIC_MODS_DIR="${MINECRAFT_DIR}/static_mods" \
	MINECRAFT_CONFIG_DIR="${MINECRAFT_DIR}/config" \
	MINECRAFT_WORLD_DIR="${MINECRAFT_DIR}/world" \
	FORGE_VERSION="${MINECRAFT_VERSION}-${FORGE_VERSION_BASE}.${FORGE_BUILD}" \
	SPONGE_VERSION_URL="https://dl-api.spongepowered.org/v1/org.spongepowered/spongeforge/downloads?type=${SPONGE_TYPE}&minecraft=${MINECRAFT_VERSION}"
	
ENV SPONGE_FILE="${MINECRAFT_STATIC_MODS_DIR}/sponge.jar"

# Upgrading system and install cURL, grep
RUN apk update && \
	apk upgrade && \
	apk --update add curl ca-certificates grep coreutils

# Create directories
RUN mkdir -p ${MINECRAFT_DIR} && mkdir -p ${MINECRAFT_STATIC_MODS_DIR}

# Install Minecraft Forge
RUN cd ${MINECRAFT_DIR} && \
	curl -vo ./installer.jar "${FORGE_BASE_URL}/${FORGE_PACKAGE}/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar" && \
	java -jar ./installer.jar --installServer && \
	rm ./installer.jar && \
	mv -v "./forge-${FORGE_VERSION}-universal.jar" "${SERVER_JAR}" && \
	echo "eula=true" > ./eula.txt

# Install SpongeForge
RUN curl -vo "${SPONGE_FILE}" "$(curl -v "${SPONGE_VERSION_URL}" | grep -oP 'https://[^"]+' | head -n 1)"

EXPOSE 25565/tcp
VOLUME ["${MINECRAFT_MODS_DIR}", "${MINECRAFT_CONFIG_DIR}", "${MINECRAFT_WORLD_DIR}"]
WORKDIR ${MINECRAFT_DIR}
ENTRYPOINT java -jar "${SERVER_JAR}" --mods "./$(realpath --relative-to="${MINECRAFT_DIR}" "${SPONGE_FILE}")"
