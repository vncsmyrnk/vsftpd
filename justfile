default:
  just --list

build:
  nix build -L .#docker
  docker load < result

run-example:
  docker run -it --rm \
    -p 21:21 \
    -v ./upload:/home/ftpuser/ftp/upload \
    -e FTP_USER=nobody \
    -e FTP_PASS=password \
    vsftpd:latest
