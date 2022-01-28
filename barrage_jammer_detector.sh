#!/usr/bin/sh

#Check/Add the Python executable to the shell PATH environment
#Check/Add ~/Code/srsRAN directory to the path 

sudo ip netns add ue1

sudo srsepc &

sleep 5
#may need priveleges and hang
# sudo srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2001,rx_port=tcp://localhost:2000,id=ue,base_srate=23.04e6" --gw.netns=ue1
sudo srsue &
sleep 5

#Open the Python script and have it read from stdout buffer
python3 connection_plot.py & 
sleep 5


#may need privelges and hang
#srsenb --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,tx_port=tcp://*:2000,rx_port=tcp://localhost:2001,id=enb,base_srate=23.04e6" &
sudo srsenb & 


#Sleep time approximates how long to gather data for
sleep 100

# kills all srsenb processes, this works!!
pgrep srsenb | xargs sudo kill
# kill all srsue processes
pgrep srsue | xargs sudo kill
# kill all srsepc processes
pgrep srsepc | xargs sudo kill

#Need to figure out how to let Python program shut down without losing 
#any work in progress 