<?php
// Skrip debugging sederhana
if (!empty($_GET)) {
    echo "GET parameters received:\n";
    var_dump($_GET);
} else {
    echo "No GET parameters received.\n";
}
?>