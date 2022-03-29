#/bin/bash
logfile=/www/wwwlogs/
last_minutes=1 
start_time=`date -d"$last_minutes minutes ago" +"%H:%M:%S"`
echo $start_time
stop_time=`date +"%H:%M:%S"`    
echo $stop_time
# 这里www.3byte.me.log 替换为你自己的站点log文件
tac $logfile/www.3byte.me.log | awk -v st="$start_time" -v et="$stop_time" '{t=substr($2,RSTART+14,21);if(t>=st && t<=et) {print $0}}' | awk '{print $1}' | sort | uniq -c | sort -nr > $logfile/log_ip_top10
ip_top=`cat $logfile/log_ip_top10 | head -1 | awk '{print $1}'`
ip=`cat $logfile/log_ip_top10 | awk '{if($1>120)print $2}'`
# 单位时间[1 分钟]内单 ip 访问次数超过 120 次的 ip 记录入 black.txt
for line in $ip
do
echo $line >> $logfile/black.txt
echo $line
done
    CFEMAIL="CF的账户邮箱"
    # 填Cloudflare API key
    CFAPIKEY="填CloudflareAPIKEY"
    # 填Cloudflare Zones ID 域名对应的ID
    ZONESID="填Cloudflare Zones ID"
    # /www/wwwlogs/black.txt存放恶意攻击的IP列表
    # IP一行一个。
    IPADDR=$(</www/wwwlogs/black.txt)
    # 循环提交 IPs 到 Cloudflare  防火墙黑名单
    # 模式（mode）有 block, challenge, whitelist, js_challenge
    for IPADDR in ${IPADDR[@]}; do
    echo $IPADDR
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONESID/firewall/access_rules/rules" \
      -H "X-Auth-Email: $CFEMAIL" \
      -H "X-Auth-Key: $CFAPIKEY" \
      -H "Content-Type: application/json" \
      --data '{"mode":"block","configuration":{"target":"ip","value":"'$IPADDR'"},"notes":"CC Attatch"}'
    done
    # 删除 IPs 文件收拾干净
     rm -rf /www/wwwlogs/black.txt