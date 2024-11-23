#!/bin/sh
# xml_file: default to omcienv.xml extracted from omcimain.tgz while preparing targetfs
# custom_file: each line could be blank, comment(started with #) or key/value pair

xml_file=$1
custom_file=$2

change_omcienv_xml() {
	local xml; xml=$1
	local key; key=$2
	local value; value=$3

	[ -z "$xml" ] && return 1
	[ -z "$key" ] && return 1
	[ -z "$value" ] && return 1
	cp $xml_file /tmp/omcienv.xml.$$
	cat /tmp/omcienv.xml.$$  | sed -e "s|<$key>.*</$key>|<$key>$value</$key>|"  > $xml_file
	rm -f /tmp/omcienv.xml.$$
	return 0;
}

usage () {
        echo "$0 [omcienv.xml] [custom_omeienv]"
        exit 1
}

[ -z "$2" -o ! -f $xml_file -o ! -f $custom_file ] && usage

cat $custom_file | while read line ; do
	set -- $line
	# ignore blank line
	if [ -z "$2" ]; then
		continue
	fi
	# ignore comment line
	if echo $1|grep -q '^#'; then
		continue
	fi
	change_omcienv_xml $xml_file $1 $2
done
