############################################################
# Dockerfile to build php container images
# Based on Centos 7.5
############################################################
FROM centos:7.5.1804

# 导入证书
RUN rpm --import /etc/pki/rpm-gpg/RPM* && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && export TERM=linux

# 安装Apache & PHP
ADD oneinstack.tar.gz /
RUN /oneinstack/install.sh --apache_option 1 --apache_mpm_option 1 --apache_mode_option 2 --php_option 6 --php_extensions \
     imagick,fileinfo,imap,redis,memcached,memcache,mongodb,xdebug

# 工作目录
WORKDIR /data/wwwroot

# PHP扩展
COPY no-debug-zts-20160303/*.so /usr/local/php/lib/php/extensions/no-debug-zts-20160303/
ADD rabbitmq-c.tar.gz /usr/local/
RUN echo "extension=amqp.so" > /usr/local/php/etc/php.d/02.amqp.ini && \
    echo "extension=phalcon.so" > /usr/local/php/etc/php.d/00.phalcon.ini && \
    echo "extension=ssh2.so" > /usr/local/php/etc/php.d/00.ssh2.ini && rm -rf /oneinstack

STOPSIGNAL WINCH

# 开放端口 80:web 9000:PHPStorm
EXPOSE 88 9000

# 启动脚本
COPY httpd-foreground /usr/local/bin/
CMD ["httpd-foreground"]