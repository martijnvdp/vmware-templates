# pip install -U selenium
# https://chromedriver.storage.googleapis.com/index.html?path=88.0.4324.96/
from selenium import webdriver
chromedriver = "/usr/sbin/chromedriver"
driver = webdriver.Chrome(chromedriver)
driver.get('https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019?filetype=ISO')
download = '//*[@id="btnRegisterWithFileTypes"]'
firstname_input = '//*[@id="marketoFirstName"]'
lastname_input = '//*[@id="marketoLastName"]'
company_input = '//*[@id="marketoCompany"]'
companysize_input = '//*[@id="marketoCompanySize"]'
jobtitle_input = '//*[@id="marketoJobTitle"]'
email_input = '//*[@id="marketoEmail"]'
phone_input = '//*[@id="marketoPhone"]'
country_input = '//*[@id="marketoCountry"]'
continue_input = '//*[@id="btnMarketoContinue"]'
language = '//*[@id="routingLangList"]'
download2 = '//*[@id="btnRoutingDownload"]'
driver.find_element_by_xpath(download).click()
driver.find_element_by_xpath(firstname_input).send_keys("somename")
driver.find_element_by_xpath(lastname_input).send_keys("somenlastame")
driver.find_element_by_xpath(company_input).send_keys("somecompany")
driver.find_element_by_xpath(companysize_input).send_keys("1")
driver.find_element_by_xpath(jobtitle_input).send_keys("a")
driver.find_element_by_xpath(email_input).send_keys("somemail@gmaleril.com")
driver.find_element_by_xpath(phone_input).send_keys("1234322123")
driver.find_element_by_xpath(country_input).send_keys("a")
driver.find_element_by_xpath(continue_input).click()
driver.find_element_by_xpath(language).send_keys("e")
driver.find_element_by_xpath(download2).click()
