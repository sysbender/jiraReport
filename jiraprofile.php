<?php

	$ch = curl_init('http://localhost:2990/jira/rest/api/2/user?username='.$_POST['username']);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

	if(isset($_COOKIE['JSESSIONID']))
		$cookiestr='JSESSIONID='.$_COOKIE['JSESSIONID'];
	else
		$cookiestr="";

	curl_setopt($ch, CURLOPT_HTTPHEADER, array('cookie:'.$cookiestr));

	$result = curl_exec($ch);
	curl_close($ch);
	$sess_arr = json_decode($result, true);

	if(isset($sess_arr['errorMessages'][0])) {
		echo $sess_arr['errorMessages'][0];
	}
	else {
		echo $sess_arr['displayName'];
		echo "\n";
		echo $sess_arr['emailAddress'];
	}
?>