#!/usr/bin/env bash

set -ex -o pipefail

export JAVA8_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
MAVEN_HOME_CLIENT=~/.m2/repository/org/opensearch/client
VERSION=1.2.0

mkdir -p "$MAVEN_HOME_CLIENT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-hadoop/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-hadoop-mr/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-hadoop-hive/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-spark-20_2.10/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-spark-20_2.11/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-spark-20_2.12/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-spark-30_2.12/$VERSION-SNAPSHOT"
mkdir -p "$MAVEN_HOME_CLIENT/opensearch-spark-30_2.13/$VERSION-SNAPSHOT"

./gradlew -S -Dbuild.snapshot=true -Dorg.gradle.warning.mode=summary distribution --no-configuration-cache --info

for i in `find . -path '*/distributions/*' -name "*.jar" -type f`; do
  md5sum "$i" >> "$i.md5"
  sha1sum "$i" >> "$i.sha1"
  sha256sum "$i" >> "$i.sha256"
  sha512sum "$i" >> "$i.sha512"
done

for i in `find . -path '*/poms/*' -name "*.pom" -type f`; do
  md5sum "$i" >> "$i.md5"
  sha1sum "$i" >> "$i.sha1"
  sha256sum "$i" >> "$i.sha256"
  sha512sum "$i" >> "$i.sha512"
done

rm -rf dist/build/distributions/*.zip
cp -R mr/build/distributions/* $MAVEN_HOME_CLIENT/opensearch-hadoop-mr/$VERSION-SNAPSHOT
cp -R mr/build/poms/* $MAVEN_HOME_CLIENT/opensearch-hadoop-mr/$VERSION-SNAPSHOT
cp -R hive/build/distributions/* $MAVEN_HOME_CLIENT/opensearch-hadoop-hive/$VERSION-SNAPSHOT
cp -R hive/build/poms/* $MAVEN_HOME_CLIENT/opensearch-hadoop-hive/$VERSION-SNAPSHOT
cp -R dist/build/distributions/* $MAVEN_HOME_CLIENT/opensearch-hadoop/$VERSION-SNAPSHOT
cp -R dist/build/poms/* $MAVEN_HOME_CLIENT/opensearch-hadoop/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/distributions/opensearch-spark-20_2.10* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.10/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/poms/opensearch-spark-20_2.10* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.10/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/distributions/opensearch-spark-20_2.11* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.11/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/poms/opensearch-spark-20_2.11* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.11/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/distributions/opensearch-spark-20_2.12* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.12/$VERSION-SNAPSHOT
cp -R spark/sql-20/build/poms/opensearch-spark-20_2.12* $MAVEN_HOME_CLIENT/opensearch-spark-20_2.12/$VERSION-SNAPSHOT
cp -R spark/sql-30/build/distributions/opensearch-spark-30_2.12* $MAVEN_HOME_CLIENT/opensearch-spark-30_2.12/$VERSION-SNAPSHOT
cp -R spark/sql-30/build/poms/opensearch-spark-30_2.12* $MAVEN_HOME_CLIENT/opensearch-spark-30_2.12/$VERSION-SNAPSHOT
cp -R spark/sql-30/build/distributions/opensearch-spark-30_2.13* $MAVEN_HOME_CLIENT/opensearch-spark-30_2.13/$VERSION-SNAPSHOT
cp -R spark/sql-30/build/poms/opensearch-spark-30_2.13* $MAVEN_HOME_CLIENT/opensearch-spark-30_2.13/$VERSION-SNAPSHOT
