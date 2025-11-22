FROM ubuntu:noble
ENV DEBIAN_FRONTEND=noninteractive

RUN \
  apt update -y && \
  apt upgrade -y && \
  apt install -y sudo git make openjdk-17-jdk device-tree-compiler curl gawk python-is-python3 locales lsb-release \
    libncurses-dev libmpc-dev libssl-dev gcc gcc-riscv64-linux-gnu flex bison bc udev dosfstools unzip pigz wget && \
  apt autoclean && \
  apt autoremove

# Install libtinfo5 which is required by Vivado but not available by default on Ubuntu 23.04+
RUN \
  wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
  sudo apt install -y ./libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
  rm libtinfo5_6.3-2ubuntu0.1_amd64.deb

RUN \
  locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"

COPY vivado-installer/ /vivado-installer/

# Install the Xilinx Vivado tools and updates in headless mode
ARG VIVADO_VERSION=2025.2
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

# Download and install board files
RUN \
  if [ -d /opt/Xilinx/Vivado/${VIVADO_VERSION} ] ; then \
    VIVADO_HOME=/opt/Xilinx/Vivado/${VIVADO_VERSION} ; \
  else \
    VIVADO_HOME=/opt/Xilinx/${VIVADO_VERSION}/Vivado ; \
  fi && \
  cp ${VIVADO_HOME}/settings64.sh /etc/profile.d/vivado-settings.sh && \
  unzip /vivado-installer/board_files.zip -d ${VIVADO_HOME}/data/boards/board_files && \
  git config --system --add safe.directory '*' && \
  cd / && \
  git clone --branch ${VIVADO_VERSION} --single-branch https://github.com/Xilinx/XilinxBoardStore.git && \
  mkdir -p ${VIVADO_HOME}/data/boards/board_files/XilinxBoardStore && \
  cp -r XilinxBoardStore/boards/* ${VIVADO_HOME}/data/boards/board_files/XilinxBoardStore/ && \
  rm -rf ${VIVADO_HOME}/data/boards/board_files/XilinxBoardStore/iWave && \
  rm -rf XilinxBoardStore && \
  git clone https://github.com/Digilent/vivado-boards.git && \
  mkdir -p ${VIVADO_HOME}/data/boards/board_files/Digilent && \
  cp -r vivado-boards/new/board_files/* ${VIVADO_HOME}/data/boards/board_files/Digilent/ && \
  rm -rf vivado-boards

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

# Workaround for Vivado crash
ENV LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1

# ENV var to help users to find the version of Vivado
ENV VIVADO_VERSION=${VIVADO_VERSION}

WORKDIR /src
ARG HOST_GID=1000
ARG HOST_UID=1000
RUN getent group $HOST_GID || groupadd -g $HOST_GID vivado
RUN if getent passwd $HOST_UID ; then usermod -d /src `id -un $HOST_UID` ; else useradd -u $HOST_UID -g $HOST_GID -d /src vivado ; fi
RUN echo "#$HOST_UID ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vivado-sudoers
