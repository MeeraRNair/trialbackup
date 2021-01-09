/*
 * Author   : Anuj Shah
 * Purpose  : Test class for Populate Account User fields based on Account Team Members
 *        
 * Revision Ref Number  Release No  Date            Modified By     Description
 * -------- ----------  ----------  -----------     ------------    -----------
 * 1.0      6742302     0802      12-JUN-2019     Anuj Shah        Test Class for Populate Account User fields based on Account Team Members            
 *
*/

@isTest
public class BatchPopulateAccFieldsFromATMTest {  
    @TestSetup
    public static void setup()
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
                         Username = strUniqueName + '@test' + strOrgId + 'dellteam.com', 
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
                         Username = strUniqueName + '@test' + strOrgId + 'dellteam.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = strUniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test2' + Integer.valueOf(Math.rint(Math.random()*1000000)),
                         ProfileId = pf.Id
                        ); 
        strUniqueName=strOrgId+strDateString+Integer.valueOf(Math.rint(Math.random()*1000000)); 
        User uu3=new User(firstname = 'user3', 
                         lastName = 'XYZ', 
                         email = strUniqueName + '@dellteam.com', 
                         Username = strUniqueName + '@test' + strOrgId + 'dellteam.com', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = strUniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                          Badge_Number__c = 'test3' + Integer.valueOf(Math.rint(Math.random()*1000000)),
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
    }
    
    @isTest
    public static void testEndUserAccForInside()
    {
        
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
           
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
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();
        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        System.assertEquals(usr.Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
    
    @isTest
    public static void testEndUserAccForMultiples()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        List<User> listUsrs = [SELECT id FROM User WHERE FirstName = 'user1' OR FirstName = 'user2'];
        System.debug('size '+listUsrs.size());
       List<Account_Team__c> listATM = new List<Account_Team__c>();
        
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = listUsrs[0].Id;
        atm.Team_Member_Role__c = 'Inside Sales Rep';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm) ;
        
        Account_Team__c  atm1 = new Account_Team__c();
        atm1.User__c = listUsrs[1].Id;
        atm1.Team_Member_Role__c = 'Client & Compute Inside Sales Rep';
        atm1.Account__c = acc.Id;
        atm1.Account_User_ID__c = '1112';
        atm1.Status__c = 'Active';
        atm1.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm1) ;
        
        insert listATM;
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();
        //assert
        System.debug('User listUsrs[0].Id '+listUsrs[0].Id);
        System.debug('User listUsrs[1].Id '+listUsrs[1].Id);
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        System.assertEquals(listUsrs[0].Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
    
    @isTest
    public static void testEndUserAccForMultipleInactive()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        List<User> listUsrs = [SELECT id FROM User WHERE FirstName = 'user1' OR FirstName = 'user2'];
       List<Account_Team__c> listATM = new List<Account_Team__c>();
        
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = listUsrs[0].Id;
        atm.Team_Member_Role__c = 'Inside Sales Rep';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm) ;
        
        Account_Team__c  atm1 = new Account_Team__c();
        atm1.User__c = listUsrs[1].Id;
        atm1.Team_Member_Role__c = 'Client & Compute Inside Sales Rep';
        atm1.Account__c = acc.Id;
        atm1.Account_User_ID__c = '1112';
        atm1.Status__c = 'Active';
        atm1.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm1) ;
        
        insert listATM;
        
        //call actual class method
       Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        
        Test.startTest();
        atm.ATM_Status__c = 'Waiting To Process';
        atm.Status__c = 'Delete';
        update atm;
        
        atm1.ATM_Status__c = 'Waiting To Process';
        update atm1;
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();

        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_EndUser'];
        System.assertEquals(listUsrs[1].Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
    
    @isTest
    public static void testPartnerAccForInside()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Partner'];
        User usr = [SELECT id FROM User WHERE FirstName = 'user1'];
       
       
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = usr.Id;
        atm.Team_Member_Role__c = 'Inside Channel Account Manager';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        insert atm;
        
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();
        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Partner'];
        System.assertEquals(usr.Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
    
    @isTest
    public static void testMasterAccForInside()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Master'];
        User usr = [SELECT id FROM User WHERE FirstName = 'user1'];
       
       
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = usr.Id;
        atm.Team_Member_Role__c = 'Inside Channel Account Manager';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        insert atm;
        
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();
        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Master'];
        System.assertEquals(usr.Id, accUpdated.Inside_Sales_Rep_ICAM__c);
    }
        
     @isTest
    public static void testEndUserAccForMultiplesPDM()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c,Account_Executive_PDM__c FROM Account WHERE Name = 'Test1_EndUser'];
        List<User> listUsrs = [SELECT id FROM User WHERE FirstName = 'user1' OR FirstName = 'user2'];
       List<Account_Team__c> listATM = new List<Account_Team__c>();
        
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = listUsrs[0].Id;
        atm.Team_Member_Role__c = 'Client & Compute Sales Exec';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm) ;
        
        Account_Team__c  atm1 = new Account_Team__c();
        atm1.User__c = listUsrs[1].Id;
        atm1.Team_Member_Role__c = 'Client & Compute Global Sales Exec';
        atm1.Account__c = acc.Id;
        atm1.Account_User_ID__c = '1112';
        atm1.Status__c = 'Active';
        atm1.ATM_Status__c = 'Waiting To Process';
        listATM.add(atm1) ;
        
        insert listATM;
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();
        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c,Account_Executive_PDM__c FROM Account WHERE Name = 'Test1_EndUser'];
        System.assertEquals(listUsrs[0].Id, accUpdated.Account_Executive_PDM__c);
    }
    
     @isTest
    public static void testPArtnerAccForMultipleInactivePDM()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Partner'];
        List<User> listUsrs = [SELECT id FROM User WHERE FirstName = 'user1' OR FirstName = 'user2'];
       List<Account_Team__c> listATM = new List<Account_Team__c>();
        
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = listUsrs[0].Id;
        atm.Team_Member_Role__c = 'Distribution Partner Development Manager';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        insert atm;
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        //
        
        Account_Team__c  atm1 = new Account_Team__c();
        atm1.User__c = listUsrs[1].Id;
        atm1.Team_Member_Role__c = 'Partner Development Manager';
        atm1.Account__c = acc.Id;
        atm1.Account_User_ID__c = '1112';
        atm1.Status__c = 'Active';  
        atm1.ATM_Status__c = 'Waiting To Process';
        insert atm1;
        
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();

        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c,Account_Executive_PDM__c FROM Account WHERE Name = 'Test1_Partner'];
        System.assertEquals(listUsrs[1].Id, accUpdated.Account_Executive_PDM__c);
    }
    
    @isTest
    public static void testPArtnerAccForAllInactivePDM()
    {
        Abort_CMAP_Job__c abortTiming = new Abort_CMAP_Job__c();
        abortTiming.NAME = 'aBORT 1';
        abortTiming.Start_Date__c = datetime.newInstance(2019, 9, 10, 2, 30, 0);
        abortTiming.End_Date__c = datetime.newInstance(2109, 10, 15, 13, 30, 0);
        insert abortTiming;
        
        Account acc = [SELECT id,Inside_Sales_Rep_ICAM__c FROM Account WHERE Name = 'Test1_Partner'];
        List<User> listUsrs = [SELECT id FROM User WHERE FirstName = 'user1' OR FirstName = 'user2'];
       List<Account_Team__c> listATM = new List<Account_Team__c>();
        
        Account_Team__c  atm = new Account_Team__c();
        atm.User__c = listUsrs[0].Id;
        atm.Team_Member_Role__c = 'Distribution Partner Development Manager';
        atm.Account__c = acc.Id;
        atm.Account_User_ID__c = '1111';
        atm.Status__c = 'Active';
        atm.ATM_Status__c = 'Waiting To Process';
        insert atm;
        
        Account_Team__c  atm1 = new Account_Team__c();
        atm1.User__c = listUsrs[1].Id;
        atm1.Team_Member_Role__c = 'Partner Development Manager';
        atm1.Account__c = acc.Id;
        atm1.Account_User_ID__c = '1112';
        atm1.Status__c = 'Active'; 
        atm1.ATM_Status__c = 'Waiting To Process';
        insert atm1;
        
         //call actual class method
        
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        //
        atm.Status__c = 'Delete';
    atm.ATM_Status__c = 'Waiting To Process';
        update atm;
        atm1.Status__c = 'Delete';
        atm1.ATM_Status__c = 'Waiting To Process';
        update atm1;
        
        Test.startTest();
        //call actual class method
        Database.executeBatch(new BatchPopulateAccFieldsFromATM());
        
        Test.stopTest();

        //assert
        Account accUpdated = [SELECT id,Inside_Sales_Rep_ICAM__c,Account_Executive_PDM__c FROM Account WHERE Name = 'Test1_Partner'];
     //   System.assertEquals(null, accUpdated.Account_Executive_PDM__c); //need to decide
    }
}