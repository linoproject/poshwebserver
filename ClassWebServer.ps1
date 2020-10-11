class WebServer{
    [string]$sBinding = "http://localhost:8080/"
    [object]$oListener
    [string]$sExt = ""


    WebServer(){
        $this.sExt = ""
        $this.Start()
    }

    WebServer([string]$sBinding){
        if (!$sBinding){
            $this.sBinding = $sBinding
        }
        $this.WebServer()
    }

    [void]Start(){
        $this.oListener = New-Object System.Net.HttpListener
        $this.oListener.Prefixes.Add($this.sBinding)
        $this.oListener.Start()
    }

    [void]Stop(){
        $this.oListener.stop()
        $this.oListener.close()

    }

    [string]Hello(){
        return "hello"
    }


    [string]GetQueryStringParam([object]$sRequest, [string]$sParamName){
        $aParams = $this.GetQueryString($sRequest)
        return $aParams.Value[$sParamName]
        
    }

    [string]getUri([object]$sRequest){
        return [URI]$sRequest.Url
    }

    [ref]GetQueryString([object]$sRequest){
        $uri = [URI]$sRequest.Url
	    $ParsedQueryString = [System.Web.HttpUtility]::ParseQueryString($uri.Query)
	    return $ParsedQueryString
    }
}