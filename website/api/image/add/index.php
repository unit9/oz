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

if(isset($_FILES['file']))
{
	if($_FILES["file"]["error"] > 0)
	{
		echo "Return Code: " . $_FILES["file"]["error"] . "<br>";
	} else
	{
		$newFileName = md5($_FILES["file"]["tmp_name"]) . substr($_FILES["file"]["name"], strrpos($_FILES["file"]["name"], '.'), strlen($_FILES["file"]["name"]));
		move_uploaded_file($_FILES["file"]["tmp_name"], dirname(__FILE__) . "/upload/" . $newFileName);
		echo "{\"result\":{\"id\": 1, \"uri\": \"" . "/api/image/add/upload/" . $newFileName . "\"}}";
	}
} else
{
	echo "{\"result\":{\"id\": 1, \"uri\": \"/api/image/add/get/1\"}}";
}

?>