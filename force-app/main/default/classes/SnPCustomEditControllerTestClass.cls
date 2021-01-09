/**
 * Name: SnPCustomEditControllerTestClass
 * Author: Patrick Redor
 * Date: May 20, 2013
 */
@isTest(SeeAllData=true)
private class SnPCustomEditControllerTestClass{  
        
    static testMethod void SnPCustomEditControllerTestMethod(){
        // Creating specific test data for testing this class
        S_P_Vendor_Automation__c svAuto = new S_P_Vendor_Automation__c(Vendor_Name__c = '@@', Automation_Type__c = 'Full Automation',
                                                    Vendor_URL__c = 'https://test.salesforce.com/');
        insert svAuto;
        
        Sales_Channel_Group__c testSCG = new Sales_Channel_Group__c (Name = 'Test SCG', Group_ID__c = '12345', 
                                                                            Segment_Name__c = '');
        insert testSCG;
        
        Account acc = new Account(Name = 'Test Account', Sales_Channel__c = testSCG.Id, Account_Country__c = 'UNITED STATES');
        insert acc;
        
        //Contact
        Contact contTest = new Contact(AccountID = acc.id, Email = 'Email_1@dellTeam.Com', FirstName = 'Tony Tony', LastName = 'Chopper', Title='VP',MailingStreet='123 Main',
                   MailingCity='Peoria', MailingState='IL', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',
                   Status__c = 'Marketing Suspect');
        Contact contTest2 = new Contact(AccountID = acc.id, Email = 'Email_2@dellTeam.Com', FirstName = 'Roronoa', LastName = 'Zoro', Title='VP',MailingStreet='123 Main',
                   MailingCity='Peoria', MailingState='IL', MailingPostalCode='33333',Phone='3213213212',MobilePhone='3213213212',Fax='3213123212',
                   Status__c = 'Invalid - Email');
        insert contTest;
        insert contTest2;
        
        //get standard pricebook
        Product2 prd1 = new Product2 (Name='ARX',Description='ARX',productCode = 'ABC', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID='01s300000001iPvAAI',UnitPrice=50, isActive=true);
        insert pbe1;
        // Test Start
        Test.startTest();
        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.id, CloseDate = System.today(), StageName = 'Plan - 1%', 
                                                CurrencyIsoCode = 'USD', Primary_Product_Delivery_Address_Region__c = 'NORTH AMERICA',
                                                Primary_Product_Delivery_Address_Country__c = 'UNITED STATES');
        insert opp;
        
        /*
        OpportunityLineItem lineItem1 = new OpportunityLineItem(Opportunityid =opp.Id,
                                                                    pricebookEntryId=pbe1.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );
        insert lineItem1;*/
        
        S_P_Vendors__c sv = new S_P_Vendors__c(Opportunity__c = opp.Id,
                Sent_to_Vendor_Date__c = null, S_P_Deal_Status__c = 'Pending',
                Customer_Name__c = 'test', Contact_Name__c = 'test test', Phone__c = '9999999', 
                Email__c = 'test@test.com', Role__c = 'test', Ship_to_Address__c = 'test', 
                City__c = 'test', Zip__c = 'test', Total_NET__c = 76556, 
                Country__c = 'UNITED STATES', State__c = 'FL', 
                CurrencyIsoCode = 'USD', Distributor_Name__c = 'Ingram Micro',
                How_did_you_uncover_this_opportunity1__c = 'test', Sales_Activities_to_Date__c = 
                'Multiple meetings with customer and sent quote.', S_P_Vendors_Name__c = 'F5',
                Website__c = 'www.google.com', Industry__c = 'Gove - Federal', Product_Type__c = 'Software Module',
                Application_Vendor__c = 'BMC', Estimated_Closed_Date__c = '31-60 Days', Business_Type__c = 'New business', 
                Lead_Source__c = 'Other', Project_Description__c = 'test description'); 
        insert sv;
        
        
        SnPCustomEditController snpCEC = new SnPCustomEditController (new ApexPages.StandardController(sv));
        
        snpCEC.assignContact();
        
        snpCEC.svRec = SnPCustomEditControllerTestClass.saveRec(snpCEC, snpCEC.svRec);
        snpCEC.svRec.S_P_Deal_Status__c = 'Sent to Vendor';        
        snpCEC.svRec = SnPCustomEditControllerTestClass.saveRec(snpCEC, snpCEC.svRec);        
        snpCEC.svRec.S_P_Deal_Status__c = 'Pending';
        
        sv.S_P_Vendors_Name__c = 'VMware';
        sv.Customer_Name__c = '';
        update sv;
        snpCEC = new SnPCustomEditController (new ApexPages.StandardController(sv));
        
        snpCEC.svRec.Program_Type__c = 'Advantage+';
        snpCEC.defaultToResellerVMware();
        System.assertEquals('Reseller', snpCEC.svRec.Your_primary_involvement_in_the_deal__c);
        
        snpCEC.svRec.Program_Type__c = 'EPP Post-Sale Burn-Down';
        snpCEC.defaultToResellerVMware();
        //System.assertEquals('', snpCEC.svRec.Your_primary_involvement_in_the_deal__c);
        snpCEC.reRenderPanel();
        snpCEC.svRec.Program_Type__c = 'Advantage+';
        sv.S_P_Vendors_Name__c = 'Microsoft';
        update sv;
        snpCEC = new SnPCustomEditController (new ApexPages.StandardController(sv));
        
        snpCEC.svRec.Is_this_an_Enterprise_Agreement__c = 'No';
        snpCEC.svRec.Licensing_Program__c = null;
        snpCEC.defaultToSelectPlusMS();
        //System.assertEquals('Select Plus', snpCEC.svRec.Licensing_Program__c);
        
        sv = SnPCustomEditControllerTestClass.saveRec(snpCEC, sv);
        Test.stopTest();
        // Test End
        System.debug('##### - ' + snpCEC.isEmptyContact);        
    }
    
    public static S_P_Vendors__c saveRec(SnPCustomEditController snpCEC, S_P_Vendors__c sv){
        if(sv.S_P_Vendors_Name__c == 'F5')
            snpCEC.saveF5();
        else
            snpCEC.save();
            
        return sv;
    }
}