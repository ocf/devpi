FROM docker.ocf.berkeley.edu/theocf/debian:stretch
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3.7-dev \
    python3.7-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN python3.7 -m ensurepip
ADD requirements.txt /
ADD devpi.conf /
RUN python3.7 -m pip install -r /requirements.txt
VOLUME /mnt
EXPOSE 3141
ADD run.sh /
CMD ["/run.sh"]
