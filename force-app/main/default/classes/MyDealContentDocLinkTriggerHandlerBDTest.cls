/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@IsTest
public class MyDealContentDocLinkTriggerHandlerBDTest {
     @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
	static testmethod void contentDocLinkDeleteTest(){
		 String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'BeforeDelete' => new List<Boolean>{true, false, false, true, false}
        }; 
            
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "ContentDocumentLink", "Class_Name__c": "MyDealContentDocLinkTriggerHandlerBD"},';
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
        Opportunity opp=[select id from Opportunity Limit 1];
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob blbBody=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=blbBody; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        system.assertNotEquals(opp.id, null);
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=opp.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        Delete contentlink;
        Test.stopTest();
    }
}