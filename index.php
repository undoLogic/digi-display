<?php
# this will download the initialization script
$file_url = 'https://raw.githubusercontent.com/undoLogic/digi-display/init_digiDisplay.sh';
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past
header('Content-Type: application/octet-stream');
header("Content-Transfer-Encoding: Binary");
header("Content-disposition: attachment; filename=\"init_digiDisplay.sh\"");
readfile($file_url);
die();