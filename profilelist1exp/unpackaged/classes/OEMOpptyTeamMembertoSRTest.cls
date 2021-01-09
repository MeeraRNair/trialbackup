/*
 * Revision CR Number   Release No            Date            Modified By        Description
 * -------- ---------   ----------            -----------     ------------       -----------
 * 1.0       7216521    FY20\PI4\SP21-Nov06   19-Nov-2019     Sarbjeet Heera      Update – OEM BDM Email field from Opportunity Teams with role OEM Business Development Manager
       
*/

@isTest  
private class OEMOpptyTeamMembertoSRTest { 
    
    @testSetup static void setup() {
        // Create common test OWD settings
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
    }
    
    static PricebookEntry pricebookEntry;
    static void createProduct(){
      
      Product2 product = new product2(name='Test Product 1',family='Services',isActive=true, Dgr_Eligible__c = 'Yes',Product_ID__c = '12SV');
      insert product;
      
      Pricebook2 pb = [select Id from Pricebook2 where isStandard=true ];
            
      pricebookEntry = new PricebookEntry(pricebook2id=pb.id,
          product2id=product.id, unitprice=1000.0, isActive=true);
      insert pricebookEntry;
      
     }

    static testmethod void populateOEMBDMEmail(){
    
        String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Support_Request__c", "Class_Name__c": "SupportRequestTriggerHandlerBI"},'; 
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        List<OpportunityTeamMember> listOpportunityTM=new List<OpportunityTeamMember>();
        List<User> listTestUsr = new List<User>();
        List<Support_Request__c> listSupportRequest=new List<Support_Request__c>();
        Support_Request__c supportRequestItem;
        
        Account account=new Account(name='Test Account');
        insert account;
        
        Id standardRTId = IdLookupUtils.getRecordTypeId('Standard Opportunity', 'Opportunity', true);
        
        Opportunity testOpportunity = new Opportunity(RecordTypeId=standardRTId, 
                                    Name='Test Opportunity', AccountId= account.Id, CurrencyIsoCode='USD',
                                    Type='Deal/Bid Direct', CloseDate= system.today(), 
                                    Domain__c='Business Solutions', 
                                    StageName='Plan - 1%',Probability=1);     

        
        
        List<Opportunity> listopportunity = new List<Opportunity>();
        listopportunity.add(testOpportunity);
        ProcessFlowTriggerController.isTest = true;
        insert listopportunity;
        
       

        //Create Test User Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer intval=0; intval<1;intval++){
            User user = new User(Username='test' +intval+ System.currentTimeMillis() + '@test.com',
            Alias = 'test'+intval, 
            Email='test'+ intval +'@dell.com', 
            FirstName='Tfirst'+intval, 
            LastName='TLast'+intval,
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'+intval );

            listTestUsr.add(user);   
        }

        insert listTestUsr;

        OpportunityTeamMember otm01=new OpportunityTeamMember(userId=listTestUsr[0].Id,
                                    TeamMemberRole='OEM Business Development Manager',
                                    opportunityId = testOpportunity.id); 
        listOpportunityTM.add(otm01);

        
        insert listOpportunityTM;   
        
        Id objectOEMRecordTypeId = Schema.SObjectType.Support_Request__c.getRecordTypeInfosByDeveloperName().get('Request_OEM_Customized_Solution_Support').getRecordTypeId();
        
        supportRequestItem=new Support_Request__c(RecordTypeId=objectOEMRecordTypeId, Proposal_Support__c='RFI/PQQ', Opportunity__c=testOpportunity.id,
        Deliverable_Due_Date__c=Date.newInstance(2009,05,07), Submission_Deadline__c=Date.newInstance(2009,12,12),
        Project_Duration_months__c = 12.00,Support_owner__c=listTestUsr[0].Id,Support_Owner_Team_Role__c='Buddy',Request_Status__c='Scoping');
        listSupportRequest.add(supportRequestItem); 


        Test.startTest();
       
        insert listSupportRequest;        
        Test.stopTest(); 

        List<Support_Request__c> listsr=[select id,OEM_BDM_Email__c   
                                        from Support_Request__c 
                                        WHERE id IN:listSupportRequest];       
                                         
        System.assertEquals(listTestUsr[0].Email,listsr[0].OEM_BDM_Email__c);

      

    }
    
}