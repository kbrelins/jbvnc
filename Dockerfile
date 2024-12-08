FROM alpine:3.19

LABEL AboutImage "Home Assistant Dashboard trough VNC"
#Locale

ENV LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="UTC"

RUN	apk update && \
	apk add --no-cache tzdata ca-certificates supervisor curl wget openssl bash python3 py3-requests sed unzip xvfb x11vnc websockify openbox chromium nss alsa-lib font-noto font-noto-cjk
# noVNC SSL certificate
RUN	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key -out /etc/ssl/novnc.cert > /dev/null 2>&1
# TimeZone
RUN	cp /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone

# Wipe Temp Files
RUN	apk del build-base curl wget unzip tzdata openssl && \
	rm -rf /var/cache/apk/* /tmp/*

RUN apk add git
ARG NOVNC_VERSION=v0.5.1
RUN git clone -c http.sslVerify=false --branch $NOVNC_VERSION https://github.com/novnc/noVNC.git /opt/novnc

RUN apk add procps

COPY chrome-novnc.sh /usr/bin/chrome-novnc.sh
COPY index.html /opt/novnc/index.html
RUN chmod +x /usr/bin/chrome-novnc.sh

COPY config /config

#VNC Resolution(720p is preferable)
# 768x1024 is iPad2
ENV	VNC_RESOLUTION="768x1024" \
#VNC Server Title(w/o spaces)
VNC_TITLE="Home Assistant Dashboard" \
#Local Display Server Port
DISPLAY=:0 \
#NoVNC Port
NOVNC_PORT=$PORT \
PORT=8080

CMD ["supervisord", "-l", "/var/log/supervisord.log", "-c","/config/supervisord.conf"]
#CMD ["bash", "-c", "/usr/bin/chrome-novnc.sh"]
