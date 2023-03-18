FROM alpine

RUN apk add --no-cache openssh lftp xz
COPY ./root/ /

CMD [ "crond", "-f", "-l", "2" ]
