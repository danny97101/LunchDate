<?php

    $DBUSER = "";
    $DBPASS = "";
    $DBNAME = "LunchDate";

    protected function makeDBConnection($giveUp=0){
	$success = 0;
	$tries = 0;
	while ($success == 0) {
	$mysqli = mysqli_init();
	//$mysqli->ssl_set(NULL,NULL, config::DBPEM, NULL,NULL);
	$mysqli->real_connect("127.0.0.1", $DBUSER, $DBPASS, $DBNAME);
	if ($mysqli->connect_errno) {
	    $tries += 1;
	    error_log("Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error);
	    $success = 0;
	    $mysqli->close();
	    usleep(rand(100000,500000)); //sleep a random time between 0.1 seconds and 0.5 seconds before retrying
	} else {
	    $success = 1;
	}
	return $mysqli;
    }

    public function addUser($username, $password, $fullName, $type) {
    $salt = random_bytes(32);
    $hash = hash_pbkdf2("sha256", $password, $salt, 1000, 32);
    $mysqli = self::makeDBConnection();
    if (!($stmt = $mysqli->prepare("INSERT INTO users (username, password, salt, full_name, type) VALUES (?,?,?,?,?)"))) {
        error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
    }
    if (!$stmt->bind_param("ssssd", $username, $hash, $salt, $fullName, $type)) {
        error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
    }
    $stmt->execute();
    if ($stmt->errno) {
        error_log("Could not add user " . $username . ".");
    }
    $stmt->close();
    }

    public function getUser($username, $password) {
    $mysqli = self::makeDBConnection();
    if (!($stmt = $mysqli->prepare("SELECT * FROM `users` WHERE username = ? ORDER BY `id` DESC"))) {
        error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
    }
    if (!$stmt->bind_param("s", $username)) {
        error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
    }
    if (!$stmt->execute()) {
        error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
    }
    $result = $stmt->get_result();
    $ret = array();
    while ($row = $result->fetch_array(MYSQLI_ASSOC))
        {
            $ret[] = $row;
        }
    if (count($ret) > 0) {
        $user = $ret[0];
        $hash = hash_pbkdf2("sha256", $password, $user["salt"], 1000, 32);
        if ($hash == $user["password"]) {
        return $user;
        } else {
        return -1;
        }
    } else {
        return -1;
    }
    }

?>
