# docker port forward

`kubctl port-forward` like for docker


## Usage

```sh
dpf <container-name> <local-port> <container-port>
```

or

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
