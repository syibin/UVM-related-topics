#!/usr/bin/perl

$trace =1;

@tests = qw(
 iicMasterTxRxArbTest
);


for ($i=1; $i<10; $i++) {
 $seed = $i;
 foreach $test (@tests) {
  system("./run.pl $test $trace $seed");
 }
}
