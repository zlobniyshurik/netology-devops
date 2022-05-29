# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению

----
1. *Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.*

**Вот [репозиторий](https://github.com/zlobniyshurik/netology-block2-dz82-repo), конкретно под этот урок**

----
2. *Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.*

**Сделано**

----
3. *Подготовьте хосты в соответствии с группами из предподготовленного playbook.*

**Воспользуемся готовой тестовой виртуалкой `Test` на основе `Alma Linux 8.xx`**

----
## Основная часть

1. *Приготовьте свой собственный inventory файл `prod.yml`.*

**Сделано, теперь внутренности `playbook/inventory/prod.yml` выглядят так:**  
```yml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: test
      connect: ssh
```

----
2. *Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).*

**Playbook потребовал кардинальной переработки, иначе часть с установкой `Clickhouse` была абсолютно нежизнеспособна**  

----
3. *При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.*

**Если уж оригинальный playbook был ориентирован на `rpm`, то и будем использовать готовый `ansible.builtin.dnf` модуль. Даже с ним приключений будет достаточно.**  

----
4. *Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.*

**Сделано. И даже работает...**

**В итоге всё выглядело примерно так:**  
```yml
---
- name: Install Clickhouse
  hosts: clickhouse

  handlers:

    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: started
        enabled: yes

  tasks:

    - name: Install GPG-key for Clickhouse
      become: true
      ansible.builtin.rpm_key:
        state: present
        key: https://repo.clickhouse.com/CLICKHOUSE-KEY.GPG

    - name: Check if Clickhouse repo already exists
      ansible.builtin.stat:
        path: /etc/yum.repos.d/clickhouse.repo
      register: clickrepo

    - name: Configure Clickhouse-repo
      block:
        - name: Add Clickhouse repo (if not exists yet)
          ansible.builtin.command: "dnf config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo"

        - name: Disable clickhouse-stable repo (to avoid unintentional updates to new versions due system update)
          ansible.builtin.command: "dnf config-manager --disable clickhouse-stable"
      when: not clickrepo.stat.exists
      become: true

    - name: Install clickhouse packages
      become: true
      ansible.builtin.dnf:
        enablerepo: clickhouse-stable
        name: "{{ item }}-{{ clickhouse_version }}"
        state: present
      with_items: "{{ clickhouse_packages }}"
      notify: Start clickhouse service

    - name: Start clickhouse service (if needed)
      ansible.builtin.meta: flush_handlers

    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0

- name: Install Vector
  hosts: clickhouse

  handlers:

    - name: Start vector service
      become: true
      ansible.builtin.service:
        name: vector
        state: started
        enabled: yes

# Образчик редкостного бардака в репозитории vector`а:
# Все билды всех разновидностей для всех архитектур
# лежат в одном каталоге без какой-либо сортировки.
# Было бы на моих серверах - тупо выкачал бы нужный
# пакет и создал бы локальную репу.
# P.S. И, да, GPG-ключи тоже не найдены

  tasks:

    - name: Install RPMs from Vector site
      become: true
      ansible.builtin.dnf:
        name: "https://packages.timber.io/vector/{{ vector_version }}/{{ item }}-{{ vector_version }}-{{ vector_rpm_build }}.{{ vector_arch }}.rpm"
        state: present
        disable_gpg_check: true
      with_items: "{{ vector_packages }}"
      notify: Start vector service
```

----
5. *Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.*

**Да откуда же у меня ошибки? Нет их там, уже... :)**  
```
[shurik@megaboss playbook]$ ansible-lint inventory/prod.yml site.yml 
WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
[shurik@megaboss playbook]$
```

----
6. *Попробуйте запустить playbook на этом окружении с флагом `--check`.*

**Выдало следующее:**  
```
[shurik@megaboss playbook]$ ansible-playbook --check -i inventory/prod.yml site.yml

PLAY [Install Clickhouse] ********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/libexec/platform-python, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Install GPG-key for Clickhouse] ********************************************************************************************************
changed: [clickhouse-01]

TASK [Check if Clickhouse repo already exists] ***********************************************************************************************
ok: [clickhouse-01]

TASK [Add Clickhouse repo (if not exists yet)] ***********************************************************************************************
skipping: [clickhouse-01]

TASK [Disable clickhouse-stable repo (to avoid unintentional updates to new versions due system update)] *************************************
skipping: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************
failed: [clickhouse-01] (item=clickhouse-client) => {"ansible_loop_var": "item", "changed": false, "failures": ["No package clickhouse-client-22.3.3.44 available."], "item": "clickhouse-client", "msg": "Failed to install some of the specified packages", "rc": 1, "results": []}
failed: [clickhouse-01] (item=clickhouse-server) => {"ansible_loop_var": "item", "changed": false, "failures": ["No package clickhouse-server-22.3.3.44 available."], "item": "clickhouse-server", "msg": "Failed to install some of the specified packages", "rc": 1, "results": []}
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "failures": ["No package clickhouse-common-static-22.3.3.44 available."], "item": "clickhouse-common-static", "msg": "Failed to install some of the specified packages", "rc": 1, "results": []}

PLAY RECAP ***********************************************************************************************************************************
clickhouse-01              : ok=3    changed=1    unreachable=0    failed=1    skipped=2    rescued=0    ignored=0
```

----
7. *Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.*

**Сделано:**
```
[shurik@megaboss playbook]$ ansible-playbook --diff -i inventory/prod.yml site.yml

PLAY [Install Clickhouse] ********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/libexec/platform-python, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Install GPG-key for Clickhouse] ********************************************************************************************************
changed: [clickhouse-01]

TASK [Check if Clickhouse repo already exists] ***********************************************************************************************
ok: [clickhouse-01]

TASK [Add Clickhouse repo (if not exists yet)] ***********************************************************************************************
changed: [clickhouse-01]

TASK [Disable clickhouse-stable repo (to avoid unintentional updates to new versions due system update)] *************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Start clickhouse service (if needed)] **************************************************************************************************

RUNNING HANDLER [Start clickhouse service] ***************************************************************************************************
changed: [clickhouse-01]

TASK [Create database] ***********************************************************************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [clickhouse-01]

TASK [Install RPMs from Vector site] *********************************************************************************************************
changed: [clickhouse-01] => (item=vector)

RUNNING HANDLER [Start vector service] *******************************************************************************************************
changed: [clickhouse-01]

PLAY RECAP ***********************************************************************************************************************************
clickhouse-01              : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
----
8. *Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.*

**Идемпотентней некуда:**  
```
[shurik@megaboss playbook]$ ansible-playbook --diff -i inventory/prod.yml site.yml

PLAY [Install Clickhouse] ********************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
[WARNING]: Platform linux on host clickhouse-01 is using the discovered Python interpreter at /usr/libexec/platform-python, but future
installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-
core/2.12/reference_appendices/interpreter_discovery.html for more information.
ok: [clickhouse-01]

TASK [Install GPG-key for Clickhouse] ********************************************************************************************************
ok: [clickhouse-01]

TASK [Check if Clickhouse repo already exists] ***********************************************************************************************
ok: [clickhouse-01]

TASK [Add Clickhouse repo (if not exists yet)] ***********************************************************************************************
skipping: [clickhouse-01]

TASK [Disable clickhouse-stable repo (to avoid unintentional updates to new versions due system update)] *************************************
skipping: [clickhouse-01]

TASK [Install clickhouse packages] ***********************************************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
ok: [clickhouse-01] => (item=clickhouse-common-static)

TASK [Start clickhouse service (if needed)] **************************************************************************************************

TASK [Create database] ***********************************************************************************************************************
ok: [clickhouse-01]

PLAY [Install Vector] ************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************
ok: [clickhouse-01]

TASK [Install RPMs from Vector site] *********************************************************************************************************
ok: [clickhouse-01] => (item=vector)

PLAY RECAP ***********************************************************************************************************************************
clickhouse-01              : ok=7    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
```

----
9. *Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.*

**Сделано.**

----
10. *Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.*

**Сделано. Вот [ссылка](https://github.com/zlobniyshurik/netology-block2-dz82-repo). Без выбора тэга полную версию README.md не показывает. А в гитлабе всё красиво и видно сразу.**

---

### Как оформить ДЗ?

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
