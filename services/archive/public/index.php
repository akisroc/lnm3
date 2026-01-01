<?php

declare(strict_types=1);

function uri(): string {
    if (isset($_SERVER['PATH_INFO'])) {
        return $_SERVER['PATH_INFO'];
    }

    if (isset($_SERVER['BASE'])) {
        $c = 1;
        return str_replace($_SERVER['BASE'], '', strtok($_SERVER['REQUEST_URI'], '?'), $c);
    }

    return '/';
}

try {
    $db = new \PDO('sqlite:../data/lnm_archive.db');
    $db->setAttribute(\PDO::ATTR_ERRMODE, \PDO::ERRMODE_EXCEPTION);
} catch (\Exception $e) {
    die('Database error: ' . $e->getMessage());
}

$routes = [
    '/' => '../src/homepage.php',
    '/topic' => '../src/topic.php',
    '/no-topic' => '../src/no_topic.php'
];

require $routes[uri()] ?? $routes['/'];
