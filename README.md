# Dockerfile for Arduino development environment

This Dockerfile aims to create a development environment for the Arduino platform in a Debian 11 image.
This image supports there cores:

- AVR
- ESP32
- ESP8266

## How to build the Image

To build the image, use this command:

```bash
  docker build --no-cache --build-arg "host_uid=$(id -u)" --build-arg "host_gid=$(id -g)" --pull --rm -t arduino-cli-container:v0.0.1 .
```

## Run the docker Image

In the project directory, run:

```bash
    docker run --rm -it --privileged -p 50051:50051 -v ${PWD}:/arduino -w /arduino -it arduino-cli-container:v0.0.1
```

## Compile sketch

- https://arduino.github.io/arduino-cli/0.32/commands/arduino-cli_compile/

## Upload binary

- https://arduino.github.io/arduino-cli/0.32/commands/arduino-cli_upload/

## TODO

Improve the documentation
