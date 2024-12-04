<?php
include 'connection.php';

$data = json_decode(file_get_contents('php://input'), true);
$id = $data['id'];

$query = "DELETE FROM anggota WHERE id=?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Data berhasil dihapus"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
}

$stmt->close();
$conn->close();
?> 