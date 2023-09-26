FROM cubeengine/sponge:1.16.5-8.2.0

# Database configuration
ENV DB_TABLE_PREFIX="cube_" \
    DB_LOG_DATABASE_QUERIES="false"

# Install server
COPY download_cubeengine_plugins.sh /docker-entrypoint.d/
