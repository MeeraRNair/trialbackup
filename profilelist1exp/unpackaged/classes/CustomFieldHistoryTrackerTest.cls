/***********************************************************
    * Name          : CustomFieldHistoryTrackerTest 
    * Description   : test class for Class CustomFieldHistoryTracker.
    * ---------------------------------------------------------
    * Revision  Name         Date        Description
    * 1.0       Azwanti    06.07.2015    MAJ16.07 CR11598: created 
    * 2.0		Azwanti 				 (SeeAllData=true)
    * 3.0		Azwanti 	19.10.2016	 CR13624 : Track CM status creation history changes in Campaign Member 2.0, delete (SeeAllData=true)
    * 
    ************************************************************/
@isTest
public class CustomFieldHistoryTrackerTest {

    static testMethod void testEditOLI() {     
        //v3.0 create custom setting values
        List<Supportability_Field_Tracking__c> listSuppSetting = new List<Supportability_Field_Tracking__c>();
                
        Supportability_Field_Tracking__c suppSetting1 = new Supportability_Field_Tracking__c(Name = 'Alternate_Item__c', Type__c='Text');
        listSuppSetting.add(suppSetting1);
        Supportability_Field_Tracking__c suppSetting2 = new Supportability_Field_Tracking__c(Name = 'Configuration_Services__c', Type__c='Picklist');
        listSuppSetting.add(suppSetting2);
        Supportability_Field_Tracking__c suppSetting3 = new Supportability_Field_Tracking__c(Name = 'Customer_Requested_Date__c', Type__c='Date');
        listSuppSetting.add(suppSetting3);
        Supportability_Field_Tracking__c suppSetting4 = new Supportability_Field_Tracking__c(Name = 'Discount_off__c', Type__c='Percent');
        listSuppSetting.add(suppSetting4);
        Supportability_Field_Tracking__c suppSetting5 = new Supportability_Field_Tracking__c(Name = 'DPID__c', Type__c='Text');
        listSuppSetting.add(suppSetting5);
        Supportability_Field_Tracking__c suppSetting6 = new Supportability_Field_Tracking__c(Name = 'Mrgn__c', Type__c='Percent');
        listSuppSetting.add(suppSetting6);
        Supportability_Field_Tracking__c suppSetting7 = new Supportability_Field_Tracking__c(Name = 'Quantity', Type__c='Number');
        listSuppSetting.add(suppSetting7);
        Supportability_Field_Tracking__c suppSetting8 = new Supportability_Field_Tracking__c(Name = 'Quote_Expiration_Date__c', Type__c='Date');
        listSuppSetting.add(suppSetting8);
        Supportability_Field_Tracking__c suppSetting9 = new Supportability_Field_Tracking__c(Name = 'Quote__c', Type__c='Text');
        listSuppSetting.add(suppSetting9);
        Supportability_Field_Tracking__c suppSetting10 = new Supportability_Field_Tracking__c(Name = 'Request_Type__c', Type__c='Picklist');
        listSuppSetting.add(suppSetting10);
		Supportability_Field_Tracking__c suppSetting11 = new Supportability_Field_Tracking__c(Name = 'Sales_Response_Due_On__c', Type__c='Date');
        listSuppSetting.add(suppSetting11);
		Supportability_Field_Tracking__c suppSetting12 = new Supportability_Field_Tracking__c(Name = 'Supportability_Additional_Comments__c', Type__c='Text Area');
        listSuppSetting.add(suppSetting12);
		Supportability_Field_Tracking__c suppSetting13 = new Supportability_Field_Tracking__c(Name = 'Supportability_Comments__c', Type__c='Long Text Area');
        listSuppSetting.add(suppSetting13);
        Supportability_Field_Tracking__c suppSetting14 = new Supportability_Field_Tracking__c(Name = 'Supportability_Last_Updated__c', Type__c='Date/Time');
        listSuppSetting.add(suppSetting14);
        Supportability_Field_Tracking__c suppSetting15 = new Supportability_Field_Tracking__c(Name = 'Supportability_Status__c', Type__c='Picklist');
        listSuppSetting.add(suppSetting15);
        Supportability_Field_Tracking__c suppSetting16 = new Supportability_Field_Tracking__c(Name = 'Supported_Quantity__c', Type__c='Number');
        listSuppSetting.add(suppSetting16);
        Supportability_Field_Tracking__c suppSetting17 = new Supportability_Field_Tracking__c(Name = 'Support_by_Date__c', Type__c='Date');
        listSuppSetting.add(suppSetting17);
        Supportability_Field_Tracking__c suppSetting18 = new Supportability_Field_Tracking__c(Name = 'TotalPrice', Type__c='Currency');
        listSuppSetting.add(suppSetting18);
        Supportability_Field_Tracking__c suppSetting19 = new Supportability_Field_Tracking__c(Name = 'UnitPrice', Type__c='Currency');
        listSuppSetting.add(suppSetting19);
        
        insert listSuppSetting;
        //v3.0 end
        
        //create acc
        Account testAcc = new Account(Name='testCustomFieldHistoryTrackerTest Account');
        insert testAcc;
        
        //create Opportunity
        Opportunity testOppty = new Opportunity(StageName='Propose - 60%', Probability=60, AccountId=testAcc.Id, Name='TEST Oppty 1', CloseDate = System.today() + 30, 
                                                Primary_Product_Delivery_Address_Region__c = 'REGION1', Primary_Product_Delivery_Address_Country__c = 'COUNTRY1',
                                                Region__c='APJ',Competitor_Lost_To__c='Unknown');
        //v2.0
        ProcessFlowTriggerController.isTest = true; //v3.0 added to avoid CANNOT_EXECUTE_FLOW_TRIGGER error on flow       
		insert testOppty;
        ProcessFlowTriggerController.isTest = false; //v3.0 set back to false
        
        Id pricebookId = Test.getStandardPricebookId();

        //Create your product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = testOppty.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 500.00
        );
        insert oli;
               
        
        //edit product
        OpportunityLineItem editOli = [Select Alternate_Item__c, Configuration_Services__c, Customer_Requested_Date__c, Discount_off__c, DPID__c,
                                       Mrgn__c, Quantity, Quote_Expiration_Date__c, Quote__c, Request_Type__c, Supportability_Comments__c, Supportability_Status__c,
                                       Supported_Quantity__c, Support_by_Date__c 
                                       From OpportunityLineItem Where Id = :oli.Id limit 1];
        
        editOli.Alternate_Item__c = 'new test product';
        editOli.Configuration_Services__c = 'Yes';
        editOli.Customer_Requested_Date__c = System.Today() + 100;
        editOli.Discount_off__c = 2;
        editOli.DPID__c = '1234';
        editOli.Mrgn__c = 2;
        editOli.Quantity = 1000;
        editOli.Quote_Expiration_Date__c = System.Today() + 10;
        editOli.Quote__c = '4321';
        editOli.Request_Type__c = 'Ship';
        editOli.Supportability_Comments__c = 'added comment';
        editOli.Supportability_Status__c = 'Under Review';
        editOli.Supported_Quantity__c = 20000;
        editOli.Support_by_Date__c = System.Today() + 15;
        editOli.UnitPrice = 1.00;
        Test.startTest();
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false); // v3.0
        update editOli;       
        
        Integer actualHistoryCreated = [Select count() From Supportability_Field_History__c Where Record_Id__c = :editOli.Id];     
        system.debug('############# actualHistory : '+actualHistoryCreated);
        system.assert(actualHistoryCreated > 0);
        Test.stopTest();
    }
    
    //v3.0
    static testMethod void testCMUpdateStatus(){
		//create custom setting values
        List<Campaign_Member_Field_Tracking__c> listCMSetting = new List<Campaign_Member_Field_Tracking__c>();
                
        Campaign_Member_Field_Tracking__c cmSetting1 = new Campaign_Member_Field_Tracking__c(Name = 'CM_Status__c', Type__c='Picklist');
        listCMSetting.add(cmSetting1);
        
        Campaign_Member_Field_Tracking__c cmSetting2 = new Campaign_Member_Field_Tracking__c(Name = 'CreatedDate', Type__c='Date/Time', ReferenceName__c = 'Created Date');
        listCMSetting.add(cmSetting2);
        
        Test.startTest();
        insert listCMSetting;
        
        LeadTestData.bCreate = true;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> listDirectLeads2 = LeadTestData.lstLeads;   
        
        List<Id> listCampaignId = new List<Id>();        
        for(Lead lead:listDirectLeads2){
            listCampaignId.add(lead.Campaign__c);
        }
                
        List<CampaignMember> listCM = [SELECT Id, CM_Status__C FROM CampaignMember WHERE CampaignId IN : listCampaignId];
		List<CampaignMember> listActualCM = new List<CampaignMember>();
        List<Id> listActualCMId = new List<Id>();
        for(CampaignMember objCM: listCM){
        	objCM.CM_Status__c = 'Accepted';
            listActualCMId.add(objCM.Id);
            listActualCM.add(objCM);    
        }   
        
        Integer intActualCMHistoryCreated = [SELECT count() FROM Campaign_Member_Field_History__c WHERE Record_Id__c IN : listActualCMId];
        system.debug('intActualCMHistoryCreated: '+intActualCMHistoryCreated);
        system.assert(intActualCMHistoryCreated > 0);
        
        system.debug('listCM: '+listCM);
              
        Database.update(listActualCM);        
        
        Integer intActualCMHistoryUpd = [SELECT count() FROM Campaign_Member_Field_History__c WHERE Record_Id__c IN : listActualCMId];
        system.debug('intActualCMHistoryUpd: '+intActualCMHistoryUpd);
        system.assert(intActualCMHistoryUpd > 0);
        Test.stopTest();
    }
    
}