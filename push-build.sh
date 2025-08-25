#!/usr/bin/env sh

mvn -f ./pom_confluent.xml clean package -Dgpg.skip=true -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 -DskipTests=true

aws s3 cp ./target/snowflake-kafka-connector-3.1.0.jar "s3://leap-build-artifacts-persistent/snowflake-kafka-connector/3.1.0/snowflake-kafka-connector-3.1.0.jar" --profile leap-shared-dev-admin
