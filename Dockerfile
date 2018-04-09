# Run `make run` to get things started

# our image is centos default image with systemd
FROM centos/systemd

MAINTAINER "Fabien ANTOINE" <fabien.antoine@m4x.org>

# this is the version what we're building
ENV TABLEAU_VERSION="10-5-0" \
    LANG=en_US.UTF-8

# make systemd dbus visible 
VOLUME /sys/fs/cgroup /run /tmp /var/opt/tableau

COPY tableau-tabcmd-${TABLEAU_VERSION}.noarch.rpm /var/tmp/
COPY tableau-server-${TABLEAU_VERSION}.x86_64.rpm /var/tmp/

# Install core bits and their deps:w
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y iproute curl sudo vim && \
    adduser tsm && \
    (echo tsm:tsm | chpasswd) && \
    (echo 'tsm ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tsm) && \
    mkdir -p  /run/systemd/system /opt/tableau/docker_build && \
    yum install -y \
	    /var/tmp/tableau-tabcmd-${TABLEAU_VERSION}.noarch.rpm \
	    /var/tmp/tableau-server-${TABLEAU_VERSION}.x86_64.rpm &&\
    rm -rf /var/tmp/*rpm 


COPY config/* /opt/tableau/docker_build/

RUN mkdir -p /etc/systemd/system/ && \
    cp /opt/tableau/docker_build/tableau_server_install.service /etc/systemd/system/ && \
    systemctl enable tableau_server_install

# Expose TSM and Gateway ports
EXPOSE 80 8850

CMD /sbin/init
