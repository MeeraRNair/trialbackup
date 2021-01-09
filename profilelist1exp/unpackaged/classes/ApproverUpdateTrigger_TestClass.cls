/*
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Fenny       21-Oct-2014     Sprint 3    10520   DGRApproverAfterInsertChatterFeed trigger created and require FeedItem.PartnerId from Approver__c.Approver__c

*/
@isTest
private class ApproverUpdateTrigger_TestClass{
    static testMethod void unittest(){
     
        Approval_Request__c apreq = new Approval_Request__c();
        apreq.Approval_Request_Type__c = 'DGR Qualify Gate Approval';
        insert apreq;
        
        Approver__c apinsert = new Approver__c();
        apinsert.Approver_Status__c = 'Submitted';
        apinsert.Action__c = 'Approval Request Submitted to Approver';
        apinsert.Approval_Request__c = apreq.id;
        apinsert.Approver__c = UserInfo.getUserId(); // 1.0
        insert apinsert;
        
        Approver__c ap = new Approver__c();
        ap.Approver_Status__c = '';
        ap.Action__c = 'Approval Request Submitted to Approver';
        ap.Approval_Request__c = apreq.id;
        ap.Approver__c = UserInfo.getUserId(); // 1.0
        insert ap;
        
        ap.Approver_Status__c = 'Submitted';
        update ap;
        
    } 
}