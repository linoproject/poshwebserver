<#
.Synopsis
Starts powershell webserver
.Description
Starts webserver as powershell process.
Some API Implemented
Call of /api/script uploads a powershell script and executes it (as a function).
Call of /log returns the webserver logs, /starttime the start time of the webserver, /time the current time.

You may have to configure a firewall exception to allow access to the chosen port, e.g. with:
  netsh advfirewall firewall add rule name="Powershell Webserver" dir=in action=allow protocol=TCP localport=8080

After stopping the webserver you should remove the rule, e.g.:
  netsh advfirewall firewall delete rule name="Powershell Webserver"
.Parameter BINDING
Binding of the webserver
.Inputs
None
.Outputs
None
.Example
Start-Webserver.ps1

Starts webserver with binding to http://localhost:8080/
.Example
Start-Webserver.ps1 "http://+:8080/"

Starts webserver with binding to all IP addresses of the system.
Administrative rights are necessary.
.Example
Project Idea and Firt Author: Markus Scholtes, 2016-10-22
Modified by: Lino Telera, 2017-08-29
#>
Import-Module -Force  "./ClassWebServer.ps1"
Import-Module -Force  "./Template.ps1"

[WebServer]$oWebServer = $NULL

try{

	# Check on argouments
	if ($args[0]){
		$oWebServer = [WebServer]::new($args[0])
	}else{
		$oWebServer = [WebServer]::new()
	}

	# Starting the powershell webserver
	"$(Get-Date -Format s) Starting powershell webserver..."
	$Error.Clear()

	$EXT = $oWebServer.sExt
	
    "$(Get-Date -Format s) Powershell webserver started."
	$WEBLOG = "$(Get-Date -Format s) Powershell webserver started.`n"
	$STARTTIME = "$(Get-Date -Format s)"
    while ($oWebServer.oListener.IsListening){
        # analyze incoming request
        $CONTEXT = $oWebServer.oListener.GetContext()
        $REQUEST = $CONTEXT.Request
        $RESPONSE = $CONTEXT.Response
        $RESPONSEWRITTEN = $FALSE

        # log to console
        "$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)"
        # and in log variable
        $WEBLOG += "$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)`n"

        # is there a fixed coding for the request?
        $RECEIVED = '{0} {1}' -f $REQUEST.httpMethod, $REQUEST.Url.LocalPath
        $HTMLRESPONSE = $HTMLRESPONSECONTENTS[$RECEIVED]
	      $RESULT = ''

        # check for known commands
        switch ($RECEIVED){
            "GET /" {	# Show default page
				$RESULT = '<h2>Welcome to PWSH Webserver </h2>'
            	break
			}
			
			"GET /api/script" {
				
				
				$sParamFilename= $oWebServer.GetQueryStringParam($REQUEST,"filename")# getQueryString -request $REQUEST
				$sParamParam = $oWebServer.GetQueryStringParam($REQUEST,"params")

			
				
    		    if (![STRING]::IsNullOrEmpty($sParamFilename)){
					
					
					try {
						$RESULT = Invoke-Expression -EA SilentlyContinue "pwsh -NonInteractive '$sParamFilename' $sParamParam" | Out-String
					}catch	{
						
						$RESPONSE.StatusCode = 404
						$RESULT = "<h1>Error executing script</h1><br>File: "+$sParamFilename+"<br> Params: " +$sParamParam
						Write-Host $_.Exception.Message
					}
				    $RESULT
					
				}
      	        break; 
			}

			"GET /api/connect_vcenter"{
				
				Connect-VIServer -Server $VC_SERVER -Username $VC_USER-Password -VC_PASSWORD -WarningAction SilentlyContinue
				$RESULT = '[{"Name":"Result","Value":"Connected"}]' #TODO Change here base on VC Login 
			}
			
			"GET /api/list_scripts"{

				$sPath = $oWebServer.GetQueryStringParam($REQUEST,"path")
				try{
					
					$aFiles = @(Get-ChildItem -Path $sPath -Force -Name -Include *.ps1) #Only script

					$RESULT = $aFiles | ConvertTo-Json -depth 1

				}catch{
					$RESPONSE.StatusCode = 404
					$RESULT = "<h1>Error executing list script</h1><br>Path: "+$ScriptPath
					Write-Host $_.Exception.Message
				}
				
				break;
			}

           
            "GET /log"{ 
                # return the webserver log (stored in log variable)
      	        $RESULT = $WEBLOG
      	        break
            }

            "GET /time"{ 
                # return current time
      	        $RESULT = Get-Date -Format s
      	        break
            }

            "GET /starttime"{ 
                $RESULT = "Server Started at "+$STARTTIME
      	        break
            }

            
			"GET /status"{ # stop powershell webserver, nothing to do here
				$RESULT = "Server is running since "+$STARTTIME
      	        break
			}
			
			"GET /quit"{ # stop powershell webserver, nothing to do here
				$RESULT = "Server Stopped at $(Get-Date -Format s)"
      	        break
            }

           
            default{	
 
                #Try to find page
                try {
            		$oWebServer.sExt = [IO.Path]::GetExtension($($PSScriptRoot + "/" + $($RECEIVED -replace "GET /")))
            		
            		$HTMLRESPONSE = [System.IO.File]::ReadAllText( $($PSScriptRoot + "/" + $($RECEIVED -replace "GET /") ))
            		
            		if ($oWebServer.sExt -eq ".gif"){
            			$HTMLRESPONSE = [System.IO.File]::ReadAllBytes( $($PSScriptRoot + "/" + $($RECEIVED -replace "GET /") ))
            		}
            		if ($oWebServer.sExt -eq ".jpg"){
            			$HTMLRESPONSE = [System.IO.File]::ReadAllBytes( $($PSScriptRoot + "/" + $($RECEIVED -replace "GET /") ))
            		}
            		
            		if ($oWebServer.sExt -eq ".png"){
            			$HTMLRESPONSE = [System.IO.File]::ReadAllBytes( $($PSScriptRoot + "/" + $($RECEIVED -replace "GET /") ))
            		}
            		
            		
                    
                     
		        }catch	{
                    "Service Error"
                    $RESPONSE.StatusCode = 404
					$HTMLRESPONSE = "<html><body><h1>File not found</h1></body></html>"
					Write-Host $_.Exception.Message
                }

            }

        }

		
        try{
			$BUFFER = [Text.Encoding]::UTF8.GetBytes($HTMLRESPONSE)
		} catch{
			
			$RESPONSE.StatusCode = 404
            $HTMLRESPONSE = "<html><body><h1>File not found</h1></body></html>"
		}
		
		#Write-Host $BUFFER

        # only send response if not already done
        if (!$RESPONSEWRITTEN -and $RESPONSE.StatusCode -eq 200){
 			       
    	    if ($oWebServer.sExt -ne ""){
    	    	
    	    	if ($oWebServer.sExt -eq ".html"){
    	    		
        			$RESPONSE.Headers.Add("Content-Type","text/html")
        		}
        		if ($oWebServer.sExt -eq ".js"){
        			
        			$RESPONSE.Headers.Add("Content-Type","application/javascript")
        		}
        		if ($oWebServer.sExt -eq ".css"){
        			
        			$RESPONSE.Headers.Add("Content-Type","text/css")
        		}
        		if ($oWebServer.sExt -eq ".html"){
        			
        			$RESPONSE.Headers.Add("Content-Type","text/html")
        		}
        		if ($oWebServer.sExt -eq ".gif"){
        			$BUFFER = $HTMLRESPONSE
        			$RESPONSE.Headers.Add("Content-Type","image/gif")
        		}
        		if ($oWebServer.sExt -eq ".jpg"){
        			$BUFFER = $HTMLRESPONSE
        			$RESPONSE.Headers.Add("Content-Type","image/jpg")
        		}
        		if ($oWebServer.sExt -eq ".png"){
        			$BUFFER = $HTMLRESPONSE
        			$RESPONSE.Headers.Add("Content-Type","image/png")
        		}
        		
        		
        	}else{
				
        		 # return HTML answer to caller
    	    	# insert header line string into HTML template
		   		$HTMLRESPONSE = $HTMLRESPONSE -replace '!HEADERLINE', $HEADERLINE
		    	# insert result string into HTML template
		   		$HTMLRESPONSE = $HTMLRESPONSE -replace '!RESULT', $RESULT
		   		$BUFFER = [Text.Encoding]::UTF8.GetBytes($HTMLRESPONSE)
        	}
    	    $oWebServer.sExt = ""
    	    $RESPONSE.StatusCode = 200
    	    
		}else{
			# In case of errors
			$HTMLRESPONSE = $HTMLRESPONSE -replace '!HEADERLINE', $HEADERLINE
			# insert result string into HTML template
			$HTMLRESPONSE = $HTMLRESPONSE -replace '!RESULT', $RESULT
			$BUFFER = [Text.Encoding]::UTF8.GetBytes($HTMLRESPONSE)
			$oWebServer.sExt = ""
    	    $RESPONSE.StatusCode = 200
		}
		
		
		$RESPONSE.ContentLength64 = $BUFFER.Length
    	$RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
		
	
        $RESPONSE.Close()

        
        if ($RECEIVED -eq 'GET /quit'){ # Here break the loop
    	    "$(Get-Date -Format s) Stopping powershell webserver..."
    	    break;
        }
    }
}catch{
	"WebServer General Error"
	Write-Host $_.Exception.Message
}finally{
	# Stop powershell webserver
	$oWebServer.Stop()
    "$(Get-Date -Format s) Powershell webserver stopped."
}

