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
    if (isset($_POST['id']) && isset($_POST['photoIndex'])) {
        $id = $_POST['id'];
        $photoIndex = $_POST['photoIndex'];

        $sql = "SELECT photos FROM as_enduser_devices WHERE id = ?";
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $stmt->bind_result($photos);
        $stmt->fetch();
        $stmt->close();

        if ($photos) {
            $photosArray = explode(';', $photos);

            if (isset($photosArray[$photoIndex])) {
                unset($photosArray[$photoIndex]);
                $newPhotos = implode(';', $photosArray);

                $sql = "UPDATE as_enduser_devices SET photos = ? WHERE id = ?";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("si", $newPhotos, $id);

                if ($stmt->execute()) {
                    echo "Photo deleted successfully";
                } else {
                    echo "Error deleting photo: " . $conn->error;
                }

                $stmt->close();
            } else {
                echo "Invalid photo index";
            }
        } else {
            echo "No photos found";
        }
    } else {
        echo "Invalid request";
    }
} else {
    echo "Invalid request method";
}

$conn->close();
?>
