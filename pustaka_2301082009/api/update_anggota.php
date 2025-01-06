<?php
include 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);

$id = $data['id'];
$nim = $data['nim'];
$nama = $data['nama'];
$alamat = $data['alamat'];
$jenis_kelamin = $data['jenis_kelamin'];

// Check if password is being updated
if (!empty($data['password'])) {
    // If password is provided, update all fields including password
    $password = password_hash($data['password'], PASSWORD_DEFAULT);
    $query = "UPDATE anggota SET nim=?, password=?, nama=?, alamat=?, jenis_kelamin=? WHERE id=?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("sssssi", $nim, $password, $nama, $alamat, $jenis_kelamin, $id);
} else {
    // If no password provided, update all fields except password
    $query = "UPDATE anggota SET nim=?, nama=?, alamat=?, jenis_kelamin=? WHERE id=?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ssssi", $nim, $nama, $alamat, $jenis_kelamin, $id);
}

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Data berhasil diupdate"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}

$stmt->close();
$conn->close();
?> 