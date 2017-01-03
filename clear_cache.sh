ssh -t ubuntu@vm-4-4 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
