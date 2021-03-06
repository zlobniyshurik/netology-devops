Домашнее задание N15
====================

Задача 1
--------
  
*Есть скрипт:*
```bash
a=1
b=2
c=a+b
d=$a+$b
e=$(($a+$b))
```
*Какие значения переменным c,d,e будут присвоены? Почему?*

В **c** будет **a+b**, так как "a+b" в данном случае просто строка, не имеющая отношения к переменным **a** и **b**.  
  
В **d** будет **1+2**, так как выводится значение переменной **а**, затем знак **+**, затем значение переменной **b**  
  
В **c** будет **3**, так как вычисляется сумма значений переменных **a** и **b**.  
  
Задача 2
--------
  
*На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность,  
записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться).  
В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске  
постоянно уменьшается. Что необходимо сделать, чтобы его исправить:*
```bash
while ((1==1)
do
    curl https://localhost:4757
    if (($? != 0))
    then
	date >> curl.log
    fi
done
```

Скрипт в примере выше содержит целую кучу ошибок и недоработок:  
1. Потеряна закрывающая скобка в первой строчке  
  
2. **curl** вызывается без ключа **-s**, забивая **stdout** не интересующей нас информацией  
  
3. Дата проверки **до**писывается в файл **curl.log** (потому он и постоянно растёт),  
а должна **пере**записываться (нет смысла в логировании всех неудачных попыток, достаточно и одной последней)  
  
4. Скрипт работает на максимальной скорости, напрасно отъедая системные ресурсы,  
его надо притормозить, делая проверку раз в N секунд  
  
5. Скрипт слишком длинный и понятный, конкурентов с низким уровнем подготовки надо отсекать :)  
  
Скрипт-однострочник, доработанный с учётом имеющихся недостатков:  
```bash
#!/usr/bin/env bash
while ( !(curl -s "https://localhost:4757") && (date > curl.log) ) do sleep 10; done
```
  
Задача 3
--------
  
*Необходимо написать скрипт, который проверяет доступность трёх IP: 192.168.0.1, 173.194.222.113, 87.250.250.242  
по 80 порту и записывает результат в файл* ***log*** *. Проверять доступность необходимо пять раз для каждого узла.*
  
Например, так:  
```bash
#!/usr/bin/env bash

#Список тестируемых хостов, разделённых пробелами
TEST_HOSTS=(192.168.0.1 173.194.222.113 87.250.250.242)

#Номер тестируемого порта
TEST_PORT=80

#Количество циклов тестирования
TEST_CYCLES=5

#Тестируем N циклов наш список хостов
for ((j=1;j<=$TEST_CYCLES;j++))
do
    #Собственно перебираем список тестируемых хостов
    for i in "${TEST_HOSTS[@]}"
    do
        if ( nc -z -w2 $i $TEST_PORT )
            then
                echo -n -e "Хост $i доступен\n" >> log
            else
                echo -n -e "Хост $i НЕдоступен\n" >> log
        fi
    done
done
```
  
Задача 4
--------
  
*Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор,  
пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла  
пишется в файл* ***error*** *, скрипт прерывается.*  
  
Если я правильно понял, то успешные проверки в лог писать уже не надо, тогда скрипт будет таким:  
```bash
#!/usr/bin/env bash

#Список тестируемых хостов, разделённых пробелами
TEST_HOSTS=(192.168.0.1 173.194.222.113 87.250.250.242)

#Номер тестируемого порта
TEST_PORT=80

#Тестируем до бесконечности наш список хостов
while ((1==1))
do
    #Собственно перебираем список тестируемых хостов
    for i in "${TEST_HOSTS[@]}"
    do
        if (!( nc -z -w2 $i $TEST_PORT ))
            then
                echo -n -e "Хост $i НЕдоступен\n" >> error
                exit 1
        fi
    done
done
```
