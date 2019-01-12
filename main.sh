#!/bin/bash

ARCHIVE_DIR=work/rhel74
OUTDIR_CSV=work/out
OUTDIR_PLOT=work/plot
METRICS_DIR=work/metrics
ARCHIVE=$ARCHIVE_DIR/`grep ^Archive: $ARCHIVE_DIR/Latest | awk '{print $3}'`
DURATION=60s
STARTTIME=-3hour

function make_csv() {
  cat $2 | awk '{print $1}' | \
    xargs pmrep -a $1 -f "%H:%M:%S" -o csv -t $DURATION -S $STARTTIME | \
    sed '1s/^Time/time/'
}

echo processing csv...
mkdir -p $OUTDIR_CSV
for path in $METRICS_DIR/* ; do
  echo " $path"
  f=`basename $path`
  make_csv $ARCHIVE $path > $OUTDIR_CSV/${f}.csv
done

echo ""
echo processing plots...
for path in $METRICS_DIR/* ; do
  echo " $path"
  f=`basename $path`
  outdir=$OUTDIR_PLOT/$f
  mkdir -p $outdir
  ./plot.r $METRICS_DIR/$f $OUTDIR_CSV/${f}.csv $outdir 2>> $OUTDIR_PLOT/plot.log
done
