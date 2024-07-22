<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "mobile";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_GET['id'])) {
    $id = $_GET['id'];

    // Prepare the SQL query
    $sql = "SELECT photos FROM as_enduser_devices WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $stmt->bind_result($photos);
    $stmt->fetch();
    $stmt->close();

    if ($photos) {
        // Decode the JSON-encoded photos
        $photosArray = json_decode($photos, true);

        if (is_array($photosArray)) {
            foreach ($photosArray as $photo) {
                // Decode the base64-encoded photo
                $photoDecoded = base64_decode($photo);

                // Get the content type
                $finfo = new finfo(FILEINFO_MIME_TYPE);
                $mimeType = $finfo->buffer($photoDecoded);

                // Display the image
                echo '<img src="data:' . $mimeType . ';base64,' . $photo . '" style="max-width: 200px; max-height: 200px; margin: 10px;">';
            }
        } else {
            echo "No valid photos found for this device.";
        }
    } else {
        echo "No photo found for this device.";
    }
} else {
    echo "Device ID not specified.";
}

$conn->close();
?>
