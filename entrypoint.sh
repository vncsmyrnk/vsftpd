#!/bin/sh

FTP_USER=nobody

mkdir -p /var/run/vsftpd/empty

if [ -z "$FTP_PASS" ]; then
  echo "FATAL: Please set the FTP_PASS environment variables."
  exit 1
fi

# Create user with useradd (from shadow package)
useradd -m -d "/home/$FTP_USER" -s /bin/sh "$FTP_USER"

# Set password using passwd
echo "$FTP_USER:$FTP_PASS" | chpasswd -c SHA512

/bin/vsftpd
