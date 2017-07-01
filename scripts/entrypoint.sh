#!/bin/bash
#IFS=$'\x20'

relativize_file() {
	echo "./$(realpath --relative-to="${MINECRAFT_DIR}" "$1")"
}

create_complete_ce_classpath() {
	for filename in ${MINECRAFT_CE_PLUGINS_DIR}/*.jar; do
		if [ -z "${classpath}" ]
		then
			classpath=$(echo $(relativize_file $filename))
		else
			classpath=$(echo ${classpath},$(relativize_file $filename))
		fi
	done

	echo ${classpath}
}

create_include_ce_classpath() {
	classpath=$(echo $(relativize_file "${MINECRAFT_CE_PLUGINS_DIR}/libcube.jar"))

	for plugin in ${CE_PLUGINS[@]}; do
		classpath=$(echo ${classpath},$(relativize_file "${MINECRAFT_CE_PLUGINS_DIR}/${plugin}.jar"))
	done
	
	echo ${classpath}
}

if [ -z "${CE_PLUGINS}" ]
then
	echo "Loads all CE Plugins..."
	ce_classpath=$(echo $(create_complete_ce_classpath))
else
	echo "Loads CE Plugins with include strategy..."
	echo "Plugins to include: ${CE_PLUGINS}"
	ce_classpath=$(echo $(create_include_ce_classpath))
fi
echo "Created CE Plugin Classpath is '${ce_classpath}'"

echo "-------------------------------"

java ${JAVA_VM_ARGS} -jar "${SERVER_JAR}" --mods "${ce_classpath},$(relativize_file ${SPONGE_FILE}),$(relativize_file ${CUBE_ENGINE_FILE})"
