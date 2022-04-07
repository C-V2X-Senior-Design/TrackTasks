Note the debug information you get with -v and -vv on the RX side (pssch_ue).
What you're getting with -v is from sync_ue.c please understand this debug output.
What you get with -vv is .bin files containing raw symbols for detected packets.
 
Running TX as:
./build/cv2x_traffic_generator/cv2x_traffic_generator -g 40 -a "clock=external,time=external"

Running RX as:
./build/pssch_ue/pssch_ue -o log.log -v > pssch_ue_no_sync.log
