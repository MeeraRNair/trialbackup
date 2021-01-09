/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
public class VfCntrlUpdateRelatedContactTest{
    static list<Account> listAcc;
    static list<Campaign> listCamp;
    static list<Contact> listcon;
    static list<Lead> listlead;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Campaign> listCampaignTDF = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
        insert listCampaignTDF;
        list<Account> listAccTDF = TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTDF;
        list<Contact> listConTDF = TestDataFactory.CreateNContacts(1);
        listConTDF[0].AccountId=listAccTDF[0].id;
        insert listConTDF;
        list<Lead> listleadTDF = TestDataFactory.createNLeads(1,'Direct Lead 2.0');
        listleadTDF[0].Campaign__c = listCampaignTDF[0].id;
        listleadTDF[0].Contact__c = listConTDF[0].id;
        insert listleadTDF;
        TriggerExecutionController.setSkipAllTriggers(true);
    }
    static testMethod void updRelCnctTestMethod(){
        TriggerExecutionController.setSkipAllTriggers(true);
        //Create Test Account
        listacc = [select Id from Account];
        listcon = [select Id from Contact];
        listlead = [select Id from Lead];
        listcamp = [select Id from Campaign];
        system.assertNotEquals(listacc[0].id, null);
        /*Account testAccount=new Account(name='testAccount_No1');
insert testAccount;

// Instantiate a new controller with all parameters in the page
Contact testCon = new Contact(Status__c    = 'Active', 
AccountId    = listacc.Id, 
firstname    = 'Test',
LastName     = 'TestContact0367',
Phone        = '111-1000',
Decision_Making_Role__c            = 'Influencer',
EMEA_Decision_Making_Role__c       = 'Influencer', 
Purchaser_Influence_over_Merged__c = 'Enterprise - Networking' 
);
insert testCon;

Campaign  testCampaign = new Campaign(Name='Test Campaign',
Campaign_Objective__c = 'LOB Conversion',
Type='DM',
Segment_Business_Unit__c='PUB',
//Region__c='ABU',
StartDate=System.Today() - 10,
EndDate=System.Today(),
Description='This is Test Campaign',                                            
Account_Play_Expiry_Date__c=System.today() + 60,
IsActive=true);
insert testCampaign;*/
        /*   Lead testLead = new Lead(FirstName = 'NewTest',
LastName = 'Lead',
Company = 'Test Company',
Status = 'Open',
Phone = '1234567891',
Campaign__c = listcamp[0].id,
Contact__c = listcon[0].id,
Data_Center_Optimization__c = 'Virtualization',
End_user_Productivity__c = 'SharePoint',
IT_Process_Simplification__c = 'Flex Computing',
Dell_can_contact_me_in_the_future__c = 'Yes',
Decision_Making_Role__c = 'Influencer',
Employees__c = '10000+',
Dell_Existing_Customer__c = 'Yes',
Purchase_Timeframe__c = 'Immediately',
Purchase_Influence_Over__c = 'Services - Client',
Country_Code__c = 'AE',
LeadSource = 'Email',
Lead_Type__c = 'Inbound');//,
//Questions_Comments__c = 'Sample Questions');
insert testLead;
*/
        Lead testLead=[select id,Campaign__c,Contact__c,Country_Code__c,LeadSource,Lead_Type__c from lead limit 1];
        //Insert records to custom settings object
        List<Enhance_Contact_from_Lead__c> listEcfl = new list<Enhance_Contact_from_Lead__c>();
        Enhance_Contact_from_Lead__c ec1 = new Enhance_Contact_from_Lead__c(Name='First Name',
                                                                            Contact_Field_Name__c = 'FirstName',
                                                                            Lead_Field_Name__c = 'FirstName',
                                                                            Hide_Field__c = false,
                                                                            Order__c = 1);
        listEcfl.add(ec1);
        
        Enhance_Contact_from_Lead__c ec2 = new Enhance_Contact_from_Lead__c(Name='Last Name',
                                                                            Contact_Field_Name__c = 'LastName',
                                                                            Lead_Field_Name__c = 'LastName',
                                                                            Hide_Field__c = false,
                                                                            Order__c = 2);
        listEcfl.add(ec2);
        
        Enhance_Contact_from_Lead__c ec3 = new Enhance_Contact_from_Lead__c(Name='NO LABEL',
                                                                            Contact_Field_Name__c = 'CASL_Consent__c',
                                                                            Lead_Field_Name__c = '',
                                                                            Hide_Field__c = true,
                                                                            Order__c = 3);
        listEcfl.add(ec3);
        
        Enhance_Contact_from_Lead__c ec4 = new Enhance_Contact_from_Lead__c(Name='NO LABEL1',
                                                                            Contact_Field_Name__c = 'CASL_Selection__c',
                                                                            Lead_Field_Name__c = '',
                                                                            Hide_Field__c = true,
                                                                            Order__c = 4);
        listEcfl.add(ec4);
        
        insert listEcfl; 
        
        Test.startTest();
        PageReference pageRef = Page.VfUpdateRelatedContact;
        pageRef.getParameters().put('leadId', testLead.id);
        pageRef.getParameters().put('ContactId', listcon[0].id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController tlead = new ApexPages.StandardController(testLead);
        VfCntrlUpdateRelatedContact urc = new VfCntrlUpdateRelatedContact();
        VfCntrlUpdateRelatedContact.Compare comparevar = new VfCntrlUpdateRelatedContact.Compare('Test1');
        urc.save();
        urc.Cancel();
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}