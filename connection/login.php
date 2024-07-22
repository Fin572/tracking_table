<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "mobile";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user = $_POST['username'];
    $pass = $_POST['password'];
    
    // Hash the password using MD5
    $hashed_pass = md5($pass);

    $stmt = $conn->prepare("SELECT sec_users.login, sec_users.username, sec_users.email, sec_users_groups.group_id 
                            FROM sec_users 
                            JOIN sec_users_groups ON sec_users.login = sec_users_groups.login 
                            WHERE sec_users.login = ? AND sec_users.pswd = ?");
    $stmt->bind_param("ss", $user, $hashed_pass);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user_data = $result->fetch_assoc();
        $group_id = $user_data['group_id'];

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

        echo json_encode([
            "status" => "success",
            "user" => $user_data,
            "organizations" => $organizations
        ]);
    } else {
        echo json_encode(["status" => "error"]);
    }

    $stmt->close();
}

$conn->close();
?>
