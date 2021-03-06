<?php

if($session['status'] == FALSE) {
	echo "No direct access";
	return;
}

if($session['session']->rank < ADMIN_RANK) {
	echo "Invalid page access";
	return;
}

$operation = isset($_POST['operation']) ? strtolower(trim($_POST['operation'])) : '';
$id = isset($_POST['id']) ? (int)(trim($_POST['id'])) : 0;

if(($operation && !$id) || (!$operation && $id)) {
	echo "Invalid operation";
}
elseif($operation && $id) {
	$sql = "SELECT * FROM appeal WHERE id=$id LIMIT 1";
	$result = mysql_query($sql);
	if(!$result || mysql_num_rows($result) == 0) {
	  echo "No record found";
	  return;
	}
	$row = mysql_fetch_object($result);
	
  $result = mysql_query("SELECT COUNT(id) AS total FROM appeal AS total WHERE user='$row->user' AND request_type='user'");

  $utotal = 0;
	if($result) {
	  $utotal = mysql_fetch_object($result);
	  $utotal = $utotal->total;
	}

  if($row->request_type == 'channel') {
	  $result = mysql_query("SELECT COUNT(id) AS total FROM appeal WHERE channel='$row->channel' AND request_type='channel'");
  	$ctotal = 0;
  	if($result) {
  	  $ctotal = mysql_fetch_object($result);
  	  $ctotal = $ctotal->total;
  	}
	}
	
 	switch($operation) {
	  case 'view':
	    $name = $row->channel ? $row->channel : $row->user;
    ?>
    <h2>Ban Information</h2>
     <table>
    <?php
    		if($row->channel) {
    ?>
    	<tr>
    	  <td class="view-header">Channel:</td>
        <td class="view-detail"><a href="http://idm-bot.com/account/history/<?=rawurlencode($row->channel)?>" target="_blank"><?=$row->channel?> (<?=$ctotal?> items in history)</a> </td>
    	</tr>
    <?php
    		}
    ?>
    	<tr>
    	  <td class="view-header">User:</td>
    		<td class="view-detail"><a href="http://idm-bot.com/account/history/<?=rawurlencode($row->user)?>" target="_blank"><?=$row->user?> (<?=$utotal?> items in history)</a> </td>
    	</tr>
    	<tr>
    	  <td class="view-header">Ban Date:</td>
    	  <td class="view-detail"><?=$row->ban_date?></td>
    	</tr>
    	<tr>
    	  <td class="view-header">Banned By:</td>
    	  <td class="view-detail"><?=$row->banned_by?></td>
    	</tr>
    	<tr>
    	  <td class="view-header">Reason:</td>
    	  <td class="view-detail"><?=$row->reason?></td>
    	</tr>
    	<tr>
    	  <td class="view-header">Appeal Date:</td>
    	  <td class="view-detail"><?=$row->request_date?></td>
    	</tr>
    	<tr>
    	  <td class="view-header">Statement:</td>
    	  <td class="view-detail"><?=$row->request?></td>
    	</tr>
    </table>
    <p>If you wish you can leave a reason or statement for the user to read.</p>
    <p>
    <div class="appeal-operation">
    	<form method="post" action="/account/bappeal/">
    	  <textarea class="ban-statement" rows="5" cols="50" name="explanation"></textarea>
    		<input type="hidden" name="id" value="<?=$row->id?>" /><br />
        Unban when: <select name="expires">
          <option value="0" selected="selected">ASAP</option>
          <option value="1">1 Hour</option>
          <option value="2">2 Hours</option>
          <option value="6">6 Hours</option>
          <option value="12">12 Hours</option>
          <option value="24">1 Day</option>
          <option value="48">2 Days</option>
          <option value="72">3 Days</option>
          <option value="168">7 Days</option>
        </select>
    		<br />
    		<br />
    		<input type="submit" name="operation" value="Approve" />
    		<input type="submit" name="operation" value="Deny" />
    	</form>
    </div>
    <br />
    <hr />
    <?php

		  break;
		case 'approve':
    $explanation = isset($_POST['explanation']) ? mysql_real_escape_string(trim($_POST['explanation'])) : '';
    $expires = isset($_POST['expires']) ? mysql_real_escape_string(trim($_POST['expires'])) : '0';
    if (!is_numeric($expires)) { $expires = 0; }
		  $sql = "UPDATE appeal SET status='a',
								explanation='$explanation', processed_by='$user',
								processed_date=NOW()
							WHERE id=$id";
			mysql_query($sql);

			if($row->request_type == 'channel') {
			  $table = 'blist';
			  $user = $row->channel;
			}
			else {
			  $table = 'ilist';
			  $user = $row->user;
        if ($expires == "0") { mysql_query("UPDATE user SET banned = '0' WHERE user = '$user'"); }
			}
      if ($expires == "0") {
        $sql = "DELETE FROM $table WHERE user='$user' AND time='$row->ban_date'";
			  mysql_query($sql);
      }
      else {
        $sql = "UPDATE $table SET expires=DATE_ADD(now(), interval $expires hour) WHERE user='$user' AND time='$row->ban_date'";
        mysql_query($sql);
      }
			echo "The ban appeal has been successfully approved.";
			break;
		case 'deny':
		  $explanation = isset($_POST['explanation']) ? mysql_real_escape_string(trim($_POST['explanation'])) : '';
		  $sql = "UPDATE appeal SET status='d',
								explanation='$explanation', processed_by='$user',
								processed_date=NOW()
							WHERE id=$id";
			mysql_query($sql);
			echo "The ban appeal has been successfully denied.";
			break;
	}
}
// Retrieve a list of pending appeals
$sql = "SELECT * FROM appeal
				WHERE request_type='user' AND status='p'
				ORDER BY banned_by ASC, request_date ASC";
$result = mysql_query($sql);

?>
<h3>Pending User Ban Appeals</h3>

<?php
if(!$result || mysql_num_rows($result) == 0) {
  echo "There are no pending user bans to process";
}
else {
?>
<table class="table-user">
	<thead>
		<tr>
		  <th>User</th>
		  <th>Ban Date</th>
		  <th>Banned By</th>
		  <th>Reason</th>
		  <th>Appeal Date</th>
		  <th>Operation</th>
		</tr>
	</thead>
	<tbody>
<?
	$index = 1;
  while(($row = mysql_fetch_object($result)) != NULL) {
		$class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
    if(strlen($row->reason) > 50) {
      $reason = substr($row->reason, 0, 45).'...';
		}
		else {
		  $reason = $row->reason;
		}
?>
		<tr <?=$class?>>
		  <td><a href="http://idm-bot.com/u/<?=rawurlencode($row->user)?>"><?=$row->user?></td>
		  <td><?=$row->ban_date?></td>
		  <td><?=$row->banned_by?></td>
		  <td><?=$reason?></td>
		  <td><?=$row->request_date?></td>
		  <td>
				<form method="post" action="/account/bappeal/">
				  <input type="hidden" name="operation" value="view" />
				  <input type="hidden" name="id" value="<?=$row->id?>" />
				  <input type="submit" value="View" />
				</form>
			</td>
		</tr>
 <?
  }
  ?>
  </tbody>
</table>
  <?
}
$sql = "SELECT * FROM appeal
				WHERE request_type='channel' AND status='p'
				ORDER BY request_date ASC";
$result = mysql_query($sql);
?>
<hr />
<h2>Pending Channel Ban Appeals</h2>

<?
if(!$result || mysql_num_rows($result) == 0) {
	echo "There are no pending channel bans to process";

}
else {
?>
<table class="table-user">
	<thead>
	  <tr>
		  <th>Channel</th>
		  <th>Ban Date</th>
		  <th>Banned By</th>
		  <th>Reason</th>
		  <th>Appeal Date</th>
		  <th>Appealed By</th>
		  <th>Operation</th>
		</tr>
	</thead>
	<tbody>
<?
	$index = 1;
	while(($row = mysql_fetch_object($result)) != NULL) {
	  $class = ($index++ % 2 == 1) ? 'class="odd"' : 'class="even"';
	  if(strlen($row->reason > 50)) {
	    $reason = substr($row->reason, 0, 45).'...';
		}
		else {
			$reason = $row->reason;
		}
 ?>
	  <tr <?=$class?>>
	    <td><?=$row->channel?></td>
	    <td><?=$row->ban_date?></td>
	    <td><?=$row->banned_by?></td>
	    <td><?=$reason?></td>
	    <td><?=$row->request_date?></td>
	    <td><?=$row->user?></td>
	    <td>
	      <form method="post" action="/account/bappeal/">
	        <input type="hidden" name="operation" value="view" />
	        <input type="hidden" name="id" value="<?=$row->id?>" />
	        <input type="submit" value="View" />
	      </form>
	    </td>
	  </tr>
 <?
	}
	?>
	</tbody>
</table>
<?
}
?>

