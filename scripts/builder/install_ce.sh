#!/bin/bash

build_and_copy_ce_project() {
    project=$1
    echo "Build project ${project} with ${install_projects}"

    pushd "${ce_download_dir}/${project}"
        mvn install -Dmaven.test.skip=true
        if [ $? -ne 0 ]
        then
            echo "${project} couldn't be built."
            exit 1
        fi

        cp -v target/*.jar "${MINECRAFT_CE_PLUGINS_DIR}"
        cp -v **/target/*.jar "${MINECRAFT_CE_PLUGINS_DIR}"
    popd
}

install_ce() {
    ce_download_dir="${MINECRAFT_CE_PLUGINS_DIR}/ce_download"

    mkdir -v "${ce_download_dir}"

    pushd "${ce_download_dir}"
        git clone https://github.com/CubeEngine/core.git
        git clone https://github.com/CubeEngine/modules-main.git
        git clone https://github.com/CubeEngine/modules-extra.git
    popd

    build_and_copy_ce_project "core"
    build_and_copy_ce_project "modules-main"
    build_and_copy_ce_project "modules-extra"

    echo "Cleans up the maven repo..."
	rm -Rv "/home/${USER_NAME}/.m2/"
	rm -Rv "${ce_download_dir}"

    echo "Reorganizes the ce plugins dir..."
    pushd "${MINECRAFT_CE_PLUGINS_DIR}"
        for filename in *"-full.jar"
        do
            shortname=$(echo "${filename}" | cut -d'-' -f 1)
            mv -v "${filename}" "${shortname}.jar"
        done

        rm -v "LibCube.jar"

        echo "ls ${MINECRAFT_CE_PLUGINS_DIR}:"
        ls -al .
    popd
}

echo "install cubeengine..."
install_ce
