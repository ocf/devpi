FROM docker.ocf.berkeley.edu/theocf/debian:stretch
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3.7-dev \
    python3.7-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ADD run.sh /
ADD devpi.conf /
ADD requirements.txt /
RUN python3.7 -m ensurepip
RUN python3.7 -m pip install -r /requirements.txt
RUN devpi-server --init --serverdir /mnt
VOLUME /mnt
EXPOSE 3141
CMD ["devpi-server", "-c", "devpi.conf"]
