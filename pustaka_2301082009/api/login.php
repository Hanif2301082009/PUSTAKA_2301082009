<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$nim = $data['nim'];
$password = $data['password'];
$is_admin = $data['is_admin'];

if ($is_admin) {
    // Admin login
    $query = "SELECT * FROM admin WHERE username = ? AND password = ? LIMIT 1";
} else {
    // User login
    $query = "SELECT * FROM anggota WHERE nim = ? AND password = ? LIMIT 1";
}

$stmt = $conn->prepare($query);
$stmt->bind_param("ss", $nim, $password);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    echo json_encode([
        "success" => true,
        "message" => "Login berhasil",
        "user" => [
            "id" => $user['id'],
            "nim" => $user['nim'] ?? $user['username'],
            "nama" => $user['nama'],
            "is_admin" => $is_admin
        ]
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Username/NIM atau Password salah"
    ]);
}

$stmt->close();
$conn->close();
?> 