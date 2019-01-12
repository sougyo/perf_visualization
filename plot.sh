#!/bin/bash

for path in metrics/* ; do
  echo $path
  f=`basename $path`
  outdir=out/plot/$f
  mkdir -p $outdir

  ./plot.r metrics/$f out/${f}.csv $outdir
done
