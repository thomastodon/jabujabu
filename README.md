## jabujabu
Deploying concourse to [Google Compute Engine](https://cloud.google.com/compute), 
based on this [guide](https://github.com/cloudfoundry-incubator/bosh-google-cpi-release/tree/master/docs/concourse)

Get tools:
```
brew cask install google-cloud-sdk
```

Add bosh and root ssh keys to gcloud via the console

Terraform everything:
```
terraform apply
```

SSH onto the bastion VM:
```
gcloud compute ssh bosh-bastion-concourse
```

finish provisioning things:
```
bosh login admin admin
bosh target 10.0.0.6
bosh upload stemcell https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent?v=3445.11
bosh upload release https://bosh.io/d/github.com/concourse/concourse?v=3.5.0
bosh upload release https://bosh.io/d/github.com/cloudfoundry/garden-runc-release?v=1.6.0
export external_ip=`gcloud compute addresses describe --region us-central1 concourse | grep ^address: | cut -f2 -d' '`
export director_uuid=`bosh status --uuid 2>/dev/null`
```

deploy concourse:
```
bosh update cloud-config /google-bosh-director/cloud-config.yml
bosh deployment /google-bosh-director/concourse.yml
bosh deploy
```

add a dns record for concourse atc:
```
compute instances list
gcloud dns record-sets transaction add --zone thomasshoulerio \
      --name conccourse. --ttl 300 \
      --type A "<EXTERNAL_IP_FROM_INSTANCE_ABOVE>"
```
