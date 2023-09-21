$uri = 'https://automation.atlassian.com/pro/hooks/<your_webhook>'
$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}

Invoke-Expression "powercfg /batteryreport /xml"
[xml]$xml = Get-Content -Path "$pwd\battery-report.xml"

$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("b", "http://schemas.microsoft.com/battery/2012")

$computerName = $xml.SelectSingleNode("//b:ComputerName", $ns).InnerText
$designCapacity = [int]$xml.SelectSingleNode("//b:DesignCapacity", $ns).InnerText
$fullChargeCapacity = [int]$xml.SelectSingleNode("//b:FullChargeCapacity", $ns).InnerText
$manufacturer = $xml.SelectSingleNode("//b:SystemManufacturer", $ns).InnerText
$model = $xml.SelectSingleNode("//b:SystemProductName", $ns).InnerText
$health = ($fullChargeCapacity / $designCapacity) * 100
$roundedValue = [Math]::Round($health, 0)

$summary = "Laptop battery condition report - $computerName - Windows"
$description = "$computerName's ($manufacturer - $model) reported battery condition is $roundedValue%. Please contact the contractor about it and doublecheck if replacement is needed."

$body = @{
    summary = $summary
    description = $description
} | ConvertTo-Json

if ($roundedValue -lt 60 -and $computername -ne ""){
    Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
}