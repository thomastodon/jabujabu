## jabujabu
Deploying concourse to [Google Compute Engine](https://cloud.google.com/compute/)

Get tools:
```
brew cask install google-cloud-sdk
```

Set some environment variables for the project:
```
export projectid=jabujabu-id
export region=us-central1
export zone=us-central1-a
export zone2=us-central1-b
```

Terraform the bosh director
```
terraform apply
```

SSH onto the bastion VM:
```
gcloud compute ssh bosh-bastion-concourse
```