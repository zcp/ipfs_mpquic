#！ /bin/bash

function timediff() {

#time format:date +"%s.%N", such as 1502758855.907197692
    start_time=$1
    end_time=$2
    
    start_s=${start_time%.*}
    start_nanos=${start_time#*.}
    end_s=${end_time%.*}
    end_nanos=${end_time#*.}
    
    #end_nanos > start_nanos? 
    #Another way, the time part may start with 0, which means
    #it will be regarded as oct format, use "10#" to ensure
    #calculateing with decimal
    if [ "$end_nanos" -lt "$start_nanos" ];then
        end_s=$(( 10#$end_s - 1 ))
        end_nanos=$(( 10#$end_nanos + 10**9 ))
    fi
    

    time=$(( 10#$end_s - 10#$start_s )).`printf "%03d\n" $(( (10#$end_nanos - 10#$start_nanos)/10**6 ))`
    
    echo $time
}

function clear_environment(){
	echo "--------clear cache starting--------"
	sync;
	sudo bash -c "echo 1 > /proc/sys/vm/drop_caches"
	sudo bash -c "echo 2 > /proc/sys/vm/drop_caches"
	sudo bash -c "echo 3 > /proc/sys/vm/drop_caches"
	echo "--------clear cache successfully--------"
}

function cpfile(){
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/1GB/ll"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/400MB/ll"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/100MB/ll"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/1GB/rr"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/400MB/rr"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/100MB/rr"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/1GB/hbes"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/400MB/hbes"
	
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2; ls -rt zcp_client_packets_path* | head -n 6 |xargs -i mv {} /home/work2/桌面/UltimateData1.5/$1/$2/$3/100MB/hbes"
}

#function cpfilelocal(){
#}

function exam(){
	#切换环境
	echo "===切换环境->ll==="
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2/桌面/go-ipfs; cp ipfs_ll ipfs; sudo ./install.sh"

		for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_ll.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====1GB====" >>getInfo_$1_ll.txt

	killall gjs
	sleep 10s
	

	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_ll.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====400MB====" >>getInfo_$1_ll.txt

	killall gjs
	sleep 10s


	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_ll.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====100MB====" >>getInfo_$1_ll.txt
	
	mv getInfo_$1_ll.txt /home/work1/桌面/UltimateData1.5/$2/$3/ll

	#切换环境
	echo "===切换环境->rr==="
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2/桌面/go-ipfs; cp ipfs_rr ipfs; sudo ./install.sh"
	
		for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_rr.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====1GB====" >>getInfo_$1_rr.txt

	killall gjs
	sleep 10s


	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_rr.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====400MB====" >>getInfo_$1_rr.txt

	killall gjs
	sleep 10s

		for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_rr.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====100MB====" >>getInfo_$1_rr.txt
	mv getInfo_$1_rr.txt /home/work1/桌面/UltimateData1.5/$2/$3/rr


	#切换环境
	echo "===切换环境->hbes==="
	sshpass -p 123456 ssh work2@192.168.2.6 "cd /home/work2/桌面/go-ipfs; cp ipfs_hbes ipfs; sudo ./install.sh"


	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_hbes.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====1GB====" >>getInfo_$1_hbes.txt

	killall gjs
	sleep 10s


	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		#ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_hbes.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====400MB====" >>getInfo_$1_hbes.txt

	killall gjs
	sleep 10s

	for a in {1..6}
	do
		echo "===$a==="	
		killall ipfs 
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		sleep 2s
		
		clear_environment
		nohup ipfs daemon > work1_daemon.txt &
		
		sshpass -p 123456 ssh work2@192.168.2.6 "nohup ipfs daemon > work2_daemon.txt"  &
		sleep 10s
		sshpass -p 123456 ssh work2@192.168.2.6 "ipfs swarm connect /ip4/192.168.3.3/udp/4001/quic/p2p/12D3KooWBNqWUhMAyMDDEPip1YxpXpXyqoVe83LJnfg8dtLGL7Gz" 

		sleep 2s
		start=$(date +"%s.%N")
		#100MB
		ipfs get QmaA4chBb4SJLSj6uRzf95F2KeEVxVFVWFLrMAdMLJ7vDK0
		#200MB
		#ipfs get QmXbSQDazDnwkbfHzhLTzGURLcmtefzw4dN964H4WqBfq60
		#400MB
		#ipfs get QmPnFgfMaQUjrzFD9MGQwJCEP6cvVAhRP98PP3FVTFTmWP0
		#600MB
		#ipfs get QmNpiuBaHgQJP5KatAN2sqoW5p2eUp35nYzPXieNQmmHja0
		#800MB
		#ipfs get QmQ7efEpiN2x8iK5PhtogM7Y46JgnPRLb5eQ3oNaeSTBnS0
		#1GB
		#ipfs get Qmb776EavDgU1wJzuiTLYQ49Wu41yvDw2Xfbw5EXR8pQ2K0
		end=$(date +"%s.%N")
		t=$(timediff $start $end)
		s=$(ls -l "train"$a".txt" | awk '{print $5}')
		echo "$t"s" $start $end" >>getInfo_$1_hbes.txt
		

		sleep 1s
		ipfs repo gc
		
		killall ipfs 
		rm -rf Qm*
		sleep 2s
		sshpass -p 123456 ssh work2@192.168.2.6 "killall ipfs"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/work2_daemon.txt /home/work2/examData2/IPFS50/work2_daemon$a.txt"
		#sshpass -p 123456 ssh work2@192.168.2.6 "cp /home/work2/zcp_client_packets_path.csv /home/work2/examData3/20ms/HBES/zcp_client_packets_path$a.csv"
		sleep 2s
		
			
	done

	echo "=====100MB====" >>getInfo_$1_hbes.txt
	mv getInfo_$1_hbes.txt /home/work1/桌面/UltimateData1.5/$2/$3/hbes	
	killall gjs
	sleep 10s


}

#改三处
arg1=20240108_20,10-20
arg2=20mbps
arg3=20,10-20

echo "===切换网络环境10ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 10"
exam $arg1,10 $arg2 $arg3,10
sleep 5s
cpfile $arg2 $arg3,x $arg3,10

echo "===切换网络环境20ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 20"
exam $arg1,20 $arg2 $arg3,20
sleep 5s
cpfile $arg2 $arg3,x $arg3,20

echo "===切换网络环境40ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 40"
exam $arg1,40 $arg2 $arg3,40
sleep 5s
cpfile $arg2 $arg3,x $arg3,40

echo "===切换网络环境80ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 80"
exam $arg1,80 $arg2 $arg3,80
sleep 5s
cpfile $arg2 $arg3,x $arg3,80

echo "===切换网络环境100ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 100"
exam $arg1,100 $arg2 $arg3,100
sleep 5s
cpfile $arg2 $arg3,x $arg3,100


echo "===切换网络环境120ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 120"
exam $arg1,120 $arg2 $arg3,120
sleep 5s
cpfile $arg2 $arg3,x $arg3,120

echo "===切换网络环境140ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 140"
exam $arg1,140 $arg2 $arg3,140
sleep 5s
cpfile $arg2 $arg3,x $arg3,140

echo "===切换网络环境160ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 160"
exam $arg1,160 $arg2 $arg3,160
sleep 5s
cpfile $arg2 $arg3,x $arg3,160

echo "===切换网络环境180ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 180"
exam $arg1,180 $arg2 $arg3,180
sleep 5s
cpfile $arg2 $arg3,x $arg3,180
echo "===切换网络环境200ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 20 25 10 20 25 200"
exam $arg1,200 $arg2 $arg3,200
sleep 5s
cpfile $arg2 $arg3,x $arg3,200



#改三处
arg1=20240108_40,10-40
arg2=40mbps
arg3=40,10-40

echo "===切换网络环境10ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 10"
exam $arg1,10 $arg2 $arg3,10
sleep 5s
cpfile $arg2 $arg3,x $arg3,10

echo "===切换网络环境20ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 20"
exam $arg1,20 $arg2 $arg3,20
sleep 5s
cpfile $arg2 $arg3,x $arg3,20

echo "===切换网络环境40ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 40"
exam $arg1,40 $arg2 $arg3,40
sleep 5s
cpfile $arg2 $arg3,x $arg3,40

echo "===切换网络环境80ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 80"
exam $arg1,80 $arg2 $arg3,80
sleep 5s
cpfile $arg2 $arg3,x $arg3,80

echo "===切换网络环境100ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 100"
exam $arg1,100 $arg2 $arg3,100
sleep 5s
cpfile $arg2 $arg3,x $arg3,100


echo "===切换网络环境120ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 120"
exam $arg1,120 $arg2 $arg3,120
sleep 5s
cpfile $arg2 $arg3,x $arg3,120

echo "===切换网络环境140ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 140"
exam $arg1,140 $arg2 $arg3,140
sleep 5s
cpfile $arg2 $arg3,x $arg3,140

echo "===切换网络环境160ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 160"
exam $arg1,160 $arg2 $arg3,160
sleep 5s
cpfile $arg2 $arg3,x $arg3,160

echo "===切换网络环境180ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 180"
exam $arg1,180 $arg2 $arg3,180
sleep 5s
cpfile $arg2 $arg3,x $arg3,180
echo "===切换网络环境200ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 40 45 200"
exam $arg1,200 $arg2 $arg3,200
sleep 5s
cpfile $arg2 $arg3,x $arg3,200




#改三处
arg1=20240108_40,10-20
arg2=20mbps
arg3=40,10-20

echo "===切换网络环境10ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 10"
exam $arg1,10 $arg2 $arg3,10
sleep 5s
cpfile $arg2 $arg3,x $arg3,10

echo "===切换网络环境20ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 20"
exam $arg1,20 $arg2 $arg3,20
sleep 5s
cpfile $arg2 $arg3,x $arg3,20

echo "===切换网络环境40ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 40"
exam $arg1,40 $arg2 $arg3,40
sleep 5s
cpfile $arg2 $arg3,x $arg3,40

echo "===切换网络环境80ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 80"
exam $arg1,80 $arg2 $arg3,80
sleep 5s
cpfile $arg2 $arg3,x $arg3,80

echo "===切换网络环境100ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 100"
exam $arg1,100 $arg2 $arg3,100
sleep 5s
cpfile $arg2 $arg3,x $arg3,100


echo "===切换网络环境120ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 120"
exam $arg1,120 $arg2 $arg3,120
sleep 5s
cpfile $arg2 $arg3,x $arg3,120

echo "===切换网络环境140ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 140"
exam $arg1,140 $arg2 $arg3,140
sleep 5s
cpfile $arg2 $arg3,x $arg3,140

echo "===切换网络环境160ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 160"
exam $arg1,160 $arg2 $arg3,160
sleep 5s
cpfile $arg2 $arg3,x $arg3,160

echo "===切换网络环境180ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 180"
exam $arg1,180 $arg2 $arg3,180
sleep 5s
cpfile $arg2 $arg3,x $arg3,180
echo "===切换网络环境200ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 40 45 10 20 25 200"
exam $arg1,200 $arg2 $arg3,200
sleep 5s
cpfile $arg2 $arg3,x $arg3,200


#改三处
arg1=20240108_80,10-40
arg2=40mbps
arg3=80,10-40

echo "===切换网络环境10ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 10"
exam $arg1,10 $arg2 $arg3,10
sleep 5s
cpfile $arg2 $arg3,x $arg3,10

echo "===切换网络环境20ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 20"
exam $arg1,20 $arg2 $arg3,20
sleep 5s
cpfile $arg2 $arg3,x $arg3,20

echo "===切换网络环境40ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 40"
exam $arg1,40 $arg2 $arg3,40
sleep 5s
cpfile $arg2 $arg3,x $arg3,40

echo "===切换网络环境80ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 80"
exam $arg1,80 $arg2 $arg3,80
sleep 5s
cpfile $arg2 $arg3,x $arg3,80

echo "===切换网络环境100ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 100"
exam $arg1,100 $arg2 $arg3,100
sleep 5s
cpfile $arg2 $arg3,x $arg3,100


echo "===切换网络环境120ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 120"
exam $arg1,120 $arg2 $arg3,120
sleep 5s
cpfile $arg2 $arg3,x $arg3,120

echo "===切换网络环境140ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 140"
exam $arg1,140 $arg2 $arg3,140
sleep 5s
cpfile $arg2 $arg3,x $arg3,140

echo "===切换网络环境160ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 160"
exam $arg1,160 $arg2 $arg3,160
sleep 5s
cpfile $arg2 $arg3,x $arg3,160

echo "===切换网络环境180ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 180"
exam $arg1,180 $arg2 $arg3,180
sleep 5s
cpfile $arg2 $arg3,x $arg3,180
echo "===切换网络环境200ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 40 45 200"
exam $arg1,200 $arg2 $arg3,200
sleep 5s
cpfile $arg2 $arg3,x $arg3,200



#改三处
arg1=20240108_80,10-80
arg2=80mbps
arg3=80,10-80

echo "===切换网络环境10ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 10"
exam $arg1,10 $arg2 $arg3,10
sleep 5s
cpfile $arg2 $arg3,x $arg3,10

echo "===切换网络环境20ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 20"
exam $arg1,20 $arg2 $arg3,20
sleep 5s
cpfile $arg2 $arg3,x $arg3,20

echo "===切换网络环境40ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 40"
exam $arg1,40 $arg2 $arg3,40
sleep 5s
cpfile $arg2 $arg3,x $arg3,40

echo "===切换网络环境80ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 80"
exam $arg1,80 $arg2 $arg3,80
sleep 5s
cpfile $arg2 $arg3,x $arg3,80

echo "===切换网络环境100ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 100"
exam $arg1,100 $arg2 $arg3,100
sleep 5s
cpfile $arg2 $arg3,x $arg3,100


echo "===切换网络环境120ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 120"
exam $arg1,120 $arg2 $arg3,120
sleep 5s
cpfile $arg2 $arg3,x $arg3,120

echo "===切换网络环境140ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 140"
exam $arg1,140 $arg2 $arg3,140
sleep 5s
cpfile $arg2 $arg3,x $arg3,140

echo "===切换网络环境160ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 160"
exam $arg1,160 $arg2 $arg3,160
sleep 5s
cpfile $arg2 $arg3,x $arg3,160

echo "===切换网络环境180ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 180"
exam $arg1,180 $arg2 $arg3,180
sleep 5s
cpfile $arg2 $arg3,x $arg3,180
echo "===切换网络环境200ms==="
sshpass -p 123456 ssh work2@192.168.2.6 "sh /home/work2/桌面/netset.sh 80 85 10 80 85 200"
exam $arg1,200 $arg2 $arg3,200
sleep 5s
cpfile $arg2 $arg3,x $arg3,200









