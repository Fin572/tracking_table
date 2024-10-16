<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "mobile";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

header('Content-Type: application/json');

if (isset($_GET['id'])) {
    $id = intval($_GET['id']);

    $sql = "SELECT photos FROM as_enduser_devices WHERE id = $id";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $photos = explode(';', $row['photos']);
        $photos = array_filter($photos); // Remove empty values
        echo json_encode($photos);
    } else {
        echo json_encode([]);
    }
} else {
    echo json_encode(['error' => 'Invalid request']);
}

$conn->close();
?>
