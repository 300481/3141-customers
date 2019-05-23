#cloud-config
ssh_authorized_keys:
  - {{ .PublicKey }}
hostname: {{ .Hostname }}
rancher:
  network:
    interfaces:
      eth0:
        address: {{ .AddressCIDR }}
        gateway: {{ .Gateway }}
        mtu: {{ .MTU }}
        dhcp: {{ .DHCP }}
    dns:
      nameservers:
      {{- range .Nameservers }}
      - {{ . }}
      {{- end }}
mounts:
- ["/dev/sdb", "/var/lib/rook", "ext4", ""]
