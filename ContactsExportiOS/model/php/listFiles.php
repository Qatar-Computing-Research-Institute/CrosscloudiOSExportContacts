<?php

$subFolder = $_REQUEST["folderName"];
$dir = "uploads/" . $subFolder . "/";

$files = scandir($dir);
$array = array(); 
foreach($files as $file)
{
    if(is_file($dir.$file))
    {
    	array_push($array , $file );
    }
}

array_push($array , $dir);

echo implode("," , $array);
?>