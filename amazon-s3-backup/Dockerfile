ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8

# add aws-cli and deps
RUN apk add -v --update --no-cache \
        python3 \
        py3-pip \
        groff \
        less \
        && \
    pip3 install --upgrade awscli

COPY run /
RUN chmod a+x /run

CMD [ "/run" ]