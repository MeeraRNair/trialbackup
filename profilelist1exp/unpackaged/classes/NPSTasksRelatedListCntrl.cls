public with sharing class NPSTasksRelatedListCntrl {
    public List<Task> NPSTask{set;get;}
    public Id CaseId{set;get;}
    public NPSTasksRelatedListCntrl(ApexPages.StandardController controller) {
        if(controller.getId() != null){
            NPSTask = [SELECT Id, Whatid, Subject, OwnerId, NSS_Category__c, ActivityDate, Status, Priority FROM Task WHERE RecordType.Name=:'NPS Task' and WhatId =: controller.getID() ORDER BY ActivityDate DESC LIMIT 1000];
            CaseId = controller.getId();
        }
        else
            NPSTask = [SELECT Id, Whatid,Subject, OwnerId, NSS_Category__c, ActivityDate, Status, Priority FROM Task WHERE RecordType.Name=:'NPS Task' and OwnerId =: UserInfo.getUserId() ORDER BY ActivityDate DESC LIMIT 1000];
    }
}