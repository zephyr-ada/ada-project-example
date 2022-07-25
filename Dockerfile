FROM ubuntu:22.04

# common dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        # python
        python3-dev \
        python3-pip \
        python3-tk \
        python3-wheel \
        python3-setuptools \
        # some system
        libsdl2-dev \
        xz-utils \
        wget \
        curl \
        gpg \
        git \
        ssh \
        file \
        gperf \
        # build tools
        make \
        cmake \
        clangd \
        ccache \
        gprbuild \
        ninja-build \
        # other
        dfu-util \
        device-tree-compiler

# install west
RUN pip3 install west pyelftools

# add zephyr-ada repo
RUN echo 'deb http://download.opensuse.org/repositories/home:/ila.embsys:/zephyr-ada/xUbuntu_22.04/ /' \
    | tee /etc/apt/sources.list.d/home:ila.embsys:zephyr-ada.list

RUN curl -fsSL https://download.opensuse.org/repositories/home:ila.embsys:zephyr-ada/xUbuntu_22.04/Release.key \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/home_ila.embsys_zephyr-ada.gpg > /dev/null

# install toolchain
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y \
        arm-zephyr-eabi \
        cmake-ada \
        gprconfig-kb-gnat-zephyr 

# create user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Add JLink debugger
# ==================
RUN apt-get update && apt install -y --no-install-recommends \
    libncurses5

ARG JLINK_DEB=JLink_Linux_x86_64.deb

RUN wget --progress=dot:giga  \
    --post-data 'accept_license_agreement=accepted&non_emb_ctr=confirmed' \
    https://www.segger.com/downloads/jlink/${JLINK_DEB} \
    && dpkg -i ${JLINK_DEB} || true \
    && rm ${JLINK_DEB} \
    && apt --fix-broken install -y

ENV PATH="/opt/SEGGER/JLink:${PATH}"

# Add Renode
# ==========

ARG RENODE_VERSION=1.13.0

# Install Renode
RUN wget --progress=dot:giga https://github.com/renode/renode/releases/download/v${RENODE_VERSION}/renode_${RENODE_VERSION}_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./renode_${RENODE_VERSION}_amd64.deb python3-dev && \
    rm ./renode_${RENODE_VERSION}_amd64.deb && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install -r /opt/renode/tests/requirements.txt --no-cache-dir

# Set locales
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.UTF-8

# set arg value to env to be visible on child images
ENV USERNAME=$USERNAME
USER $USERNAME

WORKDIR /home/$USERNAME