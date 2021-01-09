/* 
* Revision   Release No       Modified By               Description
* --------   ---------        -----------               ------------               
*            0202             Venugopalachary k         Implement Test Data Factory                               
*/ 
@isTest
Public class OSCWebserviceToCreateQuote_Test{  
    @testSetup static void setup() { 
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
        TriggerExecutionController.setSkipAllTriggers(true); 
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppTdf;
        TriggerExecutionController.setSkipAllTriggers(false); 
    }
    static testmethod void testOSCQuote(){
        list<Opportunity> listOpp=[select id from Opportunity Limit 1];
        /*Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
Opportunity opp=new Opportunity (name='teset opp SR', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Engagement_Type__c='Public Tender',
Solution_Type__c='Campus',Solution_Name__c='Wired Chassis Switches',Justification_Statement__c='test Justification_Statement__c',
End_User_Account_Name__c='test End_User_Account_Name__c', End_User_Mailing_City__c='mailing city',End_User_Mailing_State_Province_Region__c='mailing state',
End_User_Mailing_Country__c='INDIA',Save_End_Customer_to_my_list__c='Yes',End_User_First_Name__c='end fist name',End_User_Last_Name__c='end last name',
End_User_Email__c='test@gmail.com',Is_the_Customer_Part_of_a_Larger_Group__c='Yes',StageName='Plan - 1%',Primary_Product_Delivery_Address_Region__c ='LATAM',
Primary_Product_Delivery_Address_Country__c= 'INDIA');
insert opp;
*/
        Solution__c sol = new Solution__c();
        sol.Opportunity__c = listOpp[0].Id;
        sol.OSC_Regional_ID__c='AMER:2154116.1';
        insert sol;
        system.assertEquals(sol.Opportunity__c, listOpp[0].Id);
        Quote__c quo = new Quote__c();
        quo.QuoteID__c = 'test1234';
        quo.Opportunity__c=listOpp[0].Id;
        quo.Solution__c = sol.Id;
        insert quo;
        
        Solution__c sol1 = new Solution__c();
        sol1.Opportunity__c = listOpp[0].Id;
        sol1.OSC_Regional_ID__c='AMER:32154116.1';
        insert sol1;
        
        Quote__c quo1 = new Quote__c();
        quo1.QuoteID__c = 'test1236';
        quo1.Opportunity__c=listOpp[0].Id;
        quo1.Solution__c = sol1.Id;
        insert quo1;
        
        OSCWebserviceToCreateQuote.QuoteDetails resqt = new OSCWebserviceToCreateQuote.QuoteDetails();
        resqt.oscQuoteId='test123';
        resqt.oscSolutionId='AMER:2154116.1';
        
        OSCWebserviceToCreateQuote.QuoteDetails resqt1 = new OSCWebserviceToCreateQuote.QuoteDetails();
        resqt1.oscQuoteId=null;
        resqt1.oscSolutionId='AMER:2154116.1';
        
        List<OSCWebserviceToCreateQuote.QuoteDetails> listQs = new List<OSCWebserviceToCreateQuote.QuoteDetails>();
        listQs.add(resqt);
        listQs.add(resqt1);
        OSCWebserviceToCreateQuote.QuoteParameters(listQs);
        
        OSCWebserviceToCreateQuote.Response resp = new OSCWebserviceToCreateQuote.Response();
        resp.message='All records inserted succesfully';
        resp.isSuccess=true;
        List<OSCWebserviceToCreateQuote.Response> listres = new List<OSCWebserviceToCreateQuote.Response>();
        listres=OSCWebserviceToCreateQuote.QuoteParameters(listQs);
        
    }      
    
}