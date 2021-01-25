# download webdriver.dll and browser driver from https://github.com/adamdriscoll/selenium-powershell/tree/master/assemblies
$selenium_path = $PSScriptRoot
Unblock-File $selenium_path\webdriver.dll

[System.Reflection.Assembly]::LoadFrom("{0}\WebDriver.dll" -f $selenium_path)
if ($env:Path -notcontains ";$selenium_path" ) {
    $env:Path += ";$selenium_path"
}

$ChromeOptions = New-Object OpenQA.Selenium.Chrome.ChromeOptions
$ChromeOptions.AddArgument('start-maximized')
$ChromeOptions.AcceptInsecureCertificates = $True
$Driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($ChromeOptions)
$Driver.Url = 'https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?filetype=ISO'
$download = '//*[@id="btnRegisterWithFileTypes"]'
$firstname_input = '//*[@id="marketoFirstName"]'
$lastname_input = '//*[@id="marketoLastName"]'
$company_input = '//*[@id="marketoCompany"]'
$companysize_input = '//*[@id="marketoCompanySize"]'
$jobtitle_input = '//*[@id="marketoJobTitle"]'
$email_input = '//*[@id="marketoEmail"]'
$phone_input = '//*[@id="marketoPhone"]'
$country_input = '//*[@id="marketoCountry"]'
$continue_input = '//*[@id="btnMarketoContinue"]'
$language = '//*[@id="routingLangList"]'
$download2 = '//*[@id="btnRoutingDownload"]'
$driver.FindElementByXPath($download).click()
$driver.FindElementByXPath($firstname_input).sendkeys("somename")
$driver.FindElementByXPath($lastname_input).sendkeys("somenlastame")
$driver.FindElementByXPath($company_input).sendkeys("somecompany")
$driver.FindElementByXPath($companysize_input).sendkeys("1")
$driver.FindElementByXPath($jobtitle_input).sendkeys("a")
$driver.FindElementByXPath($email_input).sendkeys("somemail@gmaleril.com")
$driver.FindElementByXPath($phone_input).sendkeys("1234322123")
$driver.FindElementByXPath($country_input).sendkeys("a")
$driver.FindElementByXPath($continue_input).click()
$driver.FindElementByXPath($language).sendkeys("e")
$driver.FindElementByXPath($download2).click()
