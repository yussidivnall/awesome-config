#!/usr/bin/python
#
#Takes netstat like data from /proc/net/tcp & udp
#much quicker then netstat, doesn't host awesome.
#
import io;
class entry:
	local_port=""
	local_ip=""
	remote_port=""
	remote_ip=""
	name=""
	state=""
	
table=[];
def hex_to_port(p):
	return "%s"%(int(p,16))
def hex_to_ip(add):
	return "%s.%s.%s.%s"%(int(add[6:8],16),int(add[4:6],16),int(add[2:4],16),int(add[0:2],16))
def hex_to_state(st):
	#From include/net/tcp_states.h
	if(st=="01"):return "ESTABLISHED"
	elif(st=="02"):return "SYN_SENT"
	elif(st=="03"):return "SYN_RECV"
	elif(st=="04"):return "FIN_WAIT_1"
	elif(st=="05"):return "FIN_WAIT_2"
	elif(st=="06"):return "TIME_WAIT"
	elif(st=="07"):return "CLOSE"
	elif(st=="08"):return "CLOSE_WAIT"
	elif(st=="09"):return "LAST_ACK"
	elif(st=="0A"):return "LISTEN"
	elif(st=="0B"):return "CLOSING"
	else: return "UNKNOWN"
def parse_line(line):
	global table;
	e =entry()
	words=line.split();
	e.local_ip=hex_to_ip(words[1].split(":")[0])
	e.local_port=hex_to_port(words[1].split(":")[1])
	e.remote_ip=hex_to_ip(words[2].split(":")[0])
	e.remote_port=hex_to_port(words[2].split(":")[1])
	e.state=hex_to_state(words[3])
	table.append(e)
def dump_table():
	global table
	for e in table:
		print "%s:%s %s:%s %s" %(e.local_ip,e.local_port,e.remote_ip,e.remote_port,e.state)
f=open("/proc/net/tcp","r")
f.readline(); # skip header line
for l in f:
	parse_line(l)
f.close()
f=open("/proc/net/udp","r")
f.readline()
for l in f:
	parse_line(l)
f.close()
dump_table()
#print hex_to_ip("A82167B2")
#print hex_to_port("8C03")
