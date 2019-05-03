<?php
    require_once("../wwwinc/JWT.php");

    class db {
        const DBUSER = " ";
        const DBPASS = " ";
        const DBNAME = "LunchDate";
        const TOKENKEY = "our super secret server key";

        protected static function makeDBConnection(){
        $success = 0;
        $tries = 0;
        while ($success == 0) {
        $mysqli = mysqli_init();
        //$mysqli->ssl_set(NULL,NULL, config::DBPEM, NULL,NULL);
        $mysqli->real_connect("127.0.0.1", self::DBUSER, self::DBPASS, self::DBNAME);
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
        }

        public static function addUser($username, $password, $displayName) {
        $salt = random_bytes(32);
        $hash = hash_pbkdf2("sha256", $password, $salt, 1000, 32);
        $mysqli = self::makeDBConnection();
        if (!($stmt = $mysqli->prepare("INSERT INTO user (username, password, salt, display_name) VALUES (?,?,?,?)"))) {
            error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
        }
        if (!$stmt->bind_param("ssss", base64_encode($username), $hash, base64_encode($salt), base64_encode($displayName))) {
            error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
        }
        $stmt->execute();
        if ($stmt->errno) {
            error_log("Could not add user " . $username . ".");
            error_log($stmt->error);
        }
        $stmt->close();
        }

        public static function getUser($username, $password) {
        $mysqli = self::makeDBConnection();
        if (!($stmt = $mysqli->prepare("SELECT * FROM `user` WHERE username = ? ORDER BY `id` DESC"))) {
            error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
        }
        if (!$stmt->bind_param("s", base64_encode($username))) {
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
            $hash = hash_pbkdf2("sha256", $password, base64_decode($user["salt"]), 1000, 32);
            if ($hash == $user["password"]) {
            return $user;
            } else {
            return -1;
            }
        } else {
            return -1;
        }
        }

        public static function getToken($user) {
            $toEncode = array();
            $toEncode['username'] = $user["username"];
            $toEncode['valid_at'] = time();
            $token = JWT::encode($toEncode, self::TOKENKEY);

            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("UPDATE `user` SET `token` = ? WHERE id = ?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("sd", $token, $user["id"])) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            return $token;
        }

        public static function removeToken($user) {
            if (!($stmt = $mysqli->prepare("UPDATE `user` SET `token` = NULL WHERE id = ?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("d", $user["id"])) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
            }
        }

        public static function getUserByToken($token) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("SELECT * FROM `user` WHERE token = ? ORDER BY `id` DESC"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("s", $token)) {
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
                return $ret[0];
            } else {
                return -1;
            }
        }
        
        public static function getAllergens() {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("select * from allergen order by `name` asc"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
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
            return $ret;
        }
        
        public static function getAllergensForUser($user) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("select id, a.name, (select count(user_to_allergen.id) from allergen join user_to_allergen on allergen.id=user_to_allergen.allergen_id where user_to_allergen.user_id = ? and allergen.id=a.id and active=1) as allergic from allergen as a"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("d", $user["id"])) {
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
            return $ret;
        }
        
        public static function setAllergenByName($user, $allergen, $active) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("INSERT INTO `user_to_allergen` (user_id, allergen_id, active) VALUES (?, (SELECT id FROM `allergen` WHERE name=?), ?) ON DUPLICATE KEY UPDATE active=?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("dsdd", $user["id"], $allergen, $active, $active)) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
            }
        }
        
        public static function updateCalendar($user, $eventString) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("UPDATE `user` SET available_times=?, last_updated=NOW() WHERE id=?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("sd", $eventString, $user["id"])) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
            }
        }
        
        public static function updateUser($user, $username, $displayName, $allergic, $notAllergic) {
            if ($username=="@" or $displayName=="") {
                return 0;
            }
            
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("UPDATE `user` SET display_name=?, username=? WHERE id=?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("ssd", base64_encode($displayName), base64_encode($username), $user["id"])) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
                return 0;
            }
            
            foreach ($allergic as $key => $val) {
                self::setAllergenByName($user, $val, 1);
            }
            foreach ($notAllergic as $key => $val) {
                self::setAllergenByName($user, $val, 0);
            }
            
            return 1;
            
        }
        
        public static function getFriendRequestsForUser($user) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("select user_to_user.id, user.display_name, user.username from user join user_to_user on user.id=user_to_user.user1_id where user_to_user.status='requested' and user_to_user.user2_id=?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("d", $user["id"])) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
                return array();
            }
            $result = $stmt->get_result();
            $ret = array();
            while ($row = $result->fetch_array(MYSQLI_ASSOC))
            {
                $ret[] = $row;
            }
            return $ret;
        }
        
        public static function respondToFriendRequest($userToUserID, $response) {
            $mysqli = self::makeDBConnection();
            if (!($stmt = $mysqli->prepare("update user_to_user set status=? where id=?"))) {
                error_log("Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error);
            }
            if (!$stmt->bind_param("sd", $response, $userToUserID)) {
                error_log("Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error);
            }
            if (!$stmt->execute()) {
                error_log("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
                return array();
            }
        }


    }



?>
