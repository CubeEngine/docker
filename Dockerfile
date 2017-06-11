FROM openjdk:8-jre-alpine
MAINTAINER info@cubeengine.org

ENV MINECRAFT_DIR="/opt/minecraft" \
	MINECRAFT_VERSION=1.11.2 \
	FORGE_BUILD=2282 \
	FORGE_VERSION_BASE=13.20.0 \
	FORGE_BASE_URL="http://files.minecraftforge.net/maven" \
	FORGE_PACKAGE="net/minecraftforge/forge"

ENV SERVER_JAR="${MINECRAFT_DIR}/server.jar" \
	MINECRAFT_MODS_DIR="${MINECRAFT_DIR}/mods" \
	MINECRAFT_CONFIG_DIR="${MINECRAFT_DIR}/config" \
	MINECRAFT_WORLD_DIR="${MINECRAFT_DIR}/world" \
	FORGE_VERSION="${MINECRAFT_VERSION}-${FORGE_VERSION_BASE}.${FORGE_BUILD}

# Upgrading system and install cURL
RUN apk update && \
	apk upgrade && \
	apk --update add curl ca-certificates

RUN mkdir -p ${MINECRAFT_DIR} 

# Install Minecraft Forge
RUN cd ${MINECRAFT_DIR} && \
	curl -vo ./installer.jar "${FORGE_BASE_URL}/${FORGE_PACKAGE}/${FORGE_VERSION}/forge-${FORGE_VERSION}-installer.jar" && \
	java -jar ./installer.jar --installServer && \
	rm ./installer.jar && \
	mv -v "./forge-${FORGE_VERSION}-universal.jar" "${SERVER_JAR}" && \
	echo "eula=true" > ./eula.txt

EXPOSE 25565/tcp
VOLUME ["${MINECRAFT_MODS_DIR}", "${MINECRAFT_CONFIG_DIR}", "${MINECRAFT_WORLD_DIR}"]
WORKDIR ${MINECRAFT_DIR}
ENTRYPOINT java -jar "${SERVER_JAR}"
