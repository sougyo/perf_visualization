#!/bin/bash

rm -rf out && mkdir out

ARCHIVE_DIR=rhel74
ARCHIVE=$ARCHIVE_DIR/`grep ^Archive: $ARCHIVE_DIR/Latest | awk '{print $3}'`

for path in metrics/* ; do
  echo $path
  f=`basename $path`
  ./make_csv.sh $ARCHIVE $path > out/${f}.csv
done
