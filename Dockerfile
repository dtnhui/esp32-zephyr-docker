#
# Zephyr Docker Images
# Releases: https://github.com/zephyrproject-rtos/docker-image
#

ARG BASE_IMAGE
FROM ${BASE_IMAGE:-zephyrprojectrtos/ci-base:latest}

ARG ZSDK_VERSION=0.16.0
ARG WGET_ARGS="-q --show-progress --progress=bar:force:noscroll"

# Install Zephyr SDK
RUN mkdir -p /opt/toolchains && \
	cd /opt/toolchains && \
	wget ${WGET_ARGS} https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}.tar.xz && \
	tar xf zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}.tar.xz && \
	zephyr-sdk-${ZSDK_VERSION}/setup.sh -t all -h -c && \
	rm zephyr-sdk-${ZSDK_VERSION}_linux-${HOSTTYPE}.tar.xz

# Clean up stale packages
RUN apt-get clean -y && \
	apt-get autoremove --purge -y && \
	rm -rf /var/lib/apt/lists/*

# Run the Zephyr SDK setup script as 'user' in order to ensure that the
# `Zephyr-sdk` CMake package is located in the package registry under the
# user's home directory.
USER user

RUN sudo -E -- bash -c ' \
	/opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c && \
	chown -R user:user /home/user/.cmake \
	'

USER root
WORKDIR /workdir
RUN \
    west init && \
    west update && \
    pip3 install --user -r zephyr/scripts/requirements.txt && \
    pip3 install --user -r bootloader/mcuboot/scripts/requirements.txt

RUN west blobs fetch hal_espressif 
    
# Set the locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/toolchains/zephyr-sdk-${ZSDK_VERSION}
ENV ZEPHYR_BASE=/workdir/zephyr
ENV PATH="${ZEPHYR_BASE}/scripts:${PATH}"
