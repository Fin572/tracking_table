<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "mobile";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user = $_GET['user'];
$group_id = $_GET['group_id'];

$organization_query = "";
if ($group_id > 1) {
    $organization_query = "SELECT * FROM mis_organization WHERE OrganizationID IN (SELECT organization_id FROM sec_users_organization WHERE login = '$user')";
} else {
    $organization_query = "SELECT o.OrganizationID, o.Organization_Name, o.Code 
                           FROM mis_organization o 
                           INNER JOIN mis_location l 
                           ON o.OrganizationID = l.Owner_organization 
                           GROUP BY o.OrganizationID, o.Organization_Name, o.Code";
}

$org_result = $conn->query($organization_query);
$organizations = [];
while ($row = $org_result->fetch_assoc()) {
    $organizations[] = $row;
}

echo json_encode($organizations);

$conn->close();
?>
