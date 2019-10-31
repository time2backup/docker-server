# Dockerfile for time2backup server

FROM alpine:latest

# 1. Install dependencies
# 2. Init and secure openssh server
# 3. Create t2b user
RUN apk add --no-cache bash rsync sudo openssh && \
    /usr/bin/ssh-keygen -A && \
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_key && \
    sed -i 's/^.*PasswordAuthentication[[:space:]].*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "AllowUsers t2b" >> /etc/ssh/sshd_config && \
    adduser -D t2b && echo t2b:time2backup | chpasswd

# Copy time2backup server sources and entrypoint
COPY time2backup-server /time2backup-server
COPY docker-entrypoint.sh /docker-entrypoint.sh

# 1. Secure files
# 2. Create time2backup-server global link
RUN chown -R root:t2b /time2backup-server && chmod -R 750 /time2backup-server && \
    chown root:root /docker-entrypoint.sh && chmod 700 /docker-entrypoint.sh && \
    ln -sf /time2backup-server/t2b-server.sh /usr/bin/time2backup-server

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
