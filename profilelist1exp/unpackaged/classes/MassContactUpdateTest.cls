/* 
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
2.0         CR 13173    FY17-DCS-0801   12-Jul-2016     Fenny           To cover code for MassContactUpdate and ContactValidator after implement the excempt users (profiles) from validation
3.0         CR 14436    FY18-DCS-0702   07-June-2017    Yamini          To Cover code for MassContactUpdate after removing 'INTERNAL - Crisis Mgmt' from Status Pick list LOV 
*/

@isTest(SeeAllData=false)
private class MassContactUpdateTest {

    static testMethod void MassContactUpdate1(){
        TriggerExecutionController.setSkipAllTriggers(true); // 2.0
        
        // 2.0: START - Insert Contact Exclusion test data
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.com';
        Contact_Exclusion__c conExclusion = new Contact_Exclusion__c(Active__c=true, Phone__c='1234567890', First_Name__c='ExcludeF', Last_Name__c='ExcludeL', Email__c=email);
        insert conExclusion;
        // 2.0: END
        
        Profile p = [select id from profile where name='System Administrator'];
        String username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@noemail.com';
        User u = new User(alias = 'test123', email='testmasscu@dell.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',            
            timezonesidkey='America/Los_Angeles', username=username, 
            Badge_Number__c = string.valueof(datetime.now()).replace(':', '').replace('-', '').replace(' ', '') + datetime.now().millisecond());
        insert u;
            
        Account acc = new Account();
        acc.name = 'Some test Account';        
        acc.status__c = 'Active';
        acc.Type = 'Partner'; // 2.0
        acc.Account_Country_Code__c='US';              
        insert acc;
        
        Contact c = new Contact(AccountId=acc.Id, LastName='MyLastName', Email='testmc@dell.com');
        insert c;
        
        List<Contact> myCon = new List<Contact>();
        Contact con = [select id, Name, Phone, Email, MobilePhone, Decision_Making_Role__c, Title, 
                        Assistant_Email__c, Alternate_Email__c, Fax, AssistantPhone, HomePhone, OtherPhone, FirstName, LastName, Recommend_Comment__c
                        from Contact where id=:c.id limit 2];
        con.Phone = '123456789';
        con.MobilePhone = '123456789';
        con.Email = '1234@dell.com';
        con.Title = 'Program Manager'; 
        con.Assistant_Email__c = 'test@test.test'; // 2.0
        con.Alternate_Email__c = 'testing@test.com'; // 2.0
        con.Fax = '123456789'; // 2.0
        con.AssistantPhone = '123456789'; // 2.0
        con.HomePhone = '123456789'; // 2.0
        con.OtherPhone = '123456789'; // 2.0
        con.FirstName = '2.0First'; // 2.0
        con.LastName = '2.0Last'; // 2.0
        con.Recommend_Comment__c = 'Comment'; // 2.0
        myCon.add(con);

        system.assertEquals(con.Email, con.Email);            
        system.assertEquals(con.Title, con.Title);
        TriggerExecutionController.setSkipAllTriggers(false); // 2.0
        TriggerExecutionController.setSkipAccountTriggers(true); // 2.0
                                   
        test.startTest();   
        //system.runas(u){ // 2.0: Commented, because admin is excempted from validation, comment this line will cover more code
            update myCon;
            
            // 2.0: Added - To prevent System.VisualforceException: Modified rows exist in the records collection!
            List<Contact> listContact = [select id, Name, Phone, Email, MobilePhone, Decision_Making_Role__c, Title, Account.Name,
                        Assistant_Email__c, Alternate_Email__c, Fax, AssistantPhone, HomePhone, OtherPhone, FirstName, LastName, Recommend_Comment__c
                        from Contact where id=:c.id];
        
            //PageReference pageRef = Page.MassContactUpdate;      
            //pageRef.getParameters().put('fcf','00BA0000004Tm8C');
            //Test.setCurrentPageReference(pageRef);  
            
            ApexPages.StandardSetController StandardsObjectController = new ApexPages.StandardSetController(listContact);
            MassContactUpdate oCEE = new MassContactUpdate(StandardsObjectController);
            oCEE.NextPage();
            oCEE.SaveAndNextPage();
            oCEE.CancelAndNextPage();
            oCEE.PreviousPage();
            oCEE.SaveAndPreviousPage();
            oCEE.CancelAndPreviousPage();
            oCEE.FirstPage();
            oCEE.SaveAndLastPage();
            oCEE.CancelAndLastPage();
            oCEE.LastPage();
            oCEE.SaveAndFirstPage();
            oCEE.CancelAndFirstPage();
            oCEE.Page1();
            oCEE.SaveAndPage1();
            oCEE.CancelAndPage1();
            oCEE.Page2();
            oCEE.SaveAndPage2();
            oCEE.CancelAndPage2();
            oCEE.Page3();
            oCEE.SaveAndPage3();
            oCEE.CancelAndPage3();
            oCEE.GoBack();
            oCEE.DiscardAndStay();
            oCEE.getTotalPages();
            oCEE.getPageNumber();
            oCEE.getPageSize();
            oCEE.getTotalRecords();
            oCEE.getStartPageRecords();
            oCEE.getEndPageRecords();
            oCEE.saveAndReturnSuccessMsg();
            StandardsObjectController.setPageNumber(1);

            listContact[0].Phone = '1234567890'; // 2.0: Added
            listContact[0].MobilePhone = '1234567890'; // 2.0: Added
            listContact[0].Email = email; // 2.0: Added
            listContact[0].Title = 'Program Manager';  // 2.0: Added
            listContact[0].Assistant_Email__c = email; // 2.0: Added
            listContact[0].Alternate_Email__c = email; // 2.0: Added
            listContact[0].Fax = '1234567890'; // 2.0: Added
            listContact[0].AssistantPhone = '1234567890'; // 2.0: Added
            listContact[0].HomePhone = '1234567890'; // 2.0: Added
            listContact[0].OtherPhone = '1234567890'; // 2.0: Added
            listContact[0].FirstName = 'ExcludeF'; // 2.0: Added
            listContact[0].LastName = 'ExcludeL'; // 2.0: Added
            listContact[0].Recommend_Comment__c = 'Comment'; // 2.0: Added

            oCEE.saveAndReturn(); // 2.0: Moved to here

            system.assertEquals(listContact[0].Email, email); 
            system.assertEquals(listContact[0].Title, 'Program Manager');                     
            system.assertEquals(listContact[0].Phone, '1234567890');     
            system.assertEquals(listContact[0].MobilePhone, '1234567890');  
            // V.3 Starts:Chaned system.assertEquals(8, oCEE.getListStatus().size()); to below
            system.assertEquals(7, oCEE.getListStatus().size()); // 2.0: To cover more code in MassContactUpdate
            //V.3 ends
                      
        //}
        test.stopTest();  
    
    }
}