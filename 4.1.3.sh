#!/usr/bin/sh

sudo pkill srs

enb_tx=2101
ue_rx=2000
enb_rx=2100
ue_tx=2001

echo "Establishing network interface"
sudo ip netns add ue1

echo "Running srsepc"
sudo srsepc &

sleep 5

echo "\nRunning srsenb"
sudo srsenb --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,tx_port=tcp://*:$enb_tx,rx_port=tcp://localhost:$enb_rx,id=enb,base_srate=23.04e6" &
#sudo srsenb --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,tx_port=tcp://*:2101,rx_port=tcp://localhost:2100,id=enb,base_srate=23.04e6"

# RUN GNURADIO BEFORE RUNNING NEXT COMMAND

sleep 5
echo "\nRunning srsue"
sudo srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:$ue_tx,rx_port=tcp://localhost:$ue_rx,id=ue,base_srate=23.04e6" --gw.netns=ue1 &
#sudo srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:2001,rx_port=tcp://localhost:2000,id=ue,base_srate=23.04e6" --gw.netns=ue1 

