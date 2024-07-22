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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($_POST['id']) && isset($_POST['photo'])) {
        $id = $_POST['id'];
        $photoData = $_POST['photo'];

        $sql = "UPDATE as_enduser_devices SET photos = CONCAT(IFNULL(photos, ''), '$photoData;', '') WHERE id = $id";

        if ($conn->query($sql) === TRUE) {
            echo "Photo uploaded successfully";
        } else {
            echo "Error: " . $sql . "<br>" . $conn->error;
        }
    } else {
        echo "Invalid request";
    }
} else {
    echo "Invalid request method";
}

$conn->close();
?>
