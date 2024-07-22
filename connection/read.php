<?php 
// $con = new mysqli("localhost","root","","testdb");
// $query = "Select * from as_enduser_devices";
// $result = $con->query($query);
// if ($result) {
    // $device = array();
    // while($row = $result->fetch_assoc()){
        // $device[] = $row;
    // }
    // $json_response = json_encode($device);
    // echo $json_response;
// }else{
    // echo "Error". $con->error;
// }
// $con->close();

$conn = new mysqli("localhost", "root", "", "mobile");
$query = mysqli_query($conn, "SELECT mis_location.Owner_organization, mis_organization.Organization_Name, mis_location.Location_Name
FROM mis_location
LEFT JOIN mis_organization ON mis_location.Owner_organization = mis_organization.OrganizationID;");
$data = mysqli_fetch_all($query, MYSQLI_ASSOC);
echo json_encode($data);