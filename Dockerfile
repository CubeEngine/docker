FROM cubeengine/sponge:1.16.4-8.0.0

ENV MINECRAFT_CE_PLUGINS_DIR="${MINECRAFT_DIR}/ce-plugins"

ENV SPONGE_FILE="${MINECRAFT_STATIC_MODS_DIR}/sponge.jar"

# Database configuration
ENV DB_TABLE_PREFIX="cube_" \
    DB_LOG_DATABASE_QUERIES="false"

# Install server
COPY download_cubeengine_plugins.sh /docker-entrypoint.d/
