FROM debian:stable

LABEL maintainer="Gianluca Gabrielli" mail="tuxmealux+dockerhub@protonmail.com"
LABEL description="One-line command to generate a certificate via Let's Encrypt and share it among containers."
LABEL website="https://github.com/StayPirate"

COPY generate /usr/local/bin/

RUN apt-get update && \
    apt-get install -y certbot python-certbot-nginx && \
    chmod +x /usr/local/bin/generate && \
    mkdir /cert

ENTRYPOINT ["generate"]
