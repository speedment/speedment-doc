#!/bin/bash

SPEEDMENT_VERSION=3.0.14
MYSQL_CONNECTOR_VERSION=5.1.42
POSTGRES_CONNECTOR_VERSION=42.1.4
MARIA_DB_CONNECTOR_VERSION=2.1.2

if [[ `git remote -v | grep speedment-doc.git | wc -l` -eq 0 ]]; then
	echo "The current directory does not seem to be a speedment-doc git repo"
	exit 10
fi

if [[ `git status | grep "working tree clean" | wc -l` -eq 0 ]]; then
	echo "There are changes to the current directory that need to be reverted/pushed before we can continue:"
	git status
	exit 10
fi

echo "Making sure we have the latest changes"
git pull

function update_gav {
	GROUP_ID=$1
	ARTIFACT_ID=$2
	VERSION=$3

	echo "---"
	echo "Updating ${GROUP_ID}.${ARTIFACT_ID} to version ${VERSION}"
	echo "---"

	perl -0777 -i -pe "s:(<groupId>${GROUP_ID}</groupId>[\n\s]*<artifactId>${ARTIFACT_ID}</artifactId>[\n\s]*)<version>(\d*.\d*.\d*)</version>:\$1<version>${VERSION}</version>:g" *.md
	git --no-pager diff
	git add -A
	git commit -m "Bump ${GROUP_ID}.${ARTIFACT_ID} to version ${VERSION}"
}

function update_url {
        GROUP_ID=$1
        ARTIFACT_ID=$2
        VERSION=$3

        echo "---"
        echo "Updating ${GROUP_ID}.${ARTIFACT_ID} to version ${VERSION}"
        echo "---"

        perl -0777 -i -pe "s:(<groupId>${GROUP_ID}</groupId>[\n\s]*<artifactId>${ARTIFACT_ID}</artifactId>[\n\s]*)<version>(\d*.\d*.\d*)</version>:\$1<version>${VERSION}</version>:g" *.md
        git --no-pager diff
        git add -A
        git commit -m "Bump ${GROUP_ID}.${ARTIFACT_ID} to version ${VERSION}"
}


update_gav com.speedment documentation-examples ${SPEEDMENT_VERSION}
update_tag speedment.version ${SPEEDMENT_VERSION}

update_doc com.speedment speedment-maven-plugin ${SPEEDMENT_VERSION}
update_doc com.speedment runtime ${SPEEDMENT_VERSION}
update_doc com.speedment.plugins json-stream ${SPEEDMENT_VERSION}
update_doc mysql mysql-connector-java ${MYSQL_CONNECTOR_VERSION}
update_doc org.postgresql postgresql ${POSTGRES_CONNECTOR_VERSION}
update_doc org.mariadb.jdbc mariadb-java-client ${MARIA_DB_CONNECTOR_VERSION}

echo "Please review the committed changes and consider pushing upstream."
