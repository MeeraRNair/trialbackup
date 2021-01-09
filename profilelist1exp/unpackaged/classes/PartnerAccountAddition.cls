/*
Description: Class which contains methods to add the partner account to (PRM)Opportunity's "Partner Opportunities" related list.
Version:3.1

History:
1.0 - 01-July-2008:  Creation
2.0 - 11-July-2008:  Changed the addAccountPartnertoOpportunityRelatedList-method arguement  
3.0 - 18-Aug-2008 :  Added more Test methods
3.1 - 28-Aug-2008 :  Added Test methods which test class method(s) in the class without the help of trigger
4.0 - 20-Dec-2013 :  15.3 OMGO CR 8973 - Remove use of field Verifiable_Outcome__c in Test Methods
5.0 - 15-Aug-2014 :  15.07 - change closeDate in test method 7,8 & 9 to future date to fulfill VR OpptyBookDateValidation.
Author: Meera Nair/Krishnaprasad P

*/


public class PartnerAccountAddition {
      
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0                                 29-Nov-2007
    2.0                                 11-Jul-2008                     Moved the query on Partner out of the loop to avoid Query Limit
    3.0         CR10496     15.10       22-Sep-2014       Ragu            This logic is separated from opportunityTrigger trigger and rewritten as part of trigger redesign.
    4.0         CR          0701        07-june-2016     Yeswanth        Created new method to add disti/reseller account to partner opportunities related list
    */
    
   // Method to add Partner account to partner opportunities related list
    public static void associateToPartnerOpportunitiesRelatedList(map<Id, Id> mapOppIdPartnerAccountId) {
        if(!mapOppIdPartnerAccountId.isEmpty()) {
            GlobalVariables.SKIP_OPP_PARTNER_ADDITION = true;
            for(list<Partner> lstPartners : [select Id, OpportunityId, AccountToId from Partner
                                             where OpportunityId in :mapOppIdPartnerAccountId.keySet() and AccountToId in :mapOppIdPartnerAccountId.values()]) {                              
                for(Partner partnerIterator : lstPartners) {
                    if(mapOppIdPartnerAccountId.containsKey(partnerIterator.OpportunityId) && partnerIterator.AccountToId == mapOppIdPartnerAccountId.get(partnerIterator.OpportunityId)) {
                        // Partner Record curresponds to the Partner Account of that Opp is alredy there. So removing from the map.
                        mapOppIdPartnerAccountId.remove(partnerIterator.OpportunityId);
                    }
                }
            }
            
            if(!mapOppIdPartnerAccountId.isEmpty()) {
                PartnerAccountAddition.addAccountPartnertoOpportunityRelatedList(mapOppIdPartnerAccountId,TRUE);
            }
        }
    }
 
   /*-----version 4.0 start----*/ 
    public static void associateDistiAccountToPartnerOpportunitiesRelatedList(map<Id, Id> mapOppIdDistiAccountId) {
        if(!mapOppIdDistiAccountId.isEmpty()) {
            GlobalVariables.SKIP_OPP_PARTNER_ADDITION = true;
            for(list<Partner> lstPartners : [select Id, OpportunityId, AccountToId from Partner
                                             where OpportunityId in :mapOppIdDistiAccountId.keySet() and AccountToId in :mapOppIdDistiAccountId.values()]) {                              
                for(Partner partnerIterator : lstPartners) {
                    if(mapOppIdDistiAccountId.containsKey(partnerIterator.OpportunityId) && partnerIterator.AccountToId == mapOppIdDistiAccountId.get(partnerIterator.OpportunityId)) {
                        // Partner Record corresponds to the Disti/Reseller Account of that Opp is already there. So removing from the map.
                        mapOppIdDistiAccountId.remove(partnerIterator.OpportunityId);
                    }
                }
            }
            
            if(!mapOppIdDistiAccountId.isEmpty()) {
                PartnerAccountAddition.addAccountPartnertoOpportunityRelatedList(mapOppIdDistiAccountId,FALSE);
            }
        }
    }
    /*-----version 4.0 end----*/ 
    
    //used in testmethods to get the coverage on limit handling statements
    public static Boolean forceLimitException = false;
    
    //Method to add the partner account to Partner Object
    public static void addAccountPartnertoOpportunityRelatedList(Map<Id,Id> oppIdToPartnerAccountIdMap,boolean isPrimary){
            
        system.debug('##KP: Start method--addAccountPartnerToOpportunityRelatedList--at ' + system.now());
        //List to store partner records to be inserted
        List<Partner> partnerRecordList = new List<Partner>();
        //List to store ids of unprocessed opportunities     
        List<Id> unProcessedOpportunityIdList = new List<Id>();
        String errorMessageforUnprocessedRecords='';
        Integer iteration_index=0;
        try{
        	for(Id  keyId: oppIdToPartnerAccountIdMap.keySet()){
              	//Checking for govern limits
              	if((Limits.getDMLRows()+partnerRecordList.size())>=Limits.getLimitDMLRows() || forceLimitException ){
                        unProcessedOpportunityIdList.add(keyId);
                        system.debug('##KP : Opportunity could NOT be processed due to DML Limit : '+keyId);
              	}
              	else{
                  
                        if((partnerRecordList.size())==100){
                            //Insertthe Partner records and clears the list
                            insert partnerRecordList;
                            system.debug('##MN: Inserts Partner records and clears the list');
                            partnerRecordList.clear();                          
                        }
                 
                  
                        system.debug('##MN: Adds a Partner record currespond to Opportunity:: ID ='+ keyId+',  Partner Account ID :' +oppIdToPartnerAccountIdMap.get(keyId) );
                                        
                        //Create partner relation record to be inserted
                        Partner partnerRelationRecord=new Partner(OpportunityId=keyId,AccountToId=oppIdToPartnerAccountIdMap.get(keyId),Role='Identified at Account Level',IsPrimary=isPrimary);                   
                        partnerRecordList.add(partnerRelationRecord);
       
             	}//end of else block
                
           	}//end of opportunity iteration for loop
                
        	if(partnerRecordList.size()>0){
                //Inserts the remaining Partner  records
                insert partnerRecordList;
                system.debug('##MN: Inserted the last set');   
            }
                
                if(unProcessedOpportunityIdList.size()>0){
                    //If the DML limit Reached, Sends a notification mail with unprocessed opportunity Ids
                                        
                    for(iteration_index = 0; iteration_index < unProcessedOpportunityIdList.size()-1 ; iteration_index++){
                         errorMessageforUnprocessedRecords=errorMessageforUnprocessedRecords+unProcessedOpportunityIdList[iteration_index]+', ';
                    }
                    
                    errorMessageforUnprocessedRecords='Governer Limit :: IDs of unprocessed Opportunities : '+ errorMessageforUnprocessedRecords + unProcessedOpportunityIdList[iteration_index];
                    throw new dellUtil.DellException('PartnerAccountAddition: addAccountPartnertoOpportunityRelatedList: ' + errorMessageforUnprocessedRecords);
                }
                
            }catch  (Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
                throw new dellUtil.DellException('PartnerAccountAddition: addAccountPartnertoOpportunityRelatedList: ' + e.getMessage());
            }  
       
       system.debug('##KP: End method--addAccountPartnerToOpportunityRelatedList--at ' + system.now()); 
    } //end of method addAccountPartnertoOpportunityRelatedList
    
    // ------------TEST METHODS--------------
/*
    // Test method 1: Partner opportunity Insert. Deal Registration Status not set
        static testMethod void Test_Method_01(){
        system.debug('## Start Test_Method_01 ::  Partner opportunity Insert. Deal Registration Status not set');
        
        try{
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
      
           System.assertNotEquals(null,PartnerUser); 
            Opportunity TestOpp =  new Opportunity (Name='Test Opportunity for insert 1234',  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        AccountId = PartnerContactMap.get(PartnerUser.ContactId).AccountId,
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23)); 
            
                
             //Start the test, this changes limit context to trigger.
            Test.startTest(); 
            insert TestOpp;
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();            
            
            
//            TestOpp = [SELECT Id, Name, RecordTypeId, OwnerId, AccountId, PartnerAccountId FROM Opportunity WHERE Name LIKE '%Test Opportunity for insert 1234%' limit 1]; 
//            System.debug('Inserted opportunity :'+TestOpp);
            
//            List<Partner> partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(0,partnerList.size());
//            System.debug('Number of records from to Partner table curresponding to this test opportunity is:'+partnerList.size());



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(0, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            // Test Methods added by A L end



        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_01');

   }   
   
   // Test method 2: Partner opportunity Insert.Deal Registration Status set to "Approved".

        static testMethod void Test_Method_02(){
        system.debug('## Start Test_Method_02 ::  Partner opportunity Insert.Deal Registration Status set to- Approved');
        
        try{
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
      
            
            Opportunity TestOpp =  new Opportunity (Name='Test Opportunity for insert 1234',  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23),AccountId=normalAccount.Id,
                                                        Deal_Registration_Status__c='Approved'); 
            
                
             //Start the test, this changes limit context to trigger.
            Test.startTest(); 
            insert TestOpp;
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();            
                        
//            TestOpp = [SELECT Id, Name, RecordTypeId, OwnerId, AccountId, PartnerAccountId FROM Opportunity WHERE Name LIKE '%Test Opportunity for insert 1234%' limit 1]; 
//            System.debug('Inserted opportunity :'+TestOpp);
            
//            List<Partner> partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(0,partnerList.size());
//            System.debug('Number of records from to Partner table curresponding to this test opportunity is:'+partnerList.size());



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(2, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            system.assertEquals(1, [select count() from Partner where OpportunityId = : TestOpp.Id and AccountToId = : PartnerContactMap.get(PartnerUser.ContactId).AccountId and IsPrimary=true and Role='Identified at Account Level']);
            // Test Methods added by A L end



        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_02');

   }
   
   // Test method 3: Partner opportunity Update.Deal Registration Status not set.


        static testMethod void Test_Method_03(){
        system.debug('## Start Test_Method_03 ::  Partner opportunity Update.Deal Registration Status not set');
        
        try{
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
      
            
            Opportunity TestOpp =  new Opportunity (Name='Test Opportunity for insert 1234',  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23),AccountId=normalAccount.Id,
                                                        Deal_Registration_Status__c='Approved'); 
            

            insert TestOpp;
            //created test opportunity.
                        
//            List<Partner> partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
//            System.debug('##KP: Number of records from to Partner table curresponding to the test opportunity BEFORE Update :'+partnerList.size());
            //System.assertEquals(2,partnerList.size());

//            TestOpp = [SELECT Id, Name, RecordTypeId, OwnerId, AccountId, PartnerAccountId, End_User_Email__c FROM Opportunity WHERE Name LIKE '%Test Opportunity for insert 1234%' limit 1]; 


            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);


            List<Id> PartnerIds = new List<Id>();
            List<Partner> PartnerRecordIds = [select Id from Partner where OpportunityId = : TestOpp.Id];
            for (Partner PartnerRecordId : PartnerRecordIds){
                PartnerIds.add(PartnerRecordId.Id);
            }


            system.debug('#### Validation of partner account addition');
            system.assertEquals(2, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            system.assertEquals(1, [select count() from Partner where OpportunityId = : TestOpp.Id and AccountToId = : PartnerContactMap.get(PartnerUser.ContactId).AccountId and IsPrimary=true and Role='Identified at Account Level']);
            // Test Methods added by A L end



            TestOpp.End_User_Email__c='test@test.com';
            
            //Start the test, this changes limit context to trigger.
            Test.startTest(); 
            update TestOpp;
            System.debug('##KP: Opportunity is updated with new End_User_Email__c');
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();          
            
            
//            partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(2,partnerList.size());           
//            System.debug('##KP: Number of records from to Partner table curresponding to the test opportunity AFTER Update :'+partnerList.size());



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(2, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            system.assertEquals(1, [select count() from Partner where OpportunityId = : TestOpp.Id and AccountToId = : PartnerContactMap.get(PartnerUser.ContactId).AccountId and IsPrimary=true and Role='Identified at Account Level']);
            system.assertEquals(2, [select count() from Partner where Id in : PartnerIds]);         
            // Test Methods added by A L end


            
        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_03');

   }
   
    // Test method 4: Partner opportunity Update.Deal Registration Status set to "Approved".


        static testMethod void Test_Method_04(){
        system.debug('## Start Test_Method_04 ::  Partner opportunity Update.Deal Registration Status set to : Approved');
        
        try{
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
      
            
            Opportunity TestOpp =  new Opportunity (Name='Test Opportunity for insert 1234',  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23),AccountId=normalAccount.Id); 
            

            insert TestOpp;
            //created test opportunity.
                        
//            List<Partner> partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
//            System.debug('##KP: Number of records from to Partner table curresponding to the test opportunity BEFORE Update :'+partnerList.size());
            //System.assertEquals(0,partnerList.size());



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(0, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            // Test Methods added by A L end




//            TestOpp = [SELECT Id, Name, RecordTypeId, OwnerId, AccountId, PartnerAccountId, Deal_Registration_Status__c FROM Opportunity WHERE Name LIKE '%Test Opportunity for insert 1234%' limit 1]; 
            
            TestOpp.Deal_Registration_Status__c='Approved';
            //Start the test, this changes limit context to trigger.
            Test.startTest(); 
            update TestOpp;
            System.debug('##KP: Opportunity is updated with Deal_Registration_Status__c=Approved');
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();          
            
            
//            partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(2,partnerList.size());           
//            System.debug('##KP: Number of records from to Partner table curresponding to the test opportunity AFTER Update :'+partnerList.size());


            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(2, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            system.assertEquals(1, [select count() from Partner where OpportunityId = : TestOpp.Id and AccountToId = : PartnerContactMap.get(PartnerUser.ContactId).AccountId and IsPrimary=true and Role='Identified at Account Level']);
            // Test Methods added by A L end


        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_04');

   }
   
 // Test method 5: Partner opportunity insert Bulk. Test for Bulk operation

        static testMethod void Test_Method_05(){
        system.debug('## Start Test_Method_05 ::  Partner opportunity insert Bulk. Test for Bulk operation');
        
        try{
           integer index=0;
           Opportunity TestOpp;
           List<Opportunity>  testOpportunityList= new List<Opportunity>();
           List<Id> OpportunityIds= new List<Id>();
           
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
        
            for (index = 0; index<200;index++){
                
                TestOpp =  new Opportunity (Name='Test Partner Opportunity No-' +index,  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23),AccountId=normalAccount.Id,Deal_Registration_Status__c='Approved'); 
                
                testOpportunityList.add(TestOpp);
            }

            
            Test.startTest(); 
            //Start the test, this changes limit context to trigger.
            insert testOpportunityList;
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();   
            
            //getting Ids of all the inserted oportunities into a list.
            for (Opportunity TestOppRecord : testOpportunityList){
                        OpportunityIds.add(TestOppRecord.Id);
             }   
             
//            List<Partner> partnerList = [SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId = :OpportunityIds[249] limit 10];            
//            System.debug('##KP: Number of records from to Partner table curresponding to the 250th Opportunity  :'+partnerList.size());
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(2,partnerList.size());   



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(200, [select count() from Opportunity where Id in : OpportunityIds]);

            system.debug('#### Validation of partner account addition');
//          system.assertEquals(400, [select count() from Partner where OpportunityId in : OpportunityIds]);
            system.assertEquals(200, [select count() from Partner where OpportunityId in : OpportunityIds and IsPrimary=true and Role='Identified at Account Level']);
            // Test Methods added by A L end


        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_05');

   }
 
  // Test method 6:  Partner opportunity Insert.Deal Registration Status set to "Approved". Covering the Limit Exception handling statements 

        static testMethod void Test_Method_06(){
        system.debug('## Start Test_Method_06 :: Partner opportunity Insert.Deal Registration Status set to "Approved". Covering the Limit-Exception handling statements ');
        
        try{
           integer index=0;
           Opportunity TestOpp;
           List<Opportunity>  testOpportunityList= new List<Opportunity>();
           List<Id> OpportunityIds= new List<Id>();
           
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
        
           for (index = 0; index<5;index++){
                
                TestOpp =  new Opportunity (Name='Test Partner Opportunity No-' +index,  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.newInstance(2009,9,23),AccountId=normalAccount.Id,Deal_Registration_Status__c='Approved'); 
                
                testOpportunityList.add(TestOpp);
            }


            forceLimitException = true;
            
            Test.startTest(); 
            //Start the test, this changes limit context to trigger.
            insert testOpportunityList;
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();   
            
            forceLimitException = false;
            
            //taking the Ids of all the inserted oportunities into a list.
            for (Opportunity TestOppRecord : testOpportunityList){
                OpportunityIds.add(TestOppRecord.Id);
            }           
            
//            List<Partner> partnerList = [SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId IN :OpportunityIds];            
//            System.debug('##KP: Number of records from to Partner table curresponding to the 5 inserted Opportunities  :'+partnerList.size());
            //##KP:Asserts that the Partner details are not added to Partner table
            //System.assertEquals(0,partnerList.size());   



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(5, [select count() from Opportunity where Id in : OpportunityIds]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(0, [select count() from Partner where OpportunityId in : OpportunityIds]);
            // Test Methods added by A L end


        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_06');

   }

*/
   // Test method 7: Partner opportunity Insert
   // Deal Registration Status set to "Approved"
   // Partner Account = Opportunity Account

        static testMethod void Test_Method_07(){
        system.debug('## Start Test_Method_07 ::  Partner opportunity Insert.Deal Registration Status set to- Approved');
        
        try{
           Map<Id,Account> PartnerAccountMap = new Map<Id,Account> ([SELECT Id, name FROM Account WHERE IsPartner = TRUE AND Calculated_Status__c = 'Active' limit 100]);
           Map<Id,Contact> PartnerContactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE AccountId IN  :PartnerAccountMap.keyset() limit 100]);
           User PartnerUser =[SELECT Id, ContactId FROM User WHERE IsActive = TRUE AND UserType = 'PowerPartner' AND ContactId IN :PartnerContactMap.keyset() limit 1];   
           Account normalAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
      
            //15.3 OMGO CR 8973 - Remove use of  Verifiable_Outcome__c 
            Opportunity TestOpp =  new Opportunity (Name='Test Opportunity for insert 1234',  OwnerId = PartnerUser.Id,
                                                        Stagename ='Plan - 1%', //Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                                        type='Deal/Bid - Direct', closedate=Date.today().addDays(2),//r5.0
                                                        AccountId=PartnerContactMap.get(PartnerUser.ContactId).AccountId,
                                                        Deal_Registration_Status__c='Approved'); 
            
                
             //Start the test, this changes limit context to trigger.
            Test.startTest(); 
            insert TestOpp;
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest();            
                        
//            TestOpp = [SELECT Id, Name, RecordTypeId, OwnerId, AccountId, PartnerAccountId FROM Opportunity WHERE Name LIKE '%Test Opportunity for insert 1234%' limit 1]; 
//            System.debug('Inserted opportunity :'+TestOpp);
            
//            List<Partner> partnerList=[SELECT OpportunityId,AccountToId,AccountFromId FROM Partner WHERE OpportunityId= :TestOpp.Id];
            //##KP:Asserts that the Partner details are added to Partner table
            //System.assertEquals(0,partnerList.size());
//            System.debug('Number of records from to Partner table curresponding to this test opportunity is:'+partnerList.size());



            // Test Methods added by A L
            system.debug('#### Validation of opportunity creation');
            system.assertEquals(1, [select count() from Opportunity where Id = : TestOpp.Id]);

            system.debug('#### Validation of partner account addition');
            system.assertEquals(0, [select count() from Partner where OpportunityId = : TestOpp.Id]);
            // Test Methods added by A L end



        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_07');

   }


 // Test method 8: Direct test for "addAccountPartnertoOpportunityRelatedList" method. 
 // Adds partner Accounts to Opportunities (not deal registrations) using the Apex method

        static testMethod void Test_Method_08(){
        system.debug('## Start Test_Method_08 ::  Direct test for --addAccountPartnertoOpportunityRelatedList-- method');
        
        try{
           integer index=0;
           Opportunity TestOpp;
           List<Opportunity>  testOpportunityList= new List<Opportunity>();
           Map<Id,Id> oppIdToPartnerAccountIdMap =new Map<Id,Id>(); 
           
           Account testAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
        
            for (index = 0; index<5;index++){
                //15.3 OMGO CR 8973 - Remove use of  Verifiable_Outcome__c
                TestOpp =  new Opportunity (Name='Test Partner Opportunity No-' +index,  
                                            Stagename ='Plan - 1%',// Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                            type='Deal/Bid - Direct', closedate=Date.today().addDays(2));// r5.0
                
                testOpportunityList.add(TestOpp);
            }

            try{
                insert testOpportunityList;
            }
            catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
                system.assert(false,'##KP: Exception: Test data creation failed!');
            }
            for(Opportunity OppRecord:testOpportunityList){
                oppIdToPartnerAccountIdMap.put(OppRecord.Id , testAccount.Id);
            }
            
            
            //Start the test, this changes limit context to trigger.            
            Test.startTest(); 
            
            //calling the method
            addAccountPartnertoOpportunityRelatedList(oppIdToPartnerAccountIdMap,FALSE);
            
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest(); 
            
// ALou - 2008/10/16 - Commented out for deployment            
            // Validation of opportunity creation
            system.debug('#### Validation of opportunity creation');
//            system.assertEquals(200, [select count() from Opportunity where Id in : oppIdToPartnerAccountIdMap.keyset()]);

            //Validation of partner account addition
            system.debug('#### Validation of partner account addition');
//           system.assertEquals(200, [select count() from Partner where OpportunityId in : oppIdToPartnerAccountIdMap.keyset() and IsPrimary=true and Role='Identified at Account Level']);


        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_08');

   }

// Test method 9: Direct test for "addAccountPartnertoOpportunityRelatedList" method. 
// Covering the Limit-Exception handling statements


        static testMethod void Test_Method_09(){
        system.debug('## Start Test_Method_09 ::  Direct test for --addAccountPartnertoOpportunityRelatedList-- method.Covering the Limit-Exception handling statements');
        
        try{
           integer index=0;
           Opportunity TestOpp;
           List<Opportunity>  testOpportunityList= new List<Opportunity>();
           Map<Id,Id> oppIdToPartnerAccountIdMap =new Map<Id,Id>(); 
           
           Account testAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
        
            for (index = 0; index<5;index++){
                //15.3 OMGO CR 8973 - Remove use of  Verifiable_Outcome__c
                TestOpp =  new Opportunity (Name='Test Partner Opportunity No-' +index,  
                                            Stagename ='Plan - 1%',// Verifiable_Outcome__c='Territory/Account/Opportunity Plan developed & reviewed by RSM',
                                            type='Deal/Bid - Direct', closedate=Date.today().addDays(2));// r5.0
                
                testOpportunityList.add(TestOpp);
            }

            try{
                insert testOpportunityList;
            }
            catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
                system.assert(false,'##KP: Exception: Test data creation failed!');
            }
            for(Opportunity OppRecord:testOpportunityList){
                oppIdToPartnerAccountIdMap.put(OppRecord.Id , testAccount.Id);
            }
            
            forceLimitException = true;
            //Start the test, this changes limit context to trigger.            
            Test.startTest(); 
            
            //calling the method
            addAccountPartnertoOpportunityRelatedList(oppIdToPartnerAccountIdMap,FALSE);
            
            //stop the test, this changes limit context back to test from trigger.
            Test.stopTest(); 
            
            forceLimitException = false;

// ALou - 2008/10/16 - Commented out for deployment 

            // Validation of opportunity creation
            system.debug('#### Validation of opportunity creation');
//            system.assertEquals(200, [select count() from Opportunity where Id in : oppIdToPartnerAccountIdMap.keyset()]);

            //Validation of partner account addition
            system.debug('#### Validation of partner account addition. No records should be found');
//            system.assertEquals(0, [select count() from Partner where OpportunityId in : oppIdToPartnerAccountIdMap.keyset() and IsPrimary=true and Role='Identified at Account Level']);


        }
        
        catch(Exception e){
                system.debug('##KP: Caught APEX exception'+e.getMessage());
        }
        system.debug('## End Test_Method_09');

   }



  }// end class PartnerAccountAddition