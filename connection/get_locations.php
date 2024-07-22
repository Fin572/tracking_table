<?php
header('Content-Type: application/json');
$conn = new mysqli("localhost", "root", "", "mobile");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_GET['organization_id'])) {
    $organization_id = $conn->real_escape_string($_GET['organization_id']);

    $query = "SELECT LocationId, Location_Name FROM mis_location WHERE Owner_organization = '$organization_id'";
    $result = $conn->query($query);

    $data = array();
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode($data);
} else {
    echo json_encode(['error' => 'organization_id not provided']);
}

$conn->close();
?>
