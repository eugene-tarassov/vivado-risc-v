FROM ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update -y && \
  apt upgrade -y && \
  apt install -y sudo git make default-jdk device-tree-compiler curl gawk python locales lsb-release \
    libtinfo5 libmpc-dev libssl-dev gcc gcc-riscv64-linux-gnu flex bison bc udev dosfstools unzip pigz wget && \
  apt autoclean && \
  apt autoremove

RUN \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

COPY vivado-installer/ /vivado-installer/

# Install the Xilinx Vivado tools and updates in headless mode
ARG VIVADO_VERSION=2023.2
# Xilinx installer tar file originally from: https://www.xilinx.com/support/download.html
ARG VIVADO_INSTALLER="*_${VIVADO_VERSION}_*.tar.gz"
ARG VIVADO_UPDATE=""
# Installer config file
ARG VIVADO_INSTALLER_CONFIG="/vivado-installer/install_config_vivado.${VIVADO_VERSION}.txt"
RUN \
  VIVADO_INSTALLER_CNT=$(ls -1 /vivado-installer/$VIVADO_INSTALLER | wc -l) ; \
  if [ $VIVADO_INSTALLER_CNT != 1 ] ; then \
    echo "No Xilinx installer tar file was provided." ; \
    echo "Expected 1 file named like vivado-installer/$VIVADO_INSTALLER." ; \
    echo "Download the file from: https://www.xilinx.com/support/download.html" ; \
    exit 1 ; \
  fi
RUN \
  mkdir -p /vivado-installer/install && \
  ( pigz -dc /vivado-installer/$VIVADO_INSTALLER | tar xa --strip-components=1 -C /vivado-installer/install ) && \
  rm /vivado-installer/$VIVADO_INSTALLER && \
  if [ ! -e ${VIVADO_INSTALLER_CONFIG} ] ; then \
    /vivado-installer/install/xsetup \
      -p 'Vivado' \
      -e 'Vivado ML Enterprise' \
      -b ConfigGen && \
    echo "No installer configuration file was provided. Generating a default one for you to modify." && \
    echo "-------------" && \
    cat /root/.Xilinx/install_config.txt && \
    echo "-------------" && \
    exit 1 ; \
  fi && \
  /vivado-installer/install/xsetup \
    --agree 3rdPartyEULA,XilinxEULA \
    --batch Install \
    --config ${VIVADO_INSTALLER_CONFIG} && \
  rm -r /vivado-installer/install
RUN \
  if [ ! -z "$VIVADO_UPDATE" ] ; then \
    mkdir -p /vivado-installer/update && \
    ( pigz -dc /vivado-installer/$VIVADO_UPDATE | tar xa --strip-components=1 -C /vivado-installer/update ) && \
    rm /vivado-installer/$VIVADO_UPDATE && \
    /vivado-installer/update/xsetup \
      --agree 3rdPartyEULA,XilinxEULA \
      --batch Update \
      --config ${VIVADO_INSTALLER_CONFIG} && \
    rm -r /vivado-installer/update ; \
  fi
RUN \
  unzip /vivado-installer/board_files.zip -d /opt/Xilinx/Vivado/${VIVADO_VERSION}/data/boards/board_files
RUN \
  rm -rf /vivado-installer

# Apply post-install patches to fix issues found on each OS release
# Common patches
#   * Disable workaround for X11 XSupportsLocale bug.  This workaround triggers additional requirements on the host
#     to have an entire suite of X11 related libraries installed even though we only use vivado in batch/tcl mode.
#     See: https://support.xilinx.com/s/article/62553?language=en_US
COPY patches/ /patches
RUN \
  if [ -e "/patches/ubuntu-$(lsb_release --short --release)-vivado-${VIVADO_VERSION}-postinstall.patch" ] ; then \
    patch -p 1 < /patches/ubuntu-$(lsb_release --short --release)-vivado-${VIVADO_VERSION}-postinstall.patch ; \
  fi ; \
  if [ -e "/patches/vivado-${VIVADO_VERSION}-postinstall.patch" ] ; then \
    patch -p 1 < /patches/vivado-${VIVADO_VERSION}-postinstall.patch ; \
  fi
RUN \
  rm -rf /patches

RUN git config --system --add safe.directory '*'

# Download and install board files
RUN \
  cd / && \
  git clone --branch ${VIVADO_VERSION} https://github.com/Xilinx/XilinxBoardStore.git && \
  mkdir -p /opt/Xilinx/Vivado/${VIVADO_VERSION}/data/boards/board_files/XilinxBoardStore && \
  cp -r XilinxBoardStore/boards/* /opt/Xilinx/Vivado/${VIVADO_VERSION}/data/boards/board_files/XilinxBoardStore/ && \
  rm -rf XilinxBoardStore && \
  git clone https://github.com/Digilent/vivado-boards.git && \
  mkdir -p /opt/Xilinx/Vivado/${VIVADO_VERSION}/data/boards/board_files/Digilent && \
  cp -r vivado-boards/new/board_files/* /opt/Xilinx/Vivado/${VIVADO_VERSION}/data/boards/board_files/Digilent/ && \
  rm -rf vivado-boards

# Workaround for Vivado crash
ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1

# ENV vars to help users to find the version and installation directory of Vivado
ENV VIVADO_VERSION=${VIVADO_VERSION}
ENV VIVADO_HOME=/opt/Xilinx/Vivado/${VIVADO_VERSION}

WORKDIR /src
ARG HOST_UID=1000
ARG HOST_GID=1000
RUN groupadd -g $HOST_GID vivado
RUN useradd -u $HOST_UID -g $HOST_GID -d /src vivado
RUN cp /opt/Xilinx/Vivado/${VIVADO_VERSION}/settings64.sh /etc/profile.d/vivado-settings.sh
RUN echo 'vivado ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/vivado-sudoers
