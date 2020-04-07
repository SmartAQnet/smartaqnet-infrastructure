FROM netdata/netdata:v1.19.0
RUN apk add msmtp
COPY postgres.conf /etc/netdata/python.d/postgres.conf
COPY httpcheck.conf /etc/netdata/python.d/httpcheck.conf
COPY traefik.conf /etc/netdata/python.d/traefik.conf
COPY netdata.conf /etc/netdata/netdata.conf
COPY stream.conf /etc/netdata/stream.conf
COPY .msmtprc /etc/netdata/.msmtprc
COPY .msmtprc /etc/msmtprc
COPY health_alarm_notify.conf /etc/netdata/health_alarm_notify.conf
COPY health.d/cpu.conf /etc/netdata/health.d/cpu.conf
COPY health.d/disks.conf /etc/netdata/health.d/disks.conf
COPY health.d/load.conf /etc/netdata/health.d/load.conf
COPY health.d/net.conf /etc/netdata/health.d/net.conf
COPY health.d/httpcheck.conf /etc/netdata/health.d/httpcheck.conf