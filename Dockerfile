#
# Zephyr Docker Image
# Releases: https://github.com/zephyrproject-rtos/docker-image/releases
#
ARG BASE_IMAGE
FROM ${BASE_IMAGE:-zephyrprojectrtos/ci-base:latest}

#
# Zephyr SDK
# Releases: https://github.com/zephyrproject-rtos/sdk-ng/releases
#
ARG ZEPHYR_SDK_VERSION=0.16.0
ARG WGET_ARGS="-q --show-progress --progress=bar:force:noscroll"

RUN mkdir -p /opt/toolchains && \
	cd /opt/toolchains && \
	wget ${WGET_ARGS} https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HOSTTYPE}.tar.xz && \
	tar xf zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HOSTTYPE}.tar.xz && \
	zephyr-sdk-${ZEPHYR_SDK_VERSION}/setup.sh -t all -h -c && \
	rm zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-${HOSTTYPE}.tar.xz

# Clean up stale packages
RUN apt-get clean -y && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /workdir
RUN \
    west init && \
    west update && \
    pip3 install --user -r zephyr/scripts/requirements.txt && \
    pip3 install --user -r bootloader/mcuboot/scripts/requirements.txt

RUN west blobs fetch hal_espressif 

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/toolchains/zephyr-sdk-${ZEPHYR_SDK_VERSION}
ENV ZEPHYR_BASE=/workdir/zephyr
ENV PATH="${ZEPHYR_BASE}/scripts:${PATH}"
