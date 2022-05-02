# Домашнее задание к занятию "09.02 CI\CD"

## Знакомство с SonarQube

### Подготовка к выполнению

1. *Выполняем `docker pull sonarqube:8.7-community`*
2. *Выполняем `docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:8.7-community`*
3. *Ждём запуск, смотрим логи через `docker logs -f sonarqube`*
4. *Проверяем готовность сервиса через [браузер](http://localhost:9000)*
5. *Заходим под admin\admin, меняем пароль на свой*

*В целом, в [этой статье](https://docs.sonarqube.org/latest/setup/install-server/) описаны все варианты установки, включая и docker, но так как нам он нужен разово, то достаточно того набора действий, который я указал выше.*

**Сделано, получилось как-то так:**  
![Скрин с SonarQube](./pic/dz9_2_0.png)

### Основная часть

1. *Создаём новый проект, название произвольное*
2. *Скачиваем пакет sonar-scanner, который нам предлагает скачать сам sonarqube*  
**На самом деле, ссылка от запущенного ***SonarQube*** нерабочая, так что сами качаем архив с фирменного сайта и распаковываем его в `/opt/sonarscanner` на локальной машине**
3. *Делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)*  
**Проще всего сделать через линки:**
```bash
ln -s /opt/sonarscanner/bin/sonar-scanner /usr/bin/sonar-scanner
ln -s /opt/sonarscanner/bin/sonar-scanner-debug /usr/bin/sonar-scanner-debug
chmod ugo+x /usr/bin/sonar-scanner*
```
**А ещё надо прописать права для встроенной Java, иначе не работает:**
```bash
chmod 755 /opt/sonarscanner/jre/bin/java
```
4. *Проверяем `sonar-scanner --version`*  
**Получаем это:**
```
[root@juggernaut bin]# sonar-scanner --version
INFO: Scanner configuration file: /opt/sonarscanner/conf/sonar-scanner.properties
INFO: Project root configuration file: NONE
INFO: SonarScanner 4.7.0.2747
INFO: Java 11.0.14.1 Eclipse Adoptium (64-bit)
INFO: Linux 5.17.3-302.fc36.x86_64 amd64
```
5. *Запускаем анализатор против кода из директории [example](./example) с дополнительным ключом `-Dsonar.coverage.exclusions=fail.py`*
6. *Смотрим результат в интерфейсе*  
**Получаем следующее:**  
***Общий итог проверки на баги***
![Общий итог багов](./pic/dz9_2_1_1.png)  

***Расшифровка отдельных багов***
![Более подробная картина](./pic/dz9_2_1_2.png)  
7. *Исправляем ошибки, которые он выявил(включая warnings)*  
**Лихорадочно правим код...**  
***Было*** *(сбойный скрипт [здесь](./example/fail.py))* ***:***
```python
def increment(index):
    index =+ 1
    return index
def get_square(numb):
    return numb*numb
def print_numb(numb):
    print("Number is {}".format(numb))
    pass

index = 0
while (index < 10):
    index = increment(index)
    print(get_square(index))
```

***Стало*** *(скорректированный скрипт [здесь](./example/corrected.py))* ***:***
```python
def increment(index):
    result = index + 1
    return result
def get_square(numb):
    return numb*numb
def print_numb(numb):
    print("Number is {}".format(numb))

index = 0
while (index < 10):
    index = increment(index)
    print(get_square(index))
```
8. *Запускаем анализатор повторно - проверяем, что QG пройдены успешно*  
9. *Делаем скриншот успешного прохождения анализа, прикладываем к решению ДЗ*  
**Смотри-ка, реально больше не ругается...**  
![Результат исправленного скрипта](./pic/dz9_2_1_3.png)

## Знакомство с Nexus

### Подготовка к выполнению

1. *Выполняем `docker pull sonatype/nexus3`*
2. *Выполняем `docker run -d -p 8081:8081 --name nexus sonatype/nexus3`*
3. *Ждём запуск, смотрим логи через `docker logs -f nexus`*
4. *Проверяем готовность сервиса через [бразуер](http://localhost:8081)*
5. *Узнаём пароль от admin через `docker exec -it nexus /bin/bash`*
6. *Подключаемся под админом, меняем пароль, сохраняем анонимный доступ*

### Основная часть

1. *В репозиторий `maven-public` загружаем артефакт с GAV параметрами:*
   1. *groupId: netology*
   2. *artifactId: java*
   3. *version: 8_282*
   4. *classifier: distrib*
   5. *type: tar.gz*
2. *В него же загружаем такой же артефакт, но с version: 8_102*
3. *Проверяем, что все файлы загрузились успешно*  
**Похоже, сработало:**  
![Загруженные файлы](./pic/dz9_2_2_1.png)
4. *В ответе присылаем файл `maven-metadata.xml` для этого артефекта*  
**Результат** ***(он же в виде [файла](./nexus/maven-metadata.xml))*** **:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<metadata modelVersion="1.1.0">
  <groupId>netology</groupId>
  <artifactId>java</artifactId>
  <versioning>
    <latest>8_282</latest>
    <release>8_282</release>
    <versions>
      <version>8_102</version>
      <version>8_282</version>
    </versions>
    <lastUpdated>20220502071733</lastUpdated>
  </versioning>
</metadata>
```


### Знакомство с Maven

### Подготовка к выполнению

1. *Скачиваем дистрибутив с [maven](https://maven.apache.org/download.cgi)*
2. *Разархивируем, делаем так, чтобы binary был доступен через вызов в shell (или меняем переменную PATH или любой другой удобный вам способ)*  
**Распаковываем архив с ***Maven*** в папку `/opt/maven` и пользуемся линками:**  
```bash
ln -s /opt/maven/bin/mvn /usr/bin/mvn
chmod ugo+x /usr/bin/mvn
```
3. *Проверяем `mvn --version`*  
**Работает:**  
```
[root@juggernaut bin]# mvn --version
Apache Maven 3.8.5 (3599d3414f046de2324203b78ddcf9b5e4388aa0)
Maven home: /opt/maven
Java version: 17.0.2, vendor: Red Hat, Inc., runtime: /usr/lib/jvm/java-17-openjdk-17.0.2.0.8-7.fc36.x86_64
Default locale: ru_RU, platform encoding: UTF-8
OS name: "linux", version: "5.17.3-302.fc36.x86_64", arch: "amd64", family: "unix"
```
4. *Забираем директорию [mvn](./mvn) с pom*

### Основная часть

1. *Меняем в `pom.xml` блок с зависимостями под наш артефакт из первого пункта задания для Nexus (java с версией 8_282)*
2. *Запускаем команду `mvn package` в директории с `pom.xml`, ожидаем успешного окончания*
3. *Проверяем директорию `~/.m2/repository/`, находим наш артефакт*
4. *В ответе присылаем исправленный файл `pom.xml`*

---

### Как оформить ДЗ?

*Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.*

---
