#!ipxe
dhcp
set base-url http://releases.rancher.com/os/latest

kernel ${base-url}/vmlinuz printk.devkmsg=on rancher.debug=true rancher.cloud_init.datasources=[url:http://{{ .Boothost }}:{{ .BoothostPort }}/api/tpl/boot]
initrd ${base-url}/initrd
boot

