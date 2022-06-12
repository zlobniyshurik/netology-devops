# Домашнее задание к занятию "8.4 Работа с Roles"

## Подготовка к выполнению

----
1. *Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.*

- **Репозиторий [vector-role](https://github.com/zlobniyshurik/vector-role)**
- **Репозиторий [lighthouse-role](https://github.com/zlobniyshurik/lighthouse-role)**

----
2. *Добавьте публичную часть своего ключа к своему профилю в github.*

**Сделано давным-давно**

----
## Основная часть

*Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для clickhouse, vector и lighthouse и написать playbook для использования этих ролей. Ожидаемый результат: существуют три ваших репозитория: два с roles и один с playbook.*

1. *Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:*

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.11.0"
       name: clickhouse 
   ```

**Сделано.**  
***(Правда, тут уже вообще все роли, что нам потребуются)***
```
[root@juggernaut netology-dz84]# cat requirements.yml 
---
  - src: git@github.com:zlobniyshurik/vector-role.git
    scm: git
    version: "0.0.1"
    name: zlobniyshurik.vector
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse
  - src: git@github.com:geerlingguy/ansible-role-nginx
    scm: git
    version: "3.1.1"
    name: geerlingguy.nginx
  - src: git@github.com:zlobniyshurik/lighthouse-role.git
    scm: git
    version: "0.0.1"
    name: zlobniyshurik.lighthouse
```
----
2. *При помощи `ansible-galaxy` скачать себе эту роль.*

**Установлено всё необходимое:**  
```
[root@juggernaut netology-dz84]# ansible-galaxy role install -r requirements.yml
Starting galaxy role install process
- extracting zlobniyshurik.vector to /root/.ansible/roles/zlobniyshurik.vector
- zlobniyshurik.vector (0.0.1) was installed successfully
- extracting clickhouse to /root/.ansible/roles/clickhouse
- clickhouse (1.11.0) was installed successfully
- extracting geerlingguy.nginx to /root/.ansible/roles/geerlingguy.nginx
- geerlingguy.nginx (3.1.1) was installed successfully
- extracting zlobniyshurik.lighthouse to /root/.ansible/roles/zlobniyshurik.lighthouse
- zlobniyshurik.lighthouse (0.0.1) was installed successfully
```
----
3. *Создать новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.*

**Сделано, правда с помощью вот этой вот [статьи](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1), соответственно, инициализация шла через `molecule`:**  
```
[root@juggernaut test]# molecule init role zlobniyshurik.vector --driver-name=podman
INFO     Initializing new role vector...
Using /etc/ansible/ansible.cfg as config file
- Role vector was created successfully
localhost | CHANGED => {"backup": "","changed": true,"msg": "line added"}
INFO     Initialized role in /root/test/vector successfully.
```

----
4. *На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.* 

**Сделано. Дополнено с учётом кастомных unit-файлов**  
***(Почти как в вебинаре у А.Метлякова, но более корректно - в его реализации кастомные unit-файлы почему-то сделаны не через `имя_сервиса.service.d/override.conf`, как требуется по стандарту)***

----
5. *Перенести нужные шаблоны конфигов в `templates`.*

**Добавил шаблоны unit-файлов.**

----
6. *Описать в `README.md` обе роли и их параметры.*

**Сделано**

----
7. *Повторите шаги 3-6 для lighthouse. Помните, что одна роль должна настраивать один продукт.*

**Готово**

----
8. *Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию Добавьте roles в `requirements.yml` в playbook.*

**Ещё раз:**  
- **Репозиторий [vector-role](https://github.com/zlobniyshurik/vector-role)**
- **Репозиторий [lighthouse-role](https://github.com/zlobniyshurik/lighthouse-role)**
- ***requirements.yml:***
```
[root@juggernaut netology-dz84]# cat requirements.yml 
---
  - src: git@github.com:zlobniyshurik/vector-role.git
    scm: git
    version: "0.0.1"
    name: zlobniyshurik.vector
  - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse
  - src: git@github.com:geerlingguy/ansible-role-nginx
    scm: git
    version: "3.1.1"
    name: geerlingguy.nginx
  - src: git@github.com:zlobniyshurik/lighthouse-role.git
    scm: git
    version: "0.0.1"
    name: zlobniyshurik.lighthouse
```

----
9. *Переработайте playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения `roles` с `tasks`.*

**Переработано**

----
10. *Выложите playbook в репозиторий.*

**[Сделано](./playbook)**

----
11. *В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.*

- **Репозиторий [vector-role](https://github.com/zlobniyshurik/vector-role)**
- **Репозиторий [lighthouse-role](https://github.com/zlobniyshurik/lighthouse-role)**
- **[Playbook](./playbook)**

---

### Как оформить ДЗ?

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
