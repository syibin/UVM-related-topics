#!/usr/bin/perl
use Cwd;


chdir run_dirs;

@tests = <*>;

foreach $test (@tests) {
 if (-d "$test") {
  $passFail{$test} = "Failed";
  open (TEST, "$test/run.log") or print "=> No testfile for test $test\n";
  @logFile = <TEST>;
  $error = 1;
  $fatal = 1;
  $assert = 0;
  foreach $line (@logFile){
   chomp ($line);
   
   if ($line=~/UVM_ERROR :\s+(\d+)/){
    if ($1==0){
     $error=0;
    }
   }
   if ($line=~/UVM_FATAL :\s+(\d+)/){
    if ($1==0){
     $fatal=0;
    }
   }
   if ($line=~/Assertion error/){
    $assert = 1;
   }
  }
  if ($error==0 && $fatal==0 && $assert==0) {
   $passFail{$test} = "Passed";
  }
  close(TEST);
 }
}

foreach $test ( keys %passFail){
 printf "%50s $passFail{$test}\n", $test;
}
