source /home/ubuntu/run.sh
python /home/ubuntu/assignment2/question_a/cleanup_input.py /home/ubuntu/input_data/web-BerkStan.txt
hadoop fs -copyFromLocal /home/ubuntu/input_data/web-BerkStan.txt /user/ubuntu/
for trial in 1
do
for partitions in 16
do
sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches"
ssh -t ubuntu@vm-4-2 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-3 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-4 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
ssh -t ubuntu@vm-4-5 "sudo sh -c \"sync; echo 3 > /proc/sys/vm/drop_caches\""
for z in 1 2 3 4 5
do
	ssh vm-4-$z mkdir -p /home/ubuntu/output_stats/questionA3/${partitions}/trial_${trial}
	ssh -t vm-4-$z "sudo cp /proc/net/dev /home/ubuntu/output_stats/questionA3/${partitions}/trial_${trial}/net_before"
	ssh -t vm-4-$z "sudo cp /proc/diskstats /home/ubuntu/output_stats/questionA3/${partitions}/trial_${trial}/disk_before"
done
START=$(date +%s)
hadoop fs -rmr /user/ubuntu/questionA3/${partitions}/trial_${trial}
spark-submit --verbose /home/ubuntu/assignment2/question_a/a3_pagerank.py /user/ubuntu/soc-LiveJournal1.txt questionA3/${partitions}/trial_${trial} $partitions CS-838-Assignment2-PartA-3
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Program run time : $DIFF">>time_${trial}_questionA3_${partitions}
for z in 1 2 3 4 5
do
	ssh -t vm-4-$z "sudo cp /proc/net/dev /home/ubuntu/output_stats/questionA3/${partitions}/trial_${trial}/net_after"
        ssh -t vm-4-$z "sudo cp /proc/diskstats /home/ubuntu/output_stats/questionA3/${partitions}/trial_${trial}/disk_after"
done
done
done

