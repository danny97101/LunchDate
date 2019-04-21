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
            $username = $_REQUEST["username"];
            $password = $_REQUEST["password"];
            $user = db::getUser($username, $password);
            if ($user == -1) {
                header("HTTP/1.1 401 Unauthorized");
                exit;
            }
            $token = db::getToken($user);
            $user['token'] = $token;
            echo json_encode($user);
            exit(0);
            
    }
?>
