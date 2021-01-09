/*
Description: Helper Class  for beforeInsertOrUpdateCampaignMemberTrigger and afterInsertOrUpdateCampaignMemberTrigger
Version:2.0 

History:
1.0 - 09-Sept-2008: Creation
1.1 - 17-Sept-2008: [Albert Lou]
                     - In method removeFollowUpOnCampaignMembers(), updated SOQL query to further
                     filter records by status to account for scenarios in which a contact belongs
                     to multiple campaigns of different campaign types.
2.0 - 05-May-2009:  [Krishna]
                     - Added methods for adding the email Id of the Account Team Members to the 
                     curresponding fields in the Campaign Member record.  


Author: Meera Nair/Krishnaprasad P

*/
public class CampaignMemberFollowup {
    
    /*--------------------------------------- #1 ---------------------------------------------*/
    //  Method to update contacts:: sets follow_up__c = true.   
/*
    public static void setFollowUpOnContacts(Set<String> contactIds){
        List<Contact> updateContactArray=new Contact[]{};
        
        try{
            for(String contactId:contactIds){
                //Create Contact record to update
                Contact contactToUpdate = new Contact(id = contactId,follow_up__c = true);
                updateContactArray.add(contactToUpdate);
            }
            //public static Boolean BYPASS_CONTACT_TRIGGER = true;
            update updateContactArray;
            //public static Boolean BYPASS_CONTACT_TRIGGER = false;
        }
        catch(Exception e){
            //Throw exception occured
            throw new dellUtil.DellException('Class:CampaignMemberFollowup:Exception occured:'+e.getMessage());
        }
    }
    
  */  
    /*----------------------------------------- #2 -------------------------------------------*/
    //  Method to update contacts and Campaign Member objects
    //  Update contacts : sets follow_up__c = false. The list of Contacts is passed as arguement.   
    //  Update Campaign Members : sets the status as 'Completed Follow-Up'. invokes the removeFollowUpOnCampaignMembers (#3) method.
    //  called from Trigger on Activity
    
  /*  public static void removeFollowUpOnContactsAndCampaignMembers(Set<String> contactIds,List<Contact> updateContactArray){
            try{
                //invoking method to update Campaign Members
                removeFollowUpOnCampaignMembers(contactIds);    
                
                if(updateContactArray.size() > 0){
                    //THIS MUST BE SET TO TRUE OR A TRIGGER WILL FIRE WITHOUT NEED
                    globalVariables.BYPASS_CONTACT_TRIGGER = true;
                    update (updateContactArray);
                    //THIS MUST BE SET TO FALSE AFTER
                    globalVariables.BYPASS_CONTACT_TRIGGER = false;
                }
       }
       catch(Exception e){
            //Throw exception occured 
            throw new dellUtil.DellException('Class:CampaignMemberFollowup:Exception occured:'+e.getMessage());
        }
    }
    
    */
    /*----------------------------------------- #3 -------------------------------------------*/
    //  Method to update Campaign Members associated to Contacts.
    //  Update Campaign Members : sets the status as 'Completed Follow-Up'.
    //  called from Contact Trigger
    
 /*   public static void removeFollowUpOnCampaignMembers(Set<String> contactIds){
        //variable declaration
        List<Campaign_Member__c> updateCampaignMemberArray= new Campaign_Member__c[]{};
        
        try{
            //Get Campaign Member records associated to the Contacts curresponding to the contactIds
            for (List<Campaign_Member__c> campaignMembers : [select id,S__c from Campaign_Member__c 
                                                            where contact__c IN :contactIds
                                                            and IsFollowUpCampaignType__c = 'True'
                                                            and S__c = 'Requires Follow-Up']){
                //iterate over batch of 200                                                 
                for (Campaign_Member__c campaignMemberToUpdate : campaignMembers){
                                        
                    //sets the status as Completed Follow-Up'
                    campaignMemberToUpdate.S__c = 'Completed Follow-Up';
                    updateCampaignMemberArray.add(campaignMemberToUpdate);
                    //Check whether array size crosses the DML execution limit
                    
                    if (updateCampaignMemberArray.size() == 200){
                        //globalVariables.BYPASS_CAMPAIGN_TRIGGER  = true;
                        update (updateCampaignMemberArray);
                        //globalVariables.BYPASS_CAMPAIGN_TRIGGER  = false;
                        
                        //Clears the list
                        updateCampaignMemberArray.clear();
                    }//end of if block
                    
                } //end of batch-for-loop 
            }//end of Query loop
    
            //updates the remaining records in the updateCampaignMemberArray
            if(updateCampaignMemberArray.size() > 0){
                //globalVariables.BYPASS_CAMPAIGN_TRIGGER  = true;
                update updateCampaignMemberArray;
                //globalVariables.BYPASS_CAMPAIGN_TRIGGER  = false;
            }
            
       }
       catch(Exception e){
            //Throw exception occured 
             throw new dellUtil.DellException('Class:CampaignMemberFollowup:Exception occured:'+e.getMessage());
        }
    }
    
    
    
    */
    
    /*----------------------------------------- #4 -------------------------------------------*/
    //  Method to add the associate the email Ids of the required Acc team Membrs 
    //  to the email fields in the  Campaign Members records
    
 /*   public static void AddFollowUpEmailIds(Map<id,List<Campaign_Member__c>> accIdToCampMembListMap,
                                       Set<Id> campaignIdSet,
                                       Set<Id> contactIdSet,
                                       List<Campaign_Member__c> contactCampaignMemberList){
        
        
        system.debug('##KP: Inside Method AddFollowUpEmailIds  ##');
        
        //## variable declaration and initailization
        Map<Id,String> campIdToPrimaryRoleMap = new Map<Id,String>();
        Id accountIdOfContact, currentAccountId;
        Map<String,String> roleToEmailMap = new Map<String,String>();
        
        //## collects the required roles in to a set for using in SOQL query        
        Set<String> requiredRoleSet = new Set<String> {'Account Executive' ,'Inside Sales Rep'};

        
        //## Makes a contact Id => Contact Map
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE Id IN :contactIdSet]);
        
        //## Adds the Campaign Member records from contactCampaignMemberList to accIdToCampMembListMap
        for(Campaign_Member__c campaignMemberItem: contactCampaignMemberList){
            system.debug('##KP: contact Id of CampaignMember : ' + campaignMemberItem.Contact__c);
            accountIdOfContact = contactMap.get(campaignMemberItem.Contact__c).AccountId;
            system.debug('##KP: Account : ' + contactMap.get(campaignMemberItem.Contact__c));
            if(accIdToCampMembListMap.get(accountIdOfContact)== null)
                accIdToCampMembListMap.put(accountIdOfContact, new List<Campaign_Member__c>{campaignMemberItem}); 
            else 
                accIdToCampMembListMap.get(accountIdOfContact).add(campaignMemberItem);
        }   
        system.debug('##KP: accIdToCampMembListMap.size()=' + accIdToCampMembListMap.size());       
                
                
        //## Makes a map of Campaign Id=> Followup role
        for(Campaign campaignItem: [SELECT Id,Follow_Up_Role__c
                                    FROM Campaign 
                                    WHERE Id IN :campaignIdSet
                                    AND Follow_Up_Role__c!=null]){
                                     
            system.debug('##KP: campaignItem.Id=' + campaignItem.Id + ', Follow_Up_Role__c=' + campaignItem.Follow_Up_Role__c); 
            campIdToPrimaryRoleMap.put(campaignItem.Id, campaignItem.Follow_Up_Role__c);
            //## Adds to the unique role to the set
            requiredRoleSet.add(campaignItem.Follow_Up_Role__c);
        }
        system.debug('##KP: requiredRoleSet =' + requiredRoleSet);  
        //## currentAccountId keeps the AccountID that is being processed
        currentAccountId = null;

        //## SOQL query teakes the AccTeamMembs in order of AccountId,TeamMemberRole and LastModifiedDate
        for (AccountTeamMember  accountTeamMemberItem : [SELECT Id, User.Email, AccountId, TeamMemberRole 
                                                       FROM AccountTeamMember
                                                       WHERE AccountId IN :accIdToCampMembListMap.keySet() 
                                                       AND TeamMemberRole IN :requiredRoleSet              
                                                       ORDER BY AccountId,TeamMemberRole,LastModifiedDate DESC]){
    
    
            if(currentAccountId == null){
                //## executes only once : kind of initialization
                currentAccountId = accountTeamMemberItem.AccountId;
            }
            system.debug('##KP: currentAccountId =' + currentAccountId +',Team role=' + accountTeamMemberItem.TeamMemberRole);
            if(currentAccountId != accountTeamMemberItem.AccountId){  
                system.debug('##KP: Account Id changed. Calling method');
                //## The Account Id being processed is changed; means all the AccTeamMemb for that Acc are already selected
                //## method is called to assign the AccTeamMemb emails to the CampMembrecords
                assignTheEmailsToCampaignMemberFields(accIdToCampMembListMap,currentAccountId,roleToEmailMap,campIdToPrimaryRoleMap);   
                //## Changes the currentAccountId to the latest AccountId
                currentAccountId = accountTeamMemberItem.AccountId;
                //## refreshes the Rolename=>email map
                roleToEmailMap.clear();
            }
                
            //## Adds the AccTeamMemb email to the Rolename=>email map
            if(roleToEmailMap.get(accountTeamMemberItem.TeamMemberRole)==null){
                roleToEmailMap.put(accountTeamMemberItem.TeamMemberRole,accountTeamMemberItem.user.email);
            }
            system.debug('##KP: current roleToEmailMap =' + roleToEmailMap);
        }//end of query for loop
        
        if(roleToEmailMap.size()>0){
            system.debug('##KP: remaining assignment. Calling method');
            assignTheEmailsToCampaignMemberFields(accIdToCampMembListMap,currentAccountId,roleToEmailMap,campIdToPrimaryRoleMap);
        }
        
    }//end of method
*/    
    /*----------------------------------------- #5 -------------------------------------------*/
    //  Method to assigns the email fields 
    
  /*  public static void assignTheEmailsToCampaignMemberFields(Map<id,List<Campaign_Member__c>> accIdToCampMembListMap,
                                                        Id currentAccountId,
                                                        Map<String,String> roleToEmailMap,
                                                        Map<Id,String> campIdToPrimaryRoleMap){
                                            
        system.debug('##KP: Inside method :assignTheEmailsToCampaignMemberFields ');
        //## takes the list of CampMemb records curresponding to CurrentAccountId
        List<Campaign_Member__c> tempCampMembList = accIdToCampMembListMap.get(currentAccountId);
        
        for(Campaign_Member__c campaignMemberItem : tempCampMembList){          
            
            //## Assigns the email Id from the role=> email map to each Camp Memb record
            campaignMemberItem.Primary_Follow_up_email__c = RoleToEmailMap.get(campIdToPrimaryRoleMap.get(campaignMemberItem.Campaign__c));
            campaignMemberItem.Inside_Sales_Rep_email__c = RoleToEmailMap.get('Inside Sales Rep');
            campaignMemberItem.Account_Executive_email__c = RoleToEmailMap.get('Account Executive');    
                
        }//end of for loop
        
    }//end of method
    
    
    
    */
    
/*----------------------------------------- TEST METHODS -------------------------------------------*/
    
    /*---------- TEST METHODS FOR method setFollowUpOnContacts AND beforeInsertOrUpdateCampaignMemberTrigger-------- */
     
     
     // Test method 1: Pass an invalid contact id to the set so that Exception will occur
     
   /*     public static testMethod void Test_exception_setFollowUpOnContacts(){
            system.debug('##MN: Start Test_exception_setFollowUpOnContacts ');
            //Create Test Data
            Boolean exceptionThrown = false;
            try{
                Set<String> contactIdsToUpdate = new Set<String>();
                contactIdsToUpdate.add('abc');
                Test.startTest();
                //Call the method to test 
                setFollowUpOnContacts(contactIdsToUpdate);
                Test.stopTest();
            }catch(Exception e){
                exceptionThrown = true;
            }
            system.assertEquals(true,exceptionThrown);
            system.debug('##MN: END Test_exception_setFollowUpOnContacts ');
        }
      */
        
        // Test method 2: Pass a valid contact id to the set
        /* 
        public static testMethod void Test_success_setFollowUpOnContacts(){
            system.debug('##MN: Start Test_success_setFollowUpOnContacts ');
            //Create Test Data
            Boolean exceptionThrown = false;  
            
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            Contact testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');

            
            
            
            try{
                insert testContact;
                Set<String> contactIdsToUpdate = new Set<String>();
                
                contactIdsToUpdate.add(testContact.id);
                Test.startTest();
                //Call the method to test 
                setFollowUpOnContacts(contactIdsToUpdate);
                Test.stopTest();
            }catch(Exception e){
                exceptionThrown = true;
            }
            system.assertEquals(false,exceptionThrown);
            System.assertEquals(true,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);         
            system.debug('##MN: END Test_success_setFollowUpOnContacts ');
        }
    */
      
        // Test method 3: Create a Campaign Member Object with a valid status to fire the beforeInsertOrUpdateCampaignMemberTrigger
        
    /*    
    public static testMethod void Test_followup_campaignMemberTrigger(){
            system.debug('##MN: Start Test_followup_campaignMemberTrigger');
            
            //CREATING TEST DATA

            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            Contact testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
            
            insert testContact;
            
            //creating test Campaign
            Campaign  TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign 1234');
            insert TestCampaign;
            

            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            Campaign_Member__c testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,
                                                                        Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');


            Test.startTest();
            //insert the new Campaign Member Object 
            insert testCampaignMember;
            Test.stopTest();
            
            System.assertEquals(true,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            system.debug('##MN: END Test_followup_campaignMemberTrigger');
        }
 */       
        // Test method 4: Create a Campaign Member Object with an invalid status to prevent the execution of beforeInsertOrUpdateCampaignMemberTrigger
 /*       
        public static testMethod void Test_no_followup_campaignMemberTrigger(){
            system.debug('##MN: Start Test_no_followup_campaignMemberTrigger');
            
        
            //CREATING TEST DATA

            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            Contact testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
            
            insert testContact;
            
            //creating test Campaign
            Campaign  TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign 1234');
            insert TestCampaign;
            
            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            Campaign_Member__c testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,
                                                                        Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,S__c='Test');

            
            
            Test.startTest();
            //insert the new Campaign Member Object 
            insert testCampaignMember;
            Test.stopTest();
                
            System.assertEquals(false,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            system.debug('##MN: END Test_no_followup_campaignMemberTrigger');
        }
   */     
        
    /*---------- TEST METHODS FOR method removeFollowUpOnContactsAndCampaignMembers AND beforeInsertOrUpdateActivityTrigger-------- */
        
        
        // Test method 6: Pass a contact with invalid id to the list so that Exception will occur
     /*     
          public static testMethod void Test_exception_onContact_removeFollowUpOnContactsAndCampaigns(){
            system.debug('##MN: Start Test_exception_onContact_removeFollowUpOnContactsAndCampaigns');
            //Create Test Data
            Boolean exceptionThrown = false;
            try{
                Set<String> contactIdsToUpdate = new Set<String>();
                
                //creating test contact 
                Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
                Contact testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                                EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                                Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
                
                insert testContact;
                
                contactIdsToUpdate.add(testContact.id);
                
                Contact testContact2=new Contact(id='abc', Status__c='Active', AccountId=TestAccount.Id, 
                                                EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                                Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
                                                
                                                
                                                
                List<Contact> testContactList=new List<Contact>();
                testContactList.add(testContact2);
                
                Test.startTest();               
                //Call the method to test 
                removeFollowUpOnContactsAndCampaignMembers(contactIdsToUpdate,testContactList);
                Test.stopTest();
                
            }catch(Exception e){
                exceptionThrown = true;
            }
            //assert that Exception occured
            system.assertEquals(true,exceptionThrown);
            system.debug('##MN: END Test_exception_onContact_removeFollowUpOnContactsAndCampaigns');
        }
     */   
        // Test method 7: Pass valid contactid and Contact to the method
     /*  
        public static testMethod void Test_success_removeFollowUpOnContactsAndCampaignMembers(){
            system.debug('##MN: Start Test_success_removeFollowUpOnContactsAndCampaignMembers');
            
            //Create Test Data

            Contact testContact;
            Campaign testCampaign;
            Campaign_Member__c testCampaignMember;
            
            Set<String> contactIdsToUpdate = new Set<String>();
            List<Contact> testContactList=new List<Contact>();
            
            
            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234',Follow_up__c=true);
            
            insert testContact;
                            
                            
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                    Name='Test Campaign 1234');
            insert TestCampaign;
                
            
            
            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,
                                                        Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');

                       
            //insert the new Campaign Member Object 
            insert testCampaignMember;
            
            
            contactIdsToUpdate.add(testContact.id);
            testContactList.add(testContact);
            
            Test.startTest();
                //calling method
                removeFollowUpOnContactsAndCampaignMembers(contactIdsToUpdate,testContactList);
            Test.stopTest();
                
            
            
            System.assertEquals(true,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            System.assertEquals('Completed Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMember.id].S__c);
            system.debug('##MN: END Test_success_removeFollowUpOnContactsAndCampaignMembers');
        }
    */    
         // Test method 8: Create a new Task with Type Campaign Follow Up so that trigger get executed
        
  /*      
  public static testMethod void Test_success_removefollowup_TaskTrigger(){
            system.debug('##MN: Start Test_success_removefollowup_TaskTrigger');
            
            //Create Test Data
            
            Contact testContact;
            Campaign testCampaign;
            Campaign_Member__c testCampaignMember;
            
            
            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
            
            insert testContact;         
                
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                        Name='Test Campaign 1234');
            insert TestCampaign;
                

            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,Campaign__c=TestCampaign.id,
                                                        Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');

        
            insert testCampaignMember;              
                                
            //Create a new Task with Type='Campaign Follow Up'
                                        
            rectype=[Select Name, Id From RecordType where Name='Standard Task'];
            Task testTask=new Task(Type='Campaign Follow Up',Subject='Test Subject',
                                    Status='Not Started',RecordTypeId=rectype.Id,Priority='High',OwnerId=UserInfo.getUserId(),
                                    WhoId=testContact.id);
            
                                
            Test.startTest();
            //insert the new Task Object 
            insert testTask;
            Test.stopTest();
                

            //Assert that Follow up is completed
            System.assertEquals(false,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            System.assertEquals('Completed Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMember.id].S__c);
            system.debug('##MN: END Test_success_removefollowup_TaskTrigger');
        }
    */    
        // Test method 9: Create a new Task with Type 'Test' so that trigger not get fired
 /*      
  public static testMethod void Test_noaction_TaskTrigger(){
            system.debug('##MN: Start Test_noaction _TaskTrigger');
            
            //Create Test Data
            
            Contact testContact;
            Campaign testCampaign;
            Campaign_Member__c testCampaignMember;
            
            Set<String> contactIdsToUpdate = new Set<String>();
            List<Contact> testContactList=new List<Contact>();
            
    
            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
            
            insert testContact;         
                
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign 1234');
            insert TestCampaign;
                

            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,Campaign__c=TestCampaign.id,
                                                        Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');

        
            insert testCampaignMember;
                
            //Create a new Task with Type='Test'                                
            rectype=[Select Name, Id From RecordType where Name='Standard Task'];
            Task testTask=new Task(Type='Test',Subject='Test Subject',
                                    Status='Not Started',RecordTypeId=rectype.Id,Priority='High',OwnerId=UserInfo.getUserId(),
                                    WhoId=testContact.id);
            
                            
            Test.startTest();
            //insert the new Task Object 
            insert testTask;
            Test.stopTest();
            
        

            //Assert that follow up is not over
            System.assertEquals(true,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            System.assertEquals('Requires Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMember.id].S__c);
            system.debug('##MN: END Test_noaction _TaskTrigger');
        }
        
  */      
    /*---------- TEST METHODS FOR method removeFollowUpOnCampaignMembers AND beforeUpdateContactTrigger-------- */
       
     // Test method 10: Pass an invalid contact id to the set 
   /*     
   public static testMethod void Test_exceptionOrNoaction_removeFollowUpOnCampaignMembers(){
            system.debug('##MN: Start Test_exceptionOrNoaction_removeFollowUpOnCampaignMembers');
            
            //Create Test Data
            Boolean exceptionThrown = false;
            
            try{
                Set<String> contactIdsToUpdate = new Set<String>();
                contactIdsToUpdate.add('abc');
                
                Test.startTest();
                //Call the method to test 
                removeFollowUpOnCampaignMembers(contactIdsToUpdate);
                Test.stopTest();
                
            }catch(Exception e){
                exceptionThrown = true;
            }
            //Exception will not occur since update operation is on Campaign Member object list which is empty because of invalid contact id
            system.assertEquals(false,exceptionThrown);
            system.debug('##MN: END Test_exceptionOrNoaction_removeFollowUpOnCampaignMembers');
        }
   */     
        // Test method 11: Pass a valid contact id to the set 
  /*     
   public static testMethod void Test_success_removeFollowUpOnCampaignMembers(){
            system.debug('##MN: Start Test_success_removeFollowUpOnCampaignMembers');
            
            //Create Test Data

            Contact testContact;
            Campaign testCampaign;
            Campaign_Member__c testCampaignMember;
            
            Set<String> contactIdsToUpdate = new Set<String>();
            List<Contact> testContactList=new List<Contact>();
            
            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234',Follow_up__c=true);
            
            insert testContact;
            
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign 1234');
            insert TestCampaign;
                
            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,Campaign__c=TestCampaign.id,
                                                        Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');
            
            
            contactIdsToUpdate.add(testContact.id);
            testContactList.add(testContact);
            
            Test.startTest();
            //insert the new Campaign Member Object 
            insert testCampaignMember;          
            removeFollowUpOnCampaignMembers(contactIdsToUpdate);
            Test.stopTest();

            System.assertEquals(true,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            System.assertEquals('Completed Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMember.id].S__c);         
            system.debug('##MN: END Test_success_removeFollowUpOnCampaignMembers');
        }
      */
        
        // Test method 12: Update Follow_up__c of contact from true to false so that trigger on Contact get executed 
  /*      
  public static testMethod void Test_success_removefollowup_ContactTrigger(){
            system.debug('##MN: Start Test_success_removefollowup_ContactTrigger');
            
            //Create Test Data

            Contact testContact;
            Campaign testCampaign;
            Campaign_Member__c testCampaignMember;          

            //creating test contact 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234',Follow_up__c=true);
            
            insert testContact;
            
            
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                                    IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                                    Name='Test Campaign 1234');
            insert TestCampaign;
                
            //Create new test Campaign Member
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];
            testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,Contact__c = testContact.id,Campaign__c=TestCampaign.id,
                                                        Campaign_Type__c=TestCampaign.Type,S__c='Requires Follow-Up');
            insert testCampaignMember;
            
            Contact newTestContact=[select id,follow_up__c from Contact where id=:testContact.id];
            newTestContact.follow_up__c=false;
                
            Test.startTest();
            //update the new Contact record 
            update newTestContact;
            Test.stopTest();
                
            //Assert that Follow up is completed
            System.assertEquals(false,[select follow_up__c from Contact where id=:testContact.id].follow_up__c);
            System.assertEquals('Completed Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMember.id].S__c);
            system.debug('##MN: END Test_success_removefollowup_ContactTrigger');
        }
      */ 
        // Test method 13: Bulk testing removeFollowUpOnCampaignMembers method
/*      
public static testMethod void Test_success_removeFollowUpOnCampaignMembersBulk(){
            system.debug('##MN: Start Test_success_removeFollowUpOnCampaignMembersBulk');
            
            //Create Test Data

            List<Contact> testContactList=new List<Contact>();
            Campaign testCampaign;
            
            List<Campaign_Member__c> testCampaignMemberList=new List<Campaign_Member__c>();
            Campaign_Member__c testCampaignMember;
            
            Set<String> contactIdsToUpdate = new Set<String>();
            integer i=0;
            
                            
            //creating test contacts 
            Account TestAccount = [SELECT Id, name FROM Account WHERE IsPartner = FALSE AND Calculated_Status__c = 'Active' limit 1];
            
            for(i=0;i<3;i++){
                Contact testContact=new Contact(Status__c='Active', AccountId=TestAccount.Id, 
                                            EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 100'+i,Follow_up__c=true);
                testContactList.add(testContact);
            }   
            
            insert testContactList;             
            
            //creating test Campaign
            TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                        Name='Test Campaign 1234');
            insert TestCampaign;
                
            RecordType rectype=[Select Name, Id From RecordType where SobjectType='Campaign_Member__c' AND Name LIKE '%Contact%' LIMIT 1];  

            //with first contact 
            for(i=0;i<100;i++){
                testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,
                                                        Contact__c=testContactList[0].id,
                                                        Campaign__c=testCampaign.id,Campaign_Type__c=testCampaign.Type,S__c='Requires Follow-Up');
                testCampaignMemberList.add(testCampaignMember);
            }                           
            insert testCampaignMemberList;
            testCampaignMemberList.clear();
                
                
            //with second contact
            for(i=0;i<100;i++){
                testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,
                                                        Contact__c=testContactList[1].id,
                                                        Campaign__c=testCampaign.id,Campaign_Type__c=testCampaign.Type,S__c='Requires Follow-Up');
                testCampaignMemberList.add(testCampaignMember);
            }                           
            insert testCampaignMemberList;
            testCampaignMemberList.clear();
                
                
                
            //with third contact
            for(i=0;i<100;i++){
                testCampaignMember=new Campaign_Member__c(RecordTypeId=rectype.Id,
                                                        Contact__c=testContactList[2].id,
                                                        Campaign__c=testCampaign.id,Campaign_Type__c=testCampaign.Type,S__c='Requires Follow-Up');
                testCampaignMemberList.add(testCampaignMember);
            }                           
            insert testCampaignMemberList;                      
        
            
            Set<String> ContactIdSet=new Set<String> {testContactList[0].id, testContactList[1].id,testContactList[2].id};          
            Test.startTest();                   
            removeFollowUpOnCampaignMembers(ContactIdSet);          
            Test.stopTest();
            
            
            System.assertEquals('Completed Follow-Up',[select S__c from Campaign_Member__c where id =:testCampaignMemberList[0].id].S__c);
            system.debug('##MN: END Test_success_removeFollowUpOnCampaignMembersBulk');

        }
        
     */   
       

      // Test method 14: Testing the beforeInsertUpdateCampaignMemberTrigger one contact CM and one Account CM
    /* 
      public static testMethod void Test_addFollowUpEmailIds_Insert(){
            system.debug('##MN: Start Test_addFollowUpEmailIds_Insert');
            
            //Create Test Data

            integer i=0;            
            Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];            
            List<User> testUserList =new List<User>();
            //create test user                      
            for (i=0; i<3;i++){
                User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                    Alias = 'test'+i, 
                                    Email='test'+ i +'@dell.com', 
                                    FirstName='Tfirst'+i, 
                                    LastName='TLast'+i,
                                    ProfileId = userProfile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='TEST12345'+i
                );
                
                testUserList.add(user);               
                
            }
            
            insert testUserList;
            
            //creating test Account 
            Account testAccount=new Account(name='testAccount');
            insert testAccount;
            
            //creating test contact 
            Contact testContact=new Contact(Status__c='Active', AccountId=testAccount.Id, 
                                        EMEA_Decision_Making_Role__c='Influencer', Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                        Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact 1234');
            
            insert testContact;
            
            
            List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
            
             // Add users to the test account's AccountTeamMember list  
            for(Integer j=0; j< 3; j++){         
                AccountTeamMember testAccTM = new AccountTeamMember();
                testAccTM.userid = testUserList[j].id;
                testAccTM.accountid = testAccount.id;               
                testAcctTMs.add(testAccTM);             
            }
            testAcctTMs[0].TeamMemberRole= 'Account Executive'; 
            testAcctTMs[1].TeamMemberRole= 'Inside Sales Rep';
            testAcctTMs[2].TeamMemberRole= 'System Consultant';
                        
            insert testAcctTMs;
            
            //creating test Campaign
            Campaign TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                        Name='Test Campaign 1234',Follow_Up_Role__c='System Consultant');
            insert TestCampaign;
            
                        
            List<Campaign_Member__c> testCampaignMemberList=new List<Campaign_Member__c>();
            Campaign_Member__c testCampaignMember;
            
            for(RecordType RecordTypeItem: [Select Name, Id From RecordType 
                                            where SobjectType='Campaign_Member__c' 
                                            AND (Name LIKE '%Contact%' OR  Name LIKE '%Account%') LIMIT 2]){
                                                
                            
                testCampaignMember=new Campaign_Member__c(RecordTypeId=RecordTypeItem.Id,                                                               
                                                            Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,
                                                            S__c='Requires Follow-Up');
                    
                if(RecordTypeItem.name.contains('Contact')){                    
                    testCampaignMember.Contact__c=testContact.id;                   
                }
                if(RecordTypeItem.name.contains('Account')){                    
                    testCampaignMember.Account__c=testAccount.id;
                }
                testCampaignMemberList.add(testCampaignMember);
            }
             
                        
            Test.startTest();                   
            insert testCampaignMemberList;          
            Test.stopTest();
            
            system.debug('testCampaignMemberList'+ testCampaignMemberList);
            system.debug('testCampaignMemberList[0].id'+ testCampaignMemberList[0].id);
            
            System.assertEquals('test0@dell.com',[select id, Account_Executive_email__c from Campaign_Member__c where id =:testCampaignMemberList[0].id limit 1].Account_Executive_email__c);
            system.debug('##MN: END Test_addFollowUpEmailIds_Insert');

        }
        
      */
      
      // Test method 15: Testing the beforeInsertUpdateCampaignMemberTrigger two Account CM
    /*
      public static testMethod void Test_addFollowUpEmailIds_Insert_twoAccounts(){
            system.debug('##MN: Start Test_addFollowUpEmailIds_Insert_twoAccounts');
            
            //Create Test Data

            integer i=0;            
            Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];            
            List<User> testUserList =new List<User>();
            //create test user                      
            for (i=0; i<3;i++){
                User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                    Alias = 'test'+i, 
                                    Email='test'+ i +'@dell.com', 
                                    FirstName='Tfirst'+i, 
                                    LastName='TLast'+i,
                                    ProfileId = userProfile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='TEST12345'+i
                );
                
                testUserList.add(user);               
                
            }
            
            insert testUserList;
            
            //creating test Account 
            List<Account> testAccountList=new List<Account>{new Account(name='testAccount1'),new Account(name='testAccount2')};
            insert testAccountList;
            
            List<AccountTeamMember> testAcctTMs = new List<AccountTeamMember>();
            
            
             // Add users to the test account's AccountTeamMember list  
            for(Integer j=0; j< 3; j++){
                         
                AccountTeamMember testAccTM = new AccountTeamMember();
                testAccTM.userid = testUserList[j].id;
                testAccTM.accountid = testAccountList[0].id;                    
                testAccTM.TeamMemberRole= 'Account Executive';                  
                testAcctTMs.add(testAccTM); 
                
                testAccTM = new AccountTeamMember();
                testAccTM.userid = testUserList[j].id;
                testAccTM.accountid = testAccountList[1].id;
                testAccTM.TeamMemberRole= 'Account Executive';              
                testAcctTMs.add(testAccTM);     
            }
            
            insert testAcctTMs;
            
            //creating test Campaign
            Campaign TestCampaign = new Campaign (Type='eSeminar/Webcast/Webinar', EndDate= date.newInstance(2010, 1, 1), 
                                        IsActive=true, Description='Test Campaign', StartDate=date.newInstance(2009, 12, 1), 
                                        Name='Test Campaign 1234',Follow_Up_Role__c='Account Executive');
            insert TestCampaign;
            
                        
            List<Campaign_Member__c> testCampaignMemberList=new List<Campaign_Member__c>();
            Campaign_Member__c testCampaignMember;
            
            RecordType RecordTypeItem= [Select Name, Id From RecordType 
                                            where SobjectType='Campaign_Member__c' 
                                            AND Name LIKE '%Account%' LIMIT 1];
                                                
                        
            testCampaignMember=new Campaign_Member__c(RecordTypeId=RecordTypeItem.Id,Account__c=testAccountList[0].Id,                                                          
                                                        Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,
                                                        S__c='Requires Follow-Up');             

            testCampaignMemberList.add(testCampaignMember);
    
            testCampaignMember=new Campaign_Member__c(RecordTypeId=RecordTypeItem.Id,Account__c=testAccountList[1].Id,                                                          
                                                        Campaign__c=TestCampaign.id,Campaign_Type__c=TestCampaign.Type,
                                                        S__c='Requires Follow-Up');
                                                        
            testCampaignMemberList.add(testCampaignMember);
                        
            Test.startTest();                   
            insert testCampaignMemberList;          
            Test.stopTest();
            
            system.debug('testCampaignMemberList'+ testCampaignMemberList);
            system.debug('testCampaignMemberList[0].id'+ testCampaignMemberList[0].id);
            
            System.assertNotEquals(null,[select id, Account_Executive_email__c from Campaign_Member__c where id =:testCampaignMemberList[0].id limit 1].Account_Executive_email__c);
            system.debug('##MN: END Test_addFollowUpEmailIds_Insert_twoAccounts');

        }
        
     */ 
        

} //end of class CampaignMemberFollowup