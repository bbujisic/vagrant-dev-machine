# Install host manager
  vagrant plugin install vagrant-hostmanager

# Install proxy
  vagrant plugin install vagrant-proxyconf

# Put any sql code you want to run automatically into data/db.sql
  NB. the code must have CREATE TABLE statement

# Start your vagrant
  vagrant up

# Wanna ssh?
  vagrant ssh

# Wanna shut down the machine?
  vagrant halt

# Wanna remove the machine?
  vagrant destroy
