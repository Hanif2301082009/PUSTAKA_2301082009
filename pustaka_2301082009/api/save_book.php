<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

include 'connection.php';

// Terima data JSON dari Flutter
$data = json_decode(file_get_contents('php://input'), true);

$response = array();

try {
    // Ambil data dari request
    $id = isset($data['id']) ? $data['id'] : null;
    $judul = $data['judul'];
    $pengarang = $data['pengarang'];
    $penerbit = $data['penerbit'];
    $tahun_terbit = $data['tahun_terbit'];
    $image = $data['image'];

    // Prepare statement untuk menghindari SQL injection
    if ($id) {
        // Update data buku
        $query = "UPDATE buku SET judul=?, pengarang=?, penerbit=?, tahun_terbit=?, image=? WHERE id=?";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssssbi", $judul, $pengarang, $penerbit, $tahun_terbit, $image, $id);
    } else {
        // Insert data buku baru
        $query = "INSERT INTO buku (judul, pengarang, penerbit, tahun_terbit, image) VALUES (?, ?, ?, ?, ?)";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("ssssb", $judul, $pengarang, $penerbit, $tahun_terbit, $image);
    }

    if ($stmt->execute()) {
        $response['success'] = true;
        $response['message'] = $id ? 'Buku berhasil diupdate' : 'Buku berhasil ditambahkan';
    } else {
        throw new Exception($stmt->error);
    }

    $stmt->close();

} catch (Exception $e) {
    $response['success'] = false;
    $response['message'] = 'Error: ' . $e->getMessage();
}

echo json_encode($response);
$conn->close();
?> 