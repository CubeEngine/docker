#!/bin/bash

cubeengine_db_conf="${MINECRAFT_CONFIG_DIR}/config/cubeengine/database.yml"
mongo_database_conf="${MINECRAFT_CONFIG_DIR}/cubeengine/modules/bigdata/config.yml"

initialize_database_config() {
  mkdir -p "$(dirname ${cubeengine_db_conf})"

  echo "Creates ${cubeengine_db_conf}"
  local conf=<<EOF
log-database-queries: ${DB_LOG_DATABASE_QUERIES}
table-prefix: ${DB_TABLE_PREFIX}
EOF
    echo "$conf" > "${cubeengine_db_conf}"
}


#######################################
# Initializes the mongodb configuration.
# Arguments:
#   None
# Returns:
#   None
#######################################
initialize_mongo_database_config() {
  echo "Creates ${mongo_database_conf}"
	mkdir -p "$(dirname ${mongo_database_conf})"

  local conf=<<EOF
host: "${MONGO_DB_HOST}"
port: ${MONGO_DB_PORT}
connection: ${MONGO_DB_CONNECTION_TIMEOUT}
authentication:
  database: "${MONGO_DB_NAME}"
  username: "${MONGO_DB_USER}"
  password: "${MONGO_DB_PASSWORD}"
EOF
    echo "$conf" > "${mongo_database_conf}"
}

initialize_database_config
initialize_mongo_database_config
