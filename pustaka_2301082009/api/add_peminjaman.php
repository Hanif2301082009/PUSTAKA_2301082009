<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

// Ambil data dari request
$id_anggota = $_POST['id_anggota'] ?? null;
$id_buku = $_POST['id_buku'] ?? null;
$tanggal_pinjam = $_POST['tanggal_pinjam'] ?? date('Y-m-d');

if (!$id_anggota || !$id_buku) {
    echo json_encode([
        "success" => false,
        "message" => "ID anggota dan ID buku harus diisi"
    ]);
    exit;
}

try {
    // Cek apakah buku sedang dipinjam
    $check_query = "SELECT id FROM peminjaman 
                   WHERE id_buku = ? 
                   AND tanggal_kembali IS NULL";
    
    $check_stmt = mysqli_prepare($conn, $check_query);
    mysqli_stmt_bind_param($check_stmt, "i", $id_buku);
    mysqli_stmt_execute($check_stmt);
    $check_result = mysqli_stmt_get_result($check_stmt);
    
    if (mysqli_num_rows($check_result) > 0) {
        echo json_encode([
            "success" => false,
            "message" => "Buku ini sedang dipinjam"
        ]);
        exit;
    }

    // Tambah peminjaman baru
    $query = "INSERT INTO peminjaman (id_anggota, id_buku, tanggal_pinjam) 
              VALUES (?, ?, ?)";
              
    $stmt = mysqli_prepare($conn, $query);
    mysqli_stmt_bind_param($stmt, "iis", $id_anggota, $id_buku, $tanggal_pinjam);
    
    if (mysqli_stmt_execute($stmt)) {
        echo json_encode([
            "success" => true,
            "message" => "Peminjaman berhasil ditambahkan"
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