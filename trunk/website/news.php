<?php
/******************************************************************************
 * POST SYNDICATION SCRIPT by chAos
 *
 * A very basic script that pulls threads with the first post from the database
 * and puts them into an array form so you can use them as you like.
 *
 * For use with phpBB3, freely distributable
 *
 ******************************************************************************/

/** Notes:
 *
 * - Attachments haven't been handled properly.
 * - Starts a forum session as Guest user, taking all the default values for time, bbcode style (from theme), etc
 * - While viewing this page, users will appear to be viewing the Forum Index on viewonline.php.
 *   This can't be helped without modifying other code which is beyond this
 *
 */

//////////////////////////////////////
//

function news_init() {

global $phpbb_root_path, $phpEx, $user, $db, $config, $cache, $template;

define('FORUM_ID', 4); // Forum ID to get data from
define('POST_LIMIT', 8); // How many to get
define('PHPBB_ROOT_PATH', '/home/idm/public_forum/'); // Path to phpBB (including trailing /)
define('PRINT_TO_SCREEN', true);
define('IN_PHPBB', true);

$phpbb_root_path = PHPBB_ROOT_PATH;
$phpEx = substr(strrchr(__FILE__, '.'), 1);

include($phpbb_root_path . 'common.' . $phpEx);
include($phpbb_root_path . 'includes/functions_display.' . $phpEx);
include($phpbb_root_path . 'includes/bbcode.' . $phpEx);

// Start session management
$user->session_begin(false);
$auth->acl($user->data);

// Grab user preferences
$user->setup();

}

function news_display () {

global $phpbb_root_path, $phpEx, $user, $db, $cache, $template;

$query = "SELECT u.user_id, u.username, t.topic_title, t.topic_poster, t.forum_id, t.topic_id, t.topic_time, t.topic_replies, t.topic_first_post_id, p.poster_id, p.topic_id, p.post_id, p.post_text, p.bbcode_bitfield, p.bbcode_uid
FROM " . USERS_TABLE . " u, " . TOPICS_TABLE . " t, " . POSTS_TABLE . " p
WHERE u.user_id = t.topic_poster
AND u.user_id = p.poster_id
AND t.topic_id = p.topic_id
AND p.post_id = t.topic_first_post_id
AND t.forum_id = " . FORUM_ID . "
ORDER BY t.topic_time DESC";

$result = $db->sql_query_limit($query, POST_LIMIT);
$posts = array ();
$news = array ();
$bbcode_bitfield = '';
$message = '';
$poster_id = 0;

while (($r = $db->sql_fetchrow($result)) != NULL) {
	$posts [] = array (

	'topic_id' => $r ['topic_id'], 'topic_time' => $r ['topic_time'], 'username' => $r ['username'], 'topic_title' => $r ['topic_title'], 'post_text' => $r ['post_text'], 'bbcode_uid' => $r ['bbcode_uid'], 'bbcode_bitfield' => $r ['bbcode_bitfield'], 'topic_replies' => $r ['topic_replies']
	);
	$bbcode_bitfield = $bbcode_bitfield | base64_decode($r ['bbcode_bitfield']);
}

// Instantiate BBCode
if ($bbcode_bitfield !== '') {
	$bbcode = new bbcode(base64_encode($bbcode_bitfield));
}

$current = 1;

// Output the posts
foreach ($posts as $m) {
	$message = $m ['post_text'];
	if ($m ['bbcode_bitfield']) {
		$bbcode->bbcode_second_pass($message, $m ['bbcode_uid'], $m ['bbcode_bitfield']);
	}

	$message = str_replace("\n", '<br />', $message);
	$message = smiley_text($message);

	if ($current == "1" || $current == "2") {
		$content .= "<div class=\"title\"><a href=\"http://forum.idm-bot.com/viewtopic.php?t=" . $m ['topic_id'] . "\">" . $m ['topic_title'] . "</a></div>\n
				<div class=\"info\">By:" . $m ['username'] . " on " . date("M j, Y, g:i a", $m ['topic_time']) . "</div>\n
				<div class=\"text\">" . $message . "</div>\n";
	} else {
		if ($current == "3") $content .= "<div class=\"title\">Old News Posts:</div>";
		$content .= "<div class=\"sub-news\">» <a href=\"http://forum.idm-bot.com/viewtopic.php?t=" . $m ['topic_id'] . "\">" . $m ['topic_title'] . "</a></div>\n";
	}

	$current++;
	unset($message, $poster_id);
}
print $content;
}
?>
