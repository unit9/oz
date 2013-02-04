<?php

/**
 * @author Maciej Zasada maciej@unit9.com
 * 
 * This script is not intended for production.
 * It only mimics GAE behaviour and responses in order to facilitate testing on SVN
 *
 */

header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Last-Modified: " . gmdate("D, d M Y H:i:s") . " GMT");
header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

if(isset($_POST["data"]))
{
    echo "{\"result\":{\"id\": 1}}";
}
else
{
    $name = '../../js/data/loopstart.json';
    $fp = fopen($name, 'rb');

    header("Content-Type: application/json");
    header("Content-Length: " . filesize($name));

    fpassthru($fp);
    exit;
}

?>