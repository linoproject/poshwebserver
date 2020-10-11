# HTML answer templates for specific calls, placeholders !RESULT, !FORMFIELD, !PROMPT are allowed
$HTMLRESPONSECONTENTS = @{
'GET /'  =  @"
<html><body>
	!HEADERLINE
	<pre>!RESULT</pre>
"@ 

'GET /page'  =  @"
<html><body>!HEADERLINE</body></html>
"@

'GET /api/script'  =  @"
  !RESULT
"@

'GET /api/list_scripts'  =  @"
  !RESULT
"@

'GET /api/connect_vcenter'  =  @"
  !RESULT
"@

'GET /log'  =  @"
  !RESULT
"@

'GET /starttime'  =  @"
  !RESULT
"@

'GET /time'  =  @"
  !RESULT
"@

'GET /status'  =  @"
  !RESULT
"@

'GET /quit'  =  @"
  !RESULT
"@



}

$HEADERLINE = "<p> <a href='/log'>Web logs</a> <a href='/starttime'>Webserver start time</a> <a href='/time'>Current time</a> <a href='/quit'>Stop webserver</a></p>"

$VC_SERVER = "vc.yourdomain"
$VC_USER = "administrator@vsphere.local"
$VC_PASSWORD = "yourpassword"
