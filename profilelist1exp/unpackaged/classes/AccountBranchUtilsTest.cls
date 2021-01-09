/*-----------------------------------------------------------------------------------------
Description: Utility Class  for Account Branch (Duplicate check and Delete)
CR #2573
Version:1.0 

History:
    
Rev    Date      Author      Remarks
1.0             Manju
2.0    16/12/2011    Azwanti      CR5786 CRQ0241 : change reference to LOB_Name__c field
------------------------------------------------------------------------------------------*/
@isTest
private class AccountBranchUtilsTest {

    //Test method for Account Branch deletion
    static testMethod void testAccountBranchDelete() {
        Set<String> accBranchIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
  //      List<String> pickList = new List<String>();
        List<LOB_Administration__c> listOfLOBName = new List<LOB_Administration__c>();
        List<LOB_Registration__c> listOfLOBRegObjects = new List<LOB_Registration__c>();
        Map<String, Account_Branch__c> accountBranchMap = new Map<String, Account_Branch__c>();
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
                                
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    Title='GCC Program Manager', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
     //   CRQ0241 reminder : uncomment after type change  
        System.runAs(testUser){
            Account testEUAccount = new Account(Name='Test EU Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = testUser.Id);
            insert testEUAccount;
            Account testEUAcc = new Account(Name='Test EU Account',Type = 'End User',
                                            Participating_in_LOB_Program__c = true,
                                            OwnerId = testUser.Id);
            insert testEUAcc;
            Account_Branch__c accBrObj = new Account_Branch__c(Name = 'Test Account Branch', 
                                                               Account__c = testEUAccount.Id);
            if(testEUAccount.OwnerId == Userinfo.getUserId() || testEUAcc.OwnerId == Userinfo.getUserId()){
                insert accBrObj;
            }
            RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                     WHERE  SobjectType = 'LOB_Registration__c' and 
                                     name = 'LOB_registration_before_Approval'];
          //r2.0 CRQ0241: change reference to LOB_Name__c
            listOfLOBName = [SELECT Name FROM LOB_Administration__c WHERE Active__c = true]; 
        /*    Schema.Describefieldresult F = LOB_Registration__c.LOB_Name__c.getDescribe();
            List<Schema.Picklistentry> P = F.getPicklistValues();
            for(Schema.Picklistentry pickListValue : P){
                pickList.add(pickListValue.getLabel()); 
            }*/
            
            for(Integer j=0; j<listOfLOBName.size(); j++){
                LOB_Registration__c currentLOBReg = new LOB_Registration__c(
                                                    Registered_End_User__c = testEUAccount.Id,
                                                    LOB_registration_status__c = 'Open',
                                                    Location__c = accBrObj.Id,
                                                    LOB_Name__c = listOfLOBName[j].Name, RecordTypeId=recordType.Id);
                listOfLOBRegObjects.add(currentLOBReg);
            }   
            insert listOfLOBRegObjects;
            accBranchIdSet.add(accBrObj.Id);
            accountIdSet.add(accBrObj.Account__c);
            accountBranchMap.put(accBrObj.Id,accBrObj);
            //AccountBranchUtils.checkAndDeleteAccountBranches(accountBranchMap,accBranchIdSet,accountIdSet);
            delete accBrObj;
        }
    }//End of testAccountBranchDelete()
    
      
    //Test method to check duplicate Account Branch name
    static testMethod void testAccountBranchDuplicate() {
        List<Account_Branch__c> listOfAccBrRecs = new List<Account_Branch__c>();
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
                                
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    Title='GCC Program Manager',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        System.runAs(testUser){
            Account testEUAccount = new Account(Name='Test EU Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = testUser.Id);
            insert testEUAccount;
            Account testEUAcc = new Account(Name='Test EU Account',Type = 'End User',
                                            Participating_in_LOB_Program__c = true,
                                            OwnerId = testUser.Id);
            insert testEUAcc;
            AccountBranchController controller = new AccountBranchController
                                                 (new ApexPages.StandardController(testEUAccount));
            Account_Branch__c accBrRec = new Account_Branch__c(Name = 'Test Account', 
                                                               Account__c = testEUAccount.Id);
            if(testEUAccount.OwnerId == Userinfo.getUserId() || testEUAcc.OwnerId == Userinfo.getUserId()){
                insert accBrRec;
            }
            for(Integer i=0; i<2; i++ ){
                Account_Branch__c accBrObj = new Account_Branch__c(Name = 'Test Account'+i, 
                                                                   Account__c = testEUAccount.Id);
                listOfAccBrRecs.add(accBrObj);
            }
            Account_Branch__c accBrObj2 = new Account_Branch__c(Name = 'Abc', 
                                                                Account__c = testEUAccount.Id);
            listOfAccBrRecs.add(accBrObj2);                                                       
            Account_Branch__c accBrObj3 = new Account_Branch__c(Name = 'Xyz', 
                                                                Account__c = testEUAcc.Id);
            listOfAccBrRecs.add(accBrObj3);
            if(testEUAccount.OwnerId == Userinfo.getUserId() || testEUAcc.OwnerId == Userinfo.getUserId()){                                                       
                insert listOfAccBrRecs;
            }
            AccountBranchUtils.preventDuplicates(listOfAccBrRecs);
        }
        
    }//End of testAccountBranchDuplicate()
    
    
    //Test method to delete all Account Branches and its LOBs if 'Participating in LOB' is unchecked
    static testMethod void testAccBrLOBDeleteIfUnchecked() {
        Set<Id> accountIdSet = new Set<Id>();
        List<LOB_Administration__c> listOfLOBName = new List<LOB_Administration__c>();//r2.0
        Map<String, Account> accountMap = new Map<String, Account>();
        List<LOB_Registration__c> listOfLOBRegObjects = new List<LOB_Registration__c>();
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
                                
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    Title='GCC Program Manager',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        System.runAs(testUser){
            Account testEUAccount = new Account(Name='Test EU Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = testUser.Id);
            insert testEUAccount;
            Account_Branch__c accBrObj = new Account_Branch__c(Name = 'Test Account Branch', 
                                                               Account__c = testEUAccount.Id);
            if(testEUAccount.OwnerId == Userinfo.getUserId()){
                insert accBrObj;
            }
            RecordType recordType = [SELECT SobjectType, Name, Id FROM RecordType  
                                     WHERE  SobjectType = 'LOB_Registration__c' and 
                                     name = 'LOB_registration_before_Approval'];
        //  r2.0 CRQ0241: change reference to LOB_Name__c            
          listOfLOBName = [SELECT Name FROM LOB_Administration__c WHERE Active__c = true];       
        /*   Schema.Describefieldresult F = LOB_Registration__c.LOB_Name__c.getDescribe();
            List<Schema.Picklistentry> P = F.getPicklistValues();
            for(Schema.Picklistentry pickListValue : P){
                pickList.add(pickListValue.getLabel()); 
            }*/
            for(Integer j=0; j<listOfLOBName.size(); j++){
                LOB_Registration__c currentLOBReg = new LOB_Registration__c(
                                                    Registered_End_User__c = testEUAccount.Id,
                                                    LOB_registration_status__c = 'Open',
                                                    Location__c = accBrObj.Id,                                                     
                                                    LOB_Name__c = listOfLOBName[j].Name, RecordTypeId=recordType.Id);
                listOfLOBRegObjects.add(currentLOBReg);
            }   
            insert listOfLOBRegObjects;
            testEUAccount.Participating_in_LOB_Program__c = false;
            update testEUAccount;
            accountIdSet.add(testEUAccount.Id);
            accountMap.put(testEUAccount.Id,testEUAccount);
            AccountBranchUtils.deleteAllAccBrAndLOBs(accountIdSet);
        }
    }
}//End of test class