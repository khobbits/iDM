<?php

class irccolors {
  function parse($log) {
  	$org = $log;
  	$log = htmlspecialchars($log);
  	$log = str_replace("  "," &nbsp;",$log);

  	$color["color:0;"] = "color:white;";
  	$color["color:1;"] = "color:black;";
  	$color["color:2;"] = "color:navy;";
  	$color["color:3;"] = "color:green;";
  	$color["color:4;"] = "color:red;";
  	$color["color:5;"] = "color:maroon;";
  	$color["color:6;"] = "color:purple;";
  	$color["color:7;"] = "color:orange;";
  	$color["color:8;"] = "color:yellow;";
  	$color["color:9;"] = "color:lime;";
  	$color["color:00;"] = "color:white;";
  	$color["color:01;"] = "color:black;";
  	$color["color:02;"] = "color:navy;";
  	$color["color:03;"] = "color:green;";
  	$color["color:04;"] = "color:red;";
  	$color["color:05;"] = "color:maroon;";
  	$color["color:06;"] = "color:purple;";
  	$color["color:07;"] = "color:orange;";
  	$color["color:08;"] = "color:yellow;";
  	$color["color:09;"] = "color:lime;";
  	$color["color:10;"]= "color:teal;";
  	$color["color:11;"]= "color:aqua;";
  	$color["color:12;"]= "color:blue;";
  	$color["color:13;"]= "color:fuchsia;";
  	$color["color:14;"]= "color:gray;";
  	$color["color:15;"]= "color:silver;";
  	
  	$ctrl->k = chr(03);
  	$log = preg_replace("/$ctrl->k([[:digit:]]{1,2}),([[:digit:]]{1,2})/",
  		"</span><span style=\"color:\\1;background-color:\\2;\">",
  		$log);
  	$log = preg_replace("/$ctrl->k([[:digit:]]{1,2})/",
  		"</span><span style=\"color:\\1;\">",
  		$log);
  	$log = str_replace($ctrl->k,
  		"</span>",
  		$log);
  	$log = strtr($log,$color);

    $ctrl_o = chr(15);

  	//for font bold
  	$ctrl_b = chr(02);
  	$log = preg_replace("/$ctrl_b([^\r{$ctrl_b}{$ctrl_o}]*)[$ctrl_b]/","<b>\\1</b>",$log);
    $log = preg_replace("/$ctrl_b([^\r$ctrl_b]*)[{$ctrl_o}]/","<b>\\1</b>$ctrl_o",$log);
  	$log = preg_replace("/$ctrl_b([^\r$ctrl_b]*)\r/","<b>\\1</b>\r",$log);
  	//for font underlined
  	$ctrl_u = chr(31);
  	$log = preg_replace("/$ctrl_u([^\r{$ctrl_u}{$ctrl_o}]*)[$ctrl_u]/","<u>\\1</u>",$log);
    $log = preg_replace("/$ctrl_u([^\r$ctrl_u]*)[$ctrl_o]/","<u>\\1</u>$ctrl_o",$log);
  	$log = preg_replace("/$ctrl_u([^\r$ctrl_u]*)\r/","<u>\\1</u>\r",$log);

    // Resets all formatting
    $temp = explode($ctrl_o, $log);
    for($i = 0; $i < sizeof($temp); $i++){
      $numMatches = preg_match_all("/<span/", $temp[$i], $spanMatches);
      for($j = 0; $j < $numMatches; $j++){
        $temp[$i] .= "</span>";
      }
    }
    $log = implode("", $temp);

  	return strtr($log,array("\r\n"=>" </span><br>\r\n"));
  }
}