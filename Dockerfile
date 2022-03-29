ARG BASE=alpine:3.15
FROM ${BASE} as builder

WORKDIR /build

# Install dependencies
RUN apk add --no-cache git python3 python3-dev py3-pip py3-wheel build-base gcc libffi-dev openssl-dev musl-dev cargo

# Fetch AppDaemon
ARG APPDAEMON_TAG=4.2.1
RUN git clone --depth 1 --branch $APPDAEMON_TAG https://github.com/AppDaemon/appdaemon.git
RUN pip install -r appdaemon/requirements.txt

FROM ${BASE}

EXPOSE 5050

# Mountpoints for configuration & certificates
VOLUME /conf
VOLUME /certs

# Copy appdaemon into image
WORKDIR /usr/src/app

# Install runtime required packages
RUN apk add --no-cache curl python3 py3-pip tzdata

# Steal compiled deps from builder image
COPY --from=builder /usr/lib/python3.9/site-packages/ /usr/lib/python3.9/site-packages/

# Copy over necessary sources
COPY --from=builder /build/appdaemon/dockerStart.sh /build/appdaemon/requirements.txt /build/appdaemon/README.md /build/appdaemon/setup.py ./
COPY --from=builder /build/appdaemon/appdaemon/ ./appdaemon/

# Run instal
RUN pip install .

# Start script
RUN chmod +x /usr/src/app/dockerStart.sh
ENTRYPOINT ["./dockerStart.sh"]
