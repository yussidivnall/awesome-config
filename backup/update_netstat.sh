#!/bin/bash
function update(){
	args=`cat /tmp/.awesome.netstat`
	
	time_stamp=`date`

	echo $time_stamp > /tmp/.awesome.netstat_out.tmp
	netstat $args 2>/dev/null|tail --lines=+3 >> /tmp/.awesome.netstat_out.tmp
	echo $time_stamp > /tmp/.awesome.listening.tmp
	netstat -lptu 2>/dev/null | tail --lines=+3 >> /tmp/.awesome.listening.tmp

	mv /tmp/.awesome.netstat_out.tmp /tmp/.awesome.netstat_out
	mv  /tmp/.awesome.listening.tmp  /tmp/.awesome.listening
#	netstat_out=`netstat $args 2>/dev/null`
#	listening=`netstat -lptu 2>/dev/null`

#	echo $time_stamp > /tmp/.awesome.netstat_out
#	echo $netstat_out >> /tmp/.awesome.netstat_out

#	echo $time_stamp > /tmp/.awesome.listening 
#	echo $listening > /tmp/.awesome.listening 
#	date > /tmp/.awesome.netstat_out
#	netstat $args >> /tmp/.awesome.netstat_out 2>/dev/null

#	date > /tmp/.awesome.listening
#	netstat -lptu > /tmp/.awesome.listening 2>/dev/null
}



while true; do
	[ -e "/tmp/.awesome.netstat" ]&&update
	sleep 1
done
