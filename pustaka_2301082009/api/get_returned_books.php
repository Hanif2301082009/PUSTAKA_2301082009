<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

try {
    $query = "SELECT 
                pg.id,
                pg.tanggal_pengembalian,
                pg.denda,
                p.tanggal_pinjam,
                b.judul as judul_buku,
                a.nama as nama_anggota
              FROM pengembalian pg
              INNER JOIN peminjaman p ON pg.id_peminjaman = p.id
              INNER JOIN buku b ON p.id_buku = b.id
              INNER JOIN anggota a ON p.id_anggota = a.id
              ORDER BY pg.tanggal_pengembalian DESC";
              
    $result = mysqli_query($conn, $query);
    
    if (!$result) {
        throw new Exception(mysqli_error($conn));
    }

    $data = array();
    while ($row = mysqli_fetch_assoc($result)) {
        $row['tanggal_pinjam'] = date('d-m-Y', strtotime($row['tanggal_pinjam']));
        $row['tanggal_pengembalian'] = date('d-m-Y', strtotime($row['tanggal_pengembalian']));
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