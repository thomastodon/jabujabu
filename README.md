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

Build and start a docker machine
```
$ brew install docker docker-compose docker-machine libyaml
$ brew cask install virtualbox
$ docker-machine create --driver virtualbox default
$ eval "$(docker-machine env default)"
```

Generate a new ssh key pair. Add the public key to github.
```
$ ssh-keygen -t rsa
```

Clone down this repo
```
$ git clone git@github.com:thomastodon/jabujabu.git
```

```
$ export CONCOURSE_EXTERNAL_URL=http://192.168.99.100:8080
```