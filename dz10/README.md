Домашнее задание 10
===================

Задача 1
--------

*Узнайте о sparse (разряженных) файлах.*  
  
Ознакомился, но я о них и так знал.

Задача 2
--------

*Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?*  
  
Не могут, ибо по сути своей - это всё алиасы одного и того же файла, у которого может быть только один  
набор разрешений и владельцев.

Задача 3
--------

*Сделайте* ***vagrant destroy*** на имеющийся инстанс Ubuntu. Замените содержимое ***Vagrantfile*** следующим:*
<code>
    Vagrant.configure("2") do |config|  
      config.vm.box = "bento/ubuntu-20.04"  
      config.vm.provider :virtualbox do |vb|  
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"  
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"  
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]  
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]  
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]  
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]  
      end  
    end  
</code>

Готово:
![Диски в вагранте](/dz10/pic/dz10_3.png)

Задача 4
--------

