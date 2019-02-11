task driver::print_test_result( input string result );

  $display("\n");
  $display("********************************************************");
  if (result == "PASSED")	$display("\033[1;32m*                     TEST %s                      *\033[0m", result);
  else $display("\033[1;31m*                     TEST %s                      *\033[0m", result);
  $display("********************************************************");

  //$finish(2);

endtask : print_test_result