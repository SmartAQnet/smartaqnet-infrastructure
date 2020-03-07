FROM netdata/netdata:v1.19.0
RUN apk add msmtp
COPY postgres.conf /etc/netdata/python.d/postgres.conf
COPY traefik.conf /etc/netdata/python.d/traefik.conf
COPY netdata.conf /etc/netdata/netdata.conf
COPY stream.conf /etc/netdata/stream.conf
COPY .msmtprc /etc/netdata/.msmtprc
COPY .msmtprc /etc/msmtprc
COPY health_alarm_notify.conf /etc/netdata/health_alarm_notify.conf