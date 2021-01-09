/*****************************************************************************************************************
* Name          : VFCntrlr_AddInternalContactTest
* Description   : Test Method for VFCntrlr_AddInternalContact
* -----------------------------------------------------------
* Revision  Name            Date            Description
* 1.0       Krishnamoorthi  22.04.2013      R 14.5 CR 8200
******************************************************************************************************************/
@isTest
private class VFCntrlr_AddInternalContactTest {

    static Account newAccount = new Account();
    static List<AccountTeamMember> newATMList = new List<AccountTeamMember>();
    static AccountTeamMember ATM1 = new AccountTeamMember();
    static AccountTeamMember ATM2 = new AccountTeamMember();
    static Contact newContact = new Contact();
    static Case newCase = new Case();
    static List<User> userLst = new List<User>();
    static List<VFCntrlr_AddInternalContact.AcctTM> ATMRecords=new List<VFCntrlr_AddInternalContact.AcctTM>(); 
    
     public static void createData(){
        
        RecordType caseRT=[Select Name, Id From RecordType where 
                            sObjectType='Case' and Name like '%PartnerDirect%' limit 1];
                            
        RecordType accRT=[Select Name, Id From RecordType where 
                            sObjectType='Account' and Name like '%Partner Account%' limit 1];
                            
        newaccount.name = 'Test Account';
        newaccount.RecordTypeId = accRT.Id;
        insert newaccount;
        
        newContact.AccountId=newaccount.id;
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact';
        newContact.Email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_')+'@dell.com';
        newContact.Phone = '1234567891';
        insert newContact;
        
        Profile profiles=[select id,name from Profile where name like 'Standard%' limit 1];
        
        for(Integer i = 0; i < 2; i++){
            userLst.add(
                new User(
                    Username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_')+i+'@dell.com',
                    Alias = 'test'+i, 
                    Email=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_')+i+'@dellteam.com', 
                    FirstName='John', 
                    LastName='Doe'+i, 
                    ProfileId = profiles.Id,
                    Phone = '123456789'+i, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c='testuser'+i                     
                   )
            );
        }
        insert userLst;
        
        ATM1.UserId = userLst[0].Id;
        ATM1.AccountId = newaccount.Id;
       // ATM1.AccountAccessLevel = 'Read/Write';
        ATM1.TeamMemberRole = 'Account Executive';
        insert ATM1;
        
        ATM2.UserId = userLst[1].Id;
        ATM2.AccountId = newaccount.Id;
        //ATM2.AccountAccessLevel = 'Read/Write';
        ATM2.TeamMemberRole = 'Sales Support';
        insert ATM2;
        
        newCase.AccountId = newaccount.Id;
        newCase.ContactId = newContact.Id;
        newCase.Origin = 'Partner Portal';
        newCase.RecordTypeId = caseRT.Id;
        newCase.Sub_Type_Internal_User__c = 'Password Reset';
        newCase.Subject = 'Test Case Class 1';
        newCase.Description = 'This is a test';                                                    
        newCase.Priority = 'Medium';
        newCase.Alternate_Phone__c='123456789';
        insert newCase;
     }
    
    static testMethod void AddInternalContactTest() {
        createData();
        VFCntrlr_AddInternalContact.AcctTM wrapperObj=new VFCntrlr_AddInternalContact.AcctTM(ATM1);  
        wrapperObj.selected=true;
        ATMRecords.add(wrapperObj);
        
        PageReference  pr=new PageReference('/apex/AddInternalContact?id='+newCase.id+'caseaccountId='+newaccount.Id+'internalcontact='+newContact.Id);
        Test.setCurrentPage(pr);
        
        VFCntrlr_AddInternalContact controller = new VFCntrlr_AddInternalContact(new ApexPages.StandardController(newCase));
        controller.accountId = newaccount.Id;
        controller.internalContactId = newContact.Id;
        controller.caseId = newCase.Id;
        controller.getAccountTeamMember();
        controller.otherATMList[0].selected = true;
        controller.doSave();
        controller.doCancel();
        
       // Case updatedcase = [select Internal_Contact__c,Internal_Contact_Phone__c,Internal_Contact_Email__c from Case where Id =: newCase.Id];
        
      //  system.assertEquals(updatedcase.Internal_Contact__c, userLst[0].Id);
      //  system.assertEquals(updatedcase.Internal_Contact_Email__c, userLst[0].Email);
      //  system.assertEquals(updatedcase.Internal_Contact_Phone__c, userLst[0].Phone);
        
    }
}