ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8

COPY rootfs /

# add aws-cli and deps
RUN apk add -v --update --no-cache \
        python3 \
        py3-pip \
        groff \
        less \
        jq \
        && \
    pip3 install --upgrade awscli
    
CMD [ "/etc/services.d/amazon-s3-backup/run" ]    
