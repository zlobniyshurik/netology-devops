
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Как сдавать задания

Обязательными к выполнению являются задачи без указания звездочки. Их выполнение необходимо для получения зачета и диплома о профессиональной переподготовке.

Задачи со звездочкой (*) являются дополнительными задачами и/или задачами повышенной сложности. Они не являются обязательными к выполнению, но помогут вам глубже понять тему.

Домашнее задание выполните в файле readme.md в github репозитории. В личном кабинете отправьте на проверку ссылку на .md-файл в вашем репозитории.

Любые вопросы по решению задач задавайте в чате учебной группы.

---

## Задача 1

- *Опишите своими словами основные преимущества применения на практике IaaC паттернов.*
- *Какой из принципов IaaC является основополагающим?*

**Основные преимущества IaaC:**  

+ Ускорение производства программного продукта за счёт тотальной автоматизации всего, что только можно
+ Стабильность программной среды и её 100% воспроизводимость на разных машинах и в разных условиях
+ Быстрая и эффективная разработка

**Какой из принципов IaaC является основополагающим?**  

Краеугольный камень Iaac - **идемпотентность**, то есть 100%-ая воспроизводимость результата вне зависимости от количества повторов операции. То есть, мы всегда получаем программную среду с заданными компонентами именно тех версий, которые нам нужны и которые нами проверены.

## Задача 2

- *Чем Ansible выгодно отличается от других систем управление конфигурациями?*
- *Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?*

**Чем Ansible выгодно отличается от других систем управление конфигурациями?**  

Главный бонус Ansible - работа с использованием имеющейся структуры SSH, то есть, нам не надо заморачиваться с установкой специализированных агентов на каждую из подшефных машин. К тому же Ansible относительно прост и, что немаловажно, исповедует модульный подход для расширения своих возможностей.

**Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?**  

На мой взгляд, **надёжнее** метод **pull**, ибо машина-клиент может быть и выключена в момент раздачи конфигурации по клиентам.  
**Удобнее** и **предсказуемее** метод **push**. А в идеале должны поддерживаться оба метода одновременно.

## Задача 3

*Установить на личный компьютер:*

- *VirtualBox*
- *Vagrant*
- *Ansible*

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```bash
[shurik@juggernaut netology-devops]$ vagrant --version
Vagrant 2.2.16
[shurik@juggernaut netology-devops]$ ansible --version
ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/shurik/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.10.1 (main, Jan 10 2022, 00:00:00) [GCC 11.2.1 20211203 (Red Hat 11.2.1-7)]
[shurik@juggernaut netology-devops]$ VirtualBox --help
Oracle VM VirtualBox VM Selector v6.1.30_rpmfusion
(C) 2005-2021 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
[shurik@juggernaut netology-devops]$
```

## Задача 4 (*)

*Воспроизвести практическую часть лекции самостоятельно.*

- *Создать виртуальную машину.*
- *Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды*
```
docker ps
```

**Создаём виртуальную машину:**  

Выбираем провайдера виртуалок
```bash
[shurik@juggernaut vagrant]$ export VAGRANT_DEFAULT_PROVIDER=virtualbox
```

Импортируем образ убунты
```bash
[shurik@juggernaut vagrant]$ vagrant box add bento/ubuntu-20.04 --provider=virtualbox --force
==> box: Loading metadata for box 'bento/ubuntu-20.04'
    box: URL: https://vagrantcloud.com/bento/ubuntu-20.04
==> box: Adding box 'bento/ubuntu-20.04' (v202112.19.0) for provider: virtualbox
    box: Downloading: https://vagrantcloud.com/bento/boxes/ubuntu-20.04/versions/202112.19.0/providers/virtualbox.box
==> box: Successfully added box 'bento/ubuntu-20.04' (v202112.19.0) for 'virtualbox'!
```

Смотрим, какие образа есть в наличии
```bash
[shurik@juggernaut vagrant]$ vagrant box list
bento/ubuntu-20.04 (virtualbox, 202112.19.0)
```

Правим **Vagrantfile**  
*Почему-то ***private_network*** не взлетело, пришлось воспользоваться ***public_network***, да ещё и интерфейс указывать*
```bash
[shurik@juggernaut vagrant]$ vi Vagrantfile
# -*- mode: ruby -*-

ISO = "bento/ubuntu-20.04"
NET = "192.168.1."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "../ansible/inventory"

servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "140",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]

Vagrant.configure(2) do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "public_network", ip: machine[:ip], bridge: "br0"
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.playbook = "../ansible/provision.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant' }
      end
    end
  end
end
```

Правим **ansible.cfg**
```bash
[shurik@juggernaut vagrant]$ vi ansible.cfg
[defaults]
inventory=./inventory
deprecation_warnings=False
command_warnings=False
ansible_port=22
interpreter_python=/usr/bin/python3
```

Правим **../ansible/inventory**
```bash
[shurik@juggernaut vagrant]$ vi ../ansible/inventory
[nodes:children]
manager

[manager]
server1.netology ansible_host=127.0.0.1 ansible_port=20011 ansible_user=vagrant
```

Правим **../ansible/provision.yml**  
*У меня ed25519-ключи, пришлось поправить*
```bash
[shurik@juggernaut vagrant]$ vi ../ansible/provision.yml

  - hosts: nodes
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Create directory for ssh-keys
        file: state=directory mode=0700 dest=/root/.ssh/

      - name: Adding ed25519-key in /root/.ssh/authorized_keys
        copy: src=~/.ssh/id_ed25519.pub dest=/root/.ssh/authorized_keys owner=root mode=0600
        ignore_errors: yes

      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker
```

Запускаем **vagrant**
```
[shurik@juggernaut vagrant]$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: bridged
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: Warning: Connection reset. Retrying...
    server1.netology: Warning: Remote connection disconnect. Retrying...
    server1.netology: 
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology: 
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/shurik/University/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]

TASK [Adding ed25519-key in /root/.ssh/authorized_keys] ************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=['git', 'curl'])

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Через **vagrant ssh** смотрим наличие **docker**'а
```bash
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```