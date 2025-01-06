<?php
header('Content-Type: application/json');
include 'connection.php';

$judul = $_POST['judul'];
$pengarang = $_POST['pengarang'];
$penerbit = $_POST['penerbit'];
$tahun_terbit = $_POST['tahun_terbit'];
$image = $_POST['image'];

$query = "INSERT INTO buku (judul, pengarang, penerbit, tahun_terbit, image) 
          VALUES ('$judul', '$pengarang', '$penerbit', '$tahun_terbit', '$image')";

try {
    if(mysqli_query($conn, $query)) {
        echo json_encode([
            "success" => true,
            "message" => "Buku berhasil ditambahkan"
        ]);
    } else {
        throw new Exception(mysqli_error($conn));
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}

mysqli_close($conn);
?> 