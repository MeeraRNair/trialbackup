/*
  * Author   : Ravali K
  * Purpose  : This class is a test class associated to VMwareSearchCapabilityController and VMwareSearchApiCallOut.
  *
  * Revision   CR Number   Release No          Date          Modified By      Description
  * --------  ---------   ----------        -----------     ------------      -----------
  * 1.0         14782     FY18-DCS-1001       25-Aug-17      Ravali - UST      Created Test class
  *
*/

@IsTest
private class VMwareSearchCapabilityControllerTest {    
    
      
    static testMethod void TestVMwareSearch()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        
        
        Account acc=new Account(name='test contact', Account_Country_Code__c='US',Account_Country__c='United States');
        insert acc;
        
         Opportunity testOppty= new Opportunity(Name = 'test', CloseDate = System.today(), StageName = 'Plan - 1%');
         insert testOppty;
            
        
        
        S_P_Vendors__c SnPRecord = new S_P_Vendors__c();
        
        SnPRecord.Customer_Name__c = 'Test Company';
        SnPRecord.Customer_Domain__c = 'Test Domain';
        SnPRecord.Ship_to_Address__c= 'Test Address';
        SnPRecord.Country__c= 'Test Country';
        SnPRecord.City__c= 'Test City';
        SnPRecord.State__c= 'Test State';
        SnPRecord.Zip__c= 'Test Zip';
        SnPRecord.Opportunity__c =testOppty.id; 
        
        Insert SnPRecord;
        
        
         Project_Services__c ps = new Project_Services__c(name='Mulesoft',Client_Id__c='00000000A',Client_Secret__c='00000000B');
         insert Ps;  
         
         PageReference tpageRef = Page.VF_VMwareSearchCapability;
         Test.setCurrentPage(tpageRef);
         
         
         ApexPages.currentPage().getParameters().put('Id', SnpRecord.Id);
         system.debug('*********SnP Record ID********* '+ApexPages.currentPage().getParameters().get('Id'));
         ApexPages.currentPage().getParameters().put('selectedRow', 'CUST-0001573041');
         
         System.Assert(ApexPages.currentPage().getParameters().get('selectedRow')=='CUST-0001573041');
         System.Assert(ApexPages.currentPage().getParameters().get('Id')== SnpRecord.Id);
    
         Test.startTest();
                  
         //Test.setMock(HttpCalloutMock.class, new Mulesoft_MockHttpResponseGenerator());
         Test.setMock(HttpCalloutMock.class, new VMWare_MockHttpResponseGenerator());
         
         //System.assert(contentType == 'application/json');
         VMwareSearchCapabilityController controller = new VMwareSearchCapabilityController();
         Controller.Search();
         
                  
         controller.SnPRecord.Country__c= 'INDIA';
         //controller.getEnable();
         //controller.companyname = 'Wells';
         controller.Search();
         System.assert(controller.SnPRecord.Country__c == 'INDIA');
         controller.companyname = 'Wells';
         controller.Search();
         
         

         

         
         Controller.Save();

         
         //Controller.overrideDetails();
         //Controller.cancelOverrideDetails();
         
         Test.stopTest();
         TriggerExecutionController.setSkipAllTriggers(false);

         
         
         
    }

}