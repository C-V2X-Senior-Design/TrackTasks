## **Preamble**

This tutorial is intended to walk you through the process of setting up and testing the connection between a Base Station and User End using the ZeroMQ library.  

This process requires a lot of different terminal tabs, so I would recommend renaming your tabs if at all possible.

## **Step 1**: Setting up the Network

Run in its own terminal:
```
sudo srsepc
```

* Starts the network

Ready when you see:
```
SP-GW Initialized.
```

---

## **Step 2**: Base Station

Run in its own terminal:
```
ENB_TRANSMIT_PORT=2101
ENB_RECEIVER_PORT=2100
sudo srsenb --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,tx_port=tcp://*:$ENB_TRANSMIT_PORT,rx_port=tcp://localhost:$ENB_RECEIVER_PORT,id=enb,base_srate=23.04e6"
```

* Starts the ENB (base station)
    * simulates a cell tower
* Ports numbers used are arbitrary

Ready when you see:
```
==== eNodeB started ===
Type <t> to view trace
```

Can also start trace now by entering:
```
t
```

* Nothing will show up until you begin pinging/running iperf

---

## **Step 3**: Setting up the User Namespace

Run in any terminal:
```
sudo ip netns add ue1
```

* Creates a namespace for the  user end
* ue1 namespace now acts as a device separate from the base station, network-wise

---

## **Step 4**: User End

Run in its own terminal:
```
UE_TRANSMIT_PORT=2001
UE_RECEIVER_PORT=2000
sudo srsue --rf.device_name=zmq --rf.device_args="tx_port=tcp://*:$UE_TRANSMIT_PORT,rx_port=tcp://localhost:$UE_RECEIVER_PORT,id=ue,base_srate=23.04e6" --gw.netns=ue1
```

* Starts the UE (user end)
    * simulates a cell phone
* Port numbers used are arbitrary

Ready when you see:
```
Attaching UE...
```

---

## **Step 5**: Setting up the Broker

Run in any terminal:
```
gnuradio-companion &
```

* Should see a gnu-radio window open
* Create links between the ports assigned to  the ENB and UE
* Refer to the screenshots [here](https://docs.google.com/document/d/14v52WOzonhJv8HVEs_0HHCl-ZjzF5lkIgUMAdInlMIE/edit)
    * double click the "options" box and change the "id" field from "default" to anything else (i.e. "broker")

When your diagram is complete, hit the grey play button on the top toolbar.

---

## **Step 6**: Setting the IP

If you look back at your **User End** terminal, you should now see:
```
RRC Connected
Random Access Complete.     c-rnti=0x46, ta=0
Network attach successful. IP: {IP}
Software Radio Systems RAN (srsRAN) {some timestamp}
```
Where the value of IP identifies the User End.

If left idle, you will also eventually see:
```
RRC IDLE
```
For ease of testing, make the IP retrieved above an environment variable in any shell terminal in which you plan on running tests by exdecuting the following:
```
UEIP="{IP}"
```
In all of my tests, the User End IP has been:
```
UEIP="172.16.0.2"
```
and the Base Station IP has been:
```
ENBIP="172.16.0.1"
```

---

## **Step 7**: Testing Uplink Connection with Ping (OPTIONAL)

Make sure you have started the trace on both the Base Station and User End by executing `t` in both terminals.

In any free terminal, make sure the UeIP environment variable is set and run:
```
ping $UEIP
```
You should now see uplink activity in the Base Station and User End terminals.
* You may also see downlink activity. These are just ACKs as per the TCP protocol

If you use ctrl+C to stop the `ping`, you should see the activity in the Base Station and User End stop. 

---

## **Step 8**: Testing Uplink Throughput

We will be using `iperf` to establish the Base Station as a Server and the User End as a client.

In a new terminal, run:
```
iperf -s -i 1
```
* `-s` identifies this as an iperf server.
* `-i 1` makes the server report throughput every 1 second.
* As the Base Station does not have its own namespace, running this command without identifying a namespace links this iperf server to the Base Station.

In a new terminal, make sure the Base Station IP environment variable is set and run:
```
sudo ip netns exec ue1 iperf -c $ENBIP -i 1 -t 100
```
* `sudo ip netns exec ue1` runs this client in the User End namespace.
* `-c $ENBIP` identifies this as an iperf client.
   * this is typically `-c 172.16.0.1`
* `-i 1` makes the client report throughput every 1 second.
* `-t 100` means that the client will omntinue commmunicating for 100 seconds.

Bandwidth should be visible on both the iperf client and server terminals.

If you look at either the Base Station or User End terminal tab and have trace running, you should see a higher bitrate in the Uplink direction than in the Downlink direction.

---

## **Step 9**: Testing Downlink Throughput

We will be using `iperf` to establish the User End as a Server and the Base Station as a client.

In a new terminal, run:
```
sudo ip netns exec ue1 iperf -s -i 1
```
* `sudo ip netns exec ue1` runs this server in the User End namespace.
* `-s` identifies this as an iperf server.
* `-i 1` makes the server report throughput every 1 second.

In a new terminal, make sure the User End IP environment variable is set and run
```
iperf -c $UEIP -i 1 -t 100
```
* `-c $UEIP` identifies this as an iperf client.
   * this is typically `-c 172.16.0.2`
* `-i 1` makes the client report throughput every 1 second.
* `-t 100` means that the client will omntinue commmunicating for 100 seconds.
* As the Base Station does not have its own namespace, running this command without identifying a namespace links this iperf client to the Base Station.

Bandwidth should be visible on both the iperf client and server terminals.

If you look at either the Base Station or User End terminal tab and have trace running, you should see a higher bitrate in the Downlink direction than in the Uplink direction.

---

## **Step 10**: Teardown
Use "ctrl+C" to end terminal processes in this order:
* Iperf Client
* Iperf Server
* GNU Radio Broker
   * in the GNU Radio GUI, press the grey box next to the "start" button to shut down the broker first
* User End
* Base Station
* Network

Note: if you are ending all processes, any order for teardown should be fine. However, if you are only partially tearing down in order to backtrack to a prior step, use this order.
