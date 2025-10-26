# Set-Proxy
# This function sets the system proxy settings for WinHTTP and Internet Explorer.
# This script modifies registry settings and uses netsh to configure proxy settings.
# Usage: Set-Proxy -ProxyServerIP "proxyserverIPAddress" -ProxyBypassList "<local>;*.domain.com"
# parameters:
#   -ProxyServerIP: The IP address of the proxy server.
#   -ProxyBypassList: A list of domains to bypass the proxy. Example: "<local>;*.domain.com"
# This script can be run as a standalone script or as a function within other scripts. 


function Set-Proxy {
    param (
        [string]$ProxyServerIP,
        [string]$ProxyBypassList
    )
    
    # Set proxy server addresses for HTTP and HTTPS
    $proxyServerHttp = "http://$proxyServerIP:8080"
    $proxyServerHttps = "https://$proxyServerIP:8443"
    
    # Set proxy settings for WinHTTP
    netsh winhttp set proxy $ProxyServerIP ";$ProxyBypassList"

    # Set proxy settings for Internet Explorer
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    Set-ItemProperty -Path $regPath -Name ProxyServer -Value $proxyServerHttp
    Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 1
    Set-ItemProperty -Path $regPath -Name ProxyOverride -Value $ProxyBypassList

    # Set proxy settings for HTTPS connections
    Set-ItemProperty -Path $regPath -Name SecureProxyServer -Value $proxyServerHttps
    Set-ItemProperty -Path $regPath -Name SecureProxyEnable -Value 1

    # Refresh environment variables
    $env:HTTP_PROXY = $proxyServerHttp
    $env:HTTPS_PROXY = $proxyServerHttps
}


# This can be run as a standalone script as well

# Prompt user for proxy server IP and bypass list
$ProxyServerIP = read-host "Enter Proxy Server IP Address (e.g., 192.168.1.1)"
$ProxyServerBypassList = read-host "Enter Proxy Bypass List (e.g., <local>;*.domain.com)"

# Set proxy server addresses for HTTP and HTTPS
$proxyServerHttp = "http://$proxyServerIP:8080"
$proxyServerHttps = "https://$proxyServerIP:8443"

# Set proxy bypass list (optional) 
$proxyBypassList = "$ProxyServerBypassList" 

# Set proxy settings for WinHTTP 
netsh winhttp set proxy $proxyServerHttp ";$proxyBypassList" 

# Set proxy settings for Internet Explorer 
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" 
Set-ItemProperty -Path $regPath -Name ProxyServer -Value $proxyServerHttp 
Set-ItemProperty -Path $regPath -Name ProxyEnable -Value 1 
Set-ItemProperty -Path $regPath -Name ProxyOverride -Value $proxyBypassList 

# Set proxy settings for HTTPS connections 
Set-ItemProperty -Path $regPath -Name SecureProxyServer -Value $proxyServerHttps 
Set-ItemProperty -Path $regPath -Name SecureProxyEnable -Value 1 

# Refresh environment variables 
$env:HTTP_PROXY = $proxyServerHttp 
$env:HTTPS_PROXY = $proxyServerHttps

