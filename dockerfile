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
# i have chosen /usr/app/src

WORKDIR /home
RUN git config --global user.name "Oren Collaco"
RUN git config --global user.email "orencollaco97@gmail.com"
RUN git clone https://nero7991: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@github.com/CCI-NextG-Testbed/GoogleSASClient
WORKDIR /home/GoogleSASClient
RUN pip install -r requirements.txt

#CMD instruction should be used to run the software
#contained by your image, along with any arguments.
CMD cd GoogleSASClient
CMD [ "python3", "client.py"]