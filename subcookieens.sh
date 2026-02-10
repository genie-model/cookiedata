#!/bin/bash
#
# *** SUBMIT ENSEMBLE ***
#
# NOTE: order of ensemble member extensions is: 
#       o n m

# specify base-config filename
BASECONFIG='cookie.CB.p_worjh2.BASES'
# specify path to any user-configs ('/' otherwise)
USERCONFIGPATH='_PROJ/FRES'
# specify experiment (user-config) filename, excluding the .xy ensemble member extension
ENSEMBLEID='260204.ENS.RFPO4.8x8'
# specify run duration (integer years)
YEARS='10000'
# specify any restart name (empty string otherwise)
RESTARTID=''
# set first parameter axis 	== max value of 3rd digit (1-15)
mmax=8
# set second parameter axis == max value of 2nd digit (1-15)
nmax=8
# set third parameter axis 	== max value of 1st digit (1-15)
omax=1
# specific any particular queue to be used (empty string otherwise)
QUEUE='-q puppy.q'

# initialize loop counter m
o=1
while [ $o -le $omax ]; do
  # initialize loop counter n
  n=1
  while [ $n -le $nmax ]; do
    # initialize loop counter o
    m=1
    while [ $m -le $mmax ]; do
	
  	  # convert indices to hex
	  printf -v memberm "%x" $m
      printf -v membern "%x" $n
	  printf -v membero "%x" $o

      # set index and userconfig name
      RESTART=$RESTARTID
      EXPERIMENT=$ENSEMBLEID"."$membero$membern$memberm
  
      # submit
      echo $EXPERIMENT" / "$RESTART
      qsub $QUEUE -j y -o cgenie_log -V -S /bin/bash runcookie.sh $BASECONFIG $USERCONFIGPATH $EXPERIMENT $YEARS $RESTARTID
      sleep 10
      #qstat -f

      # end loops
      let m=$m+1
    done
    let n=$n+1
  done
  let o=$o+1
done

#
qstat -f
    