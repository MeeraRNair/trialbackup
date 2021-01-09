@IsTest
private class PartnerRegistrationActionPanelCtrlExTest {

    private static final Set<String> NEW_INCOMPLETE_RESUBMITTED = new Set<String>{
            null,
            PartnerConstants.REG_STATUS_DRAFT, 
             PartnerConstants.REG_STATUS_OWNED,
            PartnerConstants.REG_STATUS_INCOMPLETE,
            PartnerConstants.REG_STATUS_RESUBMITTED};
    
    private static testmethod void testErrorForUnsavedPartnerRequest() {
        final Partner_Request__c request = mockRequest();
       
        PartnerRegistrationActionPanelCtrlExt controller = new PartnerRegistrationActionPanelCtrlExt(
            new ApexPages.standardController(request));
         
        System.assertEquals(null,controller.doOnLoad()); 
        System.assertNotEquals(null,controller.errorCode); 
        System.assertEquals(true,controller.errorOccurred); 
    }
    
      private static testmethod void testMarkCompleteReviewForCompleteness1() {
        final Partner_Request__c request1 = mockRequest1();
        Database.insert(request1);
        
          final PartnerRegistrationActionPanelCtrlExt controller1 = new PartnerRegistrationActionPanelCtrlExt(
             new ApexPages.standardController(request1));
        System.assertEquals(null,controller1.doOnLoad()); 
      }
    private static testmethod void testMarkCompleteReviewForCompleteness() {
        final Partner_Request__c request = mockRequest();
        insert request;

        final PartnerRegistrationActionPanelCtrlExt controller = new PartnerRegistrationActionPanelCtrlExt(
            new ApexPages.standardController(request));
      
       System.assertEquals(null,controller.doOnLoad()); 
       System.assertEquals(null,controller.errorCode); 
       System.assertEquals(0,controller.percentComplete);
    
       System.assertEquals(null,getTaskByTaskCompleteFlagFieldName(null,null)); 
       System.assertEquals(null,getActionFromTaskByLabel(null,null)); 
       controller.ownedStatus();
       controller.removeAll();
        final PartnerOnboardingTask reviewForCompletenessIsCompleteFlagTask = getTaskByTaskCompleteFlagFieldName(
            'Review_for_Completeness_Is_Complete_Flag__c',
            controller);
        System.assertNotEquals(null,reviewForCompletenessIsCompleteFlagTask);
        final PartnerOnboardingTaskAction markCompleteAction = getActionFromTaskByLabel(
            'Mark as Complete',
            reviewForCompletenessIsCompleteFlagTask); 
       System.assertNotEquals(null,markCompleteAction);

       System.assertEquals(true,markCompleteAction.show);     
       System.assertEquals(null,markCompleteAction.doAction());  
       System.assertEquals(false,markCompleteAction.show);     
       System.assertNotEquals(0,controller.percentComplete);
    }
    
    private static PartnerOnboardingTask getTaskByTaskCompleteFlagFieldName(String strtaskCompleteFlagFieldName, 
                                                                            PartnerRegistrationActionPanelCtrlExt controller){
        if(controller != null && controller.tasks != null && controller.tasks.size() > 0){
            for(PartnerOnboardingTask task : controller.tasks){
                if(al.StringUtils.equalsIgnoreCase(strtaskCompleteFlagFieldName,task.taskCompleteFlagFieldName)){
                    return task;
                }
            } 
        }
        return null;
    }
    
    private static PartnerOnboardingTaskAction getActionFromTaskByLabel(  String strlabel, 
                                                                    PartnerOnboardingTask task){
        if(task != null && task.actions != null && task.actions.size() > 0){
            for(PartnerOnboardingTaskAction action : task.actions){
                if(al.StringUtils.equalsIgnoreCase(strlabel,action.label)){
                    return action;
                }
            } 
        }
        return null;
    }
    
    private static Partner_Request__c mockRequest(){
        return new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME Computers',
            RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER, 'Partner_Request__c', true)
        );
    }
   private static Partner_Request__c mockRequest1(){
            Partner_Request__c req = new Partner_Request__c(
            Account__c=null,
            Review_for_Completeness_Is_Complete_Flag__c=false,
            Check_For_Duplicates_Is_Complete_Flag__c=false,
            First_Name__c = 'John arryn',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'ACME sale Computers',
            RecordTypeId=IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_EXIST_PARTNER,'Partner_Request__c', true));
           
            return req;
        
        
        
    }
}