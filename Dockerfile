FROM ubuntu:14.04

RUN apt-get -qq update && \
	apt-get -qqy install \
		apache2 \
		apache2-dev \
		apache2-mpm-prefork \
		build-essential \
		cpanminus \
		libapache-dbi-perl \
		libapache-dbilogger-perl \
		libapache2-mod-apreq2 \
		libapache2-mod-fcgid \
		libapache2-mod-perl2 \
		libapache2-mod-perl2-dev \
		libapache2-request-perl \
		libapreq2-dev \
		libxml2-dev \
	&& rm -rf /var/lib/apt/lists/*

## This puts cpanm's temp files into /tmp/cpanm:
ENV PERL_CPANM_HOME /tmp/cpanm
WORKDIR /usr/src/app/
COPY cpanfile cpanfile.snapshot /usr/src/app/
RUN cpanm -qf --installdeps . \
	&& rm -Rf $PERL_CPANM_HOME

## Enables prefork in Apache, copies in config and entry point, and sets up
##  Mason's directories.
COPY mason-app.conf /etc/apache2/sites-enabled/000-default.conf
RUN a2enmod cgi fcgid \
	&& rm /etc/apache2/ports.conf \
	&& mkdir -p /etc/apache2/mason/ \
	&& chown -R www-data:www-data /etc/apache2/mason/ /usr/src/app/

ADD . /usr/src/app/

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/log/apache2/pid

EXPOSE 5000

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
