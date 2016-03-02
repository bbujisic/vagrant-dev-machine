# ===========================
# CONFIG: Temper with care
# ===========================
settingsMachineName = "LAMP box"

settingsHostName = "lamp.dev"
settingsGuestIP = "192.168.56.2"

settingsMachineRam = "1024"

settingsProxyEnabled = false;
settingsProxyHttp     = "http://192.168.66.66:80"
settingsProxyHttps    = "https://192.168.66.66:80/"
settingsProxyNoProxy = "localhost,127.0.0.1"

# ===========================
# DO NOT EDIT BELOW THIS LINE
# ===========================
Vagrant.configure(2) do |config|

  # -- Because some poor developers are behind proxy servers... --
  if settingsProxyEnabled === true
    config.proxy.http     = settingsProxyHttp
    config.proxy.https    = settingsProxyHttps
    config.proxy.no_proxy = settingsProxyNoProxy
  end

  # -- It's Ubuntu alright --
  config.vm.box = "hashicorp/precise64"

  # -- Networking stuff --
  config.vm.hostname = settingsHostName
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.vm.network "private_network", ip: settingsGuestIP

  # -- Shared folder --
  config.vm.synced_folder "./data", "/var/www/html", create: true, group: "www-data", owner: "www-data"

  # -- VirtualBox stuff --
  config.vm.provider "virtualbox" do |vb|
    # Give the machine a name
    vb.name = settingsMachineName

    # Display the VirtualBox GUI when booting the machine
    vb.gui = false

    # Customize the amount of memory on the VM:
    vb.memory = settingsMachineRam
  end

  # -- SSH --
  config.ssh.forward_agent = true

  config.vm.provision "shell" do |sh|
    sh.inline = "touch $1 && chmod 0440 $1 && echo $2 > $1"
    sh.args = %q{/etc/sudoers.d/root_ssh_agent "Defaults    env_keep += \"SSH_AUTH_SOCK\""}
  end

  # -- Provisioning --
  config.vm.provision "shell", path: "scripts/provision/WebDev.sh"
end
