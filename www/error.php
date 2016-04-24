<?php
  ob_start(); // not needed if output_buffering is on in php.ini
  ob_implicit_flush(); // implicitly calls flush() after every ob_flush()

  echo "This output is buffered.<br/>\n";
  echo "As is this.<br/>\n";

  // $buffer = ini_get('output_buffering');
  $buffer = "no"
  if ! is_numeric($buffer) $buffer = 8192

  echo "output_buffering = $buffer<br/>\n";
  echo str_pad('',$buffer)."\n";

  for ($i = 0; $i < 10; $i++)
  {
    echo "$i<br/>\n";
    echo str_pad('',$buffer)."\n"; ob_flush();
    sleep(1);
  }
?>