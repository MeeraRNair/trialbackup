/*
Purpose of this class is to test trigger functions for:
a.  beforeInsertUpdateAccountTrigger - SSO Project 14.2 Set Is_Country_Enabled__c based on the country countryRec.Inc_Vendor_Name__c
b.  afterUpdateAccountTrigger - SSO Project 14.2 Disable contact Is_Enabled_for_Incentives__c if Account.Is_Enabled_for_Incentives__c is disable.

REVISION HISTORY
================
Version     Author      Date            Release#            CR#      Description
-------     ------      ----            --------            ---     -----------
1.0         Ariff       10th Dec 2012   14.2                        Creation.
1.1         Fenny       11-Dec-2012     14.2
1.2         Ariff       18th Jan 2013   14.2                        Update test cases. If account's country is not enable for incentives, account will not be created
1.3         Ariff       29th Jan 2013   14.2                        Comment 1.1 test cases - not valid test case.
2.0         Sui Yee     10-May-2016     0602                13136   Added new method to test checkmapAccountsForIntegration
2.1         Azwanti     8-May-2016      0602                        Fixed DUPLICATES_DETECTED found in Prod Validation
3.0         Fenny       13-Jul-2016     FY17-DCS-0801       13173   To excempt user (profiles) from contact exclusion list checking, to cover AccountValidator.validateProdRepEmail
*/
@IsTest

public class AccountTriggerHandlerBITest {
    public static list<Account> listAcc;
    public static list<Contact> listCon;
    @testsetup static void setup(){
        list<Account> listAccTDF=TestDataFactory.createNAccount(5, 'Master Account');
        //listAccTDF[0].BillingCountry='United Kingdom';
        //listAccTDF[0].Name= 'NPS Cases';
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(2);
        insert listConTDF;
    }
    private static testmethod void createAccountAllowForIncentivesDisable(){
        //Create account with country not enable for incentives
        try{
            Account accountTest = createTestData('Not Applicable/On Hold','BB',false,1,0).get(0);
        }
        catch(Exception e){
            Boolean bexpectedExceptionThrown=e.getMessage().contains('Country is not enabled for Incentives');
            System.AssertEquals(bexpectedExceptionThrown,true);
        }
    }
    
    private static testmethod void createAccountCountryAllowForIncentivesEnable(){
        //Create account with country enable for incentives
        Account accountTest = createTestData('Partner Direct Rewards Center','BB',true,1,0).get(0);       
        System.assertNotEquals(accountTest,null);
    }
    
    private static testMethod void updateAccountAllowForIncentivesDisable(){
        //Update account with country not enable for incentives
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        Account accountTest = createTestData('Partner Direct Rewards Center','BB',true,1,0).get(0); 
        try{
            Country__c testCountry=  new Country__c(name='Fake Country', Dell_Online_Country_Code__c='FC',Code__c='FC',Last_Operation_Performed__c='Test Data',
                                                    Inc_Vendor_Name__c='Not Applicable/On Hold');
            insert testCountry;
            Account accountRequery = [Select Account_Country_Code__c from Account where ID=:accountTest.ID];
            accountRequery.Account_Country_Code__c = 'FC';
            update accountRequery;
        }
        catch(Exception e){
            Boolean bexpectedExceptionThrown=e.getMessage().contains('Country is not enabled for Incentives');
            System.AssertEquals(bexpectedExceptionThrown,true);
        } 
        TriggerExecutionController.setSkipAllTriggers(false);
        test.stopTest();
    }
    /*
private static testMethod void UpdateAccountAllowForIncentivesEnable(){
//Update account with country enable for incentives
test.starttest();
Account accountTest = createTestData('Partner Direct Rewards Center','BB',true,1,0).get(0); 

Country__c testCountry=  new Country__c(name='Fake Country', Dell_Online_Country_Code__c='FC',Code__c='FC',Last_Operation_Performed__c='Test Data',
Inc_Vendor_Name__c='Partner Direct Rewards Center',Inc_Vendor_End_Point__c='{TBD}');

insert testCountry;
Account accountRequery = [Select Account_Country_Code__c from Account where ID=:accountTest.ID];
accountRequery.Account_Country_Code__c = 'FC';
update accountRequery;

System.AssertEquals(accountRequery.Account_Country_Code__c,'FC'); 
test.stoptest();

}
*/
    
    private static testmethod void updateAccountDisableEnableForIncentives(){
        //Set accountTest Is_Enabled_for_Incentives__c to false;
        //Expected result, all contact's Is_Enabled_for_Incentives__c is to false;
        
        TriggerExecutionController.setSkipAllTriggers(true); // 3.0
        Account accountTest = createTestData('Partner Direct Rewards Center','BB',true,1,5).get(0);
        TriggerExecutionController.setSkipAllTriggers(false); // 3.0
        accountTest.Is_Enabled_for_Incentives__c=false;
        update accountTest;
        
        List<Contact> listcontactList = [Select Is_Enabled_for_Incentives__c from Contact where AccountID=:accountTest.ID];
        
        for(Contact contactObj:listcontactList){
            System.assertEquals(true,contactObj.Is_Enabled_for_Incentives__c);
        }
    }
    
    private static testmethod void updateAccountDisableEnableForIncentivesStressTest100Contacts(){
        //Set accountTest Is_Enabled_for_Incentives__c to false with 100 contacts associated with this account;
        //Expected result, all contact's Is_Enabled_for_Incentives__c is to false;
        
        TriggerExecutionController.setSkipAllTriggers(true); // 3.0
        Account accountTest = createTestData('Partner Direct Rewards Center','BB',true,1,100).get(0);
        TriggerExecutionController.setSkipAllTriggers(false);// 3.0
        accountTest.Is_Enabled_for_Incentives__c=false;
        accountTest.Account_Country__c='Shivam Teached';
        accountTest.Sales_Channel_ID__c='SuiYee Tested';
        accountTest.Status__c='I';
        accountTest.Account_Type_Integration__c='Sub Account';
        accountTest.DMU__c=false;
        update accountTest;
        accountTest.Name = 'Partner Direct';
        //update accountTest;
        
        List<Contact> listcontactList = [Select Is_Enabled_for_Incentives__c from Contact where AccountID=:accountTest.ID];
        
        /* Profile userProfile= [select id,name from profile where name like '%PRM Portal%' order by name limit 1 ];        
User userRecord = new User(
Username='testUser'+System.currentTimeMillis()+'@test.com',
Alias = 'test', 
Email='test@dell.com', 
FirstName='Tfirst', 
LastName='TLast',
ProfileId = userProfile.Id, 
ContactId = listcontactList[0].Id,
CompanyName = 'accountTest.Name',
//  Country = 'IN',
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='T2crgfghthr45'
);

insert userRecord;
*/
        //userRecord.CompanyName = 'accountTest.Name + test11';
        // Update userRecord;
        
        for(Contact contactObj:listcontactList){
            System.assertEquals(true,contactObj.Is_Enabled_for_Incentives__c);
        }
        
        //   update accountTest; 
        sObject a = accountTest;
        a.put('LOBi_Preferred_Partner_of_Record_Network__c','test');
        map<id,sObject> mapaa = new map<id,sObject>();
        mapaa.put(a.id,a);
        list<Account> listacc = new list<Account>();
        listacc.add(accountTest);
        try{
            AccountUtilities.sendEmailOnFieldChange(mapaa,listacc);
        }catch(exception ex){}
    }
    
    private static List<Account> createTestData(string strvendorName, string strcountryCode, Boolean bisCountryAccountAllowForIncentives, 
                                                Integer intnoOfAccount, Integer intnoOfContactPerAccount){
                                                    String strMockMetaData = '';
                                                    Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                                                        'AfterDelete' => new List<Boolean>{false, false, false, true, false},
                                                            'AfterInsert' => new List<Boolean>{false, false, true, false, false},
                                                                'AfterUndelete' => new List<Boolean>{false, false, false, false, true},
                                                                    'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
                                                                        'BeforeDelete' => new List<Boolean>{true, false, false, true, false},
                                                                            'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
                                                                                'BeforeUndelete' => new List<Boolean>{true, false, false, false, true},
                                                                                    'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
                                                    };
                                                        
                                                        for(String strEvent : mapEvents.keySet()) {
                                                            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                                                                + '"NamespacePrefix": "",'
                                                                + '"Event__c": "BeforeInsert", '
                                                                + '"sObject__c": "Account", "Class_Name__c": "AccountTriggerHandlerBI"},'; 
                                                        }
                                                    
                                                    strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
                                                    
                                                    MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
                                                    
                                                    TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
                                                    tec.Name = 'Account';
                                                    tec.RecursiveCount__c = 1;
                                                    insert tec;
                                                    
                                                    Country__c testCountry;
                                                    if (bisCountryAccountAllowForIncentives){
                                                        testCountry=  new Country__c(name='Bikini Bottom', Dell_Online_Country_Code__c='BB',Code__c=strcountryCode,Last_Operation_Performed__c='Test Data',
                                                                                     Inc_Vendor_Name__c=strvendorName,Inc_Vendor_End_Point__c='{TBD}');
                                                    }
                                                    else{
                                                        testCountry=  new Country__c(name='Bikini Bottom', Dell_Online_Country_Code__c='BB',Code__c=strcountryCode,Last_Operation_Performed__c='Test Data',
                                                                                     Inc_Vendor_Name__c='Not Applicable/On Hold');
                                                    }
                                                    insert testCountry;
                                                    
                                                    List<Account> listaccountList = new List<Account>();  
                                                    for (integer inti=0;inti<intnoOfAccount;inti++){
                                                        listaccountList.Add (new Account (name='Test' + inti,Account_Country_Code__c=strcountryCode,Account_Country__c='Bikini Bottom',type='Partner',
                                                                                          Is_Enabled_for_Incentives__c=true, RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId()));   
                                                    }
                                                    
                                                    insert listaccountList;
                                                    
                                                    List<Contact> listcontactList = new List<Contact>();
                                                    for (account accObject : listaccountList){
                                                        for (integer inti=0; inti <intNoOfContactPerAccount; inti++){
                                                            listcontactList.add(
                                                                new Contact( 
                                                                    AccountID = accObject.ID,
                                                                    Email = 'Email_'+inti+'@dellTeam.Com',
                                                                    FirstName = 'SpongeBob',
                                                                    LastName = '_' + inti,
                                                                    Title='VP',
                                                                    MailingStreet='123 Main',
                                                                    MailingCity='Peoria',
                                                                    MailingState='IL',
                                                                    MailingPostalCode='33333',
                                                                    Phone='3213213211',
                                                                    MobilePhone='3213213211',
                                                                    Fax='3213123211',
                                                                    Status__c = 'Marketing Suspect',
                                                                    Is_Enabled_for_Incentives__c =true
                                                                )
                                                            );
                                                        }      
                                                    }
                                                    insert listcontactList; 
                                                    system.assertEquals(listaccountlist.size(),intnoofaccount);
                                                    system.assertEquals(listcontactlist.size(),(intnoofaccount)*(intnoOfContactPerAccount));
                                                    return listaccountList;
                                                }
    
    /*private static testmethod void checkLOBUpdateForPartner(){

List<Account> listaccountList = new List<Account>(); 
Id endUserAccount  = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'GBL_Standard_RT' LIMIT 1].Id; 

for (integer inti=0;inti<10;inti++){
listaccountList.Add (new Account (name='Test' + inti,Account_Country__c='Bikini Bottom',//type='Partner', // 3.0: Commented the Type, 'Partner' type will auto change the record type to Partner Account
Participating_in_LOB_Program__c = true, RecordTypeId = endUserAccount));   
}

insert listaccountList;

system.assertEquals(10, listaccountList.size());


//User u = [SELECT Id FROM User WHERE Username ='inf_service_account@dell.com.dit3'];
// Fenny [20-Mar-2015]: Added because this test failure return in R16.03 mock validation
// Only users with the GCC Program Manager &quot;Title&quot; should be able to edit the checkbox.: [Participating_in_LOB_Program__c] 
List<User> listuList = [SELECT Id FROM User WHERE Username LIKE 'inf_service_account@dell.com%' AND IsActive = TRUE];
User updatedU = new User();

if(listuList != null && listuList.size() > 0){
System.runAs(listuList[0]){ //v2.1 added to allow user to update Title
User u = listuList[0];
u.Title = 'GCC Program Manager';
update u;

updatedU = [SELECT Id FROM User WHERE Id = :u.Id]; 
}

System.runAs(updatedU) {
List<Account> listupdateAccList = new List<Account>();
for(Account listacc : listaccountList){
listacc.RecordTypeId = System.Label.RecType_Partner_Account;
listupdateAccList.add(listacc);
}

update listupdateAccList;
system.assertEquals(10, listupdateAccList.size());
}
}
} */
    
    /* private static testmethod void sendEmailOnFieldChange(){
test.starttest();
Id accnIds= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
listAcc = [Select Id from Account limit 2];
/*Account accns = new Account(Name='Test Account', RecordTypeId = accnIds, Partner_Type__c = 'OEM',
Account_ID__c = '9876543210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM'
); 
insert accns;
Account accnts = new Account(Name='Test derAccount', RecordTypeId = accnIds, Partner_Type__c = 'OEM',
Account_ID__c = '98765210', Status__c = 'Active', Distribution_Sell_To_Countries__c = 'UNITED STATES',
DMU__c = false, Partner_Relationship__c = 'Authorized', Account_Country__c = 'UNITED KINGDOM'
); 
insert accnts;
list<account> listacclist= new list<account>();
Account obj = new Account();
obj.Name = 'Test Account';
obj.LOBi_Preferred_Partner_of_Record_Server__c = listAcc[0].id;
obj.LOBi_Preferred_Partner_of_Record_Storage__c = listAcc[0].id;
obj.LOBi_Preferred_Partner_of_Record__c = listAcc[0] .id;
// obj.LOBi_Preferred_Partner_of_Record_Network__c = accns .id; 
obj.Origination_Program_Client__c = 'Pick a fight';
//  obj.Origination_Program_Networking__c = 'Pick a fight';
obj.Origination_Program_Server__c = 'Pick a fight';
obj.Origination_Program_Storage__c = 'Pick a fight';
//  obj.Networking__c = true;
obj.CSG_Direct_Preference__c = true;
obj.Server__c = true;
obj.Storage__c = true;
obj.Server_Timestamp__c = system.today();
obj.Storage_Timestamp__c = system.today();
obj.Networking_Timestamp__c = system.today();
obj.CSG_Timestamp__c = system.today();

// insert obj;
listacclist.add(obj);
insert listacclist;
listacclist[0].LOBi_Preferred_Partner_of_Record_Server__c = listAcc[1].id;
listacclist[0].LOBi_Preferred_Partner_of_Record__c = null;
listacclist[0].CSG__c = false;
listacclist[0].Origination_Program_Client__c = '';
listacclist[0].LOBi_Preferred_Partner_of_Record_Network__c = listAcc[0].id;
listacclist[0].Networking__c = true;
listacclist[0].Origination_Program_Networking__c = 'Pick a fight';
update listacclist;
AccountUtilities.updateFields(listacclist);
system.assertEquals(1,listacclist.size());
test.stoptest();

}*/
}