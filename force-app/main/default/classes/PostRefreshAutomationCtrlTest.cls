@isTest(seeAllData=false)
private class PostRefreshAutomationCtrlTest {

    static Folder emailFolder;
    static Folder docFolder;
    static Document doc;
    static Document foundDoc;
    static EmailTemplate foundEmail;
    
    //test method to trigger error when calling automate4Document
    static testMethod void ReplaceDocument_NoDocumentPatternError_Test() {
    
        //use existing doc folder and create new document
        //no new pattern created, triggering error to be thrown
        findDocFolder();
        createDocument();
         
        PageReference pageRef = Page.PostRefreshAutomation;
        Test.setCurrentPage(pageRef);
      
        Test.startTest();    
        
        PostRefreshAutomationCtrl controller = new PostRefreshAutomationCtrl();
        controller.automate4Document(); 
        
        Test.stopTest();  

        queryDoc();
        
        System.assertEquals('TestDoc1', foundDoc.body.toString());
            
    }
    
    
    //test method to trigger successful replacement when calling automate4Document
    static testMethod void ReplaceDocument_Success_Test() {
    
        //use existing doc folder and create new document
        //replacement automation is done to this new document according to new document pattern
        findDocFolder();
        createDocument();
        createDocPattern();
        
        PageReference pageRef = Page.PostRefreshAutomation;
        Test.setCurrentPage(pageRef);
      
        Test.startTest();    
        
        PostRefreshAutomationCtrl controller = new PostRefreshAutomationCtrl();
        controller.automate4Document(); 
        
        Test.stopTest();  
        
        queryDoc();
        
        System.assertEquals('TestDoc2', foundDoc.body.toString());
    
    }
    
    //test method to trigger error when calling automate4EmailTemplate
    static testMethod void ReplaceEmailTemplate_NoEmailPatternError_Test() {
    
        //no new pattern created, triggering error to be thrown        
        PageReference pageRef = Page.PostRefreshAutomation;
        Test.setCurrentPage(pageRef);
      
        Test.startTest();    
        
        PostRefreshAutomationCtrl controller = new PostRefreshAutomationCtrl();
        controller.automate4EmailTemplate(); 
        
        Test.stopTest();  

        queryEmail();
        
        System.assertNotEquals('TestEmail2', foundEmail.body);
    
    }
   
   
    //test method to trigger successful replacement when calling automate4EmailTemplate
    static testMethod void ReplaceEmailTemplate_Success_Test() {
    
        //assuming the replacement will be done to existing email template with developerName below:
        //'PRMDellInternalDealRegistrationApprover','PRMDellInternalPartnerWonorLostEmail','PRMDellInternalRegistrationSalesTeam'
        //replacement automation is done to this existing email template according to new email template pattern created
        //but replacement wont be successful, as no string meet the pattern defined
        createEmailPattern();
        
        PageReference pageRef = Page.PostRefreshAutomation;
        Test.setCurrentPage(pageRef);
      
        Test.startTest();    
        
        PostRefreshAutomationCtrl controller = new PostRefreshAutomationCtrl();
        controller.automate4EmailTemplate(); 
        
        Test.stopTest();  
        
        queryEmail();
        
        System.assertNotEquals('TestEmail2', foundEmail.body);
        
    }
    
    
    static void createDocument(){
    
        doc = new Document();
    
        doc.body = Blob.valueOf('TestDoc1');
        doc.Name = 'TestDoc' + System.currentTimeMillis();
        doc.FolderId = docFolder.Id;
        doc.type = 'html';
        doc.DeveloperName = 'TestDoc' + System.currentTimeMillis();
        
        insert doc;
        
    }
    
    static void findDocFolder(){
    
        docFolder = [Select Id from Folder where Name = 'Default Theme' limit 1];
     
    } 
 
    static void queryDoc(){
    
        foundDoc = [Select body from Document where Id = :doc.Id];
    
    }
     
    static void queryEmail(){
    
        foundEmail = [Select body from EmailTemplate where DeveloperName = 'PRMDellInternalDealRegistrationApprover'];
    
    } 
     
    static void createDocPattern(){
    
        PostRefreshReplacementPattern__c patternDoc = new PostRefreshReplacementPattern__c();
    
        patternDoc.Name = 'PatternDoc' + System.currentTimeMillis();
        patternDoc.Type__c = 1;
        patternDoc.Sequence__c =  1;
        patternDoc.MatchPattern__c = 'TestDoc1';
        patternDoc.ReplacementPattern__c = 'TestDoc2';
       
        insert patternDoc ;
        
    } 

    static void createEmailPattern(){
    
        PostRefreshReplacementPattern__c patternEmail = new PostRefreshReplacementPattern__c();
    
        patternEmail.Name = 'PatternEmail' + System.currentTimeMillis();
        patternEmail.Type__c = 2;
        patternEmail.Sequence__c =  1;
        patternEmail.MatchPattern__c = 'TestEmail1';
        patternEmail.ReplacementPattern__c = 'TestEmail2';
       
        insert patternEmail ;
        
    }
    
  
}