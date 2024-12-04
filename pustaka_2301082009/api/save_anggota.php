<?php
// Pastikan tidak ada output HTML sebelum header
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$nim = $data['nim'];
$password = $data['password'];
$nama = $data['nama'];
$alamat = $data['alamat'];
$jenis_kelamin = $data['jenis_kelamin'];

// Gunakan error_log untuk debugging alih-alih print
error_log("Password received: " . $password);

$query = "INSERT INTO anggota (nim, password, nama, alamat, jenis_kelamin) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("sssss", $nim, $password, $nama, $alamat, $jenis_kelamin);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true, 
        "message" => "Data berhasil disimpan",
        "data" => [
            "nim" => $nim,
            "password" => $password,
            "nama" => $nama,
            "alamat" => $alamat,
            "jenis_kelamin" => $jenis_kelamin
        ]
    ]);
} else {
    echo json_encode([
        "success" => false, 
        "message" => "Error: " . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?> 