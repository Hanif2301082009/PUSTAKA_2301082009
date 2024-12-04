<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

$id_peminjaman = $_POST['id'] ?? null;
$tanggal_kembali = date('Y-m-d');

if (!$id_peminjaman) {
    echo json_encode([
        "success" => false,
        "message" => "ID peminjaman harus diisi"
    ]);
    exit;
}

try {
    // Update tanggal_kembali di tabel peminjaman
    $query = "UPDATE peminjaman SET tanggal_kembali = ? WHERE id = ?";
              
    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "si", $tanggal_kembali, $id_peminjaman);
    
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "success" => true,
            "message" => "Buku berhasil dikembalikan"
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