# Trying Dockerfile

How to build:

	VERSION_IN_TAG=2.2.35 ALPINE_VERSION=3.16.1 sh docker-gnupg.sh
	VERSION=0.14.0 UBI_VERSION=8.6-394 ALPINE_VERSION=3.16.1 sh docker-gpgpdump.sh

Note in 2023Q1:

	VERSION_IN_TAG=2.2.40 ALPINE_VERSION=3.17.1 sh docker-gnupg.sh
	VERSION=0.15.0 UBI_VERSION=9.1.0-13 ALPINE_VERSION=3.17.1 sh docker-gpgpdump.sh

If you run redhat/ubi9-micro images on x64 architecture, you need CPUs compatible with x86-64-v2 variant or later.

Example run:

	docker volume create testgpg
	docker run -v testgpg:/mnt --rm --network none alpine:3.16.1 sh -c 'mkdir /mnt/test && chown 1000:1000 /mnt/test'
	docker run -u1000:1000 -v testgpg:/mnt --rm alpine:3.16.1 wget -O/mnt/test/test.asc "http://${url}"
	docker run -v testgpg:/mnt:ro --rm --network none gpgpdump:0.14.0-ubi8-micro8.6-394 sh -c 'gpgpdump </mnt/test/test.asc'
	docker run -itv testgpg:/mnt:ro --rm --network none gnupg:2.2.35-alpine3.16.1
	# gpg --import /mnt/test/test.asc # in the container

Memo for a useful combination:

	echo "$data" | docker run -iu1000:1000 -v "$dir":/mnt -w /mnt --rm --network none alpine:3.16.1 sh -c 'base64 -d | tar xzf -'
