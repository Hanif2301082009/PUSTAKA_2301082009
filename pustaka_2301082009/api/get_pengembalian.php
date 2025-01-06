<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

try {
    $query = "SELECT pg.*, p.tanggal_pinjam, b.judul as judul_buku, a.nama as nama_anggota 
              FROM pengembalian pg
              JOIN peminjaman p ON pg.id_peminjaman = p.id
              JOIN buku b ON p.id_buku = b.id
              JOIN anggota a ON p.id_anggota = a.id
              ORDER BY pg.tanggal_pengembalian DESC";
              
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