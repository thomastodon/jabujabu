## jabujabu

from jabujabu, enable ssh
```
$ sudo systemsetup -setremotelogin on
```

from the client, copy your keys over to jabujabu
```
$ ssh-copy-id jabujabu.local
```

ssh into jabujabu
```
$ ssh jabujabu.local
```

Generate a new ssh key pair. Add the public key to github.
```
$ ssh-keygen -t rsa
```

Clone down this repo
```
$ git clone git@github.com:thomastodon/jabujabu.git
```

Install docker. Build and start a docker machine
```
$ brew install docker docker-compose docker-machine libyaml
$ brew cask install virtualbox
$ docker-machine create --driver virtualbox default
$ eval "$(docker-machine env default)"
```

Generate keys
```
$ mkdir -p keys/web keys/worker
$ ssh-keygen -t rsa -f ./keys/web/tsa_host_key -N ''
$ ssh-keygen -t rsa -f ./keys/web/session_signing_key -N ''
$ ssh-keygen -t rsa -f ./keys/worker/worker_key -N ''
$ cp ./keys/worker/worker_key.pub ./keys/web/authorized_worker_keys
$ cp ./keys/web/tsa_host_key.pub ./keys/worker
```

```
docker-compose up
```