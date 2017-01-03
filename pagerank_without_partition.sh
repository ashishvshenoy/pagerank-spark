source /home/ubuntu/run.sh
python /home/ubuntu/assignment2/question_a/cleanup_input.py /home/ubuntu/input_data/web-BerkStan.txt
hadoop fs -copyFromLocal /home/ubuntu/input_data/web-BerkStan.txt /user/ubuntu/
for trial in 1
do
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
ssh -t ubuntu@vm-4-2 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-3 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-4 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-5 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
for z in 1 2 3 4 5
do
	ssh vm-4-$z mkdir -p /home/ubuntu/output_stats/trial_${trial}_questionA1
	ssh -t vm-4-$z "sudo cp /proc/net/dev /home/ubuntu/output_stats/trial_${trial}_questionA1/net_before"
	ssh -t vm-4-$z "sudo cp /proc/diskstats /home/ubuntu/output_stats/trial_${trial}_questionA1/disk_before"
done
START=$(date +%s)
hadoop fs -rmr /user/ubuntu/questionA1/trial_${trial}_questionA1
spark-submit --verbose /home/ubuntu/assignment2/question_a/pagerank_wo_partition.py /user/ubuntu/web-BerkStan.txt questionA1/trial_${trial}_questionA1
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Program run time : $DIFF">>time_${trial}_questionA1
for z in 1 2 3 4 5
do
	ssh -t vm-4-$z "sudo cp /proc/net/dev /home/ubuntu/output_stats/trial_${trial}_questionA1/net_after"
        ssh -t vm-4-$z "sudo cp /proc/diskstats /home/ubuntu/output_stats/trial_${trial}_questionA1/disk_after"
done
done

