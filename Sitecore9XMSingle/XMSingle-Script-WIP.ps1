Param( 
        [Parameter(Mandatory=$true)]
        [String] 
        $resourceGroupName,
		[Parameter(Mandatory=$True)]
		[string]
		$location
		
)

#1. Login to Azure
Login-AzureRmAccount


$getSub = Get-AzureRmSubscription | select -ExpandProperty 'SubscriptionName'
Write-Host "Select the numeric value for account that you want to use for setup" -ForegroundColor Yellow

$i = 0
while($i -lt $getSub.Length)
{
    Write-Host [$i] + $getSub[$i]
    $i++
}

$getSubValue = Read-Host
$getSubName = $getSub[$getSubValue]


#2. Set Azure Subscription
Get-AzureRmSubscription -SubscriptionName $getSubName  | Select-AzureRmSubscription

#3. Create Variable and get the keys
$storageAccountName = "hidevstore"
$storageAccountkey = Get-AzureRmStorageAccountKey -ResourceGroupName 'dev-store-rg' -Name $storageAccountName 


#4. Select the first key
$key1 = $storageAccountkey | Where-Object KeyName -EQ "key1" |Select-Object -ExpandProperty value

#5. Set the context to be used in later cmdlet
$context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key1

#4. Create a folder as working director
mkdir -Path 'c:\Sitecore9-Install' -Force
$dir = 'C:\Sitecore9-Install'

#6. Download the file from storage account
$fileName = "sitecore9\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$localDirectory = "C:\Sitecore9-Install\Sitecore Azure Toolkit 2.0.0 rev.171010.zip"
$containerName = "public"
$jsonperameter = "sitecore9\azuredeploy.parameters.json"
$license  ="sitecore9\license.xml"
$jsonParameterFilePath = "$dir\azuredeploy.parameters.json"
$licenseFilePath = "$dir\license.xml"



#7. Finally get the toolkit from storage account
Get-AzureStorageBlobContent -Blob $fileName -Container $containerName -Destination $localDirectory  -Context $context

Get-AzureStorageBlobContent -Blob $jsonperameter -Container $containerName -Destination $jsonParameterFilePath  -Context $context

Get-AzureStorageBlobContent -Blob $license -Container $containerName -Destination $licenseFilePath  -Context $context

#8. unarchive the Sitecore tool kit 
Expand-Archive -Path $localDirectory -DestinationPath 'C:\Sitecore9-Install' -Force


#9. Local Path for license file
$localLicensePath = "$dir\license.xml"

#10. Local Path for Json Parameter file
$localArmParameterPath = "$dir\azuredeploy.parameters.json"

#11. Remote path for Json ARM Template
$remoteJsonPath = "https://raw.githubusercontent.com/Sitecore/Sitecore-Azure-Quickstart-Templates/master/Sitecore 9.0.0/XMSingle/azuredeploy.json"


#12. Import the modules from Sitecore toolkit that we downloaded
Import-Module $dir\tools\sitecore.cloud.cmdlets.psm1

#13. Go to the local folder
cd c:\Sitecore9-Install

#14. Start the installation.
Start-SitecoreAzureDeployment -Name 'Sitecore9xm-Single-rg' -Location 'centralus' -ArmTemplateUrl $remoteJsonPath  -ArmParametersPath $localarmParameterPath  -LicenseXmlPath $locallicensePath 



