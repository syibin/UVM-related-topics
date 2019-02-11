#!/usr/bin/perl
use Cwd;

$trace = 1;
$seed  = 1;

@tests = qw(
 iicMasterTxTxLongArbTest
 iicMasterRxRxArbTest
 iicMasterRxRxSameAddressArbTest
 iicMasterRxTest
 iicMasterRxTxArbTest
 iicMasterTxRxArbTest
 iicMasterTxTest
 iicMasterTxTxArbTest
 iicPcTest
	  );

for ($i=0; $i<10; $i++) {
 $seed = $i;
 foreach $test (@tests) {
  system("./run.pl $test $trace $seed");
 }
}
chdir ("coverage");
system("vcover merge merged.ucdb *.ucdb");
