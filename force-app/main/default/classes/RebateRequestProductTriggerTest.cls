@isTest
private class RebateRequestProductTriggerTest {

  private static testMethod void testAfterInsert() {
      profile profileId =   [select Id, Name from Profile where name like '%R16.10 GBL Sales Rep%' limit 1];
        User AllianceRebateUser = new User(Username='AllianceSalesUser' + System.currentTimeMillis() + '@dell.com',
                                           Alias = 'MTU9', 
                                           Email='AllianceUser@dell.com', 
                                           FirstName='Alliance', 
                                           LastName='Sales23',  
                                           ProfileId = profileId.id,
                                           LanguageLocaleKey='zh_CN',
                                           country = 'en_IN1',
                                           LocaleSidKey='zh_CN', 
                                           EmailEncodingKey='UTF-8', 
                                           TimeZoneSidKey='America/Los_Angeles',
                                           Badge_Number__c='Test99826513usi2', 
                                           isActive = TRUE);
        insert AllianceRebateUser;
        
          Opportunity opp = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test1sdsds@gmail.com');
        
       
         
    // Create Alliance STF Price
      
      Alliance_STF_Price__c stfPrice = new Alliance_STF_Price__c(Net_Price__c = 10,Name= '123456');
      insert stfPrice;
      
      // Create Alliance Rebate Request
      
      Alliance_Rebate_Request__c arReq = new Alliance_Rebate_Request__c();
            
            arReq.Sales_Force_Deal_ID__c = opp.id;
            arReq.System_Partner_Name__c ='Intel';
            arReq.Finance_Contact__c = 'xxx@dell.com';
            arReq.Business_Case_Information__c = 'test';
            arReq.Dell_Standard_CPU__c  =stfPrice.id;
            arReq.Partner_BDM_Name__c='test';
            insert arReq ;
      
        // Create Rebate request product
     
   
            
         Rebate_Request_Product__c productObj = new Rebate_Request_Product__c();
         productObj.Quantity__c=2;
         productObj.Part_Name_Part_Number__c='test';
         productObj.Dell_System_Model_type__c='testing';
         productObj.Alliance_Rebate_Request__c= arReq.id;
         
         insert productObj ;
       
        
  }
  
  private static testMethod void testAfterUpdate() {
      Account acc = new Account(name='Account');
      insert acc;
      TriggerExecutionController.setSkipAllTriggers(True);
     Opportunity opp1 = AllianceRebateRequestTrigger_Test.createOpportunityInfo('Test1sdsds@gmail.com');
                                        
    Alliance_STF_Price__c stfPrice1 = new Alliance_STF_Price__c(Net_Price__c = 10,Name= '123456');
      insert stfPrice1 ;
      
        list<Alliance_Rebate_Request__c> allianceReabteRequests = new list<Alliance_Rebate_Request__c>();
        for(integer i=0;i<1;i++){
            allianceReabteRequests.add(new Alliance_Rebate_Request__c(System_Partner_Name__c = 'Intel',Partner_BDM_Name__c='test',
                                                                      Sales_Force_Deal_ID__c = opp1 .id,
                                                                      Client_Enterprise__c = 'Client',
                                                                      Dell_Standard_CPU__c  = stfPrice1 .id,
                                                                      Finance_Contact__c = 'abc@gmail.com'));
        }
        insert allianceReabteRequests;
        
        list<Rebate_Request_Product__c> requestProds = new list<Rebate_Request_Product__c>();
        for(Alliance_Rebate_Request__c ar : allianceReabteRequests){
            requestProds.add(new Rebate_Request_Product__c(Alliance_Rebate_Request__c = ar.id,
                                                          Price_Requested__c = 10,
                                                          Quantity__c = 2,Status__c = 'Active'));
        }
        insert requestProds;
        
        Alliance_Rebate_Request__c newRebateReq = new Alliance_Rebate_Request__c(System_Partner_Name__c = 'Intel',Partner_BDM_Name__c='test',
                                                                      Sales_Force_Deal_ID__c = opp1 .id,
                                                                      Client_Enterprise__c = 'Client',
                                                                      Dell_Standard_CPU__c  = stfPrice1 .id,
                                                                      Finance_Contact__c = 'abc@gmail.com');
                                                                      
        insert newRebateReq;
        
        for(Rebate_Request_Product__c req : requestProds){
            req.Alliance_Rebate_Request__c = newRebateReq.id;
           req.Status__c= 'Expired';
           
        }
        update requestProds;
        TriggerExecutionController.setSkipAllTriggers(False);
  }
  
  
}