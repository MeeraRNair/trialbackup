/*
 * Author   : Anuj Shah
 * Purpose  : Test class for Scheduler class for BatchPopulateAccFieldsFromATM
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      6742302     0802      12-JUN-2019     Anuj Shah        Scheduler class for BatchPopulateAccFieldsFromATM           
 *
*/ 
@isTest
public class BatchPopulateAccFieldsFromATMSchTest {

    @isTest
    public static void testScheduler()
    {
        Profile pf= [Select Id from profile where Name='Presales Service Rep']; 
        
        String strOrgId=UserInfo.getOrganizationId(); 
        String strDateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer intRandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String strUniqueName=strOrgId+strDateString+intRandomId;
        List<User> listAllUserToInsert = new List<User>();
        User uu1=new User(firstname = 'user1', 
                         lastName = 'XYZ', 
                         email = strUniqueName + '@dellteam.com', 
                         Username = strUniqueName + '@test' + strOrgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = strUniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         Badge_Number__c = 'test1' + Integer.valueOf(Math.rint(Math.random()*1000000)),
                         ProfileId = pf.Id
                        );
        strUniqueName=strOrgId+strDateString+Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User uu2=new User(firstname = 'user2', 
                         lastName = 'XYZ', 
                         email = strUniqueName + '@dellteam.com', 
                         Username = strUniqueName + '@test' + strOrgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = strUniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test2' +Integer.valueOf(Math.rint(Math.random()*1000000)),
                         ProfileId = pf.Id
                        ); 
        strUniqueName=strOrgId+strDateString+Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User uu3=new User(firstname = 'user3', 
                         lastName = 'XYZ', 
                         email = strUniqueName + '@dellteam.com', 
                         Username = strUniqueName + '@test' + strOrgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = strUniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test3' +Integer.valueOf(Math.rint(Math.random()*1000000)),
                         ProfileId = pf.Id
                        ); 
        listAllUserToInsert.add(uu1);
        listAllUserToInsert.add(uu2);
        listAllUserToInsert.add(uu3);
        insert listAllUserToInsert;
        
        List<Account> listAllAccToInsert = new List<Account>();
        Account acc1 = new Account();
        acc1.name = 'Test1_EndUser';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End-User Account').getRecordTypeId();
        listAllAccToInsert.add(acc1);   
        
        Account acc2 = new Account();
        acc2.name = 'Test1_Master';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Master Account').getRecordTypeId();
        listAllAccToInsert.add(acc2);
        
        Account acc3 = new Account();
        acc3.name = 'Test1_Partner';
        acc3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId();
        listAllAccToInsert.add(acc3);
        
        insert listAllAccToInsert;
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        User usr = [SELECT id FROM User WHERE FirstName = 'user1'];
       
       
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = usr.Id;
        atm.Team_Member_Role__c = 'Inside Sales Rep';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        insert atm;
        
        Test.startTest();
        BatchPopulateAccFieldsFromATMScheduler obj = new BatchPopulateAccFieldsFromATMScheduler();
        obj.execute(null);
        Test.stopTest();
        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        System.assertEquals(usr.Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
}