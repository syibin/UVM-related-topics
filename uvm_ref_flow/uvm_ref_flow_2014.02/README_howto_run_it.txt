Notes from CVC (www.cvcblr.com) on how to run the Ref kit on different tools
----------------------------------------------------------------------------

1. cd run_dir
2. make vcs --> Runs in VCS (2012.09)
   make cdn --> Runs in IUS (12.2)
   make qsta --> Questa (10.2)
   make rvra --> Riviera-Pro (2014.02)

In the 2014.02 version fixed an enum typecast issue as flagged (rightly so) by
Riviera-Pro inside apb_monitor.sv file

Also some more code clean up is in pipeline, so stay tuned, check with info@cvcblr.com if interested


