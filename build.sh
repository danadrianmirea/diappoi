#!/bin/sh
# -*- coding: utf-8 -*-
# contributor: Koutaro Chikuba <miz404@gmail.com>
# about: coffeescript join, compile, test
# [require]
#   node.js vows
#
# [Sample]
# $ ./build.sh 
# 
# src/
#    core.coffee
#    char.coffee
#    scenes.coffee
#    exec.coffee    # publish for html
#    test.coffee    # if test 
# build/
#    + ge.coffee
#    + ge.js
# test/
#    + test.coffee
#    + test.js
#
# $ ./build.sh test 
# exec vows test

SRC_DIR=src
DIST_DIR=build
TEST_DIR=test
TARGET="core char scenes"
TARGET_EXEC="exec"
TARGET_TEST="test"
BUILDOUT=ge.coffee
BUILDOUT=ge.js
TEST_BUILDOUT=test.coffee
TEST_BUILDOUT_JS=test.js

echo ========== build ==========
echo "##" ${BUILDOUT} "##" > base.coffee
for name in $TARGET; do
    echo ${SRC_DIR}/${name}.coffee to ${DIST_DIR}/${name}.js
    coffee -c ${SRC_DIR}/${name}.coffee
    mv ${SRC_DIR}/${name}.js ${DIST_DIR}/
    echo "# generated by "${SRC_DIR}/${name}.coffee >> base.coffee
    cat ${SRC_DIR}/${name}.coffee >> base.coffee
done
cat base.coffee $SRC_DIR/$TARGET_EXEC.coffee > $DIST_DIR/$BUILDOUT
cat base.coffee $SRC_DIR/$TARGET_TEST.coffee > $TEST_DIR/$TEST_BUILDOUT
rm base.coffee
coffee -c $DIST_DIR/${BUILDOUT}

if [ "$1" = "test" ]; then
    echo ========== test ===========
    coffee -c $TEST_DIR/${TEST_BUILDOUT}
    node $TEST_DIR/${TEST_BUILDOUT_JS}
fi

