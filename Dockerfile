FROM debian:11
ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN \
    apt update && \
    apt install -y --no-install-recommends \
    locales curl sudo libssl-dev ca-certificates bash-completion

# Install extra packages
RUN apt install -y --no-install-recommends vim git wget curl zip python3 python3-pip

# Configure default python version
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1

RUN pip3 install esptool pyserial

# Clean apt cache
RUN \
    apt clean && \
    rm -rf /var/lib/apt

# Configure Timezone
ENV TZ=Etc/UTC
RUN \
    ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    echo "Etc/UTC" > /etc/timezone

# Configure locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# Add non-root user
ENV USER_NAME arduino
ARG host_uid=1000
ARG host_gid=1000
RUN groupadd -g $host_gid ${USER_NAME} && \
    useradd -g $host_gid -m -s /bin/bash -u $host_uid ${USER_NAME} && \
    usermod -aG dialout arduino

USER ${USER_NAME}
ENV HOME /home/${USER_NAME}
RUN mkdir -p ${HOME}/bin

# Setup path
ENV BINDIR="${HOME}/bin"
ENV PATH="${PATH}:${HOME}/bin"
RUN echo $PATH

# Install arduino-cli
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

# Initialize configuration
RUN arduino-cli config init

##### Add aditional boards to config"
RUN arduino-cli config add board_manager.additional_urls https://downloads.arduino.cc/packages/package_staging_index.json

# ESP32 - Stable
RUN arduino-cli config add board_manager.additional_urls https://espressif.github.io/arduino-esp32/package_esp32_index.json
# ESP32 - Development
#RUN arduino-cli config add board_manager.additional_urls https://espressif.github.io/arduino-esp32/package_esp32_dev_index.json

# ESP8266
RUN arduino-cli config add board_manager.additional_urls https://arduino.esp8266.com/stable/package_esp8266com_index.json

# Set user directory
# RUN arduino-cli config set directories.user /home/${USER_NAME}/Arduino
RUN arduino-cli config set directories.user /arduino

# Update the index of cores"
RUN arduino-cli core update-index

# Install boards cores
RUN arduino-cli core install arduino:avr
RUN arduino-cli core install esp32:esp32
RUN arduino-cli core install esp8266:esp8266

# Configure bash completion for arduino-cli
RUN arduino-cli completion bash > ${HOME}/bin/arduino-completion.sh 
RUN echo "source ${HOME}/bin/arduino-completion.sh " >> ${HOME}/.bashrc

# Daemon port
EXPOSE 50051/tcp

#WORKDIR /home/${USER_NAME}/Arduino
WORKDIR /arduino
CMD ["/bin/bash"]

