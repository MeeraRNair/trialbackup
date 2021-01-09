/*
History:
20-Dec-2013 :  15.3 OMGO CR 8973 - Remove use of field Verifiable_Outcome__c in Test Methods
*/

@isTest()
Public class TestNewContractRedirectController {

    public static testmethod void testcontract() {
        
        // Skill all trigger to avoid too many SOQL Query Issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Account newacc = new Account (name='new account', Account_country__c = 'USA');
        insert newacc;
        
        Contact newcon = new Contact (firstname='con',lastname='test',title='BSA',accountId=newacc.Id,phone='1234',status__c='customer',email='test@test.com',MobilePhone='1234505');
        insert newcon;
        
        //Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        
        //15.3 OMGO CR 8973 - Remove use of  Verifiable_Outcome__c 
//      Opportunity newopp = new Opportunity (name ='new oppty',accountId=newacc.Id,stagename='commit - 90%',CloseDate=system.today(),domain__c='EUC',type='design',Solution_Type__c='campus',Solution_Name__c='active system 800V',Verifiable_Outcome__c='legal approval of deal/opportunity',CurrencyIsoCode='USD',value_of_contract__c=21,Region__c='APJ',Competitor_Lost_To__c='Unknown');
        Opportunity newopp = new Opportunity (name ='new oppty',accountId=newacc.Id,stagename='commit - 90%',CloseDate=system.today(),domain__c='EUC',type='design',Solution_Type__c='campus',Solution_Name__c='active system 800V',CurrencyIsoCode='USD',value_of_contract__c=21,Region__c='APJ',Competitor_Lost_To__c='Unknown');
        insert newopp;
        
        Sales_channel_group__c newSC = new sales_channel_group__c(name='test sales',Segment_Business_Unit_Name__c='test sbu',Global_Parent_Name__c='test parent');
        insert newSC;
        
        /*Support_Request__c newSR = new Support_Request__c (,Contact_Name__c=newcon.name,Opportunity__c=newopp.name,
                          Email__c='test@test.com',Phone__c='123456',Mobile__c='1234505',Mailing_Street__c='test street',Mailing_City__c='test city',Mailing_State_Province__c='test state',Mailing_Zip_Postal_Code__c='1234',title__c=newcon.title,
                          Mailing_Country__c='test country',Dell_Company__c='8',Region__c='Americas',Sub_Region__c='NA',Country__c='test count',Business_Case_Summary__c='test summary',Contract_Template_Type__c='standard',
                          Prior_Contact_Agreement__c='yes',If_Yes_Prior_Agreement_Name_or_CC__c='12',Amend_or_Terminate_prior_Agreement__c='amend',Initial_Contract_Term_Requested__c='less than 1 year',
                          Renew__c='manual',Termination_for_Convenience_Days_Notice__c='12',Payment_Terms__c='terms',Risk_Level__c='low',Complexity__c='basic',RRC_Required__c='no',
                          Vetting_Required__c='no',Products__c='desktop',Account_Name__c=newacc.name,Anticipated_Anual_Revenue__c='89',Business_Unit1__c='mobility',Business_Unit_Secondary__c='test sec',
                          Segment_Business_Unit__c='test seg',Expected_Contract_Start_Date__c=4/29/2013,Contract_Duration_months__c='8',
                          ='no',
                          Global_Program__c='no',Utilization__c='no',RFP_Support__c='no',Contract_Requires_Signature__c='no',Contract_Extension__c='no',Value_of_Contract__c='qwr3', 
                          Contract_Code__c='6789');*/
        
        Support_Request__c newSR = new Support_Request__c (Opportunity__c=newopp.Id,Dell_Company__c='8',Region__c='Americas',Sub_Region__c='NA',Business_Case_Summary__c='test summary',Contract_Template_Type__c='standard',
                          Prior_Contact_Agreement__c='yes',If_Yes_Prior_Agreement_Name_or_CC__c='12',Amend_or_Terminate_prior_Agreement__c='amend',Initial_Contract_Term_Requested__c='less than 1 year',
                          Renew__c='manual',Termination_for_Convenience_Days_Notice__c='12',Payment_Terms__c='terms',Risk_Level__c='low',Complexity__c='basic',RRC_Required__c='no',
                          Vetting_Required__c='no',Products__c='desktop',Business_Unit1__c='mobility',Business_Unit_Secondary__c='test sec',
                          Expected_Contract_Start_Date__c=system.today(),Contract_Duration_months__c='8',Multinational_Opportunity__c=true,
                          Global_Program__c='GS',Utilization__c='Mega',RFP_Support__c=false,Contract_Requires_Signature__c=true,Contract_Extension__c=true, 
                          Contract_Code__c='6789',country__c='India',Anticipated_Anual_Revenue__c=213.00,Segment_Business_Unit__c='csmb',Contact_Name__c=newcon.Id);
                          
       insert newSR;
       system.debug('ID-----'+newSR.Id);          
       Apexpages.currentpage().getParameters().put('srId',newSR.id); 
          
       NewContractRedirectController controller = new NewContractRedirectController();
       controller.createurl();   
       
       Test.stopTest();
    }
    
    public static testmethod void testcontract1() {
        
        // Skill all trigger to avoid too many SOQL Query Issue
        TriggerExecutionController.setSkipAllTriggers(true);

        Account newacc1 = new Account (name='new account1', Account_country__c = 'USA');
        insert newacc1;
        
        Contact newcon1 = new Contact (firstname='con1',lastname='test',title='BSA',accountId=newacc1.Id,phone='1234',status__c='customer',email='test@test.com',MobilePhone='1234505');
        insert newcon1;
        
        //Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        
        //15.3 OMGO CR 8973 - Remove use of  Verifiable_Outcome__c 
        Opportunity newopp1 = new Opportunity (name ='new oppty1',accountId=newacc1.Id,stagename='commit - 90%',CloseDate=system.today(),domain__c='EUC',type='design',Solution_Type__c='campus',Solution_Name__c='active system 800V',CurrencyIsoCode='USD',value_of_contract__c=21,Region__c='APJ',Competitor_Lost_To__c='Unknown');
        insert newopp1;
        
        Sales_channel_group__c newSC1 = new sales_channel_group__c(name='test sales',Segment_Business_Unit_Name__c='test sbu',Global_Parent_Name__c='test parent');
        insert newSC1;
        
        Support_Request__c newSR1 = new Support_Request__c (Opportunity__c=newopp1.Id,Dell_Company__c='8',Region__c='Americas',Sub_Region__c='NA',Business_Case_Summary__c='test summary',Contract_Template_Type__c='standard',
                          Prior_Contact_Agreement__c='yes',If_Yes_Prior_Agreement_Name_or_CC__c='12',Amend_or_Terminate_prior_Agreement__c='amend',Initial_Contract_Term_Requested__c='less than 1 year',
                          Renew__c='manual',Termination_for_Convenience_Days_Notice__c='12',Payment_Terms__c='terms',Risk_Level__c='low',Complexity__c='basic',RRC_Required__c='no',
                          Vetting_Required__c='no',Products__c='desktop',Business_Unit1__c='mobility',Business_Unit_Secondary__c='test sec',
                          Expected_Contract_Start_Date__c=system.today(),Contract_Duration_months__c='8',Multinational_Opportunity__c=true,
                          Global_Program__c='GS',Utilization__c='Mega',RFP_Support__c=false,Contract_Requires_Signature__c=true,Contract_Extension__c=true, 
                          Contract_Code__c='6789',country__c='India',Anticipated_Anual_Revenue__c=213.00,Segment_Business_Unit__c='ple',Contact_Name__c=newcon1.Id);
                          
        insert newSR1; 
        system.debug('ID-----'+newSR1.Id);          
        Apexpages.currentpage().getParameters().put('srId',newSR1.id); 
           
        NewContractRedirectController controller = new NewContractRedirectController();
        controller.createurl();                    
        
        Test.stopTest();
    }
}