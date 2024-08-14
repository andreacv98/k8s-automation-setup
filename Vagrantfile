# Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.provider "virtualbox" do |vb|
        vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
        vb.customize [ "modifyvm", :id, "--cpus", "6" ]
        vb.customize [ "modifyvm", :id, "--memory", "4096" ]
    end
    config.vm.synced_folder '.', '/vagrant', disabled: true
    config.vm.boot_timeout = 600
    config.vm.define "k8s-manager" do |manager|
        manager.vm.box = "bento/ubuntu-22.04"
        manager.vm.network "public_network", type: "bridged"
        manager.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/setup_k8s.yml"
            ansible.extra_vars = {
                "role" => "manager"
            }
        end
    end

    (1..2).each do |i|
        config.vm.define "k8s-worker-#{i}" do |worker|
            worker.vm.box = "bento/ubuntu-22.04"
            worker.vm.network "public_network", type: "bridged"
            worker.vm.provision "ansible" do |ansible|
                ansible.playbook = "ansible/setup_k8s.yml"
                ansible.extra_vars = {
                    "role" => "worker",
                    "worker_id" => i
                }
            end
        end
    end
end
