@isTest 
private class Reset_Rebate_Rule_Page_Controller_Test{
    static testMethod void validateFunctionality() {
         Vendor__c venObj = new Vendor__c(Name = 'Test Vendor',Partner_Status__c='Active');
         insert venObj;
         Rebate_Rule_Header__c rrhObj = new Rebate_Rule_Header__c(Vendor__c = venObj.Id,Status__c='Pending',Fiscal_Quarter__c='FY17Q1', Region__c='Americas');
         insert rrhObj;
         PageReference pageRef = Page.Reset_Rebate_Rule_Page;
         Test.setCurrentPage(pageRef);
         ApexPages.currentPage().getParameters().put('id', rrhObj.Id);
         Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
         app.setObjectId(rrhObj.Id);
         Id[] ApproverIds =new Id[]{UserInfo.getUserId()};
         app.setNextApproverIds(ApproverIds);
         Approval.ProcessResult result = Approval.process(app);
         Profile p = [SELECT Id FROM Profile WHERE Name='MDF Marketing Operations / Contract Admin']; 
         User u = new User(Alias = 'standmdf', Email='standardmdfuser@dell.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='012900', UserName='standardmdfuser@dell.com');
         System.RunAs(u){
             Reset_Rebate_Rule_Page_Controller objCntrl = new Reset_Rebate_Rule_Page_Controller();
             objCntrl.strComments = 'Recall Rebate Rule Header';
             objCntrl.invokeOnLoad();
         }
    }
}