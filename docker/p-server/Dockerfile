FROM centos:7
MAINTAINER Biggs

RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
ADD mirrors.liquidweb.repo /etc/yum.repos.d/
RUN yum -y update && yum clean all
ADD dev.prov.repo /etc/yum.repos.d/

RUN rpm --import http://dev.prov.repos.int.sourcedns.com/provrpm.pub.key
RUN yum install -y git gcc make postgresql-devel lp-skel lwprov-perl && yum clean all
RUN yum install -y --nogpgcheck lwprov-pserver-modules && yum clean all

ADD context /usr/local/lp/configs/context
ENV LWDEVPATH /usr/local/lp
RUN mkdir -p /usr/local/lp/libs /usr/local/lp/git /usr/local/lp/configs/LWConfig
RUN cd /usr/local/lp/git && git clone git://devtools.int.liquidweb.com/lw-plack-app-provision-server
RUN cd /usr/local/lp/git/lw-plack-app-provision-server && /usr/local/lp/lwprov/bin/perl Makefile.PL && make && make install
RUN ln -s /usr/local/lp/git/lw/LWClasses/ /usr/local/lp/libs/perl

CMD /usr/local/lp/lwprov/bin/plackup /usr/local/lp/lwprov/bin/pserver-app.psgi

