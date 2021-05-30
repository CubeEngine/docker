#!/usr/bin/env bash

echo "Download CubeEngine Modules..."
if ! [[ -e "$MINECRAFT_MODS_DIR" ]]
then
  mkdir "$MINECRAFT_MODS_DIR"
fi

nexus_host="${NEXUS_HOST:-maven.cubyte.org}"
host_header="${HOST_HEADER:-"$nexus_host"}"

ce_repo_curl="https://${nexus_host}/service/rest/v1/search/assets/download"

while read -r module
do
  if [[ "$module" =~ ^#.* ]]
  then
    continue
  fi

  empty_pattern='^\s*$'
  if [[ "$module" =~ $empty_pattern ]]
  then
    continue
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
  echo "Via: $url"

  if [ "$nexus_host" = "$host_header" ]
  then
    curl_options=()
  else
    curl_options=(-k -H "Host: ${host_header}")
  fi

  curl "${curl_options[@]}" -s -L -o "${target_file}" "$url"
done < /cubeengine.config

ls -tl $MINECRAFT_MODS_DIR
