<?php

// Code to remove expired items in ilist
function delete_ban_user () {

    // Define the sql to update the tables
    $sql = "SELECT * FROM ilist WHERE `expires` <= now() && `expires` > 0";
    $result = mysql_query($sql) or die ('Mysql Error: ' . mysql_error());

    if($result && mysql_num_rows($result) != 0) {
       	while(($row = mysql_fetch_object($result)) != NULL) {
          if (!mysql_query("UPDATE user SET banned = '0' WHERE user = '$row->user'")) {
            echo 'Unable to remove banned status from ' . $row->user . ': ' . mysql_error();
          }
        }
    }

    // Define the sql to update the tables
    $sql = "DELETE FROM ilist WHERE `expires` <= now() && `expires` > 0";
    if (!mysql_query($sql)) die('Unable to remove records: ' . mysql_error());

    echo mysql_affected_rows() . ' records have been successfully removed from ilist';
    return;
}

// Code to remove expired items in blist
function delete_ban_chan () {

    // Define the sql to update the tables
    $sql = "DELETE FROM blist WHERE `expires` <= now() && `expires` > 0";
    if (!mysql_query($sql)) die('Unable to remove records: ' . mysql_error());

    echo mysql_affected_rows() . ' records have been successfully removed from blist';
    return;
}


?>