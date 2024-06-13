
FW_MAJOR_VER="0x0506"
FW_MINOR_VER="0x0071"
log_file=/tmp/aq_fw_download.log

i=0

sleep 25

major_minor_version=`ssdk_sh debug phy get 8 0x401e0020 | grep Data | cut -d ':'  -f2`
firmware_build_provision_id=`ssdk_sh debug phy get 8 0x401ec885 | grep Data | cut -d ':'  -f2`
# additional_info_1=`ssdk_sh debug phy get 8 0x4001c41d | grep Data | cut -d ':'  -f2`
# additional_info_2=`ssdk_sh debug phy get 8 0x4001c41e | grep Data | cut -d ':'  -f2`
if [ "$major_minor_version" == "$FW_MAJOR_VER" -a "$firmware_build_provision_id" == "$FW_MINOR_VER" ]; then
	echo `date`: "The PHY has been running with the right firmware." > $log_file
	exit 0
fi

while true
do
	if [ $((i%10)) == 0 ]; then
		echo `date`: "Start aq-fw-download for" $((i+1)) "time(s)." > $log_file
	else
		echo `date`: "Start aq-fw-download for" $((i+1)) "time(s)." >> $log_file
	fi
	i=$((i+1))	

	aq-fw-download /lib/firmware/AQR-G4_v5.6.7-AQR_Marvell_NoSwap_USX_ID44858_VER1922.cld lan1 8 ram > /dev/null &
	for j in $(seq 1 120)
	do
		sleep 1
		process_id=`pgrep aq-fw-download`
		if [ "$process_id" == "" ]; then
			# aq-fw-download ends

			break
		fi
	done
	process_id=`pgrep aq-fw-download`
	if [ "$process_id" == "" ]; then
		# aq-fw-download ends

		# check if the phy running the firmware
		major_minor_version=`ssdk_sh debug phy get 8 0x401e0020 | grep Data | cut -d ':'  -f2`
		firmware_build_provision_id=`ssdk_sh debug phy get 8 0x401ec885 | grep Data | cut -d ':'  -f2`
		# additional_info_1=`ssdk_sh debug phy get 8 0x4001c41d | grep Data | cut -d ':'  -f2`
		# additional_info_2=`ssdk_sh debug phy get 8 0x4001c41e | grep Data | cut -d ':'  -f2`
		if [ "$major_minor_version" == "$FW_MAJOR_VER" -a "$firmware_build_provision_id" == "$FW_MINOR_VER" ]; then
			break
		fi
	else
		kill $process_id
	fi
done

ssdk_sh debug phy set 8 0x4004c441 0x8
echo `date`: "aq-fw-download complete" >> $log_file

