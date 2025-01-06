<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "pustaka_2301082009";

$conn = mysqli_connect($servername, $username, $password, $dbname);

if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
?> 