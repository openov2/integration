#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# autorelease root dir
ROOT=`git rev-parse --show-toplevel`/autorelease
GERRIT_BRANCH='master'

BUILD_DIR=$ROOT/build

mkdir -p $BUILD_DIR
cd $BUILD_DIR

TMPDIR=`mktemp -d`
git checkout pom.xml

while read p; do
    cd $BUILD_DIR
    if [ -e $BUILD_DIR/$p ]; then
	cd $BUILD_DIR/$p
	git checkout $GERRIT_BRANCH
	git reset --hard
	git pull
    else
	#TODO: replace with https once repo is open to public
	git clone -b $GERRIT_BRANCH ssh://gerrit.open-o.org:29418/$p
    fi
done < $ROOT/java-projects.txt

cd $BUILD_DIR
$ROOT/scripts/fix-relativepaths.sh
$ROOT/scripts/set-version.sh
mvn clean deploy -q -DaltDeploymentRepository=staging::default::file:$TMPDIR -DskipTests=true -Dcheckstyle.skip=true
echo "TMPDIR=$TMPDIR"
