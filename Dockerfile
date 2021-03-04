# Dockerfile for time2backup server

FROM alpine:latest

ENV BRANCH=stable
ENV VERSION=1.0.3

# 1. Install dependencies
# 2. Init and secure openssh server
# 3. Create t2b user
# 4. Download time2backup server
# 5. Uncompress it
RUN apk add --no-cache bash rsync sudo openssh curl && \
    /usr/bin/ssh-keygen -A && \
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_key && \
    sed -i 's/^.*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "AllowUsers t2b" >> /etc/ssh/sshd_config && \
    adduser -D t2b && echo t2b:time2backup | chpasswd && \
    curl -o /tmp/time2backup.tgz https://time2backup.org/download/server/$BRANCH/$VERSION/time2backup-server-$VERSION.tar.gz && \
    cd / && tar zxf /tmp/time2backup.tgz

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh

# 1. Secure files
# 2. Install time2backup server
# 3. Add t2b user to t2b-server group
RUN chown root:root /docker-entrypoint.sh && chmod 700 /docker-entrypoint.sh && \
    /time2backup-server/install.sh > /dev/null && \
    adduser t2b t2b-server

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
