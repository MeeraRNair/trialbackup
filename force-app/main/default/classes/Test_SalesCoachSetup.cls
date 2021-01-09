@isTest(SeeAllData = false)
private class Test_SalesCoachSetup{
  
 
  public static testmethod void controllerMethod(){
  
    Opportunity oppRecord = new Opportunity();
    oppRecord.StageName = 'Plan - 1%';
    oppRecord.CloseDate = System.Today();
    oppRecord.Name = 'Test Opp';
    insert oppRecord;
    
    Sales_Coach_Setup__c salesCoachRecord = new Sales_Coach_Setup__c();
    salesCoachRecord.Name = 'Plan - 1%';
    salesCoachRecord.Language__c = 'English';
    salesCoachRecord.LanguageCode__c = 'en_US';
    salesCoachRecord.Active__c = true;
    salesCoachRecord.Goal_Stage__c = 'Goal Sales Coach';
    insert salesCoachRecord;
    
    List<Sales_Coach_Activity__c> salesActivityList = new List<Sales_Coach_Activity__c>();
    for(integer i =0 ; i<6 ; i++){
      Sales_Coach_Activity__c salesActivityRecord = new Sales_Coach_Activity__c();
      salesActivityRecord.Activity_Details__c ='Sales Activity'+i;
      salesActivityRecord.Ordering_Number__c = i;
      salesActivityRecord.Sales_Coach_Setup__c= salesCoachRecord.Id;
      salesActivityList.add(salesActivityRecord);
    }  
    insert salesActivityList;
    
    PageReference pageRef =Page.SalesCoachSetup;
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController  stdCon = new ApexPages.StandardController(salesCoachRecord);
    SalesCoachSetup controller = new SalesCoachSetup (stdCon); 
    
    SalesCoachSetup.getOpptyStages();
    SalesCoachSetup.getKeyprefix();
    
    controller.getLanguages();
    controller.saveClose();
    controller.btncancel();
    controller.saveActivities();    
    controller.deleteActivity();
  }
  
    
}