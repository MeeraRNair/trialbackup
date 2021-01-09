@isTest
private class Batch_OpptyShareToBuddyTest {
    private static list<Account> listAcc;
    private static List<Profile> listProfile; 
    private static GDM_Request__c objGdmReq;
    private static list<Opportunity> listOppTDF;
    private static List<User> listTestUser1; 
    Private static testMethod void testBatchDeleteAccountTeamMember() {
    TriggerExecutionController.setSkipAllTriggers(true);
        listProfile = [SELECT Id,name FROM Profile WHERE Name in ('System Administrator','R16.10 GBL EMEA Sales Rep') order by name]; 
         User objAdminUser = new User(Alias = 'standt', Email='standarduser@dell.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = listProfile.get(1).Id, userRoleId = '00E30000000w2BzEAI',  Badge_Number__c='TEST1'+System.currentTimeMillis(),
    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+ System.currentTimeMillis() +'@dell.com');
        List<User> listtestUser = new List<User>();
        listtestUser.add(objAdminUser);
        insert listtestUser;

        listTestUser1 = new List<User>();
        for (Integer inti=0; inti<3;inti++){
            User user = new User( Username='test' +inti+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+inti, 
                                Email='test'+ inti +'@dell.com', 
                                FirstName='Tfirst'+inti, 
                                LastName='TLast'+inti,
                                ProfileId = listProfile.get(0).Id, 
                                userRoleId = '00E30000000w2BzEAI',
                                ManagerId = listTestUser[0].id,
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST12345'+inti);
                
            listTestUser1.add(user);   
        } 
        
    insert listTestUser1;
        System.runAs(listTestUser1[0]){     
        objGdmReq = new GDM_Request__c();
        objGdmReq.Buddy_Access_Start_Date__c = system.today();
        objGdmReq.Buddy_Access_End_Date__c = (system.today())+2;
        objGdmReq.Buddy__c = listTestUser1[0].id;
        objGdmReq.Rep_on_Leave__c = listTestUser1[1].id;
        objGdmReq.Reason_Requested__c = 'Sickness';
        objGdmReq.Comments2__c = 'Test';
        objGdmReq.RecordTypeId = IdLookupUtils.getRecordTypeId('Buddy Access','GDM_Request__c',true);
        objGdmReq.ROL_Manager__c = listTestUser[0].id;
        insert objGdmReq;
        
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        listAccTDF[0].Type='OEM';
        listAccTDF[0].Type='MSG';
        insert listAccTDF;
        
        listOppTDF = TestDataFactory.createNOpportunities(2, 'Channel Opportunity');
        listOppTDF[0].Deal_Created_Date_Time__c=System.Today();
        listOppTDF[0].Deal_Registration_Status__c='Approved';
        listOppTDF[0].Deal_Expiration_Date__c=System.Today()+20;
        listOppTDF[0].RecordTypeid= '012A0000000Vjtg';
        listOppTDF[1].StageName='90% - Commit';
        listOppTDF[1].CloseDate=System.Today()+20;
        insert listOppTDF;
        System.assertEquals('Approved',listOppTDF[0].Deal_Registration_Status__c);
        OpportunityTeamMember testOTM1 = new OpportunityTeamMember (UserId=listTestUser1[1].Id, TeamMemberRole='OEM SR', OpportunityId=listOppTDF[0].Id);
        OpportunityTeamMember testOTM2 = new OpportunityTeamMember (UserId=listTestUser1[1].Id, TeamMemberRole='QQQ SR', OpportunityId=listOppTDF[1].Id);
        List<OpportunityTeamMember> listtestOTM = new List<OpportunityTeamMember>();
        listtestOTM.add(testOTM1);
        listtestOTM.add(testOTM2);
        
        insert listtestOTM;       
      
        }
         System.runAs(listTestUser[0]){
          if(objGdmReq != null){
            objGdmReq.Buddy_Access_Status__c = 'Approved and scheduled';
            update objGdmReq;  
          }
        }
        Batch_OpptyShareToBuddy batchObj = new Batch_OpptyShareToBuddy();              
        Database.executeBatch(batchObj);
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}