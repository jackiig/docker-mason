FROM ubuntu:14.04
MAINTAINER Jack M. <jack.m@iigins.com>

RUN apt-get -qq update && \
	apt-get -qqy install \
		apache2 \
		apache2-dev \
		apache2-mpm-prefork \
		build-essential \
		cpanminus \
		git \
		htmldoc \
		libapache-dbi-perl \
		libapache-dbilogger-perl \
		libapache2-mod-apreq2 \
		libapache2-mod-fcgid \
		libapache2-mod-perl2 \
		libapache2-mod-perl2-dev \
		libapache2-request-perl \
		libapreq2-dev \
		libxml2-dev \
		pdftk \
		python \
		python-lxml \
		python-pip \
		python-suds \
		starman \
		zlib1g-dev \
	&& rm -rf /var/lib/apt/lists/*

## This puts cpanm's temp files into /tmp/cpanm:
ENV PERL_CPANM_HOME /tmp/cpanm
RUN cpanm -qf \
	AnyData \
	Cache::Memcached \
	Cache::Memcached::Fast \
	CAM::PDF \
	Catalyst::Controller::HTML::FormFu \
	Catalyst::Devel \
	Catalyst::Model::DBIC::Schema \
	Catalyst::Plugin::I18N \
	Catalyst::Plugin::I18N::PathPrefix \
	Catalyst::View::Email \
	Catalyst::View::Email::Template \
	Catalyst::View::TT \
	CGI::Simple \
	Class::DBI::AbstractSearch \
	Class::DBI::mysql \
	Class::DBI::Pager \
	Config::General \
	Config::Tiny \
	Crypt::SSLeay \
	Data::Dumper \
	Data::Dumper::Simple \
	Data::GUID \
	Date::Calc \
	DateTime::Format::RFC3339 \
	DateTime::TimeZone \
	DBD::mysql \
	DBIx::Class \
	DBIx::Class \
	DBIx::Class::Schema::Loader \
	DBIx::Class::TimeStamp \
	Digest::HMAC \
	Email::Send \
	Email::Send::Gmail \
	Email::Simple \
	Email::Valid \
	Encoding::FixLatin \
	Filesys::DiskSpace \
	HTML::Entities::Numbered \
	HTML::Mason \
	HTML::Strip \
	HTTP::Request::Params \
	Mail::Sender \
	MasonX::Profiler \
	MasonX::Request::WithApacheSession \
	match::smart \
	Math::Currency \
	MIME::Base64::URLSafe \
	MIME::Lite \
	MIME::Types \
	Mock::Quick \
	Module::Runtime \
	MooseX::ClassAttribute \
	Net::Braintree \
	Net::SMTP::TLS \
	Net::SMTPS \
	Params::Validate \
	PDF::FDF::Simple \
	Plack::I18N \
	SOAP::Lite \
	Spreadsheet::Write \
	Spreadsheet::WriteExcel \
	Spreadsheet::WriteExcel::Big \
	SQL::Abstract \
	Sub::Import \
	Sub::Name \
	Switch \
	Template::Mustache \
	Test::MockModule \
	Test::Pod::Coverage \
	Test::WWW::Mechanize \
	Text::CSV \
	Text::Textile \
	Text::Unaccent \
	Time::HiRes \
	Try::Tiny \
	WebService::FogBugz \
	XML::Liberal \
	XML::LibXML \
	XML::Simple \
	&& rm -Rf $PERL_CPANM_HOME

RUN mkdir -p /tmp/git/ && \
	git clone https://github.com/jackiig/mailgun.perl.git \
		/tmp/git/mailgun.perl \
	&& cd /tmp/git/mailgun.perl \
	&& perl Makefile.PL && make && make test && make install \
	&& cd / && rm -Rf /tmp/git

VOLUME /usr/src/app/
ADD . /usr/src/app/

## Enables prefork in Apache, copies in config and entry point, and sets up
##  v3's models.
RUN a2dismod mpm_event && a2enmod mpm_prefork cgi fcgid \
	&& mv /usr/src/app/mason-app.conf /etc/apache2/sites-enabled/000-default.conf \
	&& chown -R www-data:www-data /usr/src/app/

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/log/apache2/pid

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
