sudo ip route add default via 192.168.1.1 dev eno1 table 101
sudo ip route add default via 192.168.2.1 dev enp1s0f1 table 102
sudo ip rule add from 192.168.1.3 table 101
sudo ip rule add from 192.168.2.6 table 102
sudo route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.1.1
sudo route del -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.1.1
sudo route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.2.1

