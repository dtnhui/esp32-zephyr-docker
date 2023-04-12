# Zephyr Docker Image for ESP32 development and CI

## Setup

### Build Docker Image
```
docker build -t zephyr-esp32:v0.16.0 .
```

## Usage
### Building application from local workspace
```
docker run -ti -v <workspace path>:/workdir/workspace -w /workdir/workspace zephyr-esp32:v0.16.0
```

### Automated build script example (Windows)
```
docker run --rm -v %cd%:/workdir/workspace -w /workdir/workspace zephyr-esp32:v0.16.0 west build -p always -b esp32c3_devkitm
```

### Automated build script example (Linux)
```
docker run --rm -v ${PWD}:/workdir/workspace -w /workdir/workspace zephyr-esp32:v0.16.0 west build -p always -b esp32c3_devkitm
```