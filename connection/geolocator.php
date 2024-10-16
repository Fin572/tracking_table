<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "mobile");

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$id = isset($_POST['id']) ? $_POST['id'] : null;
$latitude = isset($_POST['latitude']) ? $_POST['latitude'] : null;
$longitude = isset($_POST['longitude']) ? $_POST['longitude'] : null;

if ($id && $latitude && $longitude) {
    $id = $conn->real_escape_string($id);
    $latitude = $conn->real_escape_string($latitude);
    $longitude = $conn->real_escape_string($longitude);
    $geolocation = $latitude . ',' . $longitude;

    $query = "UPDATE as_enduser_devices SET geolocation = '$geolocation' WHERE id = '$id'";

    if ($conn->query($query) === TRUE) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to update geolocation: ' . $conn->error]);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Missing required parameters']);
}

$conn->close();
?>
