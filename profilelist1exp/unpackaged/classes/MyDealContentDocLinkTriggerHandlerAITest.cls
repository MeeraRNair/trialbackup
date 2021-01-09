/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@IsTest
public class MyDealContentDocLinkTriggerHandlerAITest {
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1,'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1,'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static testmethod void contentDocLinkInsertTest(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "ContentDocumentLink", "Class_Name__c": "MyDealContentDocLinkTriggerHandlerAI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'ContentDocumentLink';
        tec.RecursiveCount__c = 2;
        insert tec;      
        
        Test.startTest();
        /* Account accA =new Account(Name='Demo');
insert accA ; 
Opportunity opp = new Opportunity(Name='test opp',
StageName='Discover - 10%', 
AccountId = accA.Id ,
Probability = 10, 
Forecast_Category_Override__c = 'Commit',
CloseDate=system.today());
insert opp;
*/
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob blbBody=Blob.valueOf('Unit Test ContentVersion Body');  
        content.VersionData=blbBody; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        system.assertNotEquals(listOpp[0].id, null);
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=listOpp[0].id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Test.stopTest();
    }
}