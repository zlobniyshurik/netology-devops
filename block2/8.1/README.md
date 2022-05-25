# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению

----
1. *Установите ansible версии 2.10 или выше.*  

**Уже установлен:**  
```bash
[root@juggernaut ~]# ansible --version
ansible [core 2.12.5]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.4 (main, Mar 25 2022, 00:00:00) [GCC 12.0.1 20220308 (Red Hat 12.0.1-0)]
  jinja version = 3.0.3
  libyaml = True
```

----
2. *Создайте свой собственный публичный репозиторий на github с произвольным именем.*  

**Сделано: [https://github.com/zlobniyshurik/netology-block2-dz81-repo](https://github.com/zlobniyshurik/netology-block2-dz81-repo)**

----
3. *Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.*  

**Сделано.**

----

## Основная часть
1. *Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.*  

**Запускаем:**  
```
[shurik@juggernaut playbook]$ ansible-playbook -i inventory/test.yml site.yml 

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *********************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Fedora"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP **************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

**`some_fact`=12**

----
2. *Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.*  

**Данная переменная была в `group_vars/all/examp.yml`. Меняем содержимое `some_fact` на `all default fact`**  
**Проверяем:**  
```
[shurik@juggernaut playbook]$ ansible-playbook -i inventory/test.yml site.yml 

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *********************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Fedora"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

----
3. *Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.*  

**Скачиваем docker-образы `CentOS7` и `Ubuntu`:**  
```bash
docker login
docker pull pycontribs/centos:7
docker pull pycontribs/ubuntu:latest
```

**Смотрим - чего у нас теперь есть:**
```bash
[root@juggernaut ~]# docker image list
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
pycontribs/centos   7         bafa54e44377   13 months ago   488MB
pycontribs/ubuntu   latest    42a4e3b21923   2 years ago     664MB
```

**Запускаем образы наших подопытных кроликов:**
```bash
[root@juggernaut ~]# docker run -d --name centos7 bafa54e44377 /bin/sleep 100000000000000
9b195ac9cd0088be048ed1e90e0b1fe88728c72fedfea986ee1d3cb158c27396
[root@juggernaut ~]# docker run -d --name ubuntu 42a4e3b21923 /bin/sleep 100000000000000
d9013afe61ffab23bdf152788d6bf75fb45327ec2e73a646d9ca8dda9b071685
[root@juggernaut ~]# docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS     NAMES
d9013afe61ff   42a4e3b21923   "/bin/sleep 10000000…"   8 seconds ago    Up 3 seconds              ubuntu
9b195ac9cd00   bafa54e44377   "/bin/sleep 10000000…"   37 seconds ago   Up 34 seconds             centos7
[root@juggernaut ~]#
```

----
4. *Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.*  

**Проверяем:**  
```
[root@juggernaut playbook]# ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *********************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP **************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

**Итого - для `CentOS7` в `some_fact` лежит `el`, для `Ubuntu` там же лежит `deb`**

----
5. *Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.*  

**Для `deb` в `group_vars/deb/examp.yml` прописываем в `some_fact` значение `deb default fact`**  
**Для `el` в `group_vars/el/examp.yml` прописываем в `some_fact` значение `el default fact`**  

----
6.  *Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.*

**Проверяем:**
```
[root@juggernaut playbook]# ansible-playbook -i inventory/prod.yml site.yml

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *********************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

**Сработало!**

----
7. *При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.*  

**Шифруем:**  
```bash
ansible-vault encrypt group_vars/el/examp.yml group_vars/deb/examp.yml
```

**Проверяем:**  
```bash
[root@juggernaut playbook]# cat group_vars/el/examp.yml
$ANSIBLE_VAULT;1.1;AES256
64636365616132623562303938393731386131616165323039653333636433396362386637313061
6362323531393565643038643865663330373539366133370a643237333866613064346161303764
32643566663238656330383366386261306633336234396539336630643763313564633363666233
3061323364333931330a653134396631333536643561656666356434313162353231623966393661
65633962616234353832353562326232323635366663306565313561626634623538326537386136
3036316261366162616639373039376231613838356531316432
[root@juggernaut playbook]# cat group_vars/deb/examp.yml
$ANSIBLE_VAULT;1.1;AES256
35393663326363313461633765613765383539643936363134316530613564663631323062626365
6266646265356563343530666431666233626264326230300a343632616265333233613065643835
35396461616430313535303334646366333636313030303364623265323632393461323035616235
3861643561636430320a323737626630363433383366336234386534623239653462316333636435
30366634343866356136653630353235336131336237303930396331353336613039363063646330
3137316532323261613230623266356264633132666465343261
```

----
8. *Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.*  

**Сработало!**  
```
[root@juggernaut playbook]# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *********************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

----
9. *Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.*  

**Как-то так:**  
```
[root@juggernaut playbook]# ansible-doc --type=connection -l
[WARNING]: Collection frr.frr does not support Ansible version 2.12.5
[WARNING]: Collection ibm.qradar does not support Ansible version 2.12.5
[WARNING]: Collection splunk.es does not support Ansible version 2.12.5
[DEPRECATION WARNING]: ansible.netcommon.napalm has been deprecated. See the plugin documentation for more details. This feature will be removed from 
ansible.netcommon in a release after 2022-06-01. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
ansible.netcommon.httpapi      Use httpapi to run command on network appliances                                                                         
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection                                                                 
ansible.netcommon.napalm       Provides persistent connection using NAPALM                                                                              
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol                                                              
ansible.netcommon.network_cli  Use network_cli to run command on network appliances                                                                     
ansible.netcommon.persistent   Use a persistent unix socket for connection                                                                              
community.aws.aws_ssm          execute via AWS Systems Manager                                                                                          
community.docker.docker        Run tasks in docker containers                                                                                           
community.docker.docker_api    Run tasks in docker containers                                                                                           
community.docker.nsenter       execute on host running controller container                                                                             
community.general.chroot       Interact with local chroot                                                                                               
community.general.funcd        Use funcd to connect to target                                                                                           
community.general.iocage       Run tasks in iocage jails                                                                                                
community.general.jail         Run tasks in jails                                                                                                       
community.general.lxc          Run tasks in lxc containers via lxc python library                                                                       
community.general.lxd          Run tasks in lxc containers via lxc CLI                                                                                  
community.general.qubes        Interact with an existing QubesOS AppVM                                                                                  
community.general.saltstack    Allow ansible to piggyback on salt minions                                                                               
community.general.zone         Run tasks in a zone instance                                                                                             
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt                                                                                  
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines                                                                               
community.okd.oc               Execute tasks in pods running on OpenShift                                                                               
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools                                                                               
community.zabbix.httpapi       Use httpapi to run command on network appliances                                                                         
containers.podman.buildah      Interact with an existing buildah container                                                                              
containers.podman.podman       Interact with an existing podman container                                                                               
kubernetes.core.kubectl        Execute tasks in pods running on Kubernetes                                                                              
local                          execute on controller                                                                                                    
paramiko_ssh                   Run tasks via python ssh (paramiko)                                                                                      
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol                                                                    
ssh                            connect via SSH client binary                                                                                            
winrm                          Run tasks over Microsoft's WinRM
```

**Нам интересен `local`**

----
10. *В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.*  

**Правим `inventory/prod.yml`:**
```yml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker

  local:
    hosts:
      localhost:
        ansible_connection: local
```

----
11. *Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.*  

**Сработало:**
```
[root@juggernaut playbook]# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
Vault password: 

PLAY [Print os facts] ***************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [centos7]
ok: [ubuntu]
ok: [localhost]

TASK [Print OS] *********************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [localhost] => {
    "msg": "Fedora"
}

TASK [Print fact] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

----
12. *Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.*

## Необязательная часть

1. *При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.*
2. *Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.*
3. *Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.*
4. *Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).*
5. *Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.*
6. *Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.*

---

### Как оформить ДЗ?

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
