# Lucerna Instructions

Use JDK 8 
```bash
brew install openjdk@8
```

Build the project
```bash
mvn -f ./pom_confluent.xml clean package -Dgpg.skip=true -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 -DskipTests=true
```

## Publish a new build 

When we make changes to this repo, we need to build and publish a new version of the jar to S3. To do this, run the following script. Ensure that you have logged into AWS SSO prior to running the script.

```shell
./push-build.sh
```

## Dependency alerts policy (frozen jar)

This fork is intentionally frozen at `3.1.0` — `push-build.sh` publishes that exact jar to
`s3://leap-build-artifacts-persistent/snowflake-kafka-connector/3.1.0/`, and consumers reference it by
that filename. **We do not bump dependencies here for routine Dependabot alerts.** Only update a package
when an advisory is a *legitimate, runtime-reachable* security issue for how this connector actually runs;
otherwise dismiss the alert with a reason and comment.

Triage guide (from the DEV-7275 pass, 2026-08):

1. Check the alert's package scope in `pom_confluent.xml` (the pom `push-build.sh` builds). `<scope>test</scope>`
   deps (assertj, log4j-core) are not in the shipped jar → dismiss as `not_used`.
2. `kafka-clients`: Kafka Connect's `PluginClassLoader` always loads `org.apache.kafka.*` from the Connect
   runtime, never from this jar → dismiss as `not_used`.
3. jackson advisories: most require polymorphic deserialization (`activateDefaultTyping` / `@JsonTypeInfo`),
   which this connector never uses — record JSON is parsed to `JsonNode`/`Map`/`List`. Verify with
   `grep -rn "activateDefaultTyping\|JsonTypeInfo" src/main` before dismissing as `not_used`.
4. Anything that *is* reachable at runtime with untrusted input → bump the version property in **both**
   `pom.xml` and `pom_confluent.xml`, rebuild, run tests, and republish via `./push-build.sh`.

Dismiss via:

```shell
gh api -X PATCH repos/lucernahealth/snowflake-kafka-connector/dependabot/alerts/<n> \
  -f state=dismissed -f dismissed_reason=<not_used|tolerable_risk> -f dismissed_comment="<why, ticket ref>"
```

# Snowflake-kafka-connector
[![License](http://img.shields.io/:license-Apache%202-brightgreen.svg)](http://www.apache.org/licenses/LICENSE-2.0.txt)

Snowflake-kafka-connector is a plugin of Apache Kafka Connect - ingests data from a Kafka Topic to a Snowflake Table. 

[Official documentation](https://docs.snowflake.com/en/user-guide/kafka-connector) for the Snowflake sink Kafka Connector

### Contributing to the Snowflake Kafka Connector
The following requirements must be met before you can merge your PR:
- Tests: all test suites must pass, see the [test README](https://github.com/snowflakedb/snowflake-kafka-connector/blob/master/README-TEST.md)
- Formatter: run this script [`./format.sh`](https://github.com/snowflakedb/snowflake-kafka-connector/blob/master/format.sh) from root
- CLA: all contributers must sign the Snowflake CLA. This is a one time signature, please provide your email so we can work with you to get this signed after you open a PR.

Thank you for contributing! We will review and approve PRs as soon as we can.

### Third party licenses
Custom license handling process is run during build to meet legal standards.
- License files are copied directly from JAR if present in one of the following locations: META-INF/LICENSE.txt, META-INF/LICENSE, META-INF/LICENSE.md
- If no license file is found then license must be manually added to [`process_licenses.py`](https://github.com/snowflakedb/snowflake-kafka-connector/blob/master/scripts/process_licenses.py) script in order to pass build

### Test and Code Coverage Statuses

[![Kafka Connector Integration Test](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/IntegrationTest.yml/badge.svg?branch=master)](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/IntegrationTest.yml)

[![Kafka Connector Apache End2End Test](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/End2EndTestApache.yml/badge.svg?branch=master)](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/End2EndTestApache.yml)

[![Kafka Connector Confluent End2End Test](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/End2EndTestConfluent.yml/badge.svg?branch=master)](https://github.com/snowflakedb/snowflake-kafka-connector/actions/workflows/End2EndTestConfluent.yml)

[![codecov](https://codecov.io/gh/snowflakedb/snowflake-kafka-connector/branch/master/graph/badge.svg)](https://codecov.io/gh/snowflakedb/snowflake-kafka-connector)
