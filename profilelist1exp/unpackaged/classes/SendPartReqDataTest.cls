@isTest
public class SendPartReqDataTest {
    static list<Account> listAcc;
    static list<Campaign> listcamp;
    static testMethod void mock1() {
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
        list<user> listuserTDF = TestDataFactory.createNGenralUsers(1);
        listuserTDF[0].ProfileId = profile.Id;
        insert listuserTDF;
        
        /*   User testUser = new User(Username='testvaliduser' +'@dell.com',
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
TriggerExecutionController.setSkipUserTriggers(true);
insert testUser;  
TriggerExecutionController.setSkipUserTriggers(false);
*/
        
        
        system.runAs(listuserTDF[0]){
            Country__c c=new Country__c(Name='India1',Code__c='JZ',Region__c='LATAM');
            insert c;
            list<campaign> listcamp = TestDataFactory.createNCampaign(1, 'Campaign 2.0');
            insert listcamp;
            list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
            insert listAcc;
            /*           Campaign camp=new Campaign(Name='testcamp',IsActive=true);
insert camp;
Account a=new Account(Name='TestAcc');
insert a;*/
            Lead l=new Lead(Partner_Master_Grouping_id__c='repro',Account__c=listAcc[0].id,Lead_Type__c='Outbound',Universal_Customer_ID_UCID__c='7234692',LastName='jsd',Company='testcmp',Phone='56789',LeadSource='Web',LastNameLocal='testLead',PPA_UCID__c='234',Mg_Name__c='sdfg',Campaign__c=listcamp[0].id,Country_Code__c='IN');
            TriggerExecutionController.setSkipLeadTriggers(true);
            insert l;
            
            TriggerExecutionController.setSkipLeadTriggers(false);
            Partner_request__C pr = new Partner_request__C(Lead__c=l.id,First_Name__c='TestFirst',
                                                           Org_Country__c=c.id,Org_Address_1__c ='test',Org_Address_2__c ='test2',Link_To_Account_Flag__c=true
                                                          );   
            insert pr; 
            System.assertEquals('TestFirst', pr.First_Name__c);
            // system.debug('label : '+Label.PartReq_To_EMC_Client_ID);
            Test.startTest(); 
            Test.SetMock(HttpCallOutMock.class, new SendPRDataMock());
            try{SendPartReqData.sendPRCalloutREST(pr.id);               
               }catch(exception e){} 
            try{
                //SendPartReqData.updateMgPgIdFromEMC(null,pr.id,pr);
            }catch(exception e){}
            Test.stopTest();
        }
    }
}