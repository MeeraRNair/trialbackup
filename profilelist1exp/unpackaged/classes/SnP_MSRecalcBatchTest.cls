@isTest(SeeAllData=true)
private class SnP_MSRecalcBatchTest{
    static testMethod void SnP_MSRecalcBatchtest(){
        Profile AdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' LIMIT 1];
        User AdminUser = new User(FirstName='SnP Recalc Batch', 
                                  LastName='Test Admin', 
                                  Title='CEO', 
                                  UserName='SnP_RecalcBatchAdmin@test.com',
                                  Email='SnP_RecalcBatchAdmin@dell.com', Alias='snprecba', 
                                  CommunityNickName='snprecba', ProfileId = AdminProfile.Id,
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  EmailEncodingKey='UTF-8', 
                                  TimeZoneSidKey='Asia/Kuala_Lumpur',
                                  Badge_Number__c='snprecba');
        insert AdminUser;
        
        Account acc = new Account(Name = 'Test Account');
        Database.insert(acc);
        
        /*List<Report> snpRep = [SELECT Name FROM Report WHERE Name = 'S&P Microsoft Recalculation Report'];
        Database.upsert(snpRep);
        
        List<CurrencyType> snpCur = [SELECT IsoCode FROM CurrencyType WHERE IsoCode = 'HKD'];*/
        
        Opportunity opp = new Opportunity(Name = 'test', AccountId = acc.Id, CloseDate = System.today(), StageName = 'Plan - 1%',
                                          CurrencyIsoCode = 'USD');
        Database.insert(opp);
        
        S_P_Vendors__c mainSV = new S_P_Vendors__c(Opportunity__c = opp.Id, How_did_you_uncover_this_opportunity__c = 'sample',
            Sales_Activities_to_Date__c = 'sample', Has_a_customer_contact_been_identified__c = 'Yes',
            One_sentence_desc_of_Oppty_strategy__c = 'sample', Software_Account_Executive__c = 'sample',
            Customer_Name__c = 'sample', Contact_Name__c = 'sample', Phone__c = 'sample', Email__c = 'sample', 
            Role__c = 'sample', Ship_to_Address__c = 'sample', City__c = 'sample', Zip__c = 'sample', Country__c = 'sample',
            Software_Licensing_Specialist__c = 'sample',    Is_this_an_Enterprise_Agreement__c = 'Yes');
    
        Database.insert(mainSV);
        
        S_P_Vendor_Additional_Information__c addlInfoProd = new S_P_Vendor_Additional_Information__c(Total__c = 1000,
            SIP_Threshold_Met__c = 'No', Deal_Reg_Status__c = null, Agreement_Level__c = null, Level__c = 'Product', 
            EA_Fees_Total__c = null, SnP_Vendor_ID__c = null, Products_Included__c = 'VDI',
            S_P_Vendors_ID__c = mainSv.Id, CurrencyIsoCode = 'HKD');
        
        Database.insert(addlInfoProd);
        
        S_P_Vendor_Product_Selection__c prodSel = new S_P_Vendor_Product_Selection__c(Total__c = 1000, SIP_Fees__c = 1000, 
            SIP_Incentive__c = 'Windows 7', New_Products_Only__c = 'Windows', 
            S_P_Vendor_Additional_Information_ID__c = addlInfoProd.Id);
        
        Database.insert(prodSel);
        
        
        S_P_Vendor_Additional_Information__c addlInfoEa = new S_P_Vendor_Additional_Information__c(Total__c = 1000,
            SIP_Threshold_Met__c = 'No', Deal_Reg_Status__c = 'Incomplete', Agreement_Level__c = 'A1', Level__c = 'EA', 
            EA_Fees_Total__c = 1000, SnP_Vendor_ID__c = null, Products_Included__c = null,
            S_P_Vendors_ID__c = mainSv.Id , CurrencyIsoCode = 'HKD');
        
        Database.insert(addlInfoEa);
        
        System.runAs(AdminUser){
            
            Exception__c exceptionVar = new Exception__c();        
            exceptionVar.Object_type__c = 'S&P Vendor Product Selection';
            exceptionVar.Object_ID__c = 'a2zK00000008cSl';
            exceptionVar.Operation__c = 'Update';
            exceptionVar.Title__c = 'SQL Svr Enterprise Core';
            exceptionVar.Process_Name__c = 'Microsoft Recalculation';
            exceptionVar.Email__c = 'test';
            exceptionVar.Error_Messages__c = 'test';
            exceptionVar.Notes__c = 'test';
                
            Database.insert(exceptionVar);    
            
            List<S_P_Vendor_Queue__c> vendorQueue = new List<S_P_Vendor_Queue__c>();
            
            vendorQueue.add(new S_P_Vendor_Queue__c(Product_Family__c = 'Windows 7', Product_Description__c = 'Windows', 
                Status__c = 'Pending', Minimum_Revenue__c = 1, Percentage__c = 10 ));
                            
            vendorQueue.add(new S_P_Vendor_Queue__c(Product_Family__c = null, Product_Description__c = 'A1', Status__c = 'Pending', 
                Minimum_Revenue__c = null, Percentage__c = 10));
                            
            Database.insert(vendorQueue);
            
            Test.startTest();
            SnP_MSRecalcBatch snpBatch = new SnP_MSRecalcBatch();
            Id batchprocessid = database.executebatch(snpBatch,2000);
            
            Test.stopTest();
            
            
        }
        
         
                        
        
        
    }
    
    static testMethod void SnP_MSRecalcSchedule(){
        
        List<S_P_Vendor_Queue__c> vendorQueue = new List<S_P_Vendor_Queue__c>();
        
        vendorQueue.add(new S_P_Vendor_Queue__c(Product_Family__c = null, Product_Description__c = 'A1', Status__c = 'Pending', 
                                                Minimum_Revenue__c = null, Percentage__c = 10));
        
        Database.upsert(vendorQueue);
        
        Test.startTest();
        String CRON_EXP = '0 0 0 * * ?';
        SnP_MSRecalcSchedule sch = new SnP_MSRecalcSchedule();
        String jobId = System.schedule('TestScheduledApex',CRON_EXP,sch);
        //AsyncApexJob pending = [select Id from AsyncApexJob where apexClass.Name = 'SnP_MSRecalcBatch'];
        //System.abortJob(pending.Id);
        SnP_MSRecalcBatch snpBatch = new SnP_MSRecalcBatch();
        Id batchprocessid = database.executebatch(snpBatch,2000);
        Test.stopTest();
        
    }
    
    //static testMethod void SnP_MSRecalcSchedule(){
    //}
    
}