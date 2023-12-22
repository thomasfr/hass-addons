ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8

COPY run.sh /
RUN chmod a+x /run.sh

# add aws-cli and deps
RUN apk add -v --update --no-cache \
        python3 \
        py3-pip \
        groff \
        less \
        jq \
        && \
    pip3 install --break-system-packages --upgrade awscli
    
CMD [ "/run.sh" ]  
