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
        case 'checkToken':
            $token = $_REQUEST["token"];
            $ret = array();
            $ret["user"] = db::getUserByToken($token);
            echo json_encode($ret);
            exit(0);
        case 'getAllergens':
            $ret = json_encode(db::getAllergens());
            echo $ret;
            exit(0);

    }
?>
