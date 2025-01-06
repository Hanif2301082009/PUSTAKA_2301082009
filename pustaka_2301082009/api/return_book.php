<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

$id_peminjaman = $_POST['id'] ?? null;
$tanggal_kembali = $_POST['tanggal_kembali'] ?? date('Y-m-d');
$denda = $_POST['denda'] ?? 0; // Default denda 0 jika tidak ada

if (!$id_peminjaman) {
    echo json_encode([
        "success" => false,
        "message" => "ID peminjaman harus diisi"
    ]);
    exit;
}

try {
    // Mulai transaction
    mysqli_begin_transaction($conn);

    // 1. Update tanggal_kembali di tabel peminjaman
    $query1 = "UPDATE peminjaman SET tanggal_kembali = ? WHERE id = ?";
    $stmt1 = mysqli_prepare($conn, $query1);
    mysqli_stmt_bind_param($stmt1, "si", $tanggal_kembali, $id_peminjaman);
    
    // 2. Insert ke tabel pengembalian
    $query2 = "INSERT INTO pengembalian (id_peminjaman, tanggal_pengembalian, denda) VALUES (?, ?, ?)";
    $stmt2 = mysqli_prepare($conn, $query2);
    mysqli_stmt_bind_param($stmt2, "isd", $id_peminjaman, $tanggal_kembali, $denda);

    // Execute kedua query
    $success1 = mysqli_stmt_execute($stmt1);
    $success2 = mysqli_stmt_execute($stmt2);

    if ($success1 && $success2) {
        mysqli_commit($conn);
        echo json_encode([
            "success" => true,
            "message" => "Buku berhasil dikembalikan"
        ]);
    } else {
        throw new Exception(mysqli_error($conn));
    }

} catch (Exception $e) {
    mysqli_rollback($conn);
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}

mysqli_close($conn);
?> 