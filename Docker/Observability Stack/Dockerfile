# Base image: Using Alpine for minimal footprint
FROM alpine:latest as builder

# Install necessary dependencies (curl, tar, jq, etc.)
RUN apk add --no-cache curl tar jq

# Set working directory
WORKDIR /opt

# Install Prometheus
RUN curl -LO "https://github.com/prometheus/prometheus/releases/latest/download/prometheus-linux-amd64.tar.gz" && \
    tar -xvzf prometheus-linux-amd64.tar.gz && \
    mv prometheus-linux-amd64 prometheus

# Install Grafana
RUN curl -LO "https://dl.grafana.com/oss/release/grafana-10.0.3.linux-amd64.tar.gz" && \
    tar -xvzf grafana-10.0.3.linux-amd64.tar.gz && \
    mv grafana-10.0.3 grafana

# Install cAdvisor
RUN curl -Lo cadvisor "https://github.com/google/cadvisor/releases/latest/download/cadvisor" && \
    chmod +x cadvisor

# Install Node Exporter
RUN curl -LO "https://github.com/prometheus/node_exporter/releases/latest/download/node_exporter-$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | jq -r .tag_name)-linux-amd64.tar.gz" && \
    tar -xvzf node_exporter-*-linux-amd64.tar.gz && \
    mv node_exporter-*-linux-amd64/node_exporter /opt/node_exporter

# Install Alertmanager
RUN curl -LO "https://github.com/prometheus/alertmanager/releases/latest/download/alertmanager-$(curl -s https://api.github.com/repos/prometheus/alertmanager/releases/latest | jq -r .tag_name)-linux-amd64.tar.gz" && \
    tar -xvzf alertmanager-*-linux-amd64.tar.gz && \
    mv alertmanager-*-linux-amd64/alertmanager /opt/alertmanager

# Final stage: Use minimal base image (Alpine) for the final image
FROM alpine:latest

# Set working directory
WORKDIR /opt

# Copy binaries from builder stage
COPY --from=builder /opt/prometheus /opt/prometheus
COPY --from=builder /opt/grafana /opt/grafana
COPY --from=builder /opt/cadvisor /opt/cadvisor
COPY --from=builder /opt/node_exporter /opt/node_exporter
COPY --from=builder /opt/alertmanager /opt/alertmanager

# Expose necessary ports
EXPOSE 9090 3000 9323 9100 9093

# Start Prometheus, Grafana, cAdvisor, Node Exporter, and Alertmanager in the background
CMD [ "sh", "-c", "/opt/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml & \
                    /opt/grafana/bin/grafana-server & \
                    /opt/cadvisor & \
                    /opt/node_exporter & \
                    /opt/alertmanager --config.file=/etc/alertmanager/alertmanager.yml & \
                    wait" ]
