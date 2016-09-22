#!/bin/bash

set -ue

readonly ZPOOL=vmpool

if [[ $# -ne 2 ]]; then
  echo $( basename $0 ) release vmid >&2
  exit 1
fi

release=$1
vmid=$2

imagename () {
  echo "${1}-server-cloudimg-amd64-disk1.img"
}

download () {

  local rel=$1
  local url="https://cloud-images.ubuntu.com/${rel}/current/" \
        img=$( imagename $rel ) \
        sha="SHA256SUMS" \
        gpg="SHA256SUMS.gpg" \
        url

  rm -f $sha $gpg
  ### Download the image, sha256 checksum file and the GPG signature of the
  ### sha256sum file
  for file in $img $sha $gpg; do
    wget --timestamp --quiet --tries=5 \
         --continue $url/$file --output-document=$file
  done

  ### Verify the GPG signature of the SHA256SUMS file
  gpg --keyserver hkp://keyserver.ubuntu.com \
      --batch --no-tty --quiet               \
      --recv-keys 0xD2EB44626FDDC30B513D5BB71A5D6C4C7DB87C81 2>/dev/null
  gpg --verify --quiet --batch --no-tty --trust-model always $sha.gpg \
      $sha 2>/dev/null

  ### Verify the SHA256 sum of the image
  grep $img $sha | sha256sum --check --quiet  

  qemu-img convert -O raw $img ${img%.*}.raw  
  echo ${img%.*}.raw
}

replacehd () {
  local vmid=$1 img=$2 

  sudo dd if=$img of=/dev/zvol/$ZPOOL/vm-${vmid}-disk-1 bs=1M
  sudo /usr/sbin/qm set $vmid -serial0 socket
}

replacehd $vmid $( download $release )

# vim: set ts=2 sts=0 et sw=2 smarttab :
