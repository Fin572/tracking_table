<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "mobile");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_GET['location_id'])) {
    $location_id = $conn->real_escape_string($_GET['location_id']);

    $query = "SELECT DISTINCT device_type FROM as_enduser_devices WHERE location_id = '$location_id'";
    $result = $conn->query($query);

    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
} else {
    echo json_encode(['error' => 'location_id not provided']);
}

$conn->close();
?>
