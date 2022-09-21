ARG GIT_TOKEN=

#Deriving the latest base image
FROM    ubuntu:focal

#Labels as key value pair
LABEL Maintainer="orencollaco"

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2019-05-15

# This will make apt-get install without question
ARG         DEBIAN_FRONTEND=noninteractive
ARG         UHD_TAG=v3.15.0.0
ARG         MAKEWIDTH=2

# Install security updates and required packages
RUN         apt-get update
RUN         apt-get -y install -q \
                build-essential \
                ccache \
                git \
                python3-dev \
                python3-pip \
                curl \
                gnome-terminal


# Any working directory can be chosen as per choice like '/' or '/home' etc

# Install UHD dependencies
RUN         apt-get -y install -q \
                libboost-all-dev \
                libusb-1.0-0-dev \
                libudev-dev \
                python3-mako \
                doxygen \
                python3-docutils \
                cmake \
                python3-requests \
                python3-numpy \
                dpdk \
                libdpdk-dev

RUN          rm -rf /var/lib/apt/lists/*

RUN          mkdir -p /usr/local/src
RUN          git clone https://github.com/EttusResearch/uhd.git /usr/local/src/uhd
RUN          cd /usr/local/src/uhd/ && git checkout $UHD_TAG
RUN          mkdir -p /usr/local/src/uhd/host/build
WORKDIR      /usr/local/src/uhd/host/build
RUN          cmake .. -DENABLE_PYTHON3=ON -DUHD_RELEASE_MODE=release -DCMAKE_INSTALL_PREFIX=/usr
RUN          make -j $MAKEWIDTH
RUN          make install
RUN          uhd_images_downloader

RUN apt update

RUN DEBIAN_FRONTEND=noninteractive apt install -y \
     build-essential \
     cmake libfftw3-dev \
     libmbedtls-dev \
     libboost-program-options-dev \
     libconfig++-dev \
     libsctp-dev \
     curl \
     iputils-ping \
     iproute2 \
     iptables \
     unzip \
     git \
     gcc-10 g++-10  \
     tmux
     
RUN update-alternatives --install /usr/bin/gcc gcc  /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10

RUN update-alternatives --config gcc

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /srsran

# Pinned git commit used for this example
#22.04.1
#ARG COMMIT=ce8a3cae171f08c9bce83ae3611e56f2d168d073 

#21.10
ARG COMMIT=5275f33360f1b3f1ee8d1c4d9ae951ac7c4ecd4e  

# Download and build
RUN git clone https://github.com/srsRAN/srsRAN.git ./
RUN git fetch origin ${COMMIT}
RUN git checkout ${COMMIT}

WORKDIR /srsran/build

RUN cmake -j$(nproc) ../ -D USE_LTE_RATES=ON
RUN make -j$(nproc)
RUN make -j$(nproc) install
RUN srsran_install_configs.sh user

# Update dynamic linker
RUN apt-get update
RUN apt-get install net-tools -y
RUN apt-get install vim -y
RUN ldconfig

# Clone the SAS client and install requirements
WORKDIR /home
RUN git config --global user.name "Oren Collaco"
RUN git config --global user.email "orencollaco97@gmail.com"
RUN git clone https://nero7991:@github.com/CCI-NextG-Testbed/GoogleSASClient
WORKDIR /home/GoogleSASClient
RUN pip install -r requirements.txt
RUN chmod +x start_cbsd.sh

#CMD instruction should be used to run the software
#contained by your image, along with any arguments.
#CMD [ "/bin/bash", ""]
CMD ["./start_cbsd.sh"]

#CMD [ "tmux",  "new-session -d -s sas_client 'python3 client.py'"]