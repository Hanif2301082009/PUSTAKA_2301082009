<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');

include 'connection.php';

try {
    // Query untuk mengambil buku yang tidak sedang dipinjam
    $query = "SELECT DISTINCT b.* 
              FROM buku b 
              WHERE NOT EXISTS (
                  SELECT 1 
                  FROM peminjaman p 
                  WHERE p.id_buku = b.id 
                  AND p.tanggal_kembali IS NULL
              )
              ORDER BY b.id DESC";
              
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