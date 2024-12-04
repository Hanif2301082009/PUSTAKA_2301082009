<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

try {
    $query = "SELECT p.*, b.judul as judul_buku, a.nama as nama_anggota 
              FROM peminjaman p
              JOIN buku b ON p.id_buku = b.id
              JOIN anggota a ON p.id_anggota = a.id
              ORDER BY p.tanggal_pinjam DESC";
              
    $result = mysqli_query($conn, $query);

    if (!$result) {
        throw new Exception(mysqli_error($conn));
    }

    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;
    }

    echo json_encode([
        "success" => true,
        "data" => $data
    ]);

} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Error: " . $e->getMessage()
    ]);
}

mysqli_close($conn);
?> 