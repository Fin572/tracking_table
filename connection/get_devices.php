<?php
header('Content-Type: application/json');

$servername = "localhost"; 
$username = "root";
$password = "";
$dbname = "mobile";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    echo json_encode(['error' => 'Connection failed: ' . $conn->connect_error]);
    exit;
} 

error_log("Received GET parameters: " . json_encode(@$_GET));

$location_id = isset($_GET['location_id']) ? $_GET['location_id'] : 0; 
$device_type = isset($_GET['device_type']) ? $_GET['device_type'] : ''; 

error_log("location_id: " . $location_id);
error_log("device_type: " . $device_type);

// Prepare the SQL statement using prepared statements
$stmt = $conn->prepare("SELECT device_name,id,geolocation,device_category FROM as_enduser_devices WHERE location_id = ? AND device_type = ?");
if ($stmt === false) {
    error_log("Error preparing statement: " . $conn->error);
    echo json_encode(['error' => 'Failed to prepare SQL statement']);
    exit;
}

$stmt->bind_param("is", $location_id, $device_type); // "is" means the first parameter is an integer and the second is a string

if (!$stmt->execute()) {
    error_log("Error executing statement: " . $stmt->error);
    echo json_encode(['error' => 'Failed to execute SQL statement']);
    exit;
}

$result = $stmt->get_result();

$devices = [];
while ($row = $result->fetch_assoc()) {
    $devices[] = $row;
}

if (empty($devices)) {
    error_log("No data found for location_id: $location_id and device_type: $device_type");
}

echo json_encode($devices);

$stmt->close();
$conn->close();
?>
