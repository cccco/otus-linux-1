#!/bin/bash

lockfile=/var/local/bash.lock
nginxLog=access.log
lnfile=/var/local/lnfile

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;then   
	trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT KILL   
	#while true   
	#do       
	#	ls -ld ${lockfile}       
	#	sleep 1   
	#done  
	rm -f "$lockfile"  
	trap - INT TERM EXIT
else  
	echo "Failed to acquire lockfile: $lockfile."  
	echo "Held by $(cat $lockfile)"
fi

#check line file
if test -f "$lnfile"; then
    wasLine=$(cat $lnfile)
    curLine=$(wc -l $nginxLog | awk '{ print $1 }')
    diffLine=$((curLine-wasLine))
    echo $curLine > $lnfile
else
        curLine=$(wc -l $nginxLog | awk '{ print $1 }')
        echo $curLine > $lnfile
        diffLine=$curLine
fi

if [ $diffLine -ne 0 ]; then


# tops
top10IP=$(tail -n $diffLine $nginxLog | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 10)
top10URL=$(tail -n $diffLine $nginxLog | awk -F\" '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 10)

# http errors only
httpErrors=()
for i in {400..511}
do
   count=$(tail -n $diffLine $nginxLog | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | wc -l)
   if [ $count -ne 0 ]; then
   result=$(tail -n $diffLine $nginxLog | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 1)
   httpErrors+=("$i - $result")
fi
done

# count all http codes
for i in {100..511}
do
   count=$(tail -n $diffLine $nginxLog | awk '($9 ~ /'"$i"'/)' | awk '{print $7}' | wc -l)
   if [ $count -ne 0 ]; then
        httpCodes+=("$i - $count")
fi
done

#normalization
printHttpErrors=$(printf '%s\n' "${httpErrors[@]}")
printHttpCodes=$(printf '%s\n' "${httpCodes[@]}")
# send email
echo -e "top 10 ip-addresses:\n $top10IP\n\n top 10 requests:\n $top10URL\n\n HTTP errors:\n $printHttpErrors\n\n All HTTP codes:\n $printHttpCodes" | mail -s "nginx log stats" root@localhost

# if log file was not changed then send nothing
else
	echo -e "log file was not changed!" | mail -s "nginx log stats" root@localhost
fi

