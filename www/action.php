<?php
    require_once("../wwwinc/db.inc.php");
    $action = $_REQUEST["action"];

    switch ($action) {
        case 'logout':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user == -1) {
                header("HTTP/1.1 401 Unauthorized");
                exit;
            }
            db::removeToken($user);
            exit(0);
        case 'createUser':
            $username = $_REQUEST["username"];
            $password = $_REQUEST["password"];
            $displayName = $_REQUEST["display_name"];
            db::addUser($username, $password, $displayName);
        case 'login':
            error_log("login!!!!");
            $username = $_REQUEST["username"];
            $password = $_REQUEST["password"];
            $user = db::getUser($username, $password);
            if ($user == -1) {
                header("HTTP/1.1 401 Unauthorized");
                exit;
            }
            $token = db::getToken($user);
            $ret = array();
            $ret['token'] = $token;
            $ret['username'] = $user['username'];
            $ret['display_name'] = $user['display_name'];
            echo json_encode($ret);
            exit(0);
        case 'getUserInfo':
        case 'checkToken':
            $token = $_REQUEST["token"];
            $ret = array();
            $user = db::getUserByToken($token);
            $ret["user"] = array();
            $ret["user"]["username"] = $user["username"];
            $ret["user"]["display_name"] = $user["display_name"];
            echo json_encode($ret);
            exit(0);
        case 'getAllergens':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $ret = json_encode(db::getAllergens());
                echo $ret;
            }
            exit(0);
        case 'uploadCalendar':
            $token = $_REQUEST["token"];
            $eventString = $_REQUEST["events"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                db::updateCalendar($user, $eventString);
            }
            exit(0);
        case 'getAllergensForUser':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $ret = json_encode(db::getAllergensForUser($user));
                echo $ret;
            }
            exit(0);
        case 'updateUser':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $displayName = $_REQUEST["display_name"];
                $username = $_REQUEST["username"];
                
                $allergic = array();
                $notAllergic = array();
                foreach ($_REQUEST as $key => $val){
                    if ($key != "token" and $key != "action" and $key != "username" and $key != "display_name") {
                        if ($val == 1) {
                            array_push($allergic, $key);
                        } else {
                            array_push($notAllergic, $key);
                        }
                    }
                }
                $success = db::updateUser($user, $username, $displayName, $allergic, $notAllergic);
                $ret = array();
                $ret["success"] = $success;
                echo json_encode($ret);
            }
            exit(0);
        case 'getFriendRequests':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $ret = json_encode(db::getFriendRequestsForUser($user));
                echo $ret;
            }
            exit(0);
        case 'respondToFriendRequest':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $userToUserID = $_REQUEST["request_id"];
                $response = $_REQUEST["response"];
                if ($response == 1) {
                    $responseStr = "friends";
                } else {
                    $responseStr = "not friends";
                }
                db::respondToFriendRequest($userToUserID, $responseStr);
            }
            $ret = array();
            $ret["success"] = 1;
            echo json_encode($ret);
            exit(0);
        case 'getFriends':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $ret = json_encode(db::getFriendsForUser($user));
                echo $ret;
            }
            exit(0);
        case 'removeFriend':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $friend = $_REQUEST["username"];
                db::removeFriend($user, $friend);
                $ret = array();
                $ret["success"] = 1;
                echo json_encode($ret);
                exit(0);
            }
            $ret = array();
            $ret["success"] = 0;
            echo json_encode($ret);
            exit(0);
        case 'getPotentialDates':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $ret = db::getPotentialDates($user);
                echo json_encode($ret);
            }
            exit(0);
        case 'getPotentialLocations':
            $token = $_REQUEST["token"];
            $user = db::getUserByToken($token);
            if ($user != -1) {
                $username = $_REQUEST["username"];
                $ret = db::getPossibleDiningHalls($username);
                echo json_encode($ret);
            }
            exit(0);
    }
?>
