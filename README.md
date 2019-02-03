# docker port forward

`kubctl port-forward` for docker

Tiny shell script to port-forward a local port to a specified [Docker](https://www.docker.com) container **already running**.


## Usage

```sh
dpf <container-name> <local-port> <container-port>
```

or simply:

```sh
dpf <container-name> <port>
```


## Installation

To install or update dpf, you can use the [install script](install.sh) using cURL:

```sh
curl -o- https://raw.githubusercontent.com/vspiewak/dpf/master/install.sh | bash
```

or Wget:

```sh
wget -qO- https://raw.githubusercontent.com/vspiewak/dpf/master/install.sh | bash
```
