#!/bin/sh
HOSTNAME=`hostname`
COMPUTERNAME_XML=$HOSTNAME@linux.xml
RAWDATA=$HOSTNAME@linux@rawdata.text
FILETEXT=$HOSTNAME@linux@filelist.text

LANG=C
export LANG
clear
sleep 1

echo "#netstat -na" > $RAWDATA 2>&1
netstat -na >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1
echo "======================================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1
echo "#ps -ef" >> $RAWDATA 2>&1
ps -ef >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1
echo "======================================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1




# FTP 서비스 동작확인
find /etc/ -name "proftpd.conf" | grep "/etc/"  > proftpd.txt
find /etc/ -name "vsftpd.conf" | grep "/etc/"  > vsftpd.txt
profile=`cat proftpd.txt`
vsfile=`cat vsftpd.txt`

# Apache 서비스 동작확인
#0. 필요한 함수 선언
apache_awk() {
	if [ `ps -ef | grep -i $1 | grep -v "ns-httpd" | grep -v "grep" | awk '{print $8}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -gt 0 ]
	then
		apaflag=8
	elif [ `ps -ef | grep -i $1 | grep -v "ns-httpd" | grep -v "grep" | awk '{print $9}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -gt 0 ]
	then
		apaflag=9
	fi
}


# 1. Apache 프로세스 구동 여부 확인 및 아파치 TYPE 판단, awk 컬럼 확인
if [ `ps -ef | grep -i "httpd" | grep -v "ns-httpd" | grep -v "lighttpd" | grep -v "grep" | wc -l` -gt 0 ]
then
	apache_type="httpd"
	apache_awk $apache_type

elif [ `ps -ef | grep -i "apache2" | grep -v "ns-httpd" | grep -v "lighttpd" | grep -v "grep" | wc -l` -gt 0 ]
then
	apache_type="apache2"
	apache_awk $apache_type
else
	apache_type="null"
	apaflag=0	
fi

# 2. Apache 홈 디렉토리 경로 확인

if [ $apaflag -ne 0 ]
then

	if [ `ps -ef | grep -i $apache_type | grep -v "ns-httpd" | grep -v "grep" | awk -v apaflag2=$apaflag '{print $apaflag2}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -gt 0 ]
	then
		APROC1=`ps -ef | grep -i $apache_type | grep -v "ns-httpd" | grep -v "grep" | awk -v apaflag2=$apaflag '{print $apaflag2}' | grep "/" | grep -v "httpd.conf" | uniq`
		APROC=`echo $APROC1 | awk '{print $1}'`
		$APROC -V > APROC.txt 2>&1
				
		ACCTL=`echo $APROC | sed "s/$apache_type$/apachectl/"`
		$ACCTL -V > ACCTL.txt 2>&1
				
		if [ `cat APROC.txt | grep -i "root" | wc -l` -gt 0 ]
		then
			AHOME=`cat APROC.txt | grep -i "root" | awk -F"\"" '{print $2}'`
			ACFILE=`cat APROC.txt | grep -i "server_config_file" | awk -F"\"" '{print $2}'`
		else
			AHOME=`cat ACCTL.txt | grep -i "root" | awk -F"\"" '{print $2}'`
			ACFILE=`cat ACCTL.txt | grep -i "server_config_file" | awk -F"\"" '{print $2}'`
		fi
	fi
	
	if [ -f $AHOME/$ACFILE ]
	then
		ACONF=$AHOME/$ACFILE
	else
		ACONF=$ACFILE
	fi	
	
	if [ `echo $ACONF | sed '/^$/d' | wc -l` -eq 0 ]
	then
		APROC2=`echo $APROC | awk -F"/bin" '{print $1}'`
		ACONF=`echo $APROC2/conf/httpd.conf`
		echo $ACONF
	fi
fi

echo "<?xml version=\"1.0\" encoding=\"euc-kr\"?>" >> $COMPUTERNAME_XML 2>&1

echo "<Group>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "1) telnet 설정 확인"  >> $COMPUTERNAME_XML 2>&1

telnet_check=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"`;

if [ `echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	echo "포트 확인: $telnet_check" >> $COMPUTERNAME_XML 2>&1
	port=`echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep :$port | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		echo "포트 활성화 여부: "  >> $COMPUTERNAME_XML 2>&1
		netstat -na | grep :$port | grep -i "^tcp"  >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "[/etc/securetty 파일 설정]"  >> $COMPUTERNAME_XML 2>&1
		
		if [ -f /etc/securetty ]
		
		then
			if [ `cat /etc/securetty | grep -i "pts" | grep -v "^#" | wc -l` -gt 0 ]
			then
				cat /etc/securetty | grep -i "pts" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
				
				echo "/etc/securetty 파일에 pts/0~pts/x 설정이 존재합니다."   >> $COMPUTERNAME_XML 2>&1
				
			else	
				echo "/etc/securetty 파일에 pts/0~pts/x 설정이 존재하지 않습니다."   >> $COMPUTERNAME_XML 2>&1				
			fi
			
		else
			echo "/etc/securetty 파일이 없습니다."   >> $COMPUTERNAME_XML 2>&1
		fi
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "[/etc/pam.d/login 파일 설정]"  >> $COMPUTERNAME_XML 2>&1

		if [ -f /etc/pam.d/login ]
		
		then
			if [ `cat /etc/pam.d/login | grep -i "pam_securetty.so" | grep -v "^#" | wc -l` -gt 0 ]
			then
				cat /etc/pam.d/login | grep -i "pam_securetty.so" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
				
				echo "/etc/pam.d/login 파일에 pam_securetty.so 설정이 존재합니다."   >> $COMPUTERNAME_XML 2>&1
				
			else	
				echo "/etc/pam.d/login 파일에 pam_securetty.so 설정이 존재하지 않습니다."   >> $COMPUTERNAME_XML 2>&1				
			fi
			
		else
			echo "/etc/pam.d/login 파일이 없습니다."   >> $COMPUTERNAME_XML 2>&1
		fi
		
	else
		echo "telnet 서비스가 비활성화 되어 있습니다."   >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
	
else
	echo "telnet 서비스가 등록되어 있지 않습니다."   >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "2) ssh 설정 확인"  >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh 서비스가 비활성화 되어 있습니다."   >> $COMPUTERNAME_XML 2>&1
else
	result=0;
	
	echo "[/etc/ssh/sshd_config 파일 설정]" >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/ssh/sshd_config ]
	then
		if [ `cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin'| grep -v "^#" | wc -l` -gt 0 ]
		then
			cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin' | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
			
			if [ `cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin' | grep -v "^#" | egrep -i 'yes' | wc -l` -eq 0 ]
			then
				echo "sshd_config 파일에 PermitRootLogin이 no로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				
			else
				echo "sshd_config 파일에 PermitRootLogin이 yes로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "sshd_config 파일에 PermitRootLogin 설정이 없습니다." >> $COMPUTERNAME_XML 2>&1
			
		fi
	else
		echo "sshd_config 파일이 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
fi
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/passwd ]
then
	echo "[etc/passwd 파일]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/passwd | head -5 >> $COMPUTERNAME_XML 2>&1

	if [ `awk -F: '$2=="x"' /etc/passwd | wc -l` -eq 0 ]
	then
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "/etc/passwd 파일에 패스워드가 암호화 되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "/etc/passwd 파일에 패스워드가 암호화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
else
	echo "/etc/passwd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ ! -f /etc/shadow ]
then
	echo "/etc/shadow 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/pam.d/system-auth ]
then
	echo "[/etc/pam.d/system-auth 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/system-auth | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/pam.d/system-auth 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/pam.d/common-auth ]
then
	echo "[/etc/pam.d/common-auth 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/common-auth | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/pam.d/common-auth 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/security/pwquality.conf ]
then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[/etc/security/pwquality.conf 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/security/pwquality.conf | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/security/pwquality.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/login.defs | grep -v "^#" | egrep -i "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_MIN_LEN|PASS_WARN_AGE" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/login.defs 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1

if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi

echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.07</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_LEN" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_min_len=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_LEN" | awk -F" " '{print $2}'`;
	
	if [ "$pass_min_len" -ge 8 ]
	then
		echo "패스워드 최소 길이가 8자 이상입니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "패스워드 최소 길이가 8자 미만입니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MAX_DAYS" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_max_days=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MAX_DAYS" | awk -F" " '{print $2}'`;
	
	if [ "$pass_max_days" -le 90 ]
	then
		echo "패스워드 최대 사용기간이 90일 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "패스워드 최대 사용기간이 90일 이하로 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.09</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_DAYS" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_min_days=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_DAYS" | awk -F" " '{print $2}'`;
	
	if [ "$pass_min_days" -ge 1 ]
	then
		echo "패스워드 최소 사용기간이 1일 이상으로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "패스워드 최소 사용기간 설정이 되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/pam.d/system-auth ]
then
	echo "[/etc/pam.d/system-auth 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/system-auth | egrep -i "auth|account" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
else	
	if [ -f /etc/pam.d/common-auth ]
	then
		echo "[/etc/pam.d/common-auth 파일 설정]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/pam.d/common-auth | egrep -i "auth|account|include" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
	fi
fi

if [ -f /etc/pam.d/sshd ]
then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[/etc/pam.d/sshd 파일 설정]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/sshd | egrep -i "auth|account|include" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.14</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[로그인이 필요하지 않은 시스템 계정 확인]" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/passwd ]
then
	cat /etc/passwd | egrep "^daemon:|^bin:|^sys:|^adm:|^listen:|^nobody:|^nobody4:|^noaccess:|^diag:|^operator:|^games:|^gopher:" > nologin.txt
	
	if [ `egrep -v "nologin|false" nologin.txt | wc -l` -eq 0 ]
	then
		cat nologin.txt | egrep -v "nologin|false"  >> $COMPUTERNAME_XML 2>&1
		cat nologin.txt | egrep "nologin|false"  >> $COMPUTERNAME_XML 2>&1
		echo "로그인이 필요하지 않은 계정에 bin/false(sbin/nologin) 쉘이 부여되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		cat nologin.txt  >> $COMPUTERNAME_XML 2>&1
		echo "로그인이 필요하지 않은 계정에 bin/false(sbin/nologin) 쉘이 부여되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/passwd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "1.10 불필요한 계정 제거"  >> $RAWDATA 2>&1
echo "#cat /etc/passwd" >> $RAWDATA 2>&1
cat /etc/passwd >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "lastlog" >> $RAWDATA 2>&1 
lastlog >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1

cat /etc/passwd | egrep -v "/false|/nologin" > userlist0406.txt
lastlog -b 90 > lastlogin.txt

echo "1) 사용하지 않는 Default 계정(lp, uucp, nuucp) 확인" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/passwd | egrep "^lp:|^uucp:|^nuucp:" | wc -l` -eq 0 ]
then
	echo "lp, uucp, nuucp 계정이 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
	echo "" >> $COMPUTERNAME_XML 2>&1
	result=1;
	echo "2) 불필요한 계정 존재 여부 확인" >> $COMPUTERNAME_XML 2>&1
	for username in `cat userlist0406.txt | awk -F: '{print $1}'`
	do
		cat lastlogin.txt | grep $username >> $COMPUTERNAME_XML 2>&1
	done
else
	cat /etc/passwd | egrep "^lp:|^uucp:|^nuucp:" >> $COMPUTERNAME_XML 2>&1
	echo "" >> $COMPUTERNAME_XML 2>&1
	echo "2) 불필요한 계정 존재 여부 확인" >> $COMPUTERNAME_XML 2>&1
	for username in `cat userlist0406.txt | awk -F: '{print $1}'`
	do
		cat lastlogin.txt | grep $username >> $COMPUTERNAME_XML 2>&1
	done
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.05</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/passwd ]
then
	awk -F: '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd >> $COMPUTERNAME_XML 2>&1
	
	if [ `awk -F: '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd | grep -v "root" | wc -l` -eq 0 ]
	then
		echo "root 외에 UID가 0인 계정이 없습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "root 외에 UID가 0인 계정이 존재합니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/passwd 파일이 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[동일한 UID를 사용하는 계정]" >> $COMPUTERNAME_XML 2>&1

echo " " > total-equaluid.txt
for uid in `cat /etc/passwd | awk -F: '{print $3}'`
do
	cat /etc/passwd | awk -F: '$3=="'${uid}'" { print "UID=" $3 " -> " $1 }' > equaluid.txt
	if [ `cat equaluid.txt | wc -l` -gt 1 ]
	then
		cat equaluid.txt >> total-equaluid.txt
	fi
done
if [ `sort -k 1 total-equaluid.txt | wc -l` -gt 1 ]
then
	sort -k 1 total-equaluid.txt | uniq -d >> $COMPUTERNAME_XML 2>&1
else
	echo "동일한 UID를 사용하는 계정이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.11</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "1.11 관리자 그룹에 최소한의 계정 포함"  >> $RAWDATA 2>&1

echo "[관리자 계정 확인]" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/passwd ]
then
	awk -F: '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/passwd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "[관리자 그룹 확인]" >> $COMPUTERNAME_XML 2>&1
for group in `awk -F: '$3==0 { print $1}' /etc/passwd`
do
	cat /etc/group | grep "$group" >> $COMPUTERNAME_XML 2>&1
	cat /etc/group | grep "$group" >> $RAWDATA 2>&1
	
done

echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "1) /etc/pam.d/su 파일 설정" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/pam.d/su ]
then
	if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | wc -l` -eq 0 ]
	then
		echo "pam_wheel.so 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
	else
		cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust'>> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/pam.d/su 파일을 찾을 수 없습니다.">> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) su 파일 권한" >> $COMPUTERNAME_XML 2>&1

if [ `which su | grep -v 'no ' | wc -l` -eq 0 ]
then
	echo "su 명령 파일을 찾을 수 없습니다."  >> $COMPUTERNAME_XML 2>&1
else
	sucommand=`which su`;
	ls -alL $sucommand   >> $COMPUTERNAME_XML 2>&1
	sugroup=`ls -alL $sucommand | awk '{print $4}'`;
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "3) su 명령그룹" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/pam.d/su ]
then
	if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | grep 'group' | awk -F"group=" '{print $2}' | awk -F" " '{print $1}' | wc -l` -gt 0 ]
	then
		pamsugroup=`cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | grep 'group' | awk -F"group=" '{print $2}' | awk -F" " '{print $1}'`
		echo "- su명령 그룹(PAM모듈): `grep -E "^$pamsugroup" /etc/group`" >> $COMPUTERNAME_XML 2>&1
	else
		if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | egrep -v 'trust|#' | wc -l` -gt 0 ]
		then
			echo "- su명령 그룹(PAM모듈): `grep -E "^wheel" /etc/group`" >> $COMPUTERNAME_XML 2>&1
		fi
	fi
fi
echo "- su명령 그룹(명령파일): `grep -E "^$sugroup" /etc/group`" >> $COMPUTERNAME_XML 2>&1
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[구성원이 존재하지 않는 그룹]" >> $COMPUTERNAME_XML 2>&1

for gid in `awk -F: '$4==null {print $3}' /etc/group`
do
	if [ `grep -c :$gid: /etc/passwd` -eq 0 ]
	then
		grep :$gid: /etc/group >> nullgid.txt
	fi		
done

if [ `cat nullgid.txt | wc -l` -eq 0 ]
then
	result=1;
	echo "구성원이 존재하지 않는 그룹이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
else
	cat nullgid.txt >> $COMPUTERNAME_XML 2>&1
	
	echo "1.12 계정이 존재하지 않는 GID 금지"  >> $RAWDATA 2>&1
	cat nullgid.txt >> $RAWDATA 2>&1
	echo " " >> $RAWDATA 2>&1 
	echo "========================================================================" >> $RAWDATA 2>&1
	echo " " >> $RAWDATA 2>&1 
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1




echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.15</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SHELL 확인]" >> $COMPUTERNAME_XML 2>&1
env | grep -i "shell=" >> $COMPUTERNAME_XML 2>&1
echo " "  >> $COMPUTERNAME_XML 2>&1

echo "[TMOUT 설정 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/profile 파일"  >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/profile ]
then
	if [ `cat /etc/profile | grep -i TMOUT | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/profile | grep -i TMOUT | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "TMOUT 이 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/profile 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "2) /etc/csh.login 파일" >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/csh.login ]
then
	if [ `cat /etc/csh.login | grep -i autologout | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/csh.login | grep -i autologout | grep -v "^#"  >> $COMPUTERNAME_XML 2>&1
	else
		echo "autologout 이 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/csh.login 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "3) /etc/csh.cshrc 파일"  >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/csh.cshrc ]
then
	if [ `cat /etc/csh.cshrc | grep -i autologout | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/csh.cshrc | grep -i autologout | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
	else
		echo "autologout 이 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/csh.cshrc 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.14</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;


if [ -f /etc/hosts.allow ]
then
	if [ ! `cat /etc/hosts.allow | grep -v "#" | grep -ve '^ *$' | wc -l` -eq 0 ]
	then
		echo "[/etc/hosts.allow 파일 설정]"		>> $COMPUTERNAME_XML 2>&1
		cat /etc/hosts.allow | grep -v "#" | grep -ve '^ *$' >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.allow 파일에 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi	
else
	echo "/etc/hosts.allow 파일이 없습니다."    			>> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/hosts.deny ]
then
	if [ ! `cat /etc/hosts.deny | grep -v "#" | grep -ve '^ *$' | wc -l` -eq 0 ]
	then
		echo "[/etc/hosts.deny 파일 설정]"		>> $COMPUTERNAME_XML 2>&1
		cat /etc/hosts.deny | grep -v "#" | grep -ve '^ *$' >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.deny 파일에 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi	
else
	echo "/etc/hosts.deny 파일이 없습니다."    			>> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "[iptables 설정]"  >> $COMPUTERNAME_XML 2>&1
iptables -L INPUT >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;

echo "[PATH 환경변수 설정]" >> $COMPUTERNAME_XML 2>&1
echo $PATH >> $COMPUTERNAME_XML 2>&1

if [ `echo $PATH | grep "\." | wc -l` -gt 0 ]
	then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "PATH 변수 내에 "."가 포함되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi

if [ `echo $PATH | grep "::" | wc -l` -gt 0 ]
	then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "PATH 변수 내에 "::"가 포함되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.17</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[현재 로그인 계정 UMASK]" >> $COMPUTERNAME_XML 2>&1

umask >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/profile ]
then
 echo "[/etc/profile 파일 설정]" >> $COMPUTERNAME_XML 2>&1

 if [ `cat /etc/profile | grep -i umask | grep -v ^# | wc -l` -gt 0 ]
	then
		cat /etc/profile | grep -i umask | grep -v ^# | sed -e 's/^ *//g' -e 's/ *$//g' >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "umask 설정이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
 echo "/etc/profile 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.19</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[홈 디렉토리가 존재하지 않은 계정]" >> $COMPUTERNAME_XML 2>&1

HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq`
for dir in $HOMEDIRS
do
	if [ ! -d $dir ]
	then
		awk -F: '$6=="'${dir}'" { print "계정명 -> 홈디렉토리: "$1 " -> " $6 }' /etc/passwd >> $COMPUTERNAME_XML 2>&1
		echo " " > home_dir.txt
	fi
done

if [ ! -f home_dir.txt ]
then
	echo "홈 디렉토리가 존재하지 않은 계정이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.18</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;

HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $1":"$6}' | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq | sort -u`

echo "[홈 디렉토리 설정]" >> $COMPUTERNAME_XML 2>&1
for HOMEDIR in $HOMEDIRS
do
	user_id=`echo $HOMEDIR | awk -F":" '{print $1}'`
	dir=`echo $HOMEDIR | awk -F":" '{print $2}'`
	
	if [ -d $dir ]
	then
		ls -dal $dir | grep '\d.........' >> $COMPUTERNAME_XML 2>&1
		
		if [ `ls -dal $dir | awk '{print $3}' | egrep "root|$user_id" | wc -l` -eq 1 ]
		then
			echo "OK"
		else
			echo "해당 디렉토리는 해당 계정(또는 root) 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
		
		if [ `ls -dal $dir | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
		then
			echo "OK"
		else
			echo "해당 디렉토리는 타 사용자 쓰기권한이 존재합니다." >> $COMPUTERNAME_XML 2>&1
			echo " " >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
	fi
done


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;


echo "[홈디렉터리 환경변수 파일]" >> $COMPUTERNAME_XML 2>&1

HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $1":"$6}' | sort -u | grep -v '/bin/false' | grep -v 'nologin' | grep -v "#"`
FILES=".profile .cshrc .kshrc .login .bash_profile .bashrc .bash_login .exrc .netrc .history .sh_history .bash_history .dtprofile"

for file in $FILES
do
	FILE=/$file
	if [ -f $FILE ]
	then
		ls -alL $FILE >> $COMPUTERNAME_XML 2>&1
	
		if [ `ls -alL $FILE | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
		then
			echo "OK"
		else
			echo "해당 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
		
		if [ `ls -alL $FILE | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
		then
			echo "OK"
		else
			echo "해당 파일은 타 사용자 쓰기권한이 존재합니다." >> $COMPUTERNAME_XML 2>&1
			echo " " >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
	
	fi
done

for HOMEDIR in $HOMEDIRS
do
	user_id=`echo $HOMEDIR | awk -F":" '{print $1}'`
	dir=`echo $HOMEDIR | awk -F":" '{print $2}'`
	
	for file in $FILES
	do
		FILE=$dir/$file
		if [ -f $FILE ]
		then
			ls -alL $FILE >> $COMPUTERNAME_XML 2>&1
							
			if [ `ls -alL $FILE | awk '{print $3}' | egrep "root|$user_id" | wc -l` -eq 1 ]
			then
				echo "OK"
			else
				echo "해당 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
			
			if [ `ls -alL $FILE | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
			then
				echo "OK"
			else
				echo "해당 파일은 타 사용자 쓰기권한이 존재합니다." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
		fi
	done
done



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/passwd ]
then
	echo "[/etc/passwd 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/passwd >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/passwd | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/passwd 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/passwd 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/passwd | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/passwd 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/passwd 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/passwd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/shadow ]
then
	echo "[/etc/shadow 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/shadow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/shadow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/shadow 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/shadow 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/shadow | awk '{print $1}' | grep "..--------" | wc -l` -eq 1 ]
	then
		echo "/etc/shadow 파일의 권한은 400 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/shadow 파일의 권한은 400 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/shadow 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.05</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/hosts ]
then
	echo "[/etc/hosts 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/hosts >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/hosts | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/hosts 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/hosts | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts 파일의 권한은 600 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/hosts 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/inetd.conf ]
then
	echo "[/etc/inetd.conf 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/inetd.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/inetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/inetd.conf 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/inetd.conf 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/inetd.conf | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/inetd.conf 파일의 권한은 600 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/inetd.conf 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/inetd.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/xinetd.conf ]
then
	echo "[/etc/xinetd.conf 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/xinetd.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/xinetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/xinetd.conf 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/xinetd.conf 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/xinetd.conf | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/xinetd.conf 파일의 권한은 600 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/xinetd.conf 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/xinetd.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
if [ -d /etc/xinetd.d ]
then
		echo "[/etc/xinetd.d 하위 모든 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
        ls -al /etc/xinetd.d/* > xinetdd.txt

        for file in `awk -F" " '{ print $9 }' xinetdd.txt`
        do
			if [ -f $file ]
			then
				ls -al $file >> $COMPUTERNAME_XML 2>&1
				
				if [ `ls -alL $file | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "$file 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
				
				if [ `ls -alL $file | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "$file 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
					echo " " >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
			else
				echo "$file 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
			fi
        done

else
        echo "/etc/xinetd.d 디렉터리가 없습니다." >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.07</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/syslog.conf ]
then
	echo "[/etc/syslog.conf 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/syslog.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/syslog.conf | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/syslog.conf 파일은 root(또는 bin, sys) 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/syslog.conf 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/syslog.conf | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/syslog.conf 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/syslog.conf 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
else
	echo "/etc/syslog.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi


if [ -f /etc/rsyslog.conf ]
then
	echo "[/etc/rsyslog.conf 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/rsyslog.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/rsyslog.conf | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/rsyslog.conf 파일은 root(또는 bin, sys) 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/rsyslog.conf 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/rsyslog.conf | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/rsyslog.conf 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/rsyslog.conf 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
else
	echo "/etc/rsyslog.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>확인</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/services ]
then
	echo "[/etc/services 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/services >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/services | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/services 파일은 root(또는 bin, sys) 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/services 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/services | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/services 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/services 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/services 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.15</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/hosts.lpd ]
then
	echo "[/etc/hosts.lpd 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/hosts.lpd >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/hosts.lpd | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts.lpd 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/hosts.lpd 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/hosts.lpd | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts.lpd 파일의 권한은 600 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.lpd 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/hosts.lpd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.09</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

find /usr -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \;        > flist.txt 
find /sbin -xdev -user root -type f \( -perm -04000 -o -perm -02000 \) -exec ls -al  {}  \;        >> flist.txt 

cat flist.txt | egrep -i '/sbin/dump|/sbin/restore|/sbin/unix_chkpwd|/usr/bin/at|/usr/bin/lpq|/usr/bin/lpq-lpd|/usr/bin/lpr|/usr/bin/lpr-lpd|/usr/bin/lprm|/usr/bin/lprm-lpd|/usr/bin/newgrp|/usr/sbin/lpc|/usr/sbin/lpc-lpd|/usr/sbin/traceroute' > suid_filelist.txt

if [ -s suid_filelist.txt ]
then
	linecount=`cat suid_filelist.txt | wc -l`
	if [ $linecount -gt 10 ]
	then
		echo "불필요한 SUID,SGID 파일 "$linecount"개 존재"  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[불필요한 SUID,SGID 파일 (상위 10개)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 suid_filelist.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[불필요한 SUID,SGID 파일]"  >> $COMPUTERNAME_XML 2>&1
		cat suid_filelist.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "불필요한 SUID,SGID 파일이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.11</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -d /etc ]
then
	find /etc -perm -2 -ls | awk '{print $3 " : " $5 " : " $6 " : " $11}' | grep -v ^l >> world_writable.txt
fi
if [ -d /tmp ]
then
	find /tmp -perm -2 -ls | awk '{print $3 " : " $5 " : " $6 " : " $11}' | grep -v ^l >> world_writable.txt
fi
if [ -d /home ]
then
	find /home -perm -2 -ls | awk '{print $3 " : " $5 " : " $6 " : " $11}'| grep -v ^l >> world_writable.txt
fi
if [ -d /var ]
then
	find /var -perm -2 -ls | awk '{print $3 " : " $5 " : " $6 " : " $11}' | grep -v ^l >> world_writable.txt
fi
if [ -d /export ]
then
	find /export -perm -2 -ls | awk '{print $3 " : " $5 " : " $6 " : " $11}' | grep -v "^l" >> world_writable.txt
fi

echo "2.11 world writable 파일 점검"  >> $FILETEXT 2>&1
cat world_writable.txt >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 
echo "========================================================================" >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 

if [ -s world_writable.txt ]
then
	linecount=`cat world_writable.txt | wc -l`
	if [ $linecount -gt 10 ]
	then
		echo "World Writable 파일이 "$linecount"개 존재합니다."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[World Writable 파일 (상위 10개)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 world_writable.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[World Writable 파일]"  >> $COMPUTERNAME_XML 2>&1
		cat world_writable.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "World Writable 파일이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>인터뷰</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -d /etc ]
then
	find /etc -type f | xargs -d "\n" ls -al | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
	find /etc -type d | xargs -d "\n" ls -dl | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
fi
if [ -d /var ]
then
	find /var -type f | xargs -d "\n" ls -al | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
	find /var -type d | xargs -d "\n" ls -dl | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
fi
if [ -d /tmp ]
then
	find /tmp -type f | xargs -d "\n" ls -al | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
	find /tmp -type d | xargs -d "\n" ls -dl | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
fi
if [ -d /home ]
then
	find /home -type f | xargs -d "\n" ls -al | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
	find /home -type d | xargs -d "\n" ls -dl | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
fi
if [ -d /export ]
then
	find /export -type f | xargs -d "\n" ls -al | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
	find /export -type d | xargs -d "\n" ls -dl | awk '{$1=$2=$4=$5=$6=$7=$8=""; print $0}'|sed -e 's/^ *//g' -e 's/ *$//g' | egrep -v -i "(^a|^b|^c|^d|^e|^f|^g|^h|^i|^j|^k|^l|^m|^n|^o|^p|^q|^r|^s|^t|^u|^v|^w|^x|^y|^z)" >> filelist.txt
fi

echo "2.02 파일 및 디렉터리 소유자 설정"  >> $RAWDATA 2>&1
cat filelist.txt >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 

if [ -s filelist.txt ]
then
	linecount=`cat filelist.txt | wc -l`
	if [ $linecount -gt 10 ]
	then
		echo "소유자가 존재하지 않는 파일이 "$linecount"개 존재합니다."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[소유자가 존재하지 않는 파일 (상위 10개)]"  >> $COMPUTERNAME_XML 2>&1
		echo "(소유자 => 파일위치: 경로)"  >> $COMPUTERNAME_XML 2>&1
		head -10 filelist.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[소유자가 존재하지 않는 파일]"  >> $COMPUTERNAME_XML 2>&1
		echo "(소유자 => 파일위치: 경로)"  >> $COMPUTERNAME_XML 2>&1
		cat filelist.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "소유자가 존재하지 않는 파일이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.20</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


find /tmp -name ".*" -ls > hidden-file.txt
find /home -name ".*" -ls >> hidden-file.txt
find /usr -name ".*" -ls >> hidden-file.txt
find /var -name ".*" -ls >> hidden-file.txt


echo "2.20 숨겨진 파일 및 디렉토리 검색 및 제거"  >> $FILETEXT 2>&1
cat hidden-file.txt >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 
echo "========================================================================" >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 

linecount=`cat hidden-file.txt | wc -l`
if [ $linecount -gt 10 ]
then
	echo "리스트에서 숨겨진 파일이 "$linecount"개 존재합니다."  >> $COMPUTERNAME_XML 2>&1
	echo " "  >> $COMPUTERNAME_XML 2>&1
	echo "[리스트에서 숨겨진 파일 (상위 10개)]"  >> $COMPUTERNAME_XML 2>&1
	head -10 hidden-file.txt  >> $COMPUTERNAME_XML 2>&1
else
	echo "[리스트에서 숨겨진 파일]"  >> $COMPUTERNAME_XML 2>&1
	cat hidden-file.txt  >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>인터뷰</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>인터뷰</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


find /dev -type f -exec ls -l {} \; > device.txt

echo "2.12 /dev에 존재하지 않는 device 파일 점검"  >> $RAWDATA 2>&1
cat device.txt >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 

if [ -s device.txt ]
then
	linecount=`cat device.txt | wc -l`
	if [ $linecount -gt 10 ]
	then	
		echo "/dev에 존재하지 않는 device 파일이 "$linecount"개 존재합니다."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[/dev에 존재하지 않는 device 파일 (상위 10개)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 device.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[/dev에 존재하지 않는 device 파일]"  >> $COMPUTERNAME_XML 2>&1
		cat device.txt >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "dev 에 존재하지 않은 Device 파일이 발견되지 않았습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.05</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[DoS 공격에 취약한 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services 파일에서 포트 확인" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) 서비스 포트 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > unnecessary.txt
	fi
fi

if [ -f unnecessary.txt ]
then
	echo "불필요한 서비스가 동작하고 있습니다.(echo, discard, daytime, chargen)" >> $COMPUTERNAME_XML 2>&1
else
	echo "불필요한 서비스가 동작하고 있지 않습니다.(echo, discard, daytime, chargen)" >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.25</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[FTP 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) 포트 확인" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service: " $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]
then
	cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service:" $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/service 파일에 포트 설정이 없습니다.(Default 포트: 21)" >> $COMPUTERNAME_XML 2>&1
fi
if [ -s proftpd.txt ]
then
	if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "ProFTP 포트: " $1 " " $2}' | wc -l` -gt 0 ]
	then
		cat $profile | grep "Port" | grep -v "^#" | awk '{print "ProFTP 포트: " $1 " " $2}' >> $COMPUTERNAME_XML 2>&1
	else
		echo "ProFTP 포트 설정이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "ProFTP가 설치되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
fi
if [ -s vsftpd.txt ]
then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP 포트: " $1 " " $2}' | wc -l` -gt 0 ]
	then
		cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP 포트: " $1 " " $2}' >> $COMPUTERNAME_XML 2>&1
	else
		echo "VsFTP 포트 설정이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "VsFTP가 설치되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) 포트 활성화 여부" >> $COMPUTERNAME_XML 2>&1

################# /etc/services 파일에서 포트 확인 #################
if [ `cat /etc/services | awk -F" " '$1=="ftp" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="ftp" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo " " > ftpenable.txt
	fi
else
	netstat -na | grep ":21 " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
	echo " " > ftpenable.txt
fi
################# proftpd 에서 포트 확인 ###########################
if [ -s proftpd.txt ]
then
	port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo " " > ftpenable.txt
	fi
fi
################# vsftpd 에서 포트 확인 ############################
if [ -s vsftpd.txt ]
then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}' | wc -l` -eq 0 ]
	then
		port=21
	else
		port=`cat $vsfile | grep "listen_port" | grep -v "^#" | awk -F"=" '{print $2}'`
	fi
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo " " >> ftpenable.txt
	fi
fi

if [ -f ftpenable.txt ]
then
	echo "FTP 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
else
	echo "FTP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[Anonymous FTP 설정 확인]" >> $COMPUTERNAME_XML 2>&1


	if [ `cat /etc/passwd | egrep "^ftp:|^anonymous:" | wc -l` -gt 0 ]
	then
		echo "기본 FTP, ProFTP 설정:" >> $COMPUTERNAME_XML 2>&1
		cat /etc/passwd | egrep "^ftp:|^anonymous:" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	else
		echo "기본 FTP, ProFTP 설정: /etc/passwd 파일에 ftp 또는 anonymous 계정이 없습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi

	if [ -s vsftpd.txt ]
	then
		cat $vsfile | grep -i "anonymous_enable" | awk '{print "VsFTP 설정: " $0}' >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi

else
	echo "FTP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.26</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;



echo "[ftp 계정 쉘 확인]" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | wc -l` -gt 0 ]
then
	if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | egrep -v "false" | wc -l` -gt 0 ]
	then
		cat /etc/passwd | awk -F: '$1=="ftp"' | egrep -v "false" >> $COMPUTERNAME_XML 2>&1
	else
		cat /etc/passwd | awk -F: '$1=="ftp"' >> $COMPUTERNAME_XML 2>&1
		echo "ftp 계정에 bin/false 쉘이 부여되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
else
	echo "ftp 계정이 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.27</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[ftpusers 파일 소유자 및 권한 확인]" >> $COMPUTERNAME_XML 2>&1

	echo " " > ftpusers.txt
	ServiceDIR="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"
	for FILE in $ServiceDIR
	do
		if [ -f $FILE ]
		then
			ls -alL $FILE >> $COMPUTERNAME_XML 2>&1
			echo " " >> ftpusers.txt
			
			if [ `ls -alL $FILE | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
			then
				echo "해당 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				result=1;
			else
				echo "해당 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			fi
			
			if [ `ls -alL $FILE | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
			then
				echo "해당 파일의 권한은 640 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
			else
				echo "해당 파일의 권한은 640 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
		fi		
		
	done

	if [ `cat ftpusers.txt | wc -l` -eq 1 ]
	then
		echo "ftpusers 파일을 찾을 수 없습니다. (FTP 서비스 동작 시 취약)" >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.28</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[ftpusers 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1

	echo " " > ftpusers.txt
	if [ -s proftpd.txt ]
	then
		if [ `cat $profile | grep -i "RootLogin" | grep -v "^#" | wc -l` -gt 0 ]
		then
			echo "ProFTP 설정파일: `cat $profile | grep -i "RootLogin" | grep -v "^#"`" >> $COMPUTERNAME_XML 2>&1
		else
			echo "ProFTP 설정파일: RootLogin 설정 없음.(Default off)" >> $COMPUTERNAME_XML 2>&1
		fi
	fi
	ServiceDIR="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"
	for file in $ServiceDIR
	do
		if [ -f $file ]
		then
			if [ `cat $file | grep "root" | grep -v "^#" | wc -l` -gt 0 ]
			then
				echo "$file 파일내용: `cat $file | grep "root" | grep -v "^#"` 계정이 등록되어 있음." >> ftpusers.txt
				echo "check" > check.txt
			else
				echo "$file 파일내용: root 계정이 등록되어 있지 않음." >> ftpusers.txt
				echo "check" > check.txt
			fi
		fi
	done

	if [ -f check.txt ]
	then
		cat ftpusers.txt | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "ftpusers 파일을 찾을 수 없습니다. (FTP 서비스 동작 시 취약)" >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.11</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[tftp, talk, ntalk 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services 파일에서 포트 확인" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="tftp" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="talk" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="ntalk" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) 서비스 포트 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="tftp" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="tftp" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > tftp_talk.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="talk" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="talk" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > tftp_talk.txt
	fi
fi
if [ `cat /etc/services | awk -F" " '$1=="ntalk" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="ntalk" {print $1 " " $2}' | grep "udp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "^udp" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
		echo " " > tftp_talk.txt
	fi
fi

if [ -f tftp_talk.txt ]
then
	rm -rf tftp_talk.txt
else
	echo "tftp, talk, ntalk 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.24</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;


echo "[SSH 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) SSH 프로세스 데몬 동작 확인" >> $COMPUTERNAME_XML 2>&1


if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh 서비스가 비활성화 되어 있습니다."   >> $COMPUTERNAME_XML 2>&1
	result=0;
else
	ps -ef | grep sshd | grep -v grep   >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

echo "2) sshd_config 파일에서 포트 확인" >> $COMPUTERNAME_XML 2>&1

echo " " > ssh-result.txt
ServiceDIR="/opt/ssh/etc/sshd_config /etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config"
for file in $ServiceDIR
do
	if [ -f $file ]
	then
		if [ `cat $file | grep ^Port | grep -v ^# | wc -l` -gt 0 ]
		then
			cat $file | grep ^Port | grep -v ^# | awk '{print "SSH 설정파일: " $0 " ('${file}')"}' >> ssh-result.txt
			port1=`cat $file | grep ^Port | grep -v ^# | awk '{print $2}'`
			echo " " > port1-search.txt
		else
			echo "SSH 설정파일($file): 포트 설정 존재하지 않음" >> ssh-result.txt
		fi
	fi
done

if [ `cat ssh-result.txt | grep -v "^ *$" | wc -l` -gt 0 ]
then
	cat ssh-result.txt | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
else
	echo "SSH 설정파일: 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

# 서비스 포트 점검
echo "3) 서비스 포트 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ -f port1-search.txt ]
then
	if [ `netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "ssh 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	else
		netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
	fi
else
	if [ `netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "ssh 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	else
		netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
	fi
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

ChkSendmail=0;
result=0;


echo "[sendmail 버전 점검]" >> $COMPUTERNAME_XML 2>&1
echo "1) /sendmail 프로세스 확인" >> $COMPUTERNAME_XML 2>&1
if [ `ps -ef | grep sendmail | grep -v grep | wc -l` -gt 0 ]
then
	ps -ef | grep sendmail | grep -v grep  >> $COMPUTERNAME_XML 2>&1
	ChkSendmail=1;
	echo " " >> $COMPUTERNAME_XML 2>&1
else
	echo "Sendmail 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo "2) sendmail 버전 확인" >> $COMPUTERNAME_XML 2>&1
echo \$Z | /usr/sbin/sendmail -bt -d0 > sendmail_version.txt

echo " " >> $RAWDATA 2>&1
echo "[sendmail 버전 참조]" >> $RAWDATA 2>&1
cat sendmail_version.txt >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1
cat sendmail_version.txt | grep -i "version" >> $COMPUTERNAME_XML 2>&1

echo "" >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/mail/sendmail.cf ]
then
	grep -v '^ *#' /etc/mail/sendmail.cf | grep DZ >> $COMPUTERNAME_XML 2>&1
elif [ -f /etc/sendmail.cf ]
then
	grep -v '^ *#' /etc/sendmail.cf | grep DZ >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ $ChkSendmail = 1 ]
then
	echo "[스팸 메일 릴레이 제한 설정 확인]" >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying denied" >> $COMPUTERNAME_XML 2>&1
		result=1;
	elif [ -f /etc/sendmail.cf ]
	then
		cat /etc/sendmail.cf | grep "R$\*" | grep "Relaying denied" >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.14</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ $ChkSendmail = 1 ]
then

	echo "[일반사용자의 Sendmail 실행 방지 설정 확인]" >> $COMPUTERNAME_XML 2>&1


	if [ -f /etc/mail/sendmail.cf ]
	then
		grep -v '^ *#' /etc/mail/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		grep -v '^ *#' /etc/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.34</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ $ChkSendmail = 1 ]
then

	echo "[SMTP noexpn, novrfy 옵션 설정 확인]"  >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		grep -v '^ *#' /etc/mail/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		grep -v '^ *#' /etc/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	else
		echo "sendmail.cf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.15</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


DNSPR=`ps -ef | grep named | grep -v "grep" | awk 'BEGIN{ OFS="\n"} {i=1; while(i<=NF) {print $i; i++}}'| grep "/" | uniq`
DNSPR=`echo $DNSPR | awk '{print $1}'`
if [ `ps -ef | grep named | grep -v grep | wc -l` -gt 0 ]
then
	if [ -f $DNSPR ]
	then
	echo "[BIND 버전 확인]" >> $COMPUTERNAME_XML 2>&1
	$DNSPR -v | grep BIND >> $COMPUTERNAME_XML 2>&1
	else
	echo "$DNSPR 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "DNS 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.16</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[DNS Zone Transfer 설정 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) DNS 프로세스 확인 " >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep named | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "DNS 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	ps -ef | grep named | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
if [ `ls -al /etc/rc.d/rc*.d/* | grep -i named | grep "/S" | wc -l` -gt 0 ]
then
	ls -al /etc/rc.d/rc*.d/* | grep -i named | grep "/S" >> $COMPUTERNAME_XML 2>&1
	echo " " >> $COMPUTERNAME_XML 2>&1
fi
if [ -f /etc/rc.tcpip ]
then
	cat /etc/rc.tcpip | grep -i named  >> $COMPUTERNAME_XML 2>&1
	echo " "  >> $COMPUTERNAME_XML 2>&1
fi

echo "2) /etc/named.conf 파일의 allow-transfer 확인" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/named.conf ]
then
	cat /etc/named.conf | grep 'allow-transfer' >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/named.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "3) /etc/named.boot 파일의 xfrnets 확인" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/named.boot ]
then
	cat /etc/named.boot | grep "\xfrnets" >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/named.boot 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[finger 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) 포트 확인" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) 포트 활성화 여부" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "finger 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		netstat -na | grep ":$port " | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo "finger 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	if [ `netstat -na | grep ":79 " | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "finger 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		netstat -na | grep ":79 " | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo "finger 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.30</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]
then
	echo "SNMP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	echo "[SNMP 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
	netstat -na | grep ":161 " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
	echo "SNMP 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1	
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.31</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SNMP Community 설정 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) SNMP 서비스 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]
then
	echo "SNMP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	if [ -f /etc/snmpd.conf ]
	then
		echo "/etc/snmpd.conf 파일 설정:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /etc/snmp/snmpd.conf ]
	then
		echo "/etc/snmp/snmpd.conf 파일 설정:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmp/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /etc/snmp/conf/snmpd.conf ]
	then
		echo "/etc/snmp/conf/snmpd.conf 파일 설정:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmp/conf/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /SI/CM/config/snmp/snmpd.conf ]
	then
		echo "/SI/CM/config/snmp/snmpd.conf 파일 설정:" >> $COMPUTERNAME_XML 2>&1

		cat /SI/CM/config/snmp/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi

	if [ -f snmpd.txt ]
	then
		rm -rf snmpd.txt
	else
		echo "snmpd.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	fi
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[r'command 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services 파일에서 포트 확인" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="login" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="shell" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="exec" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) 서비스 포트 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="login" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="login" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	netstat -na | grep ":$port " | grep -i "^tcp" > services.txt
fi

if [ `cat /etc/services | awk -F" " '$1=="shell" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="shell" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	netstat -na | grep ":$port " | grep -i "^tcp" >> services.txt
fi

if [ `cat /etc/services | awk -F" " '$1=="exec" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="exec" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	netstat -na | grep ":$port " | grep -i "^tcp" >> services.txt
fi

if [ -s services.txt ]
then
	echo "r'command 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
else
	echo "r'command 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -s services.txt ]
then
	cat services.txt | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
	
	echo "[/etc/hosts.equiv 파일 설정]" >> $COMPUTERNAME_XML 2>&1

	
	if [ -f /etc/hosts.equiv ]
		then
			echo "① 파일 소유자 및 권한: " >> $COMPUTERNAME_XML 2>&1

			ls -alL /etc/hosts.equiv >> $COMPUTERNAME_XML 2>&1
			
			if [ `ls -alL /etc/hosts.equiv | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
			then
				echo "OK"
				result=1;
			else
				echo "해당 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			fi
		
			
			if [ `ls -alL /etc/hosts.equiv  | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
			then
				echo "OK"
			else
				echo "/etc/hosts.equiv 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi	

			echo "② 설정 내용:" >> $COMPUTERNAME_XML 2>&1

			if [ `cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' | wc -l` -gt 0 ]
			then
				cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
				
				if [ `cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' | grep "+" | wc -l` -eq 0 ]
				then
					echo "OK"
				else
					echo "/etc/hosts.equiv 파일에 '+' 설정이 존재합니다." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
			else
				echo "설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "/etc/hosts.equiv 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[개별 사용자의 .rhosts 파일 설정]" >> $COMPUTERNAME_XML 2>&1

	HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $1":"$6}' | sort -u`
	FILES="/.rhosts"

	for HOMEDIR in $HOMEDIRS
	do
		user_id=`echo $HOMEDIR | awk -F":" '{print $1}'`
		dir=`echo $HOMEDIR | awk -F":" '{print $2}'`
		
		for file in $FILES
		do
			FILE=$dir/$file
			if [ -f $FILE ]
			then

				echo "① 파일 소유자 및 권한: " >> $COMPUTERNAME_XML 2>&1
				ls -alL $FILE >> $COMPUTERNAME_XML 2>&1					
				
				if [ `ls -alL $FILE | awk '{print $3}' | egrep "root|$user_id" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "해당 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
				
				if [ `ls -alL $FILE | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "해당 파일의 권한은 600 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi	
				
				
				echo "② 설정 내용:" >> $COMPUTERNAME_XML 2>&1

				if [ `cat $FILE | grep -v "#" | grep -v '^ *$' | wc -l` -gt 0 ]
				then
					cat $FILE | grep -v "#" | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
					
					if [ `cat $FILE | grep -v "#" | grep -v '^ *$' | grep "+" | wc -l` -eq 0 ]
					then
						echo "OK"
					else
						echo "$FILE 파일에 '+' 설정이 존재합니다." >> $COMPUTERNAME_XML 2>&1
						result=0;
					fi
				else
					echo "설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
				fi
			echo " " >> $COMPUTERNAME_XML 2>&1
			else
				echo "$user_id의 .rhosts 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
			fi
		done
	done
else
	echo "r'command 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi




echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi

echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[NFS 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) nfsd 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ] 
then
	ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	

else
echo "nfsd가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
result=1;
fi

echo " " >> $COMPUTERNAME_XML 2>&1

echo "2) statd, lockd 활성화 여부 확인" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" | wc -l` -gt 0 ] 
then
	ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" >> $COMPUTERNAME_XML 2>&1
else
echo "statd, lockd가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo "[참고]"  >> $RAWDATA 2>&1
echo "nfs 서비스 현황" >> $RAWDATA 2>&1
service nfs status >> $RAWDATA 2>&1
echo "" >> $RAWDATA 2>&1
echo "rpc 서비스 현황" >> $RAWDATA 2>&1
service rpcbind status >> $RAWDATA 2>&1


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.07</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ] 
then

	if [ -f /etc/exports ]
	then
	echo "[/etc/exports 파일 설정]" >> $COMPUTERNAME_XML 2>&1
		if [ `cat /etc/exports | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
		then
			cat /etc/exports | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
		else
			echo "/etc/exports 파일에 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
		fi
	else
		echo "/etc/exports 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi

else
	echo "nfsd가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.33</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ] 
then


	if [ -f /etc/exports ]
	then
		echo "[/etc/exports 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
		ls -alL /etc/exports >> $COMPUTERNAME_XML 2>&1
		
		if [ `ls -alL /etc/exports | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
		then
			echo "/etc/exports 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			result=1;
		else
			echo "/etc/exports 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		fi
		
		if [ `ls -alL /etc/exports | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
		then
			echo "/etc/exports 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		else
			echo "/etc/exports 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi	
		
	 else
		echo "/etc/exports 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
	
	if [ ! -f /etc/exports ]
	then
		if [ -f /etc/dfs/dfstab ]
		then
			echo "[/etc/dfs/dfstab 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
			ls -alL /etc/dfs/dfstab >> $COMPUTERNAME_XML 2>&1
			
			if [ `ls -alL /etc/dfs/dfstab | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
			then
				echo "/etc/dfs/dfstab 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				result=1;
			else
				echo "/etc/dfs/dfstab 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			fi
			
			if [ `ls -alL /etc/dfs/dfstab | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
			then
				echo "/etc/dfs/dfstab 파일의 권한은 644 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
			else
				echo "/etc/dfs/dfstab 파일의 권한은 644 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi	
		else
			echo "/etc/dfs/dfstab 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
			result=1;
		fi
	fi

else
	echo "nfsd가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[Automountd 서비스 활성화 여부 확인]" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi" | wc -l` -gt 0 ] 
then
	ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi" >> $COMPUTERNAME_XML 2>&1
	
else
	echo "Automountd 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.09</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


SERVICE_INETD="rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd"

echo "[불필요한 RPC 서비스 활성화 여부 확인]" >> $COMPUTERNAME_XML 2>&1
if [ -d /etc/xinetd.d ]
then
	if [ `ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD | wc -l` -eq 0 ]
	then
		echo "불필요한 RPC 서비스가 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/xinetd.d 디렉토리가 존재하지 않습니다."                                           >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.16</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

SERVICE="ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|rpc.nids"

if [ `ps -ef | egrep $SERVICE | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "NIS 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	ps -ef | egrep $SERVICE | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	echo "NIS 서비스가 활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


SERVICE_NIS="ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|rpc.nids"

if [ `ps -ef | egrep $SERVICE_NIS | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "NIS 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	echo "[NIS 서비스 현황 확인]" >> $COMPUTERNAME_XML 2>&1
	ps -ef | egrep $SERVICE_NIS | grep -v "grep"	>> $COMPUTERNAME_XML 2>&1
	echo "NIS 서비스가 활성화 되어 있습니다."  >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>7.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/inetd.conf ]
then
	if [ `cat /etc/inetd.conf | grep -v "^#" | grep "swat" | wc -l` -eq 0 ]
	then
		echo "swat 서비스가 등록되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat 서비스가 등록되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
elif [ -f /etc/xinetd.conf ]
then
	if [ `cat /etc/xinetd.conf | grep -v "^#" | grep "swat" | wc -l` -eq 0 ]
	then
		echo "swat 서비스가 등록되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat 서비스가 등록되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/(x)inetd.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

if [ -d /etc/xinetd.d ]
then
	if [ `ls -al /etc/xinetd.d | grep "swat" | wc -l` -eq 0 ]
	then
		echo "swat 서비스가 등록되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat 서비스가 등록되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.18</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	
	if [ -f $ACONF ]
	then
		cat $ACONF | grep -i "user" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" | grep -i "user" >> $COMPUTERNAME_XML 2>&1
		cat $ACONF | grep -i "group" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" | grep -i "group" >> $COMPUTERNAME_XML 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	echo "[httpd 데몬 동작 계정 확인]" >> $COMPUTERNAME_XML 2>&1
	ps -ef | grep "httpd" | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.23</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.17</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	if [ -f $ACONF ]
	then
		echo "[Indexes 설정 확인]" >> $COMPUTERNAME_XML 2>&1
		
		echo "3.17" >> $RAWDATA 2>&1
		echo "[Indexes 설정 확인]" >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |Indexes|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.21</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;



if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	echo "3.21" >> $RAWDATA 2>&1
	echo "[$ACONF 파일 설정 확인]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |FollowSymLinks|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.19</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	
	echo "3.19" >> $RAWDATA 2>&1
	echo "[$ACONF 파일 설정 확인]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then	
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |AllowOverride|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.22</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	
	echo "3.22" >> $RAWDATA 2>&1
	echo "[$ACONF 파일 설정 확인]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |LimitRequestBody|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.35</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF 파일 설정 확인]" >> $COMPUTERNAME_XML 2>&1
	echo "3.35" >> $RAWDATA 2>&1
	echo "[$ACONF 파일 설정 확인]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		if [ `cat $ACONF | egrep -i "ServerTokens|ServerSignature" | grep -v '\#' | wc -l` -gt 0 ]
		then
			cat $ACONF | egrep -i "<Directory|ServerTokens|ServerSignature|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
			echo " " >> $RAWDATA 2>&1
		else
			echo "ServerTokens, ServerSignature 지시자가 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
			echo " " >> $COMPUTERNAME_XML 2>&1
		fi
	else
		echo "Apache 설정 파일을 찾을 수 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.20</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[DocumentRoot Directory]" >> $COMPUTERNAME_XML 2>&1
	if [ $apache_type = "httpd" ]
	then
		DOCROOT=`cat $ACONF | grep -i ^DocumentRoot | awk '{print $2}' | sed 's/"//g'` 2>&1
		echo $DOCROOT >> $COMPUTERNAME_XML 2>&1
	elif [ $apache_type = "apache2" ]
	then
		cat $AHOME/sites-enabled/*.conf | grep -i "DocumentRoot" | awk '{print $2}' | uniq > apache2_DOCROOT.txt 2>&1
		cat apache2_DOCROOT.txt >> $COMPUTERNAME_XML 2>&1
	fi

	find $AHOME -name "cgi-bin" -exec ls -ld {} \; > unnecessary_file.txt 2>&1
	find $AHOME -name "test-cgi" -exec ls -l {} \; >> unnecessary_file.txt 2>&1
	find $AHOME -name "printenv" -exec ls -l {} \; >> unnecessary_file.txt 2>&1
	
	find $AHOME -name "manual" -exec ls -ld {} \; > manual_directory.txt 2>&1
	
	find $DOCROOT -name "cgi-bin" -exec ls -ld {} \; >> unnecessary_file.txt 2>&1
	find $DOCROOT -name "test-cgi" -exec ls -l {} \; >> unnecessary_file.txt 2>&1
	find $DOCROOT -name "printenv" -exec ls -l {} \; >> unnecessary_file.txt 2>&1

	find $DOCROOT -name "manual" -exec ls -ld {} \; > manual_directory.txt 2>&1
	
	if [ $apache_type = "apache2" ]
	then
		for docroot2 in `cat ./apache2_DOCROOT.txt`
		do
			find $docroot2 -name "cgi-bin" -exec ls -ld {} \; >> unnecessary_file.txt 2>&1
			find $docroot2 -name "test-cgi" -exec ls -l {} \; >> unnecessary_file.txt 2>&1
			find $docroot2 -name "printenv" -exec ls -l {} \; >> unnecessary_file.txt 2>&1
			find $docroot2 -name "manual" -exec ls -ld {} \; >> manual_directory.txt 2>&1
		done
	fi
	
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[test-cgi, printenv 파일]" >> $COMPUTERNAME_XML 2>&1

	if [ `cat ./unnecessary_file.txt | wc -l` -eq 0 ]
	then
		echo "test-cgi, printenv 파일이 존재하지 않습니다."  >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		cat ./unnecessary_file.txt >> $COMPUTERNAME_XML 2>&1
	fi
	echo " "  >> $COMPUTERNAME_XML 2>&1

	echo "[manual 디렉토리]" >> $COMPUTERNAME_XML 2>&1

	if [ `cat ./manual_directory.txt | wc -l` -eq 0 ]
	then
		echo "manual 디렉토리가 존재하지 않습니다." >> $COMPUTERNAME_XML 2>&1
	else
		cat ./manual_directory.txt >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "Apache 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/cron.allow ]
then
	echo "[/etc/cron.allow 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/cron.allow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/cron.allow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.allow 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/cron.allow 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/cron.allow | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.allow 파일의 권한은 640 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.allow 파일의 권한은 640 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
else
	echo "/etc/cron.allow 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/cron.deny ]
then
	echo "[/etc/cron.deny 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/cron.deny >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/cron.deny | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.deny 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.deny 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
	if [ `ls -alL /etc/cron.deny | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.deny 파일의 권한은 640 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.deny 파일의 권한은 640 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
else
	echo "/etc/cron.deny 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.29</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/at.allow ]
then
	echo "[/etc/at.allow 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/at.allow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/at.allow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/at.allow 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/at.allow 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/at.allow | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/at.allow 파일의 권한은 640 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.allow 파일의 권한은 640 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/at.allow 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/at.deny ]
then
	echo "[/etc/at.deny 파일 소유자 및 권한 설정]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/at.deny >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/at.deny | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/at.deny 파일은 root 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.deny 파일은 root 외 다른 사용자 소유로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
	if [ `ls -alL /etc/at.deny | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/at.deny 파일의 권한은 640 이하로 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.deny 파일의 권한은 640 보다 크게 설정되어 있습니다." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi		
else
	echo "/etc/at.deny 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.32</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[배너 설정 확인]" >> $COMPUTERNAME_XML 2>&1
echo "1) 서버 로그온 메시지 설정(/etc/motd)" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/motd ]
then
	if [ `cat /etc/motd | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		cat /etc/motd | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "서버 로그온 메시지가 설정되어 있지 않습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/motd 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) Telnet 배너 설정" >> $COMPUTERNAME_XML 2>&1

telnet_check=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"`;

if [ `echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep :$port | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep :$port | grep -i "^tcp" | grep -i "LISTEN"  >> $COMPUTERNAME_XML 2>&1
		
		echo "/etc/issue.net 파일 설정"  >> $COMPUTERNAME_XML 2>&1
		
		if [ -f /etc/issue.net ]
		then
			if [ `cat /etc/issue.net | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
			then
				cat /etc/issue.net | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
			else
				echo " " >> $COMPUTERNAME_XML 2>&1
				echo "/etc/issue.net 파일에 telnet 배너 설정이 없습니다." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "/etc/issue.net 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
		fi
		
	else
		echo "telnet 서비스가 비활성화 되어 있습니다."   >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "telnet 서비스가 등록되어 있지 않습니다."   >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

echo "3) ftp 배너 설정" >> $COMPUTERNAME_XML 2>&1

if [ -f ftpenable.txt ]
then	
	
	echo "/etc/vsftpd/vsftpd.conf 파일 설정"  >> $COMPUTERNAME_XML 2>&1
	if [ -f /etc/vsftpd/vsftpd.conf ]
	then
		cat /etc/vsftpd/vsftpd.conf | grep -i "ftpd_banner" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/vsftpd/vsftpd.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "4) SMTP 배너 설정" >> $COMPUTERNAME_XML 2>&1


if [ $ChkSendmail = 1 ]
then
	if [ -f /etc/mail/sendmail.cf ]
	then
		cat /etc/mail/sendmail.cf | grep -i "SmtpGreetingMessage" >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		cat /etc/sendmail.cf | grep -i "SmtpGreetingMessage" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "5) DNS 배너 설정" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep named | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "DNS 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
else
	ps -ef | grep named | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	
	if [ -f /etc/named.conf ]
	then
		cat /etc/named.conf >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/named.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "6) SSH 배너 설정" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh 서비스가 비활성화 되어 있습니다."   >> $COMPUTERNAME_XML 2>&1
else	
	if [ -f /etc/ssh/sshd_config ]
	then
		cat /etc/ssh/sshd_config | grep Banner >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/ssh/sshd_config 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1




echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>4.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

uname -a >> $COMPUTERNAME_XML 2>&1
grep . /etc/*-release >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[담당자 인터뷰 및 증적확인]" >> $COMPUTERNAME_XML 2>&1

echo "① 일정 주기로 로그를 점검하고 있는가?" >> $COMPUTERNAME_XML 2>&1
echo "② 로그 점검결과에 따른 결과보고서가 존재하는가?" >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SYSLOG 서비스 현황]" >> $COMPUTERNAME_XML 2>&1
echo "1) SYSLOG 데몬 동작 확인" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep 'syslog' | grep -v 'grep' | wc -l` -eq 0 ]
then
	echo "SYSLOG 서비스가 비활성화 되어 있습니다." >> $COMPUTERNAME_XML 2>&1
else
	ps -ef | grep 'syslog' | grep -v 'grep' >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) SYSLOG 설정 확인" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/syslog.conf ]
then
	if [ `cat /etc/syslog.conf | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		echo "[/etc/syslog.conf 파일 설정]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/syslog.conf | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/syslog.conf 파일에 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
elif [ -f /etc/rsyslog.conf ]
then
	if [ `cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		echo "[/etc/rsyslog.conf 파일 설정]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/rsyslog.conf 파일에 설정 내용이 없습니다." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "(r)syslog.conf 파일이 없습니다." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>취약</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[NTP 서버 설정]" >> $COMPUTERNAME_XML 2>&1

ntpq -p >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>양호</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>수동</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo   "6.01"			>> $RAWDATA 2>&1


echo "# rpm -qa |grep -i bash" >> $RAWDATA 2>&1

rpm -qa |grep -i bash >> $RAWDATA 2>&1

echo " " >> $RAWDATA 2>&1

echo "echo $BASH_VERSION" >> $RAWDATA 2>&1

echo $BASH_VERSION		>> $RAWDATA 2>&1

echo " " >> $RAWDATA 2>&1



echo   "6.02"			>> $RAWDATA 2>&1


rpm -qa |grep openssl		>> $RAWDATA 2>&1

echo " " >> $RAWDATA 2>&1

echo "# openssl version -a" >> $RAWDATA 2>&1

openssl version -a >> $RAWDATA 2>&1

echo "=================================================================="
echo "Finish"
echo "=================================================================="


echo "</Group>"			>> $COMPUTERNAME_XML 2>&1

rm -rf *.txt