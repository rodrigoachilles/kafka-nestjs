#!/bin/bash

# set +x

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libkafka.sh
. /opt/bitnami/scripts/libos.sh

kafka_start_bg() {
    if [[ "${KAFKA_CFG_LISTENERS:-}" =~ SASL ]] || [[ "${KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP:-}" =~ SASL ]] || [[ "${KAFKA_ZOOKEEPER_PROTOCOL:-}" =~ SASL ]]; then
        export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_CONF_DIR}/kafka_jaas.conf"
    fi

    if [[ "${KAFKA_ZOOKEEPER_PROTOCOL:-}" =~ SSL ]]; then
        ZOOKEEPER_SSL_CONFIG=$(zookeeper_get_tls_config)
        export KAFKA_OPTS="$KAFKA_OPTS $ZOOKEEPER_SSL_CONFIG"
    fi

    flags=("$KAFKA_CONF_FILE")
    [[ -z "${KAFKA_EXTRA_FLAGS:-}" ]] || flags=("${flags[@]}" "${KAFKA_EXTRA_FLAGS[@]}")
    START_COMMAND=("$KAFKA_HOME/bin/kafka-server-start.sh" "${flags[@]}")

    info "** Starting Kafka in background **"
    if am_i_root; then
        exec gosu "$KAFKA_DAEMON_USER" "${START_COMMAND[@]}" &
    else
        exec "${START_COMMAND[@]}" &
    fi
}

kafka_stop() {
    info "** Stopping Kafka **"
    local stop_command=("$KAFKA_HOME/bin/kafka-server-stop.sh")
    am_i_root && stop_command=("gosu" "${KAFKA_DAEMON_USER}" "${stop_command[@]}")
    if [[ "${BITNAMI_DEBUG:-false}" = true ]]; then
        "${stop_command[@]}"
    else
        "${stop_command[@]}" >/dev/null 2>&1
    fi
}

are_brokers_available() {
    expected_num_brokers=3
    num_brokers=$(("$(zookeeper-shell.sh zookeeper-1:2181 ls /brokers/ids 2>/dev/null | grep -o , | wc -l)" + 1))
    echo "** $num_brokers broker(s) available(s). **"
    ((num_brokers >= expected_num_brokers))
}

info "** [Kafka custom initialize] **"

kafka_start_bg

while ! are_brokers_available; do
    echo "brokers not available yet"
    sleep 1
done

# TEST
info "** CREATING TOPIC [TEST] ... **"
/opt/bitnami/kafka/bin/kafka-topics.sh --create \
    --bootstrap-server kafka-1:9092 \
    --partitions 10 \
    --replication-factor 3 \
    --topic test \
    --config unclean.leader.election.enable=false \
    --config min.insync.replicas=2

# LIST TOPICS CREATED
info "** TOPICS CREATED **"
/opt/bitnami/kafka/bin/kafka-topics.sh --list \
    --bootstrap-server kafka-1:9092

kafka_stop

info "** [Kafka custom initialize done] **"
