#!/usr/bin/env bash

echo "Download CubeEngine Modules..."
ce_repo_curl='https://maven.cubyte.org/service/rest/v1/search/assets/download'
while read module
do
  if [[ "$module" =~ ^#.* ]]
  then
    continue;
  fi

  parts=($(tr '=' ' ' <<< "$module"))
  artifact_id="${parts[0]}"
  version_parts=($(tr '#' ' ' <<< "${parts[1]}"))
  version="${version_parts[0]}"
  classifier=""
  if [ "${#version_parts[@]}" > 1 ]
  then
    classifier="${version_parts[1]}"
  fi
  group_id=""
  if [ "$artifact_id" = "libcube" ]
  then
    group_id="org.cubeengine"
  else
    group_id="org.cubeengine.module"
  fi

  target_file="${MINECRAFT_MODS_DIR}/${artifact_id}.jar"
  echo "Download ${artifact_id}-${version} to ${target_file}"
  url="${ce_repo_curl}?sort=version&repository=public&maven.groupId=${group_id}&maven.artifactId=${artifact_id}&maven.extension=jar&maven.classifier=${classifier}&maven.baseVersion=${version}"

  curl -s -L -o "${target_file}" "$url"
done < /cubeengine.config

ls -tl $MINECRAFT_MODS_DIR
