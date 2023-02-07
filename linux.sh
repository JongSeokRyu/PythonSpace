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




# FTP ���� ����Ȯ��
find /etc/ -name "proftpd.conf" | grep "/etc/"  > proftpd.txt
find /etc/ -name "vsftpd.conf" | grep "/etc/"  > vsftpd.txt
profile=`cat proftpd.txt`
vsfile=`cat vsftpd.txt`

# Apache ���� ����Ȯ��
#0. �ʿ��� �Լ� ����
apache_awk() {
	if [ `ps -ef | grep -i $1 | grep -v "ns-httpd" | grep -v "grep" | awk '{print $8}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -gt 0 ]
	then
		apaflag=8
	elif [ `ps -ef | grep -i $1 | grep -v "ns-httpd" | grep -v "grep" | awk '{print $9}' | grep "/" | grep -v "httpd.conf" | uniq | wc -l` -gt 0 ]
	then
		apaflag=9
	fi
}


# 1. Apache ���μ��� ���� ���� Ȯ�� �� ����ġ TYPE �Ǵ�, awk �÷� Ȯ��
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

# 2. Apache Ȩ ���丮 ��� Ȯ��

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

echo "1) telnet ���� Ȯ��"  >> $COMPUTERNAME_XML 2>&1

telnet_check=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"`;

if [ `echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	echo "��Ʈ Ȯ��: $telnet_check" >> $COMPUTERNAME_XML 2>&1
	port=`echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep :$port | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		echo "��Ʈ Ȱ��ȭ ����: "  >> $COMPUTERNAME_XML 2>&1
		netstat -na | grep :$port | grep -i "^tcp"  >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "[/etc/securetty ���� ����]"  >> $COMPUTERNAME_XML 2>&1
		
		if [ -f /etc/securetty ]
		
		then
			if [ `cat /etc/securetty | grep -i "pts" | grep -v "^#" | wc -l` -gt 0 ]
			then
				cat /etc/securetty | grep -i "pts" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
				
				echo "/etc/securetty ���Ͽ� pts/0~pts/x ������ �����մϴ�."   >> $COMPUTERNAME_XML 2>&1
				
			else	
				echo "/etc/securetty ���Ͽ� pts/0~pts/x ������ �������� �ʽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1				
			fi
			
		else
			echo "/etc/securetty ������ �����ϴ�."   >> $COMPUTERNAME_XML 2>&1
		fi
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "[/etc/pam.d/login ���� ����]"  >> $COMPUTERNAME_XML 2>&1

		if [ -f /etc/pam.d/login ]
		
		then
			if [ `cat /etc/pam.d/login | grep -i "pam_securetty.so" | grep -v "^#" | wc -l` -gt 0 ]
			then
				cat /etc/pam.d/login | grep -i "pam_securetty.so" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
				
				echo "/etc/pam.d/login ���Ͽ� pam_securetty.so ������ �����մϴ�."   >> $COMPUTERNAME_XML 2>&1
				
			else	
				echo "/etc/pam.d/login ���Ͽ� pam_securetty.so ������ �������� �ʽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1				
			fi
			
		else
			echo "/etc/pam.d/login ������ �����ϴ�."   >> $COMPUTERNAME_XML 2>&1
		fi
		
	else
		echo "telnet ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
	
else
	echo "telnet ���񽺰� ��ϵǾ� ���� �ʽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "2) ssh ���� Ȯ��"  >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
else
	result=0;
	
	echo "[/etc/ssh/sshd_config ���� ����]" >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/ssh/sshd_config ]
	then
		if [ `cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin'| grep -v "^#" | wc -l` -gt 0 ]
		then
			cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin' | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
			
			if [ `cat /etc/ssh/sshd_config | egrep -i 'PermitRootLogin' | grep -v "^#" | egrep -i 'yes' | wc -l` -eq 0 ]
			then
				echo "sshd_config ���Ͽ� PermitRootLogin�� no�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				
			else
				echo "sshd_config ���Ͽ� PermitRootLogin�� yes�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "sshd_config ���Ͽ� PermitRootLogin ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			
		fi
	else
		echo "sshd_config ������ �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
fi
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/passwd ]
then
	echo "[etc/passwd ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/passwd | head -5 >> $COMPUTERNAME_XML 2>&1

	if [ `awk -F: '$2=="x"' /etc/passwd | wc -l` -eq 0 ]
	then
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "/etc/passwd ���Ͽ� �н����尡 ��ȣȭ �Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo "/etc/passwd ���Ͽ� �н����尡 ��ȣȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
else
	echo "/etc/passwd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ ! -f /etc/shadow ]
then
	echo "/etc/shadow ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/pam.d/system-auth ]
then
	echo "[/etc/pam.d/system-auth ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/system-auth | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/pam.d/system-auth ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/pam.d/common-auth ]
then
	echo "[/etc/pam.d/common-auth ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/common-auth | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/pam.d/common-auth ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/security/pwquality.conf ]
then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[/etc/security/pwquality.conf ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/security/pwquality.conf | grep -v "^#" | egrep -i "password|lcredit|ucredit|dcredit|ocredit|minlen|retry|difok" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/security/pwquality.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/login.defs | grep -v "^#" | egrep -i "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_MIN_LEN|PASS_WARN_AGE" >> $COMPUTERNAME_XML 2>&1
else
  echo "/etc/login.defs ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1

if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi

echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.07</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs ���� ����]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_LEN" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_min_len=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_LEN" | awk -F" " '{print $2}'`;
	
	if [ "$pass_min_len" -ge 8 ]
	then
		echo "�н����� �ּ� ���̰� 8�� �̻��Դϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "�н����� �ּ� ���̰� 8�� �̸��Դϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs ���� ����]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MAX_DAYS" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_max_days=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MAX_DAYS" | awk -F" " '{print $2}'`;
	
	if [ "$pass_max_days" -le 90 ]
	then
		echo "�н����� �ִ� ���Ⱓ�� 90�� ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "�н����� �ִ� ���Ⱓ�� 90�� ���Ϸ� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.09</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/login.defs ]
then
	echo "[/etc/login.defs ���� ����]" >> $COMPUTERNAME_XML 2>&1
	grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_DAYS" | awk -F" " '{print $1" "$2}' >> $COMPUTERNAME_XML 2>&1
	
	pass_min_days=`grep -v '^ *#' /etc/login.defs | grep -i "PASS_MIN_DAYS" | awk -F" " '{print $2}'`;
	
	if [ "$pass_min_days" -ge 1 ]
	then
		echo "�н����� �ּ� ���Ⱓ�� 1�� �̻����� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "�н����� �ּ� ���Ⱓ ������ �Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/login.defs ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/pam.d/system-auth ]
then
	echo "[/etc/pam.d/system-auth ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/system-auth | egrep -i "auth|account" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
else	
	if [ -f /etc/pam.d/common-auth ]
	then
		echo "[/etc/pam.d/common-auth ���� ����]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/pam.d/common-auth | egrep -i "auth|account|include" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
	fi
fi

if [ -f /etc/pam.d/sshd ]
then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[/etc/pam.d/sshd ���� ����]" >> $COMPUTERNAME_XML 2>&1
	cat /etc/pam.d/sshd | egrep -i "auth|account|include" | grep "required" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.14</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[�α����� �ʿ����� ���� �ý��� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/passwd ]
then
	cat /etc/passwd | egrep "^daemon:|^bin:|^sys:|^adm:|^listen:|^nobody:|^nobody4:|^noaccess:|^diag:|^operator:|^games:|^gopher:" > nologin.txt
	
	if [ `egrep -v "nologin|false" nologin.txt | wc -l` -eq 0 ]
	then
		cat nologin.txt | egrep -v "nologin|false"  >> $COMPUTERNAME_XML 2>&1
		cat nologin.txt | egrep "nologin|false"  >> $COMPUTERNAME_XML 2>&1
		echo "�α����� �ʿ����� ���� ������ bin/false(sbin/nologin) ���� �ο��Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		cat nologin.txt  >> $COMPUTERNAME_XML 2>&1
		echo "�α����� �ʿ����� ���� ������ bin/false(sbin/nologin) ���� �ο��Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/passwd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "1.10 ���ʿ��� ���� ����"  >> $RAWDATA 2>&1
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

echo "1) ������� �ʴ� Default ����(lp, uucp, nuucp) Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/passwd | egrep "^lp:|^uucp:|^nuucp:" | wc -l` -eq 0 ]
then
	echo "lp, uucp, nuucp ������ �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	echo "" >> $COMPUTERNAME_XML 2>&1
	result=1;
	echo "2) ���ʿ��� ���� ���� ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1
	for username in `cat userlist0406.txt | awk -F: '{print $1}'`
	do
		cat lastlogin.txt | grep $username >> $COMPUTERNAME_XML 2>&1
	done
else
	cat /etc/passwd | egrep "^lp:|^uucp:|^nuucp:" >> $COMPUTERNAME_XML 2>&1
	echo "" >> $COMPUTERNAME_XML 2>&1
	echo "2) ���ʿ��� ���� ���� ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1
	for username in `cat userlist0406.txt | awk -F: '{print $1}'`
	do
		cat lastlogin.txt | grep $username >> $COMPUTERNAME_XML 2>&1
	done
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "root �ܿ� UID�� 0�� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "root �ܿ� UID�� 0�� ������ �����մϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/passwd ������ �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[������ UID�� ����ϴ� ����]" >> $COMPUTERNAME_XML 2>&1

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
	echo "������ UID�� ����ϴ� ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.11</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "1.11 ������ �׷쿡 �ּ����� ���� ����"  >> $RAWDATA 2>&1

echo "[������ ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/passwd ]
then
	awk -F: '$3==0 { print $1 " -> UID=" $3 }' /etc/passwd >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/passwd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "[������ �׷� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
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
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "1) /etc/pam.d/su ���� ����" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/pam.d/su ]
then
	if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | wc -l` -eq 0 ]
	then
		echo "pam_wheel.so ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust'>> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/pam.d/su ������ ã�� �� �����ϴ�.">> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) su ���� ����" >> $COMPUTERNAME_XML 2>&1

if [ `which su | grep -v 'no ' | wc -l` -eq 0 ]
then
	echo "su ��� ������ ã�� �� �����ϴ�."  >> $COMPUTERNAME_XML 2>&1
else
	sucommand=`which su`;
	ls -alL $sucommand   >> $COMPUTERNAME_XML 2>&1
	sugroup=`ls -alL $sucommand | awk '{print $4}'`;
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "3) su ��ɱ׷�" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/pam.d/su ]
then
	if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | grep 'group' | awk -F"group=" '{print $2}' | awk -F" " '{print $1}' | wc -l` -gt 0 ]
	then
		pamsugroup=`cat /etc/pam.d/su | grep 'pam_wheel.so' | grep -v 'trust' | grep 'group' | awk -F"group=" '{print $2}' | awk -F" " '{print $1}'`
		echo "- su��� �׷�(PAM���): `grep -E "^$pamsugroup" /etc/group`" >> $COMPUTERNAME_XML 2>&1
	else
		if [ `cat /etc/pam.d/su | grep 'pam_wheel.so' | egrep -v 'trust|#' | wc -l` -gt 0 ]
		then
			echo "- su��� �׷�(PAM���): `grep -E "^wheel" /etc/group`" >> $COMPUTERNAME_XML 2>&1
		fi
	fi
fi
echo "- su��� �׷�(�������): `grep -E "^$sugroup" /etc/group`" >> $COMPUTERNAME_XML 2>&1
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[�������� �������� �ʴ� �׷�]" >> $COMPUTERNAME_XML 2>&1

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
	echo "�������� �������� �ʴ� �׷��� �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
else
	cat nullgid.txt >> $COMPUTERNAME_XML 2>&1
	
	echo "1.12 ������ �������� �ʴ� GID ����"  >> $RAWDATA 2>&1
	cat nullgid.txt >> $RAWDATA 2>&1
	echo " " >> $RAWDATA 2>&1 
	echo "========================================================================" >> $RAWDATA 2>&1
	echo " " >> $RAWDATA 2>&1 
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1




echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>1.15</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SHELL Ȯ��]" >> $COMPUTERNAME_XML 2>&1
env | grep -i "shell=" >> $COMPUTERNAME_XML 2>&1
echo " "  >> $COMPUTERNAME_XML 2>&1

echo "[TMOUT ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/profile ����"  >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/profile ]
then
	if [ `cat /etc/profile | grep -i TMOUT | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/profile | grep -i TMOUT | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "TMOUT �� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/profile ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "2) /etc/csh.login ����" >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/csh.login ]
then
	if [ `cat /etc/csh.login | grep -i autologout | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/csh.login | grep -i autologout | grep -v "^#"  >> $COMPUTERNAME_XML 2>&1
	else
		echo "autologout �� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/csh.login ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "3) /etc/csh.cshrc ����"  >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/csh.cshrc ]
then
	if [ `cat /etc/csh.cshrc | grep -i autologout | grep -v "^#" | wc -l` -gt 0 ]
	then
		cat /etc/csh.cshrc | grep -i autologout | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
	else
		echo "autologout �� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/csh.cshrc ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "[/etc/hosts.allow ���� ����]"		>> $COMPUTERNAME_XML 2>&1
		cat /etc/hosts.allow | grep -v "#" | grep -ve '^ *$' >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.allow ���Ͽ� ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi	
else
	echo "/etc/hosts.allow ������ �����ϴ�."    			>> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/hosts.deny ]
then
	if [ ! `cat /etc/hosts.deny | grep -v "#" | grep -ve '^ *$' | wc -l` -eq 0 ]
	then
		echo "[/etc/hosts.deny ���� ����]"		>> $COMPUTERNAME_XML 2>&1
		cat /etc/hosts.deny | grep -v "#" | grep -ve '^ *$' >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.deny ���Ͽ� ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi	
else
	echo "/etc/hosts.deny ������ �����ϴ�."    			>> $COMPUTERNAME_XML 2>&1
fi

echo " "  >> $COMPUTERNAME_XML 2>&1
echo "[iptables ����]"  >> $COMPUTERNAME_XML 2>&1
iptables -L INPUT >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;

echo "[PATH ȯ�溯�� ����]" >> $COMPUTERNAME_XML 2>&1
echo $PATH >> $COMPUTERNAME_XML 2>&1

if [ `echo $PATH | grep "\." | wc -l` -gt 0 ]
	then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "PATH ���� ���� "."�� ���ԵǾ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi

if [ `echo $PATH | grep "::" | wc -l` -gt 0 ]
	then
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "PATH ���� ���� "::"�� ���ԵǾ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=0;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.17</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[���� �α��� ���� UMASK]" >> $COMPUTERNAME_XML 2>&1

umask >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/profile ]
then
 echo "[/etc/profile ���� ����]" >> $COMPUTERNAME_XML 2>&1

 if [ `cat /etc/profile | grep -i umask | grep -v ^# | wc -l` -gt 0 ]
	then
		cat /etc/profile | grep -i umask | grep -v ^# | sed -e 's/^ *//g' -e 's/ *$//g' >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "umask ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
 echo "/etc/profile ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.19</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[Ȩ ���丮�� �������� ���� ����]" >> $COMPUTERNAME_XML 2>&1

HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $6}' | sort -u | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq`
for dir in $HOMEDIRS
do
	if [ ! -d $dir ]
	then
		awk -F: '$6=="'${dir}'" { print "������ -> Ȩ���丮: "$1 " -> " $6 }' /etc/passwd >> $COMPUTERNAME_XML 2>&1
		echo " " > home_dir.txt
	fi
done

if [ ! -f home_dir.txt ]
then
	echo "Ȩ ���丮�� �������� ���� ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.18</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;

HOMEDIRS=`cat /etc/passwd | awk -F":" 'length($6) > 0 {print $1":"$6}' | grep -v "#" | grep -v "/tmp" | grep -v "uucppublic" | uniq | sort -u`

echo "[Ȩ ���丮 ����]" >> $COMPUTERNAME_XML 2>&1
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
			echo "�ش� ���丮�� �ش� ����(�Ǵ� root) �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
		
		if [ `ls -dal $dir | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
		then
			echo "OK"
		else
			echo "�ش� ���丮�� Ÿ ����� ��������� �����մϴ�." >> $COMPUTERNAME_XML 2>&1
			echo " " >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
	fi
done


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;


echo "[Ȩ���͸� ȯ�溯�� ����]" >> $COMPUTERNAME_XML 2>&1

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
			echo "�ش� ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi
		
		if [ `ls -alL $FILE | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
		then
			echo "OK"
		else
			echo "�ش� ������ Ÿ ����� ��������� �����մϴ�." >> $COMPUTERNAME_XML 2>&1
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
				echo "�ش� ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
			
			if [ `ls -alL $FILE | awk '{print $1}' | grep "........w." | wc -l` -eq 0 ]
			then
				echo "OK"
			else
				echo "�ش� ������ Ÿ ����� ��������� �����մϴ�." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
		fi
	done
done



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/passwd ]
then
	echo "[/etc/passwd ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/passwd >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/passwd | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/passwd ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/passwd ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/passwd | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/passwd ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/passwd ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/passwd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/shadow ]
then
	echo "[/etc/shadow ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/shadow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/shadow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/shadow ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/shadow ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/shadow | awk '{print $1}' | grep "..--------" | wc -l` -eq 1 ]
	then
		echo "/etc/shadow ������ ������ 400 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/shadow ������ ������ 400 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/shadow ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.05</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/hosts ]
then
	echo "[/etc/hosts ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/hosts >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/hosts | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/hosts ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/hosts | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts ������ ������ 600 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/hosts ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ -f /etc/inetd.conf ]
then
	echo "[/etc/inetd.conf ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/inetd.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/inetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/inetd.conf ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/inetd.conf ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/inetd.conf | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/inetd.conf ������ ������ 600 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/inetd.conf ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/inetd.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ -f /etc/xinetd.conf ]
then
	echo "[/etc/xinetd.conf ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/xinetd.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/xinetd.conf | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/xinetd.conf ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/xinetd.conf ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/xinetd.conf | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/xinetd.conf ������ ������ 600 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/xinetd.conf ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/xinetd.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
if [ -d /etc/xinetd.d ]
then
		echo "[/etc/xinetd.d ���� ��� ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
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
					echo "$file ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
				
				if [ `ls -alL $file | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "$file ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
					echo " " >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
			else
				echo "$file ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
        done

else
        echo "/etc/xinetd.d ���͸��� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.07</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/syslog.conf ]
then
	echo "[/etc/syslog.conf ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/syslog.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/syslog.conf | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/syslog.conf ������ root(�Ǵ� bin, sys) ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/syslog.conf ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/syslog.conf | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/syslog.conf ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/syslog.conf ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
else
	echo "/etc/syslog.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi


if [ -f /etc/rsyslog.conf ]
then
	echo "[/etc/rsyslog.conf ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/rsyslog.conf >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/rsyslog.conf | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/rsyslog.conf ������ root(�Ǵ� bin, sys) ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/rsyslog.conf ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/rsyslog.conf | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/rsyslog.conf ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/rsyslog.conf ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
else
	echo "/etc/rsyslog.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>Ȯ��</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/services ]
then
	echo "[/etc/services ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/services >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/services | awk '{print $3}' | egrep "root|bin|sys" | wc -l` -eq 1 ]
	then
		echo "/etc/services ������ root(�Ǵ� bin, sys) ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/services ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/services | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
	then
		echo "/etc/services ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/services ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "/etc/services ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.15</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/hosts.lpd ]
then
	echo "[/etc/hosts.lpd ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/hosts.lpd >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/hosts.lpd | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts.lpd ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/hosts.lpd ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/hosts.lpd | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
	then
		echo "/etc/hosts.lpd ������ ������ 600 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/hosts.lpd ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/hosts.lpd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "���ʿ��� SUID,SGID ���� "$linecount"�� ����"  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[���ʿ��� SUID,SGID ���� (���� 10��)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 suid_filelist.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[���ʿ��� SUID,SGID ����]"  >> $COMPUTERNAME_XML 2>&1
		cat suid_filelist.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "���ʿ��� SUID,SGID ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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

echo "2.11 world writable ���� ����"  >> $FILETEXT 2>&1
cat world_writable.txt >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 
echo "========================================================================" >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 

if [ -s world_writable.txt ]
then
	linecount=`cat world_writable.txt | wc -l`
	if [ $linecount -gt 10 ]
	then
		echo "World Writable ������ "$linecount"�� �����մϴ�."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[World Writable ���� (���� 10��)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 world_writable.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[World Writable ����]"  >> $COMPUTERNAME_XML 2>&1
		cat world_writable.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "World Writable ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���ͺ�</decision>"		>> $COMPUTERNAME_XML 2>&1
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

echo "2.02 ���� �� ���͸� ������ ����"  >> $RAWDATA 2>&1
cat filelist.txt >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 

if [ -s filelist.txt ]
then
	linecount=`cat filelist.txt | wc -l`
	if [ $linecount -gt 10 ]
	then
		echo "�����ڰ� �������� �ʴ� ������ "$linecount"�� �����մϴ�."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[�����ڰ� �������� �ʴ� ���� (���� 10��)]"  >> $COMPUTERNAME_XML 2>&1
		echo "(������ => ������ġ: ���)"  >> $COMPUTERNAME_XML 2>&1
		head -10 filelist.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[�����ڰ� �������� �ʴ� ����]"  >> $COMPUTERNAME_XML 2>&1
		echo "(������ => ������ġ: ���)"  >> $COMPUTERNAME_XML 2>&1
		cat filelist.txt  >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "�����ڰ� �������� �ʴ� ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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


echo "2.20 ������ ���� �� ���丮 �˻� �� ����"  >> $FILETEXT 2>&1
cat hidden-file.txt >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 
echo "========================================================================" >> $FILETEXT 2>&1
echo " " >> $FILETEXT 2>&1 

linecount=`cat hidden-file.txt | wc -l`
if [ $linecount -gt 10 ]
then
	echo "����Ʈ���� ������ ������ "$linecount"�� �����մϴ�."  >> $COMPUTERNAME_XML 2>&1
	echo " "  >> $COMPUTERNAME_XML 2>&1
	echo "[����Ʈ���� ������ ���� (���� 10��)]"  >> $COMPUTERNAME_XML 2>&1
	head -10 hidden-file.txt  >> $COMPUTERNAME_XML 2>&1
else
	echo "[����Ʈ���� ������ ����]"  >> $COMPUTERNAME_XML 2>&1
	cat hidden-file.txt  >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>���ͺ�</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���ͺ�</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


find /dev -type f -exec ls -l {} \; > device.txt

echo "2.12 /dev�� �������� �ʴ� device ���� ����"  >> $RAWDATA 2>&1
cat device.txt >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 
echo "========================================================================" >> $RAWDATA 2>&1
echo " " >> $RAWDATA 2>&1 

if [ -s device.txt ]
then
	linecount=`cat device.txt | wc -l`
	if [ $linecount -gt 10 ]
	then	
		echo "/dev�� �������� �ʴ� device ������ "$linecount"�� �����մϴ�."  >> $COMPUTERNAME_XML 2>&1
		echo " "  >> $COMPUTERNAME_XML 2>&1
		echo "[/dev�� �������� �ʴ� device ���� (���� 10��)]"  >> $COMPUTERNAME_XML 2>&1
		head -10 device.txt  >> $COMPUTERNAME_XML 2>&1
	else
		echo "[/dev�� �������� �ʴ� device ����]"  >> $COMPUTERNAME_XML 2>&1
		cat device.txt >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "dev �� �������� ���� Device ������ �߰ߵ��� �ʾҽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.05</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[DoS ���ݿ� ����� ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services ���Ͽ��� ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="echo" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="discard" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="daytime" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="chargen" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) ���� ��Ʈ Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

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
	echo "���ʿ��� ���񽺰� �����ϰ� �ֽ��ϴ�.(echo, discard, daytime, chargen)" >> $COMPUTERNAME_XML 2>&1
else
	echo "���ʿ��� ���񽺰� �����ϰ� ���� �ʽ��ϴ�.(echo, discard, daytime, chargen)" >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.25</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[FTP ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service: " $1 " " $2}' | grep "tcp" | wc -l` -gt 0 ]
then
	cat /etc/services | awk -F" " '$1=="ftp" {print "/etc/service:" $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/service ���Ͽ� ��Ʈ ������ �����ϴ�.(Default ��Ʈ: 21)" >> $COMPUTERNAME_XML 2>&1
fi
if [ -s proftpd.txt ]
then
	if [ `cat $profile | grep "Port" | grep -v "^#" | awk '{print "ProFTP ��Ʈ: " $1 " " $2}' | wc -l` -gt 0 ]
	then
		cat $profile | grep "Port" | grep -v "^#" | awk '{print "ProFTP ��Ʈ: " $1 " " $2}' >> $COMPUTERNAME_XML 2>&1
	else
		echo "ProFTP ��Ʈ ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "ProFTP�� ��ġ�Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
if [ -s vsftpd.txt ]
then
	if [ `cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP ��Ʈ: " $1 " " $2}' | wc -l` -gt 0 ]
	then
		cat $vsfile | grep "listen_port" | grep -v "^#" | awk '{print "VsFTP ��Ʈ: " $1 " " $2}' >> $COMPUTERNAME_XML 2>&1
	else
		echo "VsFTP ��Ʈ ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "VsFTP�� ��ġ�Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) ��Ʈ Ȱ��ȭ ����" >> $COMPUTERNAME_XML 2>&1

################# /etc/services ���Ͽ��� ��Ʈ Ȯ�� #################
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
################# proftpd ���� ��Ʈ Ȯ�� ###########################
if [ -s proftpd.txt ]
then
	port=`cat $profile | grep "Port" | grep -v "^#" | awk '{print $2}'`
	if [ `netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -gt 0 ]
	then
		netstat -na | grep ":$port " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo " " > ftpenable.txt
	fi
fi
################# vsftpd ���� ��Ʈ Ȯ�� ############################
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
	echo "FTP ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
else
	echo "FTP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[Anonymous FTP ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1


	if [ `cat /etc/passwd | egrep "^ftp:|^anonymous:" | wc -l` -gt 0 ]
	then
		echo "�⺻ FTP, ProFTP ����:" >> $COMPUTERNAME_XML 2>&1
		cat /etc/passwd | egrep "^ftp:|^anonymous:" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	else
		echo "�⺻ FTP, ProFTP ����: /etc/passwd ���Ͽ� ftp �Ǵ� anonymous ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi

	if [ -s vsftpd.txt ]
	then
		cat $vsfile | grep -i "anonymous_enable" | awk '{print "VsFTP ����: " $0}' >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi

else
	echo "FTP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.26</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;



echo "[ftp ���� �� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | wc -l` -gt 0 ]
then
	if [ `cat /etc/passwd | awk -F: '$1=="ftp"' | egrep -v "false" | wc -l` -gt 0 ]
	then
		cat /etc/passwd | awk -F: '$1=="ftp"' | egrep -v "false" >> $COMPUTERNAME_XML 2>&1
	else
		cat /etc/passwd | awk -F: '$1=="ftp"' >> $COMPUTERNAME_XML 2>&1
		echo "ftp ������ bin/false ���� �ο��Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
else
	echo "ftp ������ �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.27</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[ftpusers ���� ������ �� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

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
				echo "�ش� ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				result=1;
			else
				echo "�ش� ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
			
			if [ `ls -alL $FILE | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
			then
				echo "�ش� ������ ������ 640 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
			else
				echo "�ش� ������ ������ 640 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				echo " " >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi
		fi		
		
	done

	if [ `cat ftpusers.txt | wc -l` -eq 1 ]
	then
		echo "ftpusers ������ ã�� �� �����ϴ�. (FTP ���� ���� �� ���)" >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.28</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f ftpenable.txt ]
then
	echo "[ftpusers ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

	echo " " > ftpusers.txt
	if [ -s proftpd.txt ]
	then
		if [ `cat $profile | grep -i "RootLogin" | grep -v "^#" | wc -l` -gt 0 ]
		then
			echo "ProFTP ��������: `cat $profile | grep -i "RootLogin" | grep -v "^#"`" >> $COMPUTERNAME_XML 2>&1
		else
			echo "ProFTP ��������: RootLogin ���� ����.(Default off)" >> $COMPUTERNAME_XML 2>&1
		fi
	fi
	ServiceDIR="/etc/ftpusers /etc/ftpd/ftpusers /etc/vsftpd/ftpusers /etc/vsftpd.ftpusers /etc/vsftpd/user_list /etc/vsftpd.user_list"
	for file in $ServiceDIR
	do
		if [ -f $file ]
		then
			if [ `cat $file | grep "root" | grep -v "^#" | wc -l` -gt 0 ]
			then
				echo "$file ���ϳ���: `cat $file | grep "root" | grep -v "^#"` ������ ��ϵǾ� ����." >> ftpusers.txt
				echo "check" > check.txt
			else
				echo "$file ���ϳ���: root ������ ��ϵǾ� ���� ����." >> ftpusers.txt
				echo "check" > check.txt
			fi
		fi
	done

	if [ -f check.txt ]
	then
		cat ftpusers.txt | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "ftpusers ������ ã�� �� �����ϴ�. (FTP ���� ���� �� ���)" >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.11</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[tftp, talk, ntalk ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services ���Ͽ��� ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="tftp" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="talk" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="ntalk" {print $1 " " $2}' | grep "udp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) ���� ��Ʈ Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

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
	echo "tftp, talk, ntalk ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.24</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=1;


echo "[SSH ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) SSH ���μ��� ���� ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1


if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
	result=0;
else
	ps -ef | grep sshd | grep -v grep   >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

echo "2) sshd_config ���Ͽ��� ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

echo " " > ssh-result.txt
ServiceDIR="/opt/ssh/etc/sshd_config /etc/sshd_config /etc/ssh/sshd_config /usr/local/etc/sshd_config /usr/local/sshd/etc/sshd_config /usr/local/ssh/etc/sshd_config"
for file in $ServiceDIR
do
	if [ -f $file ]
	then
		if [ `cat $file | grep ^Port | grep -v ^# | wc -l` -gt 0 ]
		then
			cat $file | grep ^Port | grep -v ^# | awk '{print "SSH ��������: " $0 " ('${file}')"}' >> ssh-result.txt
			port1=`cat $file | grep ^Port | grep -v ^# | awk '{print $2}'`
			echo " " > port1-search.txt
		else
			echo "SSH ��������($file): ��Ʈ ���� �������� ����" >> ssh-result.txt
		fi
	fi
done

if [ `cat ssh-result.txt | grep -v "^ *$" | wc -l` -gt 0 ]
then
	cat ssh-result.txt | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
else
	echo "SSH ��������: ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

# ���� ��Ʈ ����
echo "3) ���� ��Ʈ Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ -f port1-search.txt ]
then
	if [ `netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "ssh ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	else
		netstat -na | grep ":$port1 " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
	fi
else
	if [ `netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "ssh ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	else
		netstat -na | grep ":22 " | grep -i "^tcp" | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
	fi
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.12</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

ChkSendmail=0;
result=0;


echo "[sendmail ���� ����]" >> $COMPUTERNAME_XML 2>&1
echo "1) /sendmail ���μ��� Ȯ��" >> $COMPUTERNAME_XML 2>&1
if [ `ps -ef | grep sendmail | grep -v grep | wc -l` -gt 0 ]
then
	ps -ef | grep sendmail | grep -v grep  >> $COMPUTERNAME_XML 2>&1
	ChkSendmail=1;
	echo " " >> $COMPUTERNAME_XML 2>&1
else
	echo "Sendmail ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo "2) sendmail ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1
echo \$Z | /usr/sbin/sendmail -bt -d0 > sendmail_version.txt

echo " " >> $RAWDATA 2>&1
echo "[sendmail ���� ����]" >> $RAWDATA 2>&1
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
	echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ $ChkSendmail = 1 ]
then
	echo "[���� ���� ������ ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying denied" >> $COMPUTERNAME_XML 2>&1
		result=1;
	elif [ -f /etc/sendmail.cf ]
	then
		cat /etc/sendmail.cf | grep "R$\*" | grep "Relaying denied" >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.14</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

if [ $ChkSendmail = 1 ]
then

	echo "[�Ϲݻ������ Sendmail ���� ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1


	if [ -f /etc/mail/sendmail.cf ]
	then
		grep -v '^ *#' /etc/mail/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		grep -v '^ *#' /etc/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi
	
echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.34</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ $ChkSendmail = 1 ]
then

	echo "[SMTP noexpn, novrfy �ɼ� ���� Ȯ��]"  >> $COMPUTERNAME_XML 2>&1

	if [ -f /etc/mail/sendmail.cf ]
	then
		grep -v '^ *#' /etc/mail/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		grep -v '^ *#' /etc/sendmail.cf | grep PrivacyOptions >> $COMPUTERNAME_XML 2>&1
	else
		echo "sendmail.cf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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
	echo "[BIND ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	$DNSPR -v | grep BIND >> $COMPUTERNAME_XML 2>&1
	else
	echo "$DNSPR ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "DNS ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.16</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[DNS Zone Transfer ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) DNS ���μ��� Ȯ�� " >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep named | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "DNS ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
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

echo "2) /etc/named.conf ������ allow-transfer Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/named.conf ]
then
	cat /etc/named.conf | grep 'allow-transfer' >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/named.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "3) /etc/named.boot ������ xfrnets Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/named.boot ]
then
	cat /etc/named.boot | grep "\xfrnets" >> $COMPUTERNAME_XML 2>&1
else
	echo "/etc/named.boot ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[finger ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) ��Ʈ Ȱ��ȭ ����" >> $COMPUTERNAME_XML 2>&1

if [ `cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`cat /etc/services | awk -F" " '$1=="finger" {print $1 " " $2}' | grep "tcp" | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep ":$port " | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "finger ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		netstat -na | grep ":$port " | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo "finger ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	if [ `netstat -na | grep ":79 " | grep -i "LISTEN" | wc -l` -eq 0 ]
	then
		echo "finger ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		netstat -na | grep ":79 " | grep -i "LISTEN" >> $COMPUTERNAME_XML 2>&1
		echo "finger ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.30</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]
then
	echo "SNMP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	echo "[SNMP ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	netstat -na | grep ":161 " | grep -i "^udp" >> $COMPUTERNAME_XML 2>&1
	echo "SNMP ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1	
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.31</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SNMP Community ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) SNMP ���� Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `netstat -na | grep ":161 " | grep -i "^udp" | wc -l` -eq 0 ]
then
	echo "SNMP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	if [ -f /etc/snmpd.conf ]
	then
		echo "/etc/snmpd.conf ���� ����:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /etc/snmp/snmpd.conf ]
	then
		echo "/etc/snmp/snmpd.conf ���� ����:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmp/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /etc/snmp/conf/snmpd.conf ]
	then
		echo "/etc/snmp/conf/snmpd.conf ���� ����:" >> $COMPUTERNAME_XML 2>&1

		cat /etc/snmp/conf/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi
	if [ -f /SI/CM/config/snmp/snmpd.conf ]
	then
		echo "/SI/CM/config/snmp/snmpd.conf ���� ����:" >> $COMPUTERNAME_XML 2>&1

		cat /SI/CM/config/snmp/snmpd.conf | egrep -i "public|private|com2sec|community" | grep -v "^#" >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
		echo " " > snmpd.txt
	fi

	if [ -f snmpd.txt ]
	then
		rm -rf snmpd.txt
	else
		echo "snmpd.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	fi
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[r'command ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) /etc/services ���Ͽ��� ��Ʈ Ȯ��" >> $COMPUTERNAME_XML 2>&1

cat /etc/services | awk -F" " '$1=="login" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="shell" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
cat /etc/services | awk -F" " '$1=="exec" {print $1 " " $2}' | grep "tcp" >> $COMPUTERNAME_XML 2>&1
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) ���� ��Ʈ Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

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
	echo "r'command ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
else
	echo "r'command ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.13</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -s services.txt ]
then
	cat services.txt | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
	
	echo "[/etc/hosts.equiv ���� ����]" >> $COMPUTERNAME_XML 2>&1

	
	if [ -f /etc/hosts.equiv ]
		then
			echo "�� ���� ������ �� ����: " >> $COMPUTERNAME_XML 2>&1

			ls -alL /etc/hosts.equiv >> $COMPUTERNAME_XML 2>&1
			
			if [ `ls -alL /etc/hosts.equiv | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
			then
				echo "OK"
				result=1;
			else
				echo "�ش� ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
		
			
			if [ `ls -alL /etc/hosts.equiv  | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
			then
				echo "OK"
			else
				echo "/etc/hosts.equiv ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi	

			echo "�� ���� ����:" >> $COMPUTERNAME_XML 2>&1

			if [ `cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' | wc -l` -gt 0 ]
			then
				cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
				
				if [ `cat /etc/hosts.equiv | grep -v "#" | grep -v '^ *$' | grep "+" | wc -l` -eq 0 ]
				then
					echo "OK"
				else
					echo "/etc/hosts.equiv ���Ͽ� '+' ������ �����մϴ�." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
			else
				echo "���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "/etc/hosts.equiv ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	echo " " >> $COMPUTERNAME_XML 2>&1
	echo "[���� ������� .rhosts ���� ����]" >> $COMPUTERNAME_XML 2>&1

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

				echo "�� ���� ������ �� ����: " >> $COMPUTERNAME_XML 2>&1
				ls -alL $FILE >> $COMPUTERNAME_XML 2>&1					
				
				if [ `ls -alL $FILE | awk '{print $3}' | egrep "root|$user_id" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "�ش� ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi
				
				if [ `ls -alL $FILE | awk '{print $1}' | grep "...-------" | wc -l` -eq 1 ]
				then
					echo "OK"
				else
					echo "�ش� ������ ������ 600 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
					result=0;
				fi	
				
				
				echo "�� ���� ����:" >> $COMPUTERNAME_XML 2>&1

				if [ `cat $FILE | grep -v "#" | grep -v '^ *$' | wc -l` -gt 0 ]
				then
					cat $FILE | grep -v "#" | grep -v '^ *$' >> $COMPUTERNAME_XML 2>&1
					
					if [ `cat $FILE | grep -v "#" | grep -v '^ *$' | grep "+" | wc -l` -eq 0 ]
					then
						echo "OK"
					else
						echo "$FILE ���Ͽ� '+' ������ �����մϴ�." >> $COMPUTERNAME_XML 2>&1
						result=0;
					fi
				else
					echo "���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
				fi
			echo " " >> $COMPUTERNAME_XML 2>&1
			else
				echo "$user_id�� .rhosts ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
		done
	done
else
	echo "r'command ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi




echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi

echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.06</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[NFS ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) nfsd Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" | wc -l` -gt 0 ] 
then
	ps -ef | grep "nfsd" | egrep -v "statdaemon|automountd|emi" | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	

else
echo "nfsd�� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
result=1;
fi

echo " " >> $COMPUTERNAME_XML 2>&1

echo "2) statd, lockd Ȱ��ȭ ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" | wc -l` -gt 0 ] 
then
	ps -ef | egrep "statd|lockd" | egrep -v "grep|emi|statdaemon|dsvclockd|kblockd" >> $COMPUTERNAME_XML 2>&1
else
echo "statd, lockd�� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo "[����]"  >> $RAWDATA 2>&1
echo "nfs ���� ��Ȳ" >> $RAWDATA 2>&1
service nfs status >> $RAWDATA 2>&1
echo "" >> $RAWDATA 2>&1
echo "rpc ���� ��Ȳ" >> $RAWDATA 2>&1
service rpcbind status >> $RAWDATA 2>&1


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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
	echo "[/etc/exports ���� ����]" >> $COMPUTERNAME_XML 2>&1
		if [ `cat /etc/exports | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
		then
			cat /etc/exports | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
		else
			echo "/etc/exports ���Ͽ� ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		fi
	else
		echo "/etc/exports ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi

else
	echo "nfsd�� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi


echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "[/etc/exports ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
		ls -alL /etc/exports >> $COMPUTERNAME_XML 2>&1
		
		if [ `ls -alL /etc/exports | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
		then
			echo "/etc/exports ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			result=1;
		else
			echo "/etc/exports ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		fi
		
		if [ `ls -alL /etc/exports | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
		then
			echo "/etc/exports ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		else
			echo "/etc/exports ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			result=0;
		fi	
		
	 else
		echo "/etc/exports ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	fi
	
	if [ ! -f /etc/exports ]
	then
		if [ -f /etc/dfs/dfstab ]
		then
			echo "[/etc/dfs/dfstab ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
			ls -alL /etc/dfs/dfstab >> $COMPUTERNAME_XML 2>&1
			
			if [ `ls -alL /etc/dfs/dfstab | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
			then
				echo "/etc/dfs/dfstab ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				result=1;
			else
				echo "/etc/dfs/dfstab ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
			
			if [ `ls -alL /etc/dfs/dfstab | awk '{print $1}' | grep "...-.--.--" | wc -l` -eq 1 ]
			then
				echo "/etc/dfs/dfstab ������ ������ 644 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			else
				echo "/etc/dfs/dfstab ������ ������ 644 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
				result=0;
			fi	
		else
			echo "/etc/dfs/dfstab ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			result=1;
		fi
	fi

else
	echo "nfsd�� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.08</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


echo "[Automountd ���� Ȱ��ȭ ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi" | wc -l` -gt 0 ] 
then
	ps -ef | egrep 'automount|autofs' | grep -v "grep" | egrep -v "statdaemon|emi" >> $COMPUTERNAME_XML 2>&1
	
else
	echo "Automountd ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.09</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


SERVICE_INETD="rpc.cmsd|rpc.ttdbserverd|sadmind|rusersd|walld|sprayd|rstatd|rpc.nisd|rpc.pcnfsd|rpc.statd|rpc.ypupdated|rpc.rquotad|kcms_server|cachefsd|rexd"

echo "[���ʿ��� RPC ���� Ȱ��ȭ ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
if [ -d /etc/xinetd.d ]
then
	if [ `ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD | wc -l` -eq 0 ]
	then
		echo "���ʿ��� RPC ���񽺰� �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		ls -alL /etc/xinetd.d/* | egrep $SERVICE_INETD >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/xinetd.d ���丮�� �������� �ʽ��ϴ�."                                           >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>2.16</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

SERVICE="ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|rpc.nids"

if [ `ps -ef | egrep $SERVICE | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "NIS ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	ps -ef | egrep $SERVICE | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	echo "NIS ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.10</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


SERVICE_NIS="ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated|rpc.nids"

if [ `ps -ef | egrep $SERVICE_NIS | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "NIS ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
else
	echo "[NIS ���� ��Ȳ Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	ps -ef | egrep $SERVICE_NIS | grep -v "grep"	>> $COMPUTERNAME_XML 2>&1
	echo "NIS ���񽺰� Ȱ��ȭ �Ǿ� �ֽ��ϴ�."  >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "swat ���񽺰� ��ϵǾ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat ���񽺰� ��ϵǾ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
elif [ -f /etc/xinetd.conf ]
then
	if [ `cat /etc/xinetd.conf | grep -v "^#" | grep "swat" | wc -l` -eq 0 ]
	then
		echo "swat ���񽺰� ��ϵǾ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat ���񽺰� ��ϵǾ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/(x)inetd.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

if [ -d /etc/xinetd.d ]
then
	if [ `ls -al /etc/xinetd.d | grep "swat" | wc -l` -eq 0 ]
	then
		echo "swat ���񽺰� ��ϵǾ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "swat ���񽺰� ��ϵǾ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.18</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	
	if [ -f $ACONF ]
	then
		cat $ACONF | grep -i "user" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" | grep -i "user" >> $COMPUTERNAME_XML 2>&1
		cat $ACONF | grep -i "group" | grep -v "\#" | egrep -v "^LoadModule|LogFormat|IfModule|UserDir" | grep -i "group" >> $COMPUTERNAME_XML 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	echo "[httpd ���� ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	ps -ef | grep "httpd" | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.23</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $COMPUTERNAME_XML 2>&1
		echo " " >> $COMPUTERNAME_XML 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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
		echo "[Indexes ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
		
		echo "3.17" >> $RAWDATA 2>&1
		echo "[Indexes ���� Ȯ��]" >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |Indexes|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.21</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;



if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	echo "3.21" >> $RAWDATA 2>&1
	echo "[$ACONF ���� ���� Ȯ��]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |FollowSymLinks|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.19</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	
	echo "3.19" >> $RAWDATA 2>&1
	echo "[$ACONF ���� ���� Ȯ��]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then	
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |AllowOverride|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.22</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	
	echo "3.22" >> $RAWDATA 2>&1
	echo "[$ACONF ���� ���� Ȯ��]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		cat $ACONF | egrep -i "DocumentRoot " | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
		cat $ACONF | egrep -i "<Directory |LimitRequestBody|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
		echo " " >> $RAWDATA 2>&1
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.35</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ ! $apaflag -eq 0 ]
then
	echo "[$ACONF ���� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
	echo "3.35" >> $RAWDATA 2>&1
	echo "[$ACONF ���� ���� Ȯ��]" >> $RAWDATA 2>&1
	if [ -f $ACONF ]
	then
		if [ `cat $ACONF | egrep -i "ServerTokens|ServerSignature" | grep -v '\#' | wc -l` -gt 0 ]
		then
			cat $ACONF | egrep -i "<Directory|ServerTokens|ServerSignature|</Directory" | grep -v '\#' >> $RAWDATA 2>&1
			echo " " >> $RAWDATA 2>&1
		else
			echo "ServerTokens, ServerSignature �����ڰ� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
			echo " " >> $COMPUTERNAME_XML 2>&1
		fi
	else
		echo "Apache ���� ������ ã�� �� �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
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
	echo "[test-cgi, printenv ����]" >> $COMPUTERNAME_XML 2>&1

	if [ `cat ./unnecessary_file.txt | wc -l` -eq 0 ]
	then
		echo "test-cgi, printenv ������ �������� �ʽ��ϴ�."  >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		cat ./unnecessary_file.txt >> $COMPUTERNAME_XML 2>&1
	fi
	echo " "  >> $COMPUTERNAME_XML 2>&1

	echo "[manual ���丮]" >> $COMPUTERNAME_XML 2>&1

	if [ `cat ./manual_directory.txt | wc -l` -eq 0 ]
	then
		echo "manual ���丮�� �������� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		cat ./manual_directory.txt >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
else
	echo "Apache ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	result=1;
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.04</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/cron.allow ]
then
	echo "[/etc/cron.allow ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/cron.allow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/cron.allow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.allow ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/cron.allow ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/cron.allow | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.allow ������ ������ 640 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.allow ������ ������ 640 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
else
	echo "/etc/cron.allow ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/cron.deny ]
then
	echo "[/etc/cron.deny ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/cron.deny >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/cron.deny | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.deny ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.deny ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
	if [ `ls -alL /etc/cron.deny | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/cron.deny ������ ������ 640 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/cron.deny ������ ������ 640 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
else
	echo "/etc/cron.deny ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi



echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.29</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;


if [ -f /etc/at.allow ]
then
	echo "[/etc/at.allow ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/at.allow >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/at.allow | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/at.allow ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=1;
	else
		echo "/etc/at.allow ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
	
	if [ `ls -alL /etc/at.allow | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/at.allow ������ ������ 640 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.allow ������ ������ 640 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi	
	
else
	echo "/etc/at.allow ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
if [ -f /etc/at.deny ]
then
	echo "[/etc/at.deny ���� ������ �� ���� ����]"   >> $COMPUTERNAME_XML 2>&1
	ls -alL /etc/at.deny >> $COMPUTERNAME_XML 2>&1
	
	if [ `ls -alL /etc/at.deny | awk '{print $3}' | grep "root" | wc -l` -eq 1 ]
	then
		echo "/etc/at.deny ������ root ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.deny ������ root �� �ٸ� ����� ������ �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi
	
	if [ `ls -alL /etc/at.deny | awk '{print $1}' | grep "...-.-----" | wc -l` -eq 1 ]
	then
		echo "/etc/at.deny ������ ������ 640 ���Ϸ� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/at.deny ������ ������ 640 ���� ũ�� �����Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
		result=0;
	fi		
else
	echo "/etc/at.deny ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1



echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>3.32</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[��� ���� Ȯ��]" >> $COMPUTERNAME_XML 2>&1
echo "1) ���� �α׿� �޽��� ����(/etc/motd)" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/motd ]
then
	if [ `cat /etc/motd | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		cat /etc/motd | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "���� �α׿� �޽����� �����Ǿ� ���� �ʽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "/etc/motd ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) Telnet ��� ����" >> $COMPUTERNAME_XML 2>&1

telnet_check=`cat /etc/services | awk -F" " '$1=="telnet" {print $1 "   " $2}' | grep "tcp"`;

if [ `echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}' | wc -l` -gt 0 ]
then
	port=`echo $telnet_check | awk -F" " '{print $2}' | awk -F"/" '{print $1}'`;
	if [ `netstat -na | grep :$port | grep -i "^tcp" | wc -l` -gt 0 ]
	then
		netstat -na | grep :$port | grep -i "^tcp" | grep -i "LISTEN"  >> $COMPUTERNAME_XML 2>&1
		
		echo "/etc/issue.net ���� ����"  >> $COMPUTERNAME_XML 2>&1
		
		if [ -f /etc/issue.net ]
		then
			if [ `cat /etc/issue.net | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
			then
				cat /etc/issue.net | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
			else
				echo " " >> $COMPUTERNAME_XML 2>&1
				echo "/etc/issue.net ���Ͽ� telnet ��� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
			fi
		else
			echo "/etc/issue.net ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
		fi
		
	else
		echo "telnet ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "telnet ���񽺰� ��ϵǾ� ���� �ʽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1

echo "3) ftp ��� ����" >> $COMPUTERNAME_XML 2>&1

if [ -f ftpenable.txt ]
then	
	
	echo "/etc/vsftpd/vsftpd.conf ���� ����"  >> $COMPUTERNAME_XML 2>&1
	if [ -f /etc/vsftpd/vsftpd.conf ]
	then
		cat /etc/vsftpd/vsftpd.conf | grep -i "ftpd_banner" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/vsftpd/vsftpd.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "FTP ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "4) SMTP ��� ����" >> $COMPUTERNAME_XML 2>&1


if [ $ChkSendmail = 1 ]
then
	if [ -f /etc/mail/sendmail.cf ]
	then
		cat /etc/mail/sendmail.cf | grep -i "SmtpGreetingMessage" >> $COMPUTERNAME_XML 2>&1
	elif [ -f /etc/sendmail.cf ]
	then
		cat /etc/sendmail.cf | grep -i "SmtpGreetingMessage" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/mail/sendmail.cf(/etc/sendmail.cf) ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "Sendmail ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "5) DNS ��� ����" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep named | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "DNS ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
else
	ps -ef | grep named | grep -v "grep" >> $COMPUTERNAME_XML 2>&1
	
	if [ -f /etc/named.conf ]
	then
		cat /etc/named.conf >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/named.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo " " >> $COMPUTERNAME_XML 2>&1
echo "6) SSH ��� ����" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep sshd | grep -v "grep" | wc -l` -eq 0 ]
then
	echo "ssh ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�."   >> $COMPUTERNAME_XML 2>&1
else	
	if [ -f /etc/ssh/sshd_config ]
	then
		cat /etc/ssh/sshd_config | grep Banner >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/ssh/sshd_config ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1


echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.01</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[����� ���ͺ� �� ����Ȯ��]" >> $COMPUTERNAME_XML 2>&1

echo "�� ���� �ֱ�� �α׸� �����ϰ� �ִ°�?" >> $COMPUTERNAME_XML 2>&1
echo "�� �α� ���˰���� ���� ��������� �����ϴ°�?" >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.02</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[SYSLOG ���� ��Ȳ]" >> $COMPUTERNAME_XML 2>&1
echo "1) SYSLOG ���� ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ `ps -ef | grep 'syslog' | grep -v 'grep' | wc -l` -eq 0 ]
then
	echo "SYSLOG ���񽺰� ��Ȱ��ȭ �Ǿ� �ֽ��ϴ�." >> $COMPUTERNAME_XML 2>&1
else
	ps -ef | grep 'syslog' | grep -v 'grep' >> $COMPUTERNAME_XML 2>&1
fi
echo " " >> $COMPUTERNAME_XML 2>&1
echo "2) SYSLOG ���� Ȯ��" >> $COMPUTERNAME_XML 2>&1

if [ -f /etc/syslog.conf ]
then
	if [ `cat /etc/syslog.conf | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		echo "[/etc/syslog.conf ���� ����]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/syslog.conf | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/syslog.conf ���Ͽ� ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
elif [ -f /etc/rsyslog.conf ]
then
	if [ `cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$" | wc -l` -gt 0 ]
	then
		echo "[/etc/rsyslog.conf ���� ����]" >> $COMPUTERNAME_XML 2>&1
		cat /etc/rsyslog.conf | grep -v "^#" | grep -v "^ *$" >> $COMPUTERNAME_XML 2>&1
	else
		echo "/etc/rsyslog.conf ���Ͽ� ���� ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
	fi
else
	echo "(r)syslog.conf ������ �����ϴ�." >> $COMPUTERNAME_XML 2>&1
fi

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>���</decision>"		>> $COMPUTERNAME_XML 2>&1
fi
echo "</Items>"			>> $COMPUTERNAME_XML 2>&1

echo "<Items>"			>> $COMPUTERNAME_XML 2>&1

echo   "<Item>5.03</Item>"			>> $COMPUTERNAME_XML 2>&1
echo   "<Detail>"			>> $COMPUTERNAME_XML 2>&1

result=0;

echo "[NTP ���� ����]" >> $COMPUTERNAME_XML 2>&1

ntpq -p >> $COMPUTERNAME_XML 2>&1

echo   "</Detail>"			>> $COMPUTERNAME_XML 2>&1
if [ $result = 1 ]
then
        echo "<decision>��ȣ</decision>"		>> $COMPUTERNAME_XML 2>&1
else
        echo "<decision>����</decision>"		>> $COMPUTERNAME_XML 2>&1
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