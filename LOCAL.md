## jabujabu
Deploying concourse to local hardware with docker-compose

from **jabujabu**, enable ssh:
```
$ sudo systemsetup -setremotelogin on
```

from the client, copy your keys over to **jabujabu**:
```
$ ssh-copy-id jabujabu.local
```

ssh into **jabujabu**:
```
$ ssh jabujabu.local
```

install homebrew. this will pull down Command Line Tools as well:
```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

install docker:
```
$ brew install docker docker-compose docker-machine libyaml
$ brew cask install virtualbox fly
```

create a docker machine, and configure virtualbox to forward the port:
```
$ docker-machine create --driver virtualbox default
$ docker-machine stop default
$ vboxmanage modifyvm default --natpf1 'http,tcp,,8080,,8080'
$ docker-machine start default
$ eval "$(docker-machine env default)"
```

generate a new ssh key pair. Add the public key to github:
```
$ ssh-keygen -t rsa
```

clone down this repo, and step into it:
```
$ git clone git@github.com:thomastodon/jabujabu.git
```

generate keys:
```
$ mkdir -p keys/web keys/worker
$ ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
$ ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''
$ ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''
$ cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
$ cp ./keys/web/tsa_host_key.pub ./keys/worker
```

```
$ docker-compose up
```

Assign **jabujabu** a static IP, and go see the concourse GUI on port 8080 from a networked workstation.