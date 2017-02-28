<?php
	$ch = curl_init('http://localhost:2990/jira/rest/auth/1/session');
	$jsonData = array(
    'username' => $_POST['username'],
    'password' => $_POST['password'] );
	$jsonDataEncoded = json_encode($jsonData);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $jsonDataEncoded);

	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));

	$result = curl_exec($ch);
	curl_close($ch);

	$sess_arr = json_decode($result, true);

	if(isset($sess_arr['errorMessages'][0])) {
		echo $sess_arr['errorMessages'][0];
	}
	else {
		setcookie($sess_arr['session']['name'], $sess_arr['session']['value'], time() + (86400 * 30), "/");
		echo "Login Success!";
	}
?>