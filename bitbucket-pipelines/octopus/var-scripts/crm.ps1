function Set-OctopusVariable {
    param(
        $octopusURL = "https://xx/", # Octopus Server URL
        $octopusAPIKey = "",               # API key goes here
        $projectName = "crm",                        # Replace with your project name
        $spaceName = "Default",                   # Replace with the name of the space you are working in
        $environment = "",                     # Replace with the name of the environment you want to scope the variables to
        $varName = "",                            # Replace with the name of the variable
        $varValue = "",                            # Replace with the value of the variable
        $sensitiveValue ="$false"
    )

    # Defines header for API call
    $header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }

    # Get space
    $space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object {$_.Name -eq $spaceName}

    # Get project
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object {$_.Name -eq $projectName}

    # Get project variables
    $projectVariables = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header

    # Get environment to scope to
    $environmentObj = $projectVariables.ScopeValues.Environments | Where { $_.Name -eq $environment } | Select -First 1

    # Define values for variable
    $variable = @{
        Name = $varName  # Replace with a variable name
        Value = $varValue # Replace with a value
        Type = "String"
        IsSensitive = $sensitiveValue
        Scope = @{ 
            Environment = @(
                $environmentObj.Id
                )
            }
    }

    # Check to see if variable is already present. If so, removing old version(s).
    $variablesWithSameName = $projectVariables.Variables | Where-Object {$_.Name -eq $variable.Name}
    
    if ($environmentObj -eq $null){
        # The variable is not scoped to an environment
        $unscopedVariablesWithSameName = $variablesWithSameName | Where-Object { $_.Scope -like $null}
        $projectVariables.Variables = $projectVariables.Variables | Where-Object { $_.id -notin @($unscopedVariablesWithSameName.id)}
    } 
    
    if (@($variablesWithSameName.Scope.Environment) -contains $variable.Scope.Environment){
        # At least one of the existing variables with the same name is scoped to the same environment, removing all matches
        $variablesWithMatchingNameAndScope = $variablesWithSameName | Where-Object { $_.Scope.Environment -like $variable.Scope.Environment}
        $projectVariables.Variables = $projectVariables.Variables | Where-Object { $_.id -notin @($variablesWithMatchingNameAndScope.id)}
    }
    
    # Adding the new value
    $projectVariables.Variables += $variable
    
    # Update the collection
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/variables/$($project.VariableSetId)" -Headers $header -Body ($projectVariables | ConvertTo-Json -Depth 10)
}

# # Set-OctopusVariable  -environment "PROD" -varName "testVar" -varValue "value"
# Set-OctopusVariable -environment "$null" -varName "IsProduction" -varValue "false"
# Set-OctopusVariable -environment "PROD" -varName "IsProduction" -varValue "true"

# ## DB Conn
# Set-OctopusVariable -environment "$null" -varName "DBConn" -varValue "data source=#{env_aws}-vitamed;initial catalog=vitaMED;Integrated Security=SSPI;packet size=4096; Connect Timeout=250; Max Pool Size=1000"
# Set-OctopusVariable -environment "PROD" -varName "DBConn" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaMED;Integrated Security=SSPI;packet size=4096; Connect Timeout=250; Max Pool Size=1000"

# ## CRM application settings
# Set-OctopusVariable -environment "$null" -varName "PrescriptionFillsRedirect" -varValue "https://#{env_IIS}-crm.coracare.name.com/rx/fills/"
# Set-OctopusVariable -environment "PROD" -varName "PrescriptionFillsRedirect" -varValue "https://crm.coracare.name.com/rx/fills/"

# # API URLs
# Set-OctopusVariable -environment "PROD" -varName "AccessAuthorizationUrl" -varValue "https://accessauthorization.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "AccessAuthorizationUrl" -varValue "https://#{env_aws}-accessauthorization.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "IrisWebAPI" -varValue "https://iris.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "IrisWebAPI" -varValue "https://#{env_IIS}-iris.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "IrisBaseUrl" -varValue "https://iris.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "IrisBaseUrl" -varValue "https://#{env_IIS}-iris.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "BaseAddress" -varValue "https://#{env_IIS}-iris.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "BaseAddress" -varValue "https://iris.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "RebateBaseUrl" -varValue "https://#{env_IIS}-rebates.api.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "RebateBaseUrl" -varValue "https://rebates.api.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "CrmBackgroundServiceUrl" -varValue "https://#{env_IIS}-crmbs.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "CrmBackgroundServiceUrl" -varValue "https://crmbs.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "UserBaseUrl" -varValue "https://#{env_IIS}-users.api.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "UserBaseUrl" -varValue "https://users.api.coracare.name.com/"
# Set-OctopusVariable -environment "$null" -varName "PostLogoutRedirectUri" -varValue "https://#{env_IIS}-crm.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "PostLogoutRedirectUri" -varValue "https://crm.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "DocumentAPI" -varValue "https://document-api.vcrx.net/"
# Set-OctopusVariable -environment "$null" -varName "DocumentAPI" -varValue "https://#{env_aws}-document-api.lwr.vcrx.net/"
# Set-OctopusVariable -environment "PROD" -varName "PatientPortalBaselUrl" -varValue "https://api.name.com/"
# Set-OctopusVariable -environment "$null" -varName "PatientPortalBaselUrl" -varValue "https://api.#{env_IIS}.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "ServerName" -varValue "https://api.name.com/"
# Set-OctopusVariable -environment "$null" -varName "ServerName" -varValue "https://api.#{env_IIS}.name.com/"

# # Fax\Email
# Set-OctopusVariable -environment "$null" -varName "RequiredFaxFromAddress" -varValue "ccfax-dev@name.com"
# Set-OctopusVariable -environment "PROD" -varName "RequiredFaxFromAddress" -varValue "ccfax@name.com" 
# Set-OctopusVariable -environment "$null" -varName "PrescriptionFillsRedirect" -varValue "https://#{env_IIS}-crm.coracare.name.com/rx/fills"
# Set-OctopusVariable -environment "PROD" -varName "PrescriptionFillsRedirect" -varValue "https://crm.coracare.name.com/rx/fills"

# # File Paths ##
# Set-OctopusVariable -environment "PROD" -varName "SureScriptPorPdfOutputPath" -varValue "\\TWIN2\TXMD\FILES\CS\SureScriptInvalidProducts"
# Set-OctopusVariable -environment "$null" -varName "SureScriptPorPdfOutputPath" -varValue "C:\TXMD\FILES\CS\SureScriptInvalidProducts"
# Set-OctopusVariable -environment "PROD" -varName "TransferPdfFilePath" -varValue "\\TWIN2\TXMD\FILES\CS\TRANSFERPDFs"
# Set-OctopusVariable -environment "$null" -varName "TransferPdfFilePath" -varValue "C:\TXMD\FILES\CS\TRANSFERPDFs"
# Set-OctopusVariable -environment "PROD" -varName "RenewalPdfBasePath" -varValue "\\TWIN2\TXMD\FILES\CS"
# Set-OctopusVariable -environment "$null" -varName "RenewalPdfBasePath" -varValue "C:\TXMD\FILES\CS"
# Set-OctopusVariable -environment "PROD" -varName "Prescriptions.PorPdfPath" -varValue "\\TWIN2\TXMD\Files\CS\Prescriptions"
# Set-OctopusVariable -environment "$null" -varName "Prescriptions.PorPdfPath" -varValue "C:\TXMD\Files\CS\Prescriptions"
# Set-OctopusVariable -environment "PROD" -varName "Prescriptions.PorPdfArchivePath" -varValue "\\TWIN2\TXMD\Files\CS\PrescriptionsArchive"
# Set-OctopusVariable -environment "$null" -varName "Prescriptions.PorPdfArchivePath" -varValue "C:\TXMD\Files\CS\PrescriptionsArchive"
# Set-OctopusVariable -environment "PROD" -varName "Prescriptions.TransferPfdPath" -varValue  "\\TWIN2\TXMD\Files\CS\TRANSFERPDFs"
# Set-OctopusVariable -environment "$null" -varName "Prescriptions.TransferPfdPath" -varValue "C:\TXMD\Files\CS\TRANSFERPDFs"
# Set-OctopusVariable -environment "PROD" -varName "Receipts.BulkPrintingBasePath" -varValue "\\TWIN2\TXMD\Files\CS\OrderReceipts"
# Set-OctopusVariable -environment "$null" -varName "Receipts.BulkPrintingBasePath" -varValue "C:\TXMD\Files\CS\OrderReceipts"
# Set-OctopusVariable -environment "PROD" -varName "SureScriptRenewalPath" -varValue "\\LINK01\CCS\VITAMED\ORDERS\5728045"
# Set-OctopusVariable -environment "$null" -varName "SureScriptRenewalPath" -varValue "C:\TXMD\Files\CS\SureScriptRenewals"

# # Patient Portal Gateway
# Set-OctopusVariable -environment "$null" -varName "PatientPortal.SignupUrl" -varValue "https://my.#{env_IIS}.name.com/sign-up?token={0}"
# Set-OctopusVariable -environment "PROD" -varName "PatientPortal.SignupUrl" -varValue "https://my.name.com/sign-up?token={0}"
# Set-OctopusVariable -environment "PROD" -varName "PatientPortalGateway.BasedUrl" -varValue "https://gateway.api.coracare.name.com"
# Set-OctopusVariable -environment "$null" -varName "PastientPortalGateway.BasedUrl" -varValue "https://#{env_IIS}-gateway.api.coracare.name.com"
# Set-OctopusVariable -environment "PROD" -varName "ida:PatientPortalGateway.ClientId" -varValue "68b9930e-9c51-43a7-9ef1-7eafef57ac80"
# Set-OctopusVariable -environment "PATCH" -varName "ida:PatientPortalGateway.ClientId" -varValue "5c7a52cf-8cd9-4d00-b77f-9334969546a5"
# Set-OctopusVariable -environment "TACO,DEV,COFY,INT" -varName "ida:PatientPortalGateway.ClientId" -varValue "ae17e960-48ee-4ebb-ab89-9f4ab340c814"
# Set-OctopusVariable -environment "COFY" -varName "ida:PatientPortalGateway.ClientId" -varValue "ae17e960-48ee-4ebb-ab89-9f4ab340c814"
# Set-OctopusVariable -environment "TACO" -varName "ida:PatientPortalGateway.ClientId" -varValue "ae17e960-48ee-4ebb-ab89-9f4ab340c814"
# Set-OctopusVariable -environment "INT" -varName "ida:PatientPortalGateway.ClientId" -varValue "ae17e960-48ee-4ebb-ab89-9f4ab340c814"
# Set-OctopusVariable -environment "QA" -varName "ida:PatientPortalGateway.ClientId" -varValue "3802a41a-4595-4639-9fef-b75f6bba95d9"
# Set-OctopusVariable -environment "UAT" -varName "ida:PatientPortalGateway.ClientId" -varValue "4033ab3a-2000-4497-9531-643a85fc065a"
# Set-OctopusVariable -environment "PROD" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "u.et1ZGWJ6Ky4Vfjqps_2pjFL.g-.05rQ8"
# Set-OctopusVariable -environment "PATCH" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "73M4JMVg.8Sl5aHkF0C-H2s9l-aF4P~aR6"
# Set-OctopusVariable -environment "TACO,DEV,COFY,INT" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "BpDETJhOEXtXKJjNq-_6r31-v~21eiw10R"
# Set-OctopusVariable -environment "DEV" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "BpDETJhOEXtXKJjNq-_6r31-v~21eiw10R"
# Set-OctopusVariable -environment "COFY" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "BpDETJhOEXtXKJjNq-_6r31-v~21eiw10R"
# Set-OctopusVariable -environment "INT" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "BpDETJhOEXtXKJjNq-_6r31-v~21eiw10R"
# Set-OctopusVariable -environment "QA" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "J.zs_O.X1Jn-jH0FhBqblWF94~u-IlOgH5" 
# Set-OctopusVariable -environment "UAT" -varName "ida:PatientPortalGateway.ClientSecret" -varValue "yQRbEB0hJU_04~4M~oiR9_Ob~0I_fQ8sC5" 

# # Auth0
# Set-OctopusVariable -environment "PROD" -varName "Auth0.BasedUrl" -varValue "https://txmd-prod.auth0.com/"
# Set-OctopusVariable -environment "$null" -varName "Auth0.BasedUrl" -varValue "https://txmd-dev.auth0.com/"
# Set-OctopusVariable -environment "PROD" -varName "Auth0.ClientId" -varValue "pD3Cvhp9dcmGCf3O3xCx537904GmvLGj"
# Set-OctopusVariable -environment "$null" -varName "Auth0.ClientId" -varValue "XzT4Wp3HVrzGzCQDyUOHS7MV4jmwW9DY"
# Set-OctopusVariable -environment "PROD" -varName "Auth0.Connection"

# # BRAINTREE
# Set-OctopusVariable -environment "PROD" -varName "Environment" -varValue "PRODUCTION"
# Set-OctopusVariable -environment "$null" -varName "Environment" -varValue "SANDBOX"
# Set-OctopusVariable -environment "PROD" -varName  "MerchantId" -varValue "9z8nkf4zttfw425w"
# Set-OctopusVariable -environment "$null" -varName  "MerchantId" -varValue "br6w5h8r4yvq6tw9"
# Set-OctopusVariable -environment "PROD" -varName  "PublicKey" -varValue "fpcr8xx5gzhpg2rw"
# Set-OctopusVariable -environment "$null" -varName  "PublicKey" -varValue "d2y6wyj7w6qwnbtq"
# Set-OctopusVariable -environment "PROD" -varName  "PrivateKey" -varValue "9abc6dbc6d54d1a41f890e642032e7b2"
# Set-OctopusVariable -environment "$null" -varName  "PrivateKey" -varValue "b04ee6641ded8f3ee314f1fc644df58d"
# Set-OctopusVariable -environment "PROD" -varName  "MerchantAccount" -varValue "VPSvitaCarePrescriptionServicesLLC_instant"
# Set-OctopusVariable -environment "$null" -varName  "MerchantAccount" -varValue "therapeuticsmd"

# ## AD Auth
# Set-OctopusVariable -environment "PATCH" -varName "ida:ClientId" -varValue "e3858620-2bc1-4b55-8c21-63fb84d2c79e"
# Set-OctopusVariable -environment "PROD" -varName "ida:ClientId" -varValue "381a603b-33a0-4219-9b4b-0f0a2f09bb82"
# Set-OctopusVariable -environment "DEV" -varName "ida:ClientId" -varValue "0126e1fa-efa9-4026-b803-d4bead103147"
# Set-OctopusVariable -environment "COFY" -varName "ida:ClientId" -varValue "7a58301b-ca4d-4b5a-abe3-ffd00fa51a08"
# Set-OctopusVariable -environment "INT" -varName "ida:ClientId" -varValue "e3858620-2bc1-4b55-8c21-63fb84d2c79e"
# Set-OctopusVariable -environment "QA" -varName "ida:ClientId" -varValue "74963500-ee8c-441e-88cc-96b72644b8a5"
# Set-OctopusVariable -environment "TACO" -varName "ida:ClientId" -varValue "0f39609b-679e-4256-a401-f48268c26f36"
# Set-OctopusVariable -environment "UAT" -varName "ida:ClientId" -varValue "11633420-bb8d-4711-b22d-9f3a5af2cb8a"
# Set-OctopusVariable -environment "EXT" -varName "ida:ClientId" -varValue "b52015b4-59bb-4fce-95f8-0a090149fa37"
# Set-OctopusVariable -environment "TRAIN" -varName "ida:ClientId" -varValue ""
# Set-OctopusVariable -environment "$null" -varName "ida:PostLogoutRedirectUri" -varValue "https://#{env_IIS}-crm.coracare.name.com/"
# Set-OctopusVariable -environment "PROD" -varName "ida:PostLogoutRedirectUri" -varValue "https://crm.coracare.name.com/"

# ## 3rd Party keys/license info
# Set-OctopusVariable -environment "$null" -varName "APPortalLicenseKey" -varValue "125-RWAJR-MM75L-YDPCX-P7EP8-2VV8J"
# Set-OctopusVariable -environment "PROD" -varName "APPortalLicenseKey" -varValue "002-AJAJQ-5KYER-5RJ5F-YN8JS-N62GY"

# ## Constant Contact
# Set-OctopusVariable -environment "$null" -varName "ctct.accessToken" -varValue "54de01e9-42bd-4e4f-bcd4-39bb6edd6939"
# Set-OctopusVariable -environment "PROD" -varName "ctct.accessToken" -varValue "13e19ddf-dade-4282-b63b-3c2fb9fe2e64"
# Set-OctopusVariable -environment "$null" -varName "ctct.apiKey" -varValue "z68shf6envfwum9pg4d5575x"
# Set-OctopusVariable -environment "PROD" -varName "ctct.apiKey" -varValue "nuuht5vq8m2vrnzst66ces9r"
# Set-OctopusVariable -environment "$null" -varName "Testmode" -varValue "True"
# Set-OctopusVariable -environment "PROD" -varName "Testmode" -varValue "False"

# ## Serilog File Sink-
# Set-OctopusVariable -environment "$null" -varName "ApplicationLogger:serilog:minimum-level" -varValue "Information"
# Set-OctopusVariable -environment "PROD" -varName "ApplicationLogger:serilog:minimum-level" -varValue "Warning"
# Set-OctopusVariable -environment "$null" -varName "ApplicationLogger:serilog:write-to:File.restrictedToMinimumLevel" -varValue "Information"
# Set-OctopusVariable -environment "PROD" -varName "ApplicationLogger:serilog:write-to:File.restrictedToMinimumLevel" -varValue "Warning"-dataops-app

# ## For Different Namespaces - Set different logging levels 
# Set-OctopusVariable -environment "$null" -varName "serilog:minimum-level:override:Microsoft" -varValue "Information"
# Set-OctopusVariable -environment "PROD" -varName "serilog:minimum-level:override:Microsoft" -varValue "Warning"

# # ConnectionStrings
# Set-OctopusVariable -environment "$null" -varName "CustomerServicesConnectionString" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitamed;Integrated Security=SSPI;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "CustomerServicesConnectionString" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitamed;Integrated Security=SSPI;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaClaimsDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitaCLAIMS;integrated security=SSPI;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaClaimsDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaCLAIMS;integrated security=SSPI;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaScriptsDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitaSCRIPTS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaScriptsDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaSCRIPTS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaPrescriberDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitaPRESCRIBER;integrated security=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaPrescriberDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaPRESCRIBER;integrated security=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaMedDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitamed;integrated security=True;MultipleActiveResultSets=True;App=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaMedDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitamed;integrated security=True;MultipleActiveResultSets=True;App=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaViewsDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitaVIEWS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaViewsDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaVIEWS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "VitaDrugsDbContext" -varValue "data source=#{env_aws}-dataops-app.lwr.vcrx.net;initial catalog=vitaDRUGS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "PROD" -varName "VitaDrugsDbContext" -varValue "data source=dataops-app.vcrx.net;initial catalog=vitaDRUGS;integrated security=True;persist security info=True;multipleactiveresultsets=True;application name=EntityFramework;MultiSubnetFailover=True;"
# Set-OctopusVariable -environment "$null" -varName "hostName" -varValue "#{env_IIS}-crm.#{domain}"
# Set-OctopusVariable -environment "PROD" -varName "hostName" -varValue "crm.#{domain}"

## steps
## fix: envHost
## look for pre-deployment script
## attach variable sets
## run this script
## enable var transformation, look at clone proj