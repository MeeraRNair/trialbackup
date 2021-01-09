@isTest

private class LatticeOpportunityAPAssociationTest{
    static Account accountData;
    static Opportunity opportunityData;
    static Account_Play__c accountPlayData;
    
     static void CreateTestData() {

        accountData = new Account(Name='Test Account',
                                  Account_id__c='affinityID'    );
        insert accountData;
        opportunityData=new Opportunity(Name='oppToTest',
                                        RecordTypeId=PageUtils.getRecordTypeId('Opportunity', 'Standard Opportunity', true),
                                        Domain__c='IDM',
                                        AccountId=accountData.Id,
                                        CloseDate=System.Today(),
                                        Type='Design',
                                        Solution_Type__c='Storage',
                                        Solution_Name__c='Compellent',
                                        StageName='Plan - 1%',
                                        Marketing_Created_Opportunity__c = true,
                                        Lattice_PreLead_External_id__c='aaaa');
        accountPlayData=new Account_Play__c(Account__c=accountData.Id,
                                            RecordTypeId=PageUtils.getRecordTypeId('Account_Play__c', 'Lattice', true),
                                            Campaign_Vehicle__c='Multiple Vehicles',
                                            Lattice_IsActive__c=true,
                                            Lattice_Pre_Lead_External_ID__c='aaaa',
                                            Status__c='Existing Opportunity');
        
        insert accountPlayData;
        System.debug('-----------INSERTED AP--------------');
        insert opportunityData;
    }
    
    //testMethod to test association of Opportunity with existing AccountPlay
    static testMethod void testOpportunityWithExistingAP() {
        Test.startTest();       
        CreateTestData();
        Opportunity opp = [SELECT id,Lattice_Source_Id__c from Opportunity WHERE id = :opportunityData.id];
        System.assertEquals(opp .Lattice_Source_Id__c,accountPlayData.id);
        Test.stopTest();   
    }
    
    //testMethod to test association of Opportunity with a non existing AccountPlay
    static testMethod void testOpportunityWithoutExistingAP() {
        Test.startTest(); 
        if(accountData ==null)    {
            accountData = new Account(Name='Test Account',
                                      Account_id__c='affinityID');
            insert  accountData;  
         }
            
         Opportunity opportunityData1= new Opportunity(Name='oppToTest1',
                                        RecordTypeId= PageUtils.getRecordTypeId('Opportunity', 'Standard Opportunity', false),
                                        Domain__c='IDM',
                                        CloseDate=System.Today(),
                                        Type='Design',
                                        Solution_Type__c='Business Processing',
                                        StageName='Plan - 1%',
                                        Marketing_Created_Opportunity__c = true,
                                        AccountId=accountData.Id,
                                        Lattice_PreLead_External_id__c='bbbb');
        insert opportunityData1;
        List<Opportunity_Account_Play_Association__c> assocList=[select Opportunity__c,preLead_External_Id__c from Opportunity_Account_Play_Association__c where preLead_External_Id__c='bbbb'];
        system.assert(assocList.size()>0);
        for(Opportunity_Account_Play_Association__c assoc:assocList){
            System.assertEquals(assoc.Opportunity__c, opportunityData1.id);

        }
        Account_Play__c accountPlayData1=new Account_Play__c(Account__c=accountData.Id,
                                            RecordTypeId=PageUtils.getRecordTypeId('Account_Play__c', 'Lattice', false),
                                            Campaign_Vehicle__c='Multiple Vehicles',
                                            Lattice_IsActive__c=true,
                                            Lattice_Pre_Lead_External_ID__c='bbbb',
                                            Status__c='Existing Opportunity');
        
        insert accountPlayData1;
        Test.stopTest();   
        List<Account_Play__c> accplayupd = [SELECT id, Opportunity__c FROM Account_Play__c WHERE id =:accountPlayData1.id];
        System.assertEquals(accplayupd[0].Opportunity__c , opportunityData1.id);
    }
    
    //testMethod to test association of Opportunities with existing AccountPlay
    static testMethod void testOpportunitysWithExistingAP() {
        Test.startTest();       
        CreateTestData();
        /*Opportunity opportunityData1= new Opportunity(Name='oppToTest1',
                                        RecordTypeId= PageUtils.getRecordTypeId('Opportunity', 'Standard Opportunity', false),
                                        Domain__c='IDM',
                                        CloseDate=System.Today(),
                                        Type='Design',
                                        Solution_Type__c='Business Processing',
                                        StageName='Plan - 1%',
                                        Marketing_Created_Opportunity__c = true,
                                        AccountId=accountData.Id,
                                        Lattice_PreLead_External_id__c='bbbb');
        insert opportunityData1;
        */
        //Intoducing time delay
        for(Integer cnt=0;cnt<100000;cnt++){
        }
        Opportunity opportunityData2= new Opportunity(Name='oppToTest2',
                                        RecordTypeId= PageUtils.getRecordTypeId('Opportunity', 'Standard Opportunity', false),
                                        Domain__c='IDM',
                                        CloseDate=System.Today(),
                                        Type='Design',
                                        Solution_Type__c='Business Processing',
                                        StageName='Plan - 1%',
                                        Marketing_Created_Opportunity__c = true,
                                        AccountId=accountData.Id,
                                        Lattice_PreLead_External_id__c='bbbb');
        insert opportunityData2;
        Account_Play__c accountPlayData1=new Account_Play__c(Account__c=accountData.Id,
                                            RecordTypeId=PageUtils.getRecordTypeId('Account_Play__c', 'Lattice', false),
                                            Campaign_Vehicle__c='Multiple Vehicles',
                                            Lattice_IsActive__c=true,
                                            Lattice_Pre_Lead_External_ID__c='bbbb',
                                            Status__c='Existing Opportunity');
        
        insert accountPlayData1;
        
        List<Account_Play__c> accplayupd = [SELECT id, Opportunity__c FROM Account_Play__c WHERE id =:accountPlayData1.id];
        //System.assertEquals(accplayupd[0].Opportunity__c , opportunityData2.id);
        Test.stopTest();  
    }               
}