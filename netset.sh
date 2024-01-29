sudo tc qdisc del dev enp1s0f1 handle 1: root htb default 11
sudo tc qdisc del dev eno1 handle 1: root htb default 11

#path3 good
sudo tc qdisc add dev enp1s0f1 handle 1: root htb default 11

sudo tc class add dev enp1s0f1 parent 1: classid 1:1 htb rate $1Mbit ceil $2Mbit burst 100k cburst 150k

sudo tc class add dev enp1s0f1 parent 1:1 classid 1:11 htb rate $1Mbit ceil $2Mbit burst 100k cburst 150k

sudo tc qdisc add  dev enp1s0f1 parent 1:11 handle 11: netem delay $3ms limit 100000


#path1 bad
sudo tc qdisc add dev eno1 handle 1: root htb default 11

sudo tc class add dev eno1 parent 1: classid 1:1 htb rate $4Mbit ceil $5Mbit burst 105k cburst 150k

sudo tc class add dev eno1 parent 1:1 classid 1:11 htb rate $4Mbit ceil $5Mbit burst 105k cburst 150k

sudo tc qdisc add  dev eno1 parent 1:11 handle 11: netem delay $6ms limit 100000
