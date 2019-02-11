set fp [open "LOGS/$argv.log" r]
set f2 [open "CSV/output.csv" a+]

set res 1
set fullfile [split [read $fp] "\n"]
 

foreach p $fullfile {
	if {[regexp {FAILED} $p a]} {set res 0; break
	} else { continue
	}
}

if {$res == 0} {puts $f2 "$argv	FAILED"
} else { puts $f2 "$argv	PASSED"
}

close $fp
close $f2
