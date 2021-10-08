## **Step 1**: Setting up the Network

Run in any terminal:
```
sudo srsepc &
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
sudo srsenb --rf.device_name=zmq --rf.device_args="fail_on_disconnect=true,tx_port=tcp://*:$ENB_TRANSMIT_PORT,rx_port=tcp://localhost:{ENB_RECEIVER_PORT},id=enb,base_srate=23.04e6"
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

If you look back at your User End terminal, you should now see:
```
RRC Connected
```
followed by some user-specific informational lines
