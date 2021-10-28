ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8

# Copy root filesystem
COPY rootfs /

# add aws-cli and deps
RUN apk add -v --update --no-cache \
        python3 \
        py3-pip \
        groff \
        less \
        mailcap \
        && \
    pip3 install --upgrade awscli s3cmd python-magic && \
    apk -v --purge del py-pip
