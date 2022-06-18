FROM alpine

RUN apk add --no-cache samba samba-common-tools tzdata runit shadow curl jq

RUN mkdir -p /etc/runit/smbd && \
    mkdir -p /etc/runit/nmbd && \
    echo -e "#!/bin/sh\nsmbd -i --no-process-group" > /etc/runit/smbd/run && \
    echo -e "#!/bin/sh\nnmbd -i --no-process-group" > /etc/runit/nmbd/run && \
    chmod +x /etc/runit/*/run

VOLUME /var/lib/samba
VOLUME /var/cache/samba

EXPOSE 137 138 139 445

CMD ["runsvdir", "-P", "/etc/runit"]