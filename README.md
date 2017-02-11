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

$ brew install docker docker-compose docker-machine libyaml
$ brew cask install virtualbox
$ docker-machine create --driver virtualbox default
$ eval "$(docker-machine env default)"
