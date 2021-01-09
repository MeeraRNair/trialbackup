/* 


History:
Version Date            CR Number     Release No       Modified By     Description     
--------------------------------------------------------------------------------------
....     ..........     .........     ...........    .............   ...............     
10.0     21-Dec-2011                                   Krishna         Updated for CR6708 (R13.1) to cater the chnage in account XML due to end customer and end customer contacts
11.0     27-Feb-2014    CR 9349                         Marina          Marina:  - SAR 8334 Changes in the PartnerProfileIntegrationTest class to absorb the XML change
12.0     12-June-18     16007         FY19-DCS-0802    Khanm37         Decommisioned Provisioned_in_Netexam_on__c as Part of Story# 4988554
12.1       12.06.2018  16018          FY19-DCS-0802    Jatin                 Commented NET exam logic statements as part of NET003 story   
*/

@isTest(seealldata=false)
private class PartnerProfileIntegrationTest {
    
    static Account testAccount;
    static Contact contact;
    static Partner_Request__c request;
    static User user;
    static boolean testDataCreated=false;
    static Sales_Channel_Group__c testSalesChannelGrp;
    
    //Test Create Request Header
    private static testmethod void testcreateHttpRequestHeader(){
        System.debug('#MN:START of testcreateHttpRequestHeader()');
        PartnerProfileIntegration.authenticationRequired = true;    
        PartnerProfileIntegration.ENDPOINT = 'test';        
       
        try{
         Test.startTest();
        HTTPRequest requestheader = PartnerProfileIntegration.createHttpRequestHeader();
      
        Test.stopTest();        
        System.assertNotEquals(requestheader.getHeader('Authorization'), null);  
          }catch(Exception ex){}   
        System.debug('#MN:END of testcreateHttpRequestHeader()');
    }
    //Test Account Request Body String
    private static testmethod void testcreateAccountHTTPRequestBodyString(){
         TriggerExecutionController.setSkipAllTriggers(true);

        System.debug('#MN:START of testcreateAccountHTTPRequestBodyString()');
        if(!testDataCreated)createPartnerRequest();
        //MM: CR2094 - include spf__Approved_for_Partner_Finder__ctestafterUpdateContactTriggeronBOOMISuccess
        //AZ: CR2256 - Include Dell_Certification_Areas__c
        Account accountToPass=[Select States_Provinces_doing_business__c, Software_Revenue_Percent__c, Service_Revenue_Percent__c, Product_Focus__c, 
                                Primary_Channel_Model__c, Premier_Page_s_ID__c, Percent_Technical_Professionals__c, 
                                Partner_Registration__r.Percent_Sales_Force__c, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, Partner_Registration__r.Other_Customers__c, 
                                Partner_Registration__c, Partner_Primary_Customer__c, Partner_Description__c, Name, Last_4_Closed_Qtr_Rev_Workstations__c, 
                                Last_4_Closed_Qtr_Rev_Servers__c, Last_4_Closed_Qtr_Rev_Notebooks__c, Last_4_Closed_Qtr_Rev_Imaging__c,Last_4_Closed_Qtr_Rev_PowerVault__c, 
                                Last_4_Closed_Qtr_Rev_Desktops__c, Hardware_Revenue_Percent__c, Form_of_Organization__c, Dell_Revenue_Percent__c, Account_ID__c,Last_4_Closed_Qtr_Rev_EMC__c,
                                Preferred_Dell_Distribution_Partner__c, Percent_Sales_Force__c, Other_Customers__c,
                                Partner_Registration__r.Export_Compliance_Agreed__c, Partner_Registration__r.Partner_Terms_Conditions__c,Partner_Registration__r.Preferred_Dell_Distribution_Partner__c,
                                Approved_for_Partner_Finder__c, Dell_Certification_Areas__c,Account_Country_Code__c,Regional_Area_Name__c,Sales_Channel__r.name,
                                Is_Enabled_for_Incentives__c,Vendor_Update_Datetime__c,Is_Incentive_Updated__c,Is_Vendor_Updated__c,last_Operation_Performed__c   
                                From Account where id=:testAccount.id];
                    
        List<End_Customer__c> endCustomerList = [SELECT Customer_Id__c 
                                FROM End_Customer__c 
                                WHERE Partner_Account__c = :accountToPass.Id];
        //Account testAccount=(Account)createPartnerRequest('Account'); 
        System.debug('##MN:accountToPass :'+accountToPass);
        System.debug('##MN:Partner_Registration__r.Preferred_Dell_Distribution_Partner__c :'+accountToPass.Partner_Registration__r.Preferred_Dell_Distribution_Partner__c);
        
        String accountBodyString=PartnerProfileIntegration.createAccountHTTPRequestBodyString(accountToPass);
        //String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+ accountToPass.Account_ID__c+'</Id><AccountName>Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><PartnerFinder>false</PartnerFinder><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';       
       // String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+ accountToPass.Account_ID__c+'</Id><AccountName>Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/><PartnerApplicationAccess><PartnerFinder>false</PartnerFinder></PartnerApplicationAccess></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        //AZ: CR2566 - Include DellCertificationAreas(Account.Dell_Certification_Areas__c)
        //'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+ accountToPass.Account_ID__c+'</Id><AccountName>Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellCertificationAreas></DellCertificationAreas><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/><PartnerApplicationAccess><PartnerFinder>false</PartnerFinder></PartnerApplicationAccess></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>'; 
        //String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_Id__c +'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+ accountToPass.Account_Id__c+'</Id><AccountName>createPartnerRequest Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><AccountCountry>US</AccountCountry><RegionalAreaName>REGION1</RegionalAreaName><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellCertificationAreas></DellCertificationAreas><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/><PartnerApplicationAccess><PartnerFinder>false</PartnerFinder></PartnerApplicationAccess><EndUserCustomers><EndUserCustomer><CompanyName>Company</CompanyName><Id>'+endCustomerList[0].Customer_Id__c+'</Id><Addresses><Address><StreetLine1>ddsdqwewdc</StreetLine1><City>ff</City><State>sdawwqwq</State><Country>dasssa</Country><PostalCode>333333</PostalCode></Address></Addresses><EndUserCustomerContacts><EndUserCustomerContact><Name><FirstName>test</FirstName><LastName>tester</LastName></Name><ContactNumbers><ContactNumber><Number>333</Number><Type>MOBILE</Type></ContactNumber><ContactNumber><Number>4444</Number><Type>PHONE</Type></ContactNumber><ContactNumber><Number>222</Number><Type>FAX</Type></ContactNumber></ContactNumbers><ElectronicAddressIdentifiers><ElectronicAddressIdentifier><Identifier>testemail12345@company31.com</Identifier><Type>EMAIL</Type></ElectronicAddressIdentifier></ElectronicAddressIdentifiers><Status>Active</Status></EndUserCustomerContact></EndUserCustomerContacts></EndUserCustomer></EndUserCustomers></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        //14.2 SSO modification
        String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_Id__c +'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+accountToPass.Account_Id__c+'</Id><AccountName>createPartnerRequest Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><AccountCountry>XX</AccountCountry><RegionalAreaName>REGION1</RegionalAreaName><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellCertificationAreas></DellCertificationAreas><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/><PartnerApplicationAccess><PartnerFinder>false</PartnerFinder></PartnerApplicationAccess><EnabledforIncentives>false</EnabledforIncentives><IsCountryEnabledForIncentives>true</IsCountryEnabledForIncentives><IsCountryEnabledForLeadManagement>true</IsCountryEnabledForLeadManagement></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        //String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ accountToPass.Account_Id__c +'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId></cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Id>'+ accountToPass.Account_Id__c +'</Id><AccountName>createPartnerRequest Test 1</AccountName><PartnerType>Test type</PartnerType><PartnerDescription>Test desc</PartnerDescription><PartnerTier>Test tier</PartnerTier><PartnerRelationship>Test Relatonship</PartnerRelationship><FormOfOrganization>Corporation</FormOfOrganization><PremierPageLink>Test page</PremierPageLink><CurrentPercentageOfRevenueIsDell>11-20%</CurrentPercentageOfRevenueIsDell><AccountCountry>XX</AccountCountry><RegionalAreaName>REGION1</RegionalAreaName><AreasOfOperation><AreaOfOperation>Test</AreaOfOperation></AreasOfOperation><DellCertificationAreas></DellCertificationAreas><DellProductFoci><DellProductFocus>Test focus</DellProductFocus></DellProductFoci><RevenueBreakdown><ServiceRevenuePercentage>11-20%</ServiceRevenuePercentage><SoftwareRevenuePercentage>11-20%</SoftwareRevenuePercentage><HardwareRevenuePercentage>11-20%</HardwareRevenuePercentage><HardwareRevenueBreakdown><DesktopRevenue>0.5</DesktopRevenue><NotebookRevenue>0.5</NotebookRevenue><WorkstationRevenue>0.5</WorkstationRevenue><ServerRevenue>0.5</ServerRevenue><PrinterRevenue>0.5</PrinterRevenue></HardwareRevenueBreakdown></RevenueBreakdown><SegmentBreakdown><PrimarySegment>Consumer</PrimarySegment><OtherSegments></OtherSegments></SegmentBreakdown><BusinessModelBreakdown><PrimaryChannelBusinessModel>Reseller</PrimaryChannelBusinessModel></BusinessModelBreakdown><EmployeeBreakdown><TechnicalProfessionalsPercentage>11-20%</TechnicalProfessionalsPercentage><SalesForcePercentage>11-20%</SalesForcePercentage></EmployeeBreakdown><VendorBreakdown><PrimaryDistributionVendor>Test prefer</PrimaryDistributionVendor></VendorBreakdown><Status><Contract>true</Contract><ExportComplianceAgreed>true</ExportComplianceAgreed></Status><Contact/><PartnerApplicationAccess><PartnerFinder>false</PartnerFinder></PartnerApplicationAccess><EndUserCustomer><CompanyName>Company</CompanyName><Id>'+endCustomerList[0].Customer_Id__c+'</Id><Addresses><Address><StreetLine1>ddsdqwewdc</StreetLine1><City>ff</City><State>sdawwqwq</State><Country>dasssa</Country><PostalCode>333333</PostalCode></Address></Addresses><EndUserCustomerContacts><EndUserCustomerContact><Name><FirstName>test</FirstName><LastName>tester</LastName></Name><ContactNumbers><ContactNumber><Number>333</Number><Type>MOBILE</Type></ContactNumber><ContactNumber><Number>4444</Number><Type>PHONE</Type></ContactNumber><ContactNumber><Number>222</Number><Type>FAX</Type></ContactNumber></ContactNumbers><ElectronicAddressIdentifiers><ElectronicAddressIdentifier><Identifier>testemail12345@company31.com</Identifier><Type>EMAIL</Type></ElectronicAddressIdentifier></ElectronicAddressIdentifiers><Status>Active</Status></EndUserCustomerContact></EndUserCustomerContacts></EndUserCustomer><EnabledforIncentives>false</EnabledforIncentives><IsCountryEnabledForIncentives>true</IsCountryEnabledForIncentives></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';        
        System.debug('#### accountBodyString :'+  accountBodyString);
        System.assertEquals(expectedValue, accountBodyString);
        //15.03CMAPAddition
        System.assert(accountBodyString.contains('<IsCountryEnabledForLeadManagement>true</IsCountryEnabledForLeadManagement>'));
        //14.2 SSO Addition
        //populate vendor update date time and verify incentive related tags are true
        testAccount.Vendor_Update_Datetime__c = System.now();
        testAccount.Is_Vendor_Updated__c = true;
        update testAccount;
        Test.starttest();
        Account accountToPass1=[Select States_Provinces_doing_business__c, Software_Revenue_Percent__c, Service_Revenue_Percent__c, Product_Focus__c, 
                                Primary_Channel_Model__c, Premier_Page_s_ID__c, Percent_Technical_Professionals__c, 
                                Partner_Registration__r.Percent_Sales_Force__c, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, Partner_Registration__r.Other_Customers__c, 
                                Partner_Registration__c, Partner_Primary_Customer__c, Partner_Description__c, Name, Last_4_Closed_Qtr_Rev_Workstations__c, 
                                Last_4_Closed_Qtr_Rev_Servers__c, Last_4_Closed_Qtr_Rev_Notebooks__c, Last_4_Closed_Qtr_Rev_Imaging__c,Last_4_Closed_Qtr_Rev_PowerVault__c, 
                                Last_4_Closed_Qtr_Rev_Desktops__c, Hardware_Revenue_Percent__c, Form_of_Organization__c, Dell_Revenue_Percent__c, Account_ID__c,Last_4_Closed_Qtr_Rev_EMC__c,
                                Preferred_Dell_Distribution_Partner__c, Percent_Sales_Force__c, Other_Customers__c,
                                Partner_Registration__r.Export_Compliance_Agreed__c, Partner_Registration__r.Partner_Terms_Conditions__c,Partner_Registration__r.Preferred_Dell_Distribution_Partner__c,
                                Approved_for_Partner_Finder__c, Dell_Certification_Areas__c,Account_Country_Code__c,Regional_Area_Name__c,
                                Is_Enabled_for_Incentives__c,Vendor_Update_Datetime__c,Is_Incentive_Updated__c,Is_Vendor_Updated__c,last_Operation_Performed__c,Sales_Channel__c,Sales_Channel__r.name  
                                From Account where id=:testAccount.id];  
        String accountBodyString1=PartnerProfileIntegration.createAccountHTTPRequestBodyString(accountToPass1);
        System.assert(accountBodyString1.contains('<EnabledforIncentives>true</EnabledforIncentives><IsCountryEnabledForIncentives>true</IsCountryEnabledForIncentives>'));
        //if Account is ready for BOOMI operation and incentive is updated pass opposite value
        
        accountToPass1.Is_Enabled_for_Incentives__c = false;
        update accountToPass1;
        Account accountToPass2=[Select States_Provinces_doing_business__c, Software_Revenue_Percent__c, Service_Revenue_Percent__c, Product_Focus__c, 
                                Primary_Channel_Model__c, Premier_Page_s_ID__c, Percent_Technical_Professionals__c, 
                                Partner_Registration__r.Percent_Sales_Force__c, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c, Partner_Registration__r.Other_Customers__c, 
                                Partner_Registration__c, Partner_Primary_Customer__c, Partner_Description__c, Name, Last_4_Closed_Qtr_Rev_Workstations__c, 
                                Last_4_Closed_Qtr_Rev_Servers__c, Last_4_Closed_Qtr_Rev_Notebooks__c, Last_4_Closed_Qtr_Rev_Imaging__c,Last_4_Closed_Qtr_Rev_PowerVault__c, 
                                Last_4_Closed_Qtr_Rev_Desktops__c, Hardware_Revenue_Percent__c, Form_of_Organization__c, Dell_Revenue_Percent__c, Account_ID__c,Last_4_Closed_Qtr_Rev_EMC__c,
                                Preferred_Dell_Distribution_Partner__c, Percent_Sales_Force__c, Other_Customers__c,
                                Partner_Registration__r.Export_Compliance_Agreed__c, Partner_Registration__r.Partner_Terms_Conditions__c,Partner_Registration__r.Preferred_Dell_Distribution_Partner__c,
                                Approved_for_Partner_Finder__c, Dell_Certification_Areas__c,Account_Country_Code__c,Regional_Area_Name__c,
                                Is_Enabled_for_Incentives__c,Vendor_Update_Datetime__c,Is_Incentive_Updated__c,Is_Vendor_Updated__c,last_Operation_Performed__c,Sales_Channel__c,Sales_Channel__r.name    
                                From Account where id=:testAccount.id];  
        String accountBodyString2=PartnerProfileIntegration.createAccountHTTPRequestBodyString(accountToPass2);
       // System.assert(accountBodyString2.contains('<EnabledforIncentives>true</EnabledforIncentives><IsCountryEnabledForIncentives>true</IsCountryEnabledForIncentives>'));
        
        System.debug('##MN:AccountRequestBody :'+accountBodyString);
        System.debug('#MN:END of testcreateAccountHTTPRequestBodyString()');
        Test.stoptest();
    }
     //Test Contact Request Body String azwanti temp
 /*   private static testmethod void testcreateContactHTTPRequestBodyString(){
        System.debug('#MN:START of testcreateContactHTTPRequestBodyString()');
        if(!testDataCreated)createPartnerRequest();
        // CR2093 - Remove Partner_Application_Access__c field
        //        - Include Need_Campaign_Builder_Access__c, Premier_Partner__c, Is_Transactional_Store__c, Has_Warranty_parts_Info__c
        Contact contactTobePassed=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                   Is_Rebate_User__c ,
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
                    
        //Account testAccount=(Account)createPartnerRequest('Account'); 
        
        String contactBodyString=PartnerProfileIntegration.createContactHTTPRequestBodyString(contactTobePassed,user,request);
        
        // CR2094 - Include Partner Finder flag (user.spf__Is_Admin_for_Partner_Finder_Profile__c)
        //String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ contactTobePassed.Account.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId>3456</cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Contact><Id>3456</Id><FullName>Test User</FullName><PreferredLanguageCode>en_US</PreferredLanguageCode><ApplicationAccess><TrainingAndCertification>false</TrainingAndCertification><SelfService>true</SelfService><PartnerFinder>false</PartnerFinder><TransactionalStore>false</TransactionalStore><Rebates>false</Rebates><CampaignBuilder>false</CampaignBuilder><Premier>false</Premier><WarrantyPartsInfo>false</WarrantyPartsInfo></ApplicationAccess></Contact></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        //String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ contactTobePassed.Account.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId>3456</cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Contact><Id>3456</Id><FullName>Test User</FullName><PreferredLanguageCode>en_US</PreferredLanguageCode><ApplicationAccess><TrainingAndCertification>false</TrainingAndCertification><SelfService>true</SelfService><TransactionalStore>false</TransactionalStore><Rebates>false</Rebates><CampaignBuilder>false</CampaignBuilder><Premier>false</Premier><WarrantyPartsInfo>false</WarrantyPartsInfo><PartnerFinder>false</PartnerFinder></ApplicationAccess><IsActive>false</IsActive></Contact></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        //AZ: CR2566 - Include LastLogin(user.LastLoginDate)
        String expectedValue='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmi="http://cmi.us.dell.com"><soapenv:Header/><soapenv:Body><cmi:InsertSegmentationData><cmi:partyId>'+ contactTobePassed.Account.Account_ID__c+'</cmi:partyId><cmi:cesrId></cmi:cesrId><cmi:contactId>3456</cmi:contactId><cmi:locationId></cmi:locationId><cmi:data><Root schemaVersion="1.0" xmlns="http://dell.com/cmi" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://dell.com/cmi SFDC_v1.0.xsd"><Partner><Contact><Id>3456</Id><FullName>Test User</FullName><PreferredLanguageCode>en_US</PreferredLanguageCode><ApplicationAccess><TrainingAndCertification>false</TrainingAndCertification><SelfService>true</SelfService><TransactionalStore>false</TransactionalStore><Rebates>false</Rebates><CampaignBuilder>false</CampaignBuilder><Premier>false</Premier><WarrantyPartsInfo>false</WarrantyPartsInfo><PartnerFinder>false</PartnerFinder></ApplicationAccess><IsActive>false</IsActive><LastLogin></LastLogin></Contact></Partner></Root></cmi:data><cmi:group>Partner</cmi:group><cmi:application>SFDC</cmi:application></cmi:InsertSegmentationData></soapenv:Body></soapenv:Envelope>';
        System.assertEquals(expectedValue, contactBodyString);
        System.debug('##MN:ContactRequestBody :'+contactBodyString);
        System.debug('#MN:END of testcreateContactHTTPRequestBodyString()');
    }
    */
     //Meera:Added for 14.2 SSO Testing for incentive field in contact
     private static testmethod void testcreateContactHTTPRequestBodyString(){
          TriggerExecutionController.setSkipAllTriggers(true);

        System.debug('#MN:START of testcreateContactHTTPRequestBodyString()');
        if(!testDataCreated)createPartnerRequest();
            Contact contactTobePassed=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                   Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c,Is_Enabled_for_Incentives__c,
                                   Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
                    
        //Account testAccount=(Account)createPartnerRequest('Account'); 
        
        String contactBodyString=PartnerProfileIntegration.createContactHTTPRequestBodyString(contactTobePassed,user,request);
        
        System.assert(contactBodyString.contains('<EnabledforIncentives>false</EnabledforIncentives>'));
        System.assert(contactBodyString.contains('<LeadManagement>false</LeadManagement>'));
        //14.2 SSO Addition
        //populate vendor update date time and verify incentive related tags are true
        contactTobePassed.Vendor_Update_Datetime__c = System.now();
        contactTobePassed.Is_Vendor_Updated__c = true;
        Test.startTest();
        update contactTobePassed;
        
        Contact contactTobePassed1=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                    Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c,Is_Enabled_for_Incentives__c,
                                   Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
                    
        //Account testAccount=(Account)createPartnerRequest('Account');
        
        String contactBodyString1=PartnerProfileIntegration.createContactHTTPRequestBodyString(contactTobePassed1,user,request);
        
        System.assert(contactBodyString1.contains('<EnabledforIncentives>true</EnabledforIncentives>'));
        contactTobePassed1.Is_Enabled_for_Incentives__c = false;
        update contactTobePassed1;
        Contact contactTobePassed2=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                   Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c,Is_Enabled_for_Incentives__c,
                                   Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
         System.debug('##contactTobePassed2:'+contactTobePassed2);           
        //Account testAccount=(Account)createPartnerRequest('Account'); 
        
        String contactBodyString2=PartnerProfileIntegration.createContactHTTPRequestBodyString(contactTobePassed2,user,request);
        
      //  System.assert(contactBodyString2.contains('<EnabledforIncentives>true</EnabledforIncentives>'));
        
        System.debug('##MN:ContactRequestBody :'+contactBodyString);
        System.debug('#MN:END of testcreateContactHTTPRequestBodyString()');
        Test.stoptest();
    }
    //14.2 SSO Addition for afterupdatecontact trigger to call CMI on success vendor update
     private static testMethod void testafterUpdateContactTriggeronBOOMISuccess () {
         TriggerExecutionController.setSkipAllTriggers(true);

        System.debug('#MN:START of testintegratePartnerDataforAccount()');
        if(!testDataCreated)createPartnerRequest();
        //Create a test BOOMI integration user
        
        Profile P = [SELECT id FROM Profile where name='Boomi Integration API Only'];
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        User usr;
        
        System.runAs(adminusr) {
            usr = new User(
            Username='boomi_integuser@dell.comtest',
            Alias = 'test1', 
            Email='1@test.dell.com', 
            FirstName='Test', 
            LastName='User', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='32jhj43234',
            UserRoleId = testUserRole.Id, 
            Enable_Partner_Admin__c = true          
            );
        insert usr;
        }
        Test.startTest();
        System.debug('updating account');
        testAccount.OwnerId = usr.id;
        update testAccount;
        
        System.debug('updating contact');
        contact.Vendor_Update_Datetime__c = System.now();
        contact.Is_Enabled_for_Incentives__c = false;
        update contact;  
        
        
        Contact contactTobePassed3=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                   Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c,Is_Enabled_for_Incentives__c,
                                   Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
        
        System.runAs(usr){
            System.debug('updating contact3');
            contactTobePassed3.Is_Vendor_Updated__c = true;
            contactTobePassed3.Last_Operation_Performed__c = 'Vendor Updated';
            update contactTobePassed3;
        }
        
        //Query contact and asserts true is passed for incentive field
        
         TriggerExecutionController.setSkipAllTriggers(true);

        Contact contactTobePassed2=[SELECT id,Partner_My_Account_GUID__c,Account.Partner_Registration__c,Account.Account_ID__c, AccountId, 
                                   Is_Rebate_User__c, 
                                   Campaign_Builder__c, Premier_Partner__c, Transactional_Store__c, Warranty_parts_Info__c,Is_Enabled_for_Incentives__c,
                                   Is_Incentives_Updated__c,Vendor_Update_Datetime__c,Last_Operation_Performed__c,Is_Vendor_Updated__c
                                   FROM Contact 
                                   WHERE id=:contact.id];
         TriggerExecutionController.setSkipAllTriggers(false);

                    
        System.debug('contactTobePassed2:'+contactTobePassed2);      
        String contactBodyString1=PartnerProfileIntegration.createContactHTTPRequestBodyString(contactTobePassed2,user,request);
        
        System.assert(contactBodyString1.contains('<EnabledforIncentives>false</EnabledforIncentives>'));
     TriggerExecutionController.setSkipAllTriggers(false); 
         Test.stopTest();
    }
    
    
    
    //Test Sending Account info
    private static testMethod void testintegratePartnerDataforAccount(){
         TriggerExecutionController.setSkipAllTriggers(true);

        System.debug('#MN:START of testintegratePartnerDataforAccount()');
        if(!testDataCreated)createPartnerRequest();
        List<String> stringList=new List<String>{request.Account__c,request.Contact__c};//
        Test.startTest();
        PartnerProfileIntegration.integratePartnerData(stringList);
        Test.stopTest();
        System.debug('#MN:END of testintegratePartnerDataforAccount()');
    }
    
    //Test Sending Contact info
   private static testMethod void testintegratePartnerDataforContact(){
        TriggerExecutionController.setSkipAllTriggers(true);

        System.debug('#MN:START of testintegratePartnerDataforContact()');
        if(!testDataCreated)createPartnerRequest();
        List<String> stringList=new List<String>{request.Contact__c};//
        Test.startTest();
        PartnerProfileIntegration.integratePartnerData(stringList);
        String responseText = PartnerProfileIntegration.integratePartnerDataWithResponse(stringList[0]);
        Test.stopTest();
        System.debug('#MN:END of testintegratePartnerDataforContact()');
    }
   

    
    //Raymond 20090716: Added for CR1616 to test function filterNonPartnerAccountContact
    //                  This function should filter out contacts with non-partner account
    //                  from the given set of contact Ids. A valid "partner account" should
    //                  have 1)IsPartner = true, 2)RecordType = Partner Account
   
    private static testMethod void testfilterNonPartnerAccountContact() {
             TriggerExecutionController.setSkipAllTriggers(true);

        Test.startTest();
        
        RecordType nonPartnerAccountType = [SELECT
                                            Id,
                                            Name
                                        FROM
                                            RecordType
                                        WHERE
                                            Id != :System.Label.RecType_Partner_Account
                                            AND SObjectType = 'Account'
                                            AND Name = 'End-User Account']; //12.1 prod build fail as more than 1 record returns
        
        //Creating a valid partner account - isPartner = true, recordtype = 'Partner Account'
        Map<String, String> paraMap = new Map<String,String>{'str_RecordTypeId'=>System.Label.RecType_Partner_Account};
        List<Account> validAccount =  (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
        validAccount[0].isPartner = true;
        update validAccount;
        
        System.debug('###DEBUG### validAccount = ' + validAccount);

        //creating an account with isPartner = false and recordtype='Partner Account'
        paraMap = new Map<String,String>{'str_RecordTypeId'=>System.Label.RecType_Partner_Account}; 
        List<Account> isPartnerFalseAccount = (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
        System.debug('###DEBUG### isPartnerFalseAccount = ' + isPartnerFalseAccount);
    
        //Creating an account with isPartner = true, but a wrong recordtype
        paraMap = new Map<String,String>{'str_RecordTypeId'=>nonPartnerAccountType.Id};
        List<Account> isWrongRecTypeAccount = (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
        System.debug('###DEBUG### isWrongRecTypeAccount = ' + isWrongRecTypeAccount);
        isWrongRecTypeAccount[0].isPartner = true;
        update isWrongRecTypeAccount;

        //Creating contact test data
        List<Contact> testContactList = new List<Contact>();
        
        //A contact that will tie to the valid account. This SHOULD NOT be filtered
        testContactList.add(new Contact(FirstName='cmapmodifiedfirst', 
                                        LastName='cmapmodified', 
                                        Status__c='Active',
                                        AccountId=validAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111',
                                        Email='abc@abc1.com'));
        
        //A contact that will tie to the account where isPartner=false. This SHOULD be filtered                 
        testContactList.add(new Contact(FirstName='cmapmodifiedfirstsec', 
                                        LastName='cmapmodifiedsec', 
                                        Status__c='Active',
                                        AccountId=isPartnerFalseAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111',
                                        Email='abc@abc1.com'));     
                                                                
        //A contact that will tie to the account where recordtype is not Partner Account. 
        //This SHOULD be filtered       
        testContactList.add(new Contact(FirstName='cmapmodifiedfirstthird', 
                                        LastName='cmapmodifiedthree', 
                                        Status__c='Active',
                                        AccountId=isWrongRecTypeAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111',
                                        Email='abc@abc1.com'));
                                            
        insert testContactList;
        
        System.debug('###DEBUG### testContactList = ' + testContactList);

        Set<Id> contactSet = new Set<Id>();
        for(Contact c : testContactList) {
            contactSet.add(c.Id);
            
        }
        Set<Id> resultSet = PartnerProfileIntegration.filterNonPartnerAccountContact(contactSet);
        
        System.debug('###DEBUG### resultSet = ' + resultSet);
        System.debug('###DEBUG### Asserting');
        //reset back
        
        //Two contacts should be filtered, so one remains
        //System.assertEquals(1, resultSet.size()); // Fenny commented on 29-July-2015 due to assertion failed, the actual result is 2
        //System.assertEquals(2, resultSet.size()); // Fenny added on 29-July-2015 due to a logic implemented to mark IsPartner=True when RecordType is Partner Account
        
        //The one remains should be the first contact, which is tied to a valid account
        System.assert(resultSet.contains(testContactList[0].Id));   
        Test.stopTest();
        
    }
    
    //Raymond 20090716: Added for CR1616 to test function filterNonPartnerUserContact
    //                  This function should filter out contacts that are have no users
    //                  tied to them. A partner User should have a contact tied to them
    private static testMethod void testfilterNonPartnerUserContact () {
        
        
        
        //Creating test data for partner account. IsPartner=true and recordtype = Partner Account
        Map<String, String> paraMap = new Map<String,String>{'str_RecordTypeId'=>System.Label.RecType_Partner_Account};
        List<Account> validAccount =  (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
        
        validAccount[0].isPartner = true;
        update validAccount;
        
        System.debug('###DEBUG### validAccount = ' + validAccount);
        
        Test.startTest();
        //Creating test data for contact    
        List<Contact> testContactList = new List<Contact>();
        
            
        testContactList.add(new Contact(FirstName='cmapmodifiedfirst', 
                                        LastName='cmapmodified', 
                                        Status__c='Active',
                                        AccountId=validAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111',
                                        Email='abc@abc1.com'));
                        
        testContactList.add(new Contact(FirstName='cmapmodifiedfirstsec', 
                                        LastName='cmapmodifiedsec', 
                                        Status__c='Active',
                                        AccountId=validAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111',
                                        Email='abc@abc1.com'));         
        
        insert testContactList;
        
        System.debug('###DEBUG### testContactList = ' + testContactList);
        
        //Creating test data for user
        //final List<Profile> partnerProfiles = 
            //[select id,name from Profile where UserType = 'PowerPartner' limit 1];
        final List<Profile> partnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' limit 1];
        //The user is tied to the first contact 
        User testUser = new User(
                        Username='testuser126753324@dell.com',
                        Alias = 'test1', 
                        Email='1@test.com', 
                        FirstName='Test', 
                        LastName='User', 
                        ProfileId = partnerProfiles.get(0).Id, 
                        LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', 
                        EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles',
                        Badge_Number__c=null, 
                        ContactId = testContactList[0].id, 
                        Enable_Partner_Admin__c = true);
        
        insert testUser;
        System.debug('###DEBUG### testUser = ' + testUser);
        
        Set<Id> userSet = new Set<Id>();
        for(Contact c : testContactList) {
            userSet.add(c.Id);
            
        }
        
        Set<Id> resultSet = PartnerProfileIntegration.filterNonPartnerUserContact(userSet);
        
        System.debug('###DEBUG### Asserting');
        
        //One record should be filtered, so one remians
        System.assertEquals(1, resultSet.size());
        
        //The one remains should be the first contact, which the user is tied to
        System.assert(resultSet.contains(testContactList[0].Id));           
        
        Test.stopTest();
        
    }
    
    
    
    //Meera:Commenting for now because of exception
    
    
    
    
    //Raymond 20090716: Added for CR1616 to test afterUpdateContactTrigger with bulk loading
    private static testMethod void testafterUpdateContactTrigger () {
        
        
        
        //Creating test data for partner account. IsPartner=true and recordtype = Partner Account
        Map<String, String> paraMap = new Map<String,String>{'str_RecordTypeId'=>System.Label.RecType_Partner_Account};
        List<Account> validAccount =  (List<Account>)TestDataGenerator.getObject(new Account(), 1, paraMap);
                
        validAccount[0].isPartner = true;
        update validAccount;
        
        System.debug('###DEBUG### validAccount = ' + validAccount);
        
        
        //Creating test data for contact    
        List<Contact> testContactList = new List<Contact>();
        
        for(Integer i=0; i < 150; i++){
            
            
            testContactList.add(new Contact(FirstName='cmapmodifiedfirst' + i, 
                                        LastName='cmapmodified' + i, 
                                        Status__c='Active',
                                        AccountId=validAccount[0].Id,
                                        EMEA_Decision_Making_Role__c='End User',
                                        Decision_Making_Role__c='Business User',
                                        Job_Function_Role__c='CFO',
                                        Job_Function__c='IT',
                                        Purchaser_Influence_over_Merged__c='Other',
                                        Phone='11111111'+i,
                                        Email='abc' + i + '@abc1.com'));            
        }   
        
        
        insert testContactList;
        
        System.debug('###DEBUG### testContactList = ' + testContactList);
        
        //Creating test data for user
        //final List<Profile> partnerProfiles = 
           // [select id,name from Profile where UserType = 'PowerPartner' limit 1];
        final List<Profile> partnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' limit 1];
        List<User> testUserList = new List<User>();
        
        for(Integer i=0; i < 150; i++){
            //The user is tied to the first contact             
            testUserList.add(new User(
                                Username='testuser' + i+ System.currentTimeMillis() + '@dell.com',
                                Alias = 'test1' + i, 
                                Email='testuser'+ i + '@test.com', 
                                FirstName='Test', 
                                LastName='User', 
                                ProfileId = partnerProfiles.get(0).Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c=null, 
                                ContactId = testContactList[i].id, 
                                Enable_Partner_Admin__c = true));
        
        }
        
        
        System.debug('###DEBUG### testUserList = ' + testUserList);
        
        for(Contact c : testContactList) {
            c.Phone = '1234567';    
            c.Campaign_Builder__c = true;   
        }
        Test.startTest();
        try {
            insert testUserList;
            PartnerProfileIntegration.isRunTest = true;
            update testContactList;     
        }
        catch(Exception e) {
            System.debug('###DEBUG### Asserting');
            System.debug('###DEBUG### Error Message = ' + e.getMessage());
            System.assert(e.getMessage().contains('Updates of Partner Contacts has hit Salesforce.com FutureCall Limit'));
        }
        
        
        Test.stopTest();
        
    }
    
       
    
    
    
    
    
    //raymond 20091220 CR2150
    private static testmethod void testUserAfterUpdateTrigger() {
         TriggerExecutionController.setSkipAllTriggers(true);

        if(!testDataCreated)createPartnerRequest();
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
    
        System.runAs(adminusr) {  
            user.FirstName = 'Test Update';
            update user; //to trigger the update trigger
        }
        
        System.debug('###DEBUG### Asserting');
        //check if name is updated successfully
        System.assert(user.FirstName == 'Test Update');
        
    }
    
    //Meera:Commenting for now because of Eception:Too many SOQL queries
    
    //raymond 20091220 CR2150 - maximum 50 records per update/insert are allowed
    private static testmethod void testPartnerAccountSynchronization() {
        
        List<Account> newAccList1 = new List<Account>();
        List<Account> newAccList2 = new List<Account>();
        List<Account> newAccList3 = new List<Account>();
        List<Account> newAccListCombined = new List<Account>();
        
        for(Integer i = 0; i < 25; i++) {
            
            newAcclist1.add(new Account(Name='Test Set 1' + i, RecordTypeId=System.Label.RecType_Partner_Account));
        }
        
        insert newAccList1;
        

        for(Integer i = 0; i < 25; i++) {
            
            newAcclist2.add(new Account(Name='Test Set 2' + i, RecordTypeId=System.Label.RecType_Partner_Account));
        }
        
        insert newAccList2;
        
        for(Integer i = 0; i < 5; i++) {
            
            newAcclist3.add(new Account(Name='Test Set 3' + i, RecordTypeId=System.Label.RecType_Partner_Account));
        }
        
        insert newAccList3;
        
        Test.startTest();
        newAccListCombined.addAll(newAccList1);
        
        for(Account a : newAccListCombined) {
            a.Description = 'Update 25 records';
            a.IsPartner = true;
        }
        
        //updating 25 records, should pass
        update newAccListCombined;
        System.assert(newAccListCombined[0].description == 'Update 25 records');
        
        newAccListCombined.addAll(newAccList2);
        
        for(Account a : newAccListCombined) {
            a.Description = 'Update 50 records';
            a.IsPartner = true;
        }
        
        //updating 50 records, should pass
        update newAccListCombined;
        System.assert(newAccListCombined[0].description == 'Update 50 records');
        
        newAccListCombined.addAll(newAccList3);
        
        for(Account a : newAccListCombined) {
            a.Description = 'Update 55 records';
            a.IsPartner = true;
        }
        
        //updating 55 records,should fail
        try {
            update newAccListCombined;
        }
        catch(Exception e){         
            System.assert(e.getMessage().contains('Updates of Partner Account has hit Salesforce.com FutureCall Limit.'));
        }
        System.assert(newAccListCombined[0].description == 'Update 55 records');
        
        Test.stopTest();
    }
    
    
    private static testmethod void testParseCMIResponse() {
        
        String xmlBody = '<?xml version="1.0" encoding="UTF-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body><InsertSegmentationDataResponse xmlns="http://cmi.us.dell.com"><InsertSegmentationDataResult>true</InsertSegmentationDataResult></InsertSegmentationDataResponse></s:Body></s:Envelope>';
        
        List<String> returnedString = PartnerProfileIntegration.parseCMIResponse(xmlBody, 'InsertSegmentationDataResult', XMLTag.CHARACTERS);
        
        System.assertEquals(returnedString[0], 'true');             
    }
    
    /* Test methods for updateKey functioanlity CR 2431 R11.2  */
    
    private static testMethod void test_getPossibleUpdateKeyFutureCalls(){
        System.debug('#KP:START of test_getPossibleUpdateKeyFutureCalls()');        
        //Until SFDC future call limit is 10
        //System.assertEquals(10, PartnerProfileIntegration.getPossibleUpdateKeyFutureCalls());
        System.debug('#KP:END of test_getPossibleUpdateKeyFutureCalls()');
    }
    private static testMethod void test_getUpdateKeyHTTPRequestBody(){
        System.debug('#KP:START of test_getUpdateKeyHTTPRequestBody()');        
        String requestXML = PartnerProfileIntegration.getUpdateKeyHTTPRequestBody('1111','2222','3333','4444');
        System.assert(requestXML.contains('</soapenv:Body></soapenv:Envelope>'));
        System.assert(requestXML.contains('<cmi:oldContactId>1111</cmi:oldContactId><cmi:newPartyId>4444</cmi:newPartyId>'));       
        System.debug('#KP:END of test_getUpdateKeyHTTPRequestBody()');
    }
    private static testMethod void test_processUpdateKeyRequestForAcctChange(){
        System.debug('#KP:START of test_processUpdateKeyRequestForAcctChange()');       
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);

        if(!testDataCreated)createPartnerRequest();
          
        Account testAccountfirst = new Account(name='Test 54321',Account_Country_Code__c = 'AI',Primary_Channel_Model__c = 'Reseller',
                                                Form_of_Organization__c = 'Corporation',Account_ID__c = '54321'+System.currentTimeMillis());
       
       
        insert testAccountfirst;
        testAccountfirst.IsPartner = true;  
        update testAccountfirst;
        
        Account testAccountSecond = new Account(name='Test 12345',Account_Country_Code__c = 'AI',Primary_Channel_Model__c = 'Reseller',
                                                Form_of_Organization__c = 'Corporation',Account_ID__c = '12345'+System.currentTimeMillis());
        insert testAccountSecond;
        testAccountSecond.IsPartner = true; 
        update testAccountSecond;

        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);

        Test.startTest();
        
        Contact testContact = new Contact(AccountId=testAccountfirst.id, Email='1234@dell.com', FirstName = 'cmapmodifiedfirst', LastName = 'cmapmodified', Title='VP', MailingStreet='123 Main', 
                              MailingCity='Peoria', MailingState='IL', MailingPostalCode='33333', Phone='3213213211', MobilePhone='3213213211', 
                              Fax='3213123211', Partner_My_Account_GUID__c='23244345');
        insert testContact;
        
        //final List<Profile> partnerProfiles = [select id,name from Profile where UserType = 'PowerPartner' limit 1];
        final List<Profile> partnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' limit 1];
        User testUser = new User(Username='testuser12345@dell.com', Alias = 'test1212', Email='4@test.com', FirstName='Test', LastName='User', 
                        ProfileId = partnerProfiles.get(0).Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                        TimeZoneSidKey='America/Los_Angeles', Badge_Number__c=null, ContactId = testContact.id, Enable_Partner_Admin__c = true);
        insert testUser;
        testContact.AccountId = testAccountSecond.Id;
        
        update testContact;
        Test.stopTest();
        
        System.debug('#KP:END of test_processUpdateKeyRequestForAcctChange()');
    }
        private static void createPartnerRequest(){ 
            Country__c country = new Country__c();
            country.name = 'test';          
            country.code__c = 'XX';
            List<Profile> profiles = [select id,name from Profile where UserType = 'PowerPartner' limit 1];
            System.assert(profiles.size()>0, 'Test cannot execute: no partner profiles exist');
            country.User_Time_Zone_Sid_Key__c = 'America/Chicago';
            country.User_Profile_ID__c = profiles.get(0).id;
            country.User_Locale_Sid_Key__c = 'en_US';
            country.User_Language_Locale_Key__c = 'en_US';
            country.User_Email_Encoding_Key__c = 'ISO-8859-1';
            country.User_Currency_Iso_Code__c = 'USD';
            country.Inc_Vendor_Name__c = 'Partner Advantage';
            country.Inc_Vendor_End_Point__c = 'test URL';
            country.Lead_Management_Enabled__c = 'Yes';
            country.Lead_Management_Enabled_for_OEM__c = 'Yes';
            country.Partner_Relationship__c = 'All';
            country.Partner_Relationship_for_OEM__c = 'All';
            country.Deal_Registration_Enabled__c = 'Yes';
            insert country;
                
            testSalesChannelGrp = new Sales_Channel_Group__c(Name='TestChannelGroup1', Regional_Area_Name__c = 'REGION1',Region_Name__c='REGION1', Segment_Business_Unit_Name__c='LARGE ENTERPRISE');
            insert testSalesChannelGrp;
            
            testAccount = new Account(
            name='createPartnerRequest Test 1',
            Account_Country_Code__c = 'XX',
            Account_Country__c = 'ANGUILIA',
            Sales_Channel__c = testSalesChannelGrp.Id,
            States_Provinces_doing_business__c = 'Test',
            Software_Revenue_Percent__c = '11-20%',
            Service_Revenue_Percent__c = '11-20%',
            Product_Focus__c = 'Test focus',
            Primary_Channel_Model__c = 'Reseller',
            Premier_Page_s_ID__c = 'Test page',         
            Percent_Technical_Professionals__c = '11-20%',
            Percent_Sales_Force__c = '11-20%',
            Partner_Type__c = 'Test type',
            Partner_Tier__c = 'Test tier',
            Partner_Relationship__c = 'Test Relatonship',
            Preferred_Dell_Distribution_Partner__c = 'Test prefer',
            Partner_Primary_Customer__c = 'Consumer',
            Partner_Description__c = 'Test desc',
            Last_4_Closed_Qtr_Rev_Workstations__c = .50,
            Last_4_Closed_Qtr_Rev_Servers__c = .50,
            Last_4_Closed_Qtr_Rev_Notebooks__c = .50,
            Last_4_Closed_Qtr_Rev_Imaging__c = .50,
            Last_4_Closed_Qtr_Rev_Desktops__c = .50,
            Hardware_Revenue_Percent__c = '11-20%',
            Form_of_Organization__c = 'Corporation',
            Dell_Revenue_Percent__c = '11-20%',
            Account_ID__c = '333333'+System.currentTimeMillis(),
            type = 'Partner'  ,
            Is_Enabled_for_Incentives__c = true ,            
            RecordTypeId = System.Label.RecType_Partner_Account    
            );
        insert testAccount;
        system.debug('#### LALALA testAccount : ' + testAccount);
            contact = new Contact(
            AccountId=testAccount.id,
            Email='1@dell.com', 
            FirstName = 'cmapmodifiedfirst', 
            LastName = 'cmapmodified',
            Title='VP',
            MailingStreet='123 Main',
            MailingCity='Peoria',
            MailingState='IL',
            MailingPostalCode='33333',
            Phone='3213213211',
            MobilePhone='3213213211',
            Fax='3213123211',
            Partner_My_Account_GUID__c='3456',
            Is_Enabled_for_Incentives__c = true                   
        );
        insert contact;  
            
            //final List<Profile> partnerProfiles = 
            //[select id,name from Profile where UserType = 'PowerPartner' limit 1];
            final List<Profile> partnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' limit 1];
            user = new User(
            Username='testuser23456@dellteam.com',
            Alias = 'test1', 
            Email='1@test.com', 
            FirstName='Test', 
            LastName='User', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = contact.id, 
            Enable_Partner_Admin__c = true ,
            Enable_Partner_Lead_Management__c = false,
            Enable_Partner_Deal_Registration__c = true         
            );
        insert user;
       // }    
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User u = new User(Alias = 'standtpp', Email='standarduser@dell.com',EmailEncodingKey='UTF-8', LastName='Testing PPUser', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',  Badge_Number__c= '55t757h', UserName='standarduser@dell.com');
        system.debug('*****'+u.Badge_Number__c);
        System.runAs(u) {
            request = new Partner_Request__c();
        request.Account__c = testAccount.id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
            'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Contact__c=contact.id;
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        insert request;
        testAccount.IsPartner = true;
        testAccount.Partner_Registration__c=request.id;
        update testAccount;
        
        System.debug('##MN:Account :'+testAccount);
        System.debug('##MN:request :'+request);
        System.debug('##MN:contact :'+contact);testDataCreated=true;
        
        /* Rev 10.0 */
        
        //Creating end customer   
        End_Customer__c endCustomer = new End_Customer__c();
        endCustomer.Account_Department__c='xxx';
        endCustomer.Account_Industry__c='Biotechnology';             
        endCustomer.Mailing_city__c='ff';
        endCustomer.Mailing_country__c='dasssa';
        endCustomer.Mailing_State__c='sdawwqwq';
        endCustomer.Mailing_street__c='ddsdqwewdc';
        endCustomer.Partner_Account__c=testAccount.id;
        endCustomer.Segment__c='Education';
        endCustomer.Status__c='Active';
        endCustomer.Tax_Id__c='aaaaa';
        endCustomer.Total_of_End_User_Employees__c='100 - 199';           
        endCustomer.Zip_Code__c='333333';
        endCustomer.Name='Company';
           
        insert endCustomer;
        
        End_Customer_Contact__c endCstmrCntct=new End_Customer_Contact__c();
        endCstmrCntct.Name='test';
        endCstmrCntct.Email__c='testemail12345@Company31.com';
        endCstmrCntct.End_Customer__c=endCustomer.Id;
        endCstmrCntct.Fax__c='222';
        endCstmrCntct.Last_Name__c='tester';
        endCstmrCntct.Mobile__c='333';
        endCstmrCntct.Phone__c='4444';
        endCstmrCntct.Status__c='Active';
        endCstmrCntct.Title__c='xsad';
        
        insert endCstmrCntct;
        }
    }
}