#!/bin/sh
# $1 autorelease build

if [ -z "$1" ]; then
    echo $0 "<build>"
    exit 1;
fi

BUILD=$1

# docker root dir
ROOT=`git rev-parse --show-toplevel`/test/csit/docker

cd $ROOT

$ROOT/scripts/gen-dockerfiles.py $BUILD < $ROOT/../../../autorelease/binaries.csv


for file in `find -name Dockerfile`; do
    dir=`dirname $file`
    cat > $dir/Dockerfile <<EOF
#
# This file was auto-generated by gen-all-dockerfiles.sh; do not modify manually.
#
# $dir/Dockerfile
#

EOF
    cat $dir/*.txt >> $dir/Dockerfile

    if [ -f $dir/20-mysql.txt ]; then
	cat > $dir/init-mysql.sh <<EOF
#!/bin/bash -v
#
# This file was auto-generated by gen-all-dockerfiles.sh; do not modify manually.
#
# $dir/init-mysql.sh
#

EOF
	cat $ROOT/templates/init-mysql.sh >> $dir/init-mysql.sh
    else
	rm -f $dir/init-mysql.sh
    fi

    cat > $dir/docker-entrypoint.sh <<EOF
#!/bin/bash
#
# This file was auto-generated by gen-all-dockerfiles.sh; do not modify manually.
#
# $dir/docker-entrypoint.sh
#

EOF

    if [ `basename $dir` != "common-services-msb" ]; then
	cat >> $dir/docker-entrypoint.sh <<EOF
if [ -z "\$MSB_ADDR" ]; then
    echo "Missing required variable MSB_ADDR: Microservices Service Bus address <ip>:<port>"
    exit 1
fi

EOF
    fi
    
    cat >> $dir/docker-entrypoint.sh <<EOF
# Configure service based on docker environment variables
./instance-config.sh

# Perform one-time config
if [ ! -e init.log ]; then
    # Perform workarounds due to defects in release binary
    ./instance-workaround.sh
EOF
    
    if [ -f $dir/20-mysql.txt ]; then
	cat >> $dir/docker-entrypoint.sh <<EOF
    # Init mysql; set root password
    ./init-mysql.sh

EOF
    fi

    cat >> $dir/docker-entrypoint.sh <<EOF
    # microservice-specific one-time initialization
    ./instance-init.sh

    date > init.log
fi

# Start the microservice
./instance-run.sh

EOF

    touch $dir/instance-config.sh
    touch $dir/instance-init.sh
    touch $dir/instance-run.sh
    touch $dir/instance-workaround.sh
    chmod +x $dir/*.sh
done
