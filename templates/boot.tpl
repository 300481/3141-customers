#cloud-config
runcmd:
- sudo mkfs.ext4 /dev/sdb
- sudo ros install -c http://{{ .Boothost }}:{{ .BoothostPort }}/api/tpl/install/$(sudo cat /sys/class/dmi/id/product_uuid) -d /dev/sda -f
