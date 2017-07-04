# SECTION 1 Base OS install
FROM python:2.7

RUN apt-get update

RUN apt-get install -y gunicorn \
    sendmail \
    libffi-dev \
    python-dev \
    build-essential \
    libssl-dev \
    curl \
    libpcre3-dev \
    libpcre++-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    minicom \
    telnet \
    python2.7 \
    autoconf \
    automake \
    avahi-daemon \
    screen \
    locales \
    dosfstools \
    vim \
    python2.7-dev \
    sendmail \
    sqlite3 \
    sudo \
    cron \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash alarmdecoder && adduser alarmdecoder sudo

RUN cp /usr/share/zoneinfo/EST5EDT /etc/localtime

# SECTION 2  ngnix section
#  commenting out nginx secion for now
###
###ENV nginxver 1.7.4
###
###RUN cd /home/alarmdecoder && mkdir installs
###WORKDIR /home/alarmdecoder/installs
###
###RUN curl http://nginx.org/download/nginx-${nginxver}.tar.gz | tar zxvf -
###
###WORKDIR /home/alarmdecoder/installs/nginx-${nginxver}
###
###RUN ./configure --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_ssl_module --with-ipv6
###
###RUN make install
###RUN mkdir -p /var/www
###RUN mkdir -p /etc/nginx/ssl
###RUN cp html/* /var/www


# SECTION 3 gunicorn and Alarmdecoder setup 



WORKDIR /opt

RUN git clone http://github.com/nutechsoftware/alarmdecoder-webapp.git


# Sane defaults for pip
ENV PIP_NO_CACHE_DIR off
ENV PIP_DISABLE_PIP_VERSION_CHECK on

RUN pip install gunicorn --upgrade

#lets see if this helps/works - new stuff
RUN rm /usr/bin/gunicorn
RUN rm /usr/bin/gunicorn_paster
WORKDIR /usr/bin
RUN ln -s /usr/local/bin/gunicorn ./
RUN ln -s /usr/local/bin/gunicorn_paster ./

WORKDIR /opt/alarmdecoder-webapp

RUN pip install -r requirements.txt

RUN mkdir instance && chown -R alarmdecoder:alarmdecoder .

USER alarmdecoder
RUN python manage.py initdb
USER root

# sqlite db is stored here
VOLUME /opt/alarmdecoder-webapp/instance

# I'm not sure what's going on here, but the app starts its own server on port
# 5000, and that's the server that it wants exposed to the outside world. So we
# start gunicorn on port 8000, but that server is ignored and the code spins up
# the actual server that we expose.
#
# This port 5000 also seems to be hard-coded in a few different places in the app.
EXPOSE 5000

# SECTION 4 start it up

RUN echo "alarmdecoder:abc123" | chpasswd

# sqlite db is stored here
VOLUME /opt/alarmdecoder-webapp/instance

# I'm not sure what's going on here, but the app starts its own server on port
# 5000, and that's the server that it wants exposed to the outside world. So we
# start gunicorn on port 8000, but that server is ignored and the code spins up
# the actual server that we expose.
#
# This port 5000 also seems to be hard-coded in a few different places in the app.
EXPOSE 5000

WORKDIR /opt/alarmdecoder-webapp


COPY start.sh /

CMD ["/start.sh"]
