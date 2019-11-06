**Getting Setup**

 - Get AWS origin account keys
 - Run `gem install test-kitchen`
 - Install chefdk https://docs.chef.io/install_dk.html
 - Install kitchen-ec2 https://github.com/test-kitchen/kitchen-ec2
 - Run `bundle install`
 - Update kitchen.yml w/ subnet, snap and ami info look for {}
 
**Commands**

 - bundle exec kitchen create
 - bundle exec kitchen verify (optionally include windows or ubuntu to run against a particular AMI)
 - bundle exec kitchen destroy

**More info**

 - https://www.ssh.com/ssh/config/
 - Note: pem key is in .kitchen. To use SSH, cd to .kitchen and run similar command:  `ssh -i "{{machine}}.pem" ubuntu@{{instance}}.{{region}}.compute.amazonaws.com`
  
 **Dependencies**

 - Linux patch baseline releases https://github.com/dev-sec/linux-patch-baseline/releases
 - Windows patch baseline releases https://github.com/dev-sec/windows-patch-baseline/releases