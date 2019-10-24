# Dockerfile intended to be used as a build 
# environment for Swift SDK

FROM swift:5.1-bionic

RUN apt-get update && \
    apt-get -y install python3 libsodium-dev openssl libssl-dev libzip-dev

# # Cross compilation headers are required
# RUN apt-get update && \
#     apt-get -y install gcc-multilib g++-multilib \
#                        wget xz-utils \
#                        python-dev python python-pip \
#                        python3-dev python3 python3-pip \
#                        libudev-dev \
#                        libusb-1.0-0-dev \
#                        libtinfo5 \
#                        clang-tidy clang-format \
#                        protobuf-compiler python-protobuf python3-protobuf
COPY x.py /opt/x.py

ENTRYPOINT [ "/opt/x.py" ]
WORKDIR /workspace
