/*
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0       CR18117    FY20-1101   23-Sept-2019     Hari A        Test class for ContentDocLinkTriggerHandlerAD/ContentDocLinkUtilities
 * 
 */ 

@isTest
public class ContentDocLinkTriggerHandlerADTest{

public static testmethod void deleteCDLTest(){
    String strMockMetaData = '';
    
    Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
        'AfterDelete' => new List<Boolean>{false, false, false, true, false}
    };
    
    for(String strEvent : mapEvents.keySet()) {
    strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
            + '"NamespacePrefix": "",'
            + '"Event__c": "' + strEvent + '", '
            + '"sObject__c": "ContentDocumentLink", "Class_Name__c": "ContentDocLinkTriggerHandlerAD"},';
    }
    
    strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
    
    MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
      
    Test.startTest();
    Account acc = new Account(Name = 'Testacc');
    insert acc;
    
    SFDC_Acct_Plan__c sap = new SFDC_Acct_Plan__c();
    sap.Account__c = acc.id;
    sap.name = 'Test AP';
    
    insert sap;
    system.assertEquals('Test AP',sap.Name);
    SFDC_Acct_Plan__c sapDel = new SFDC_Acct_Plan__c();
    sapDel.Account__c = acc.id;
    sapDel.name = 'Test AP Del';
    
    insert sapDel;
    
    ContentVersion content=new ContentVersion(); 
    content.Title='Header_Picture1'; 
    content.PathOnClient='/' + content.Title + '.jpg'; 
    Blob blbBody=Blob.valueOf('Unit Test ContentVersion Body'); 
    content.VersionData=blbBody; 
    content.origin = 'H';
    insert content;
    
    
    ContentDocumentLink contentlink=new ContentDocumentLink();
    contentlink.LinkedEntityId=sap.id;
    contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
    contentlink.ShareType = 'I';
    contentlink.Visibility = 'AllUsers'; 
    
    insert contentlink;
    
    ContentDocumentLink contentlinkDel=new ContentDocumentLink();
    contentlinkDel.LinkedEntityId=sapDel.id;
    contentlinkDel.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
    contentlinkDel.ShareType = 'I';
    contentlinkDel.Visibility = 'AllUsers'; 
    
    insert contentlinkDel;
    
    ContentDocumentLink cdl = [select id from ContentDocumentLink where id=:contentlinkDel.id];
    delete cdl;
    Test.stopTest();

    }
}