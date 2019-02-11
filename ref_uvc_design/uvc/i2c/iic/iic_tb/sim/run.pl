#!/usr/bin/perl
use Cwd;

$testName = $ARGV[0];
$wave     = $ARGV[1];
$seed     = $ARGV[2];

$simDir = cwd();

#system("cd run_dirs");

chdir "run_dirs";

$testDirName = "${testName}_${seed}";

if (! -d $testDirName){ 
 system("mkdir $testDirName");
}

chdir $testDirName;

system("ln -s ../../work work");
#if ($wave eq "1"){
# system("cp ../../runWave.do run.do")
#} else {
# system("cp ../../runNoWave.do run.do")
#}

open (RUNDO, "> run.do") || die ("Error : could not open run.do for writing");
print RUNDO "run 0\n";
print RUNDO "log -r /top/*\n";
print RUNDO "coverage attribute -name TESTNAME -value ${testName}_${seed} \n";
print RUNDO "coverage save -onexit test.ucdb\n";
print RUNDO "force -deposit /top/scl 1'b1\n";
print RUNDO "force -deposit /top/sda 1'b1\n";
print RUNDO "run -a\n";
print RUNDO "\n";
close (RUNDO);

system("cp ../../viewWave.do viewWave.do");
system("cp ../../viewWave viewWave");


$runCmd = "vsim +UVM_TIMEOUT=2000000000,NO -cvg63 -coverage -c -l run.log +UVM_TESTNAME=$testName +UVM_VERBOSITY=UVM_NONE -sv_seed $seed -do run.do top_opt";

system("$runCmd");

system("mv test.ucdb ../../coverage/${testName}_${seed}.ucdb");

chdir $simDir;



