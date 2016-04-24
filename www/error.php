<?php
  ob_start(); // not needed if output_buffering is on in php.ini
  ob_implicit_flush(); // implicitly calls flush() after every ob_flush()

  echo "This output is buffered.\n";
  echo "As is this.\n";
  echo str_pad('',4096)."\n";    

  for ($i = 0; $i < 10; $i++)
  {
    echo "$i\n";
    ob_flush();
    sleep(1);
  }
?>