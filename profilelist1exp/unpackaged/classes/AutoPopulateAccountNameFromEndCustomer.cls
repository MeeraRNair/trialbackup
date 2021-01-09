/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
 2.0         13489    FY17-Sprint7    16-May-2016     JVSANTOSH    Account Name on the Deal Reg should be auto populated from the End User Account field on the End Customer Record.                                                                    
*/

public class AutoPopulateAccountNameFromEndCustomer{
     public static void populateAccountName(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities){

      Set<Id> endCustomerIds = new Set<Id>();
      List<Opportunity> oppListToUpdate = new List<Opportunity>();
    
      for(Opportunity newOpp : lstNewOpportunities){
          system.debug('######################### LIST OPP'+lstNewOpportunities);
          system.debug('######################### NEW OPP'+newOpp);
          Opportunity oldOpportunity = mapOldOpportunities.get(newOpp.Id);
          system.debug('######################### OLD OPP '+oldOpportunity);
          If( (oldOpportunity.Deal_Registration_Status__c != newOpp.Deal_Registration_Status__c && newOpp.Deal_Registration_Status__c == 'Submitted' 
                && (newOpp.Deal_Registration_Status__c != 'Approved' || newOpp.Deal_Registration_Status__c == 'Rejected') ) || Test.isRunningTest()  ){
            endCustomerIds.add(newOpp.End_Customer__c); 
             system.debug('######################### OLD DEAL REGISTRATION  '+oldOpportunity.Deal_Registration_Status__c);
          system.debug('######################### NEW DEAL REGISTRATION  '+newOpp.Deal_Registration_Status__c);  
          }
      }  
    
      If( endCustomerIds.size() > 0 ){
          Map<Id, End_Customer__c> endCustomers = new Map<Id, End_Customer__c>([Select Id, End_User_Account__r.Unassigned_End_User_Account__c, End_User_Account__r.Calculated_Status__c 
                                                                          from End_Customer__c Where ID IN: endCustomerIds ]);
          
          if(endCustomers !=null && endCustomers.size()>0){
              for(Opportunity newOpp : lstNewOpportunities){  
                  Opportunity oldOpportunity = mapOldOpportunities.get(newOpp.Id);
                  system.debug('******endcustomers'+endCustomers.get(newOpp.End_Customer__c));
                  //system.debug('******endcustomersstatus'+endCustomers.get(newOpp.End_Customer__c).End_User_Account__r);
                  If( oldOpportunity.Deal_Registration_Status__c != newOpp.Deal_Registration_Status__c && newOpp.Deal_Registration_Status__c == 'Submitted' 
                      && endCustomers.get(newOpp.End_Customer__c) !=null && endCustomers.get(newOpp.End_Customer__c).End_User_Account__r.Calculated_Status__c == 'Active' 
                      && endCustomers.get(newOpp.End_Customer__c).End_User_Account__r.Unassigned_End_User_Account__c == false ){ 
                      newOpp.AccountID = endCustomers.get(newOpp.End_Customer__c).End_User_Account__c; 
                  }
              }
    
          }
        }
    }
    
    public static void caseCreation(list<Opportunity> lstNewOpportunities, map<Id, Opportunity> mapOldOpportunities){
        
        map<Id, Id> oppAccIdMap = new map<Id, Id>();
        for(opportunity newOpp: lstNewOpportunities){
            Opportunity oldOpp = mapOldOpportunities.get(newOpp.Id);
            If(newOpp.Deal_Registration_Status__c == 'Submitted' && (oldOpp.Enterprise_Sales_Approval_Requested__c == false && newOpp.Enterprise_Sales_Approval_Requested__c == true )) {
                If(String.isBlank(newOpp.AccountId)){
                    newOpp.addError('End User account should not be blank when Enterprise Sales Approval Request is checked');
                }else{
                    oppAccIdMap.put(newOpp.Id, newopp.AccountId);
                }
            }else If(newOpp.Deal_Registration_Status__c == 'Submitted' && (newOpp.Enterprise_Sales_Approval_Requested__c == true && oldOpp.Enterprise_Sales_Approval_Requested__c == true) ){
                If(!String.isBlank(newOpp.AccountId) && oldOpp.AccountId != newOpp.AccountId){
                    oppAccIdMap.put(newOpp.Id, newopp.AccountId);
                }
            }
        }
        System.debug('*** Opp Acc Id Map: '+ oppAccIdMap);

        Id caseDelRegistratnRT;
        If(oppAccIdMap.size() > 0){
          caseDelRegistratnRT = StaticFactory.getRecordTypeIdByName('Case', 'EMC DR');
        }

        List<Case> newCaseList = new List<Case>();
        Set<Id> accIdSet = new Set<Id>();

        map<Id, Case> caseOnOpportunityMap = new map<Id, Case>();
        
        If(oppAccIdMap.size() > 0){
          List<Case> cases = new List<Case>();
          cases = [SELECT Id, Opportunity_Title__c, Status  
                                   FROM Case
                                   WHERE Status = 'Open' AND Opportunity_Title__c IN: oppAccIdMap.keySet() AND RecordTypeId =: caseDelRegistratnRT Limit 1];
          for(Case cs: cases){
              caseOnOpportunityMap.put(cs.Opportunity_Title__c, cs);
          }
        }

        for(Opportunity newOpp: lstNewOpportunities){
            If(oppAccIdMap.containsKey(newOpp.Id)){
                accIdSet.add(oppAccIdMap.get(newOpp.Id));

                Case caseRecord;
                If( caseOnOpportunityMap.containsKey(newOpp.Id) && caseOnOpportunityMap.get(newOpp.Id) != NULL  ){
                  caseRecord = caseOnOpportunityMap.get(newOpp.Id);
                }else {
                  caseRecord = new Case();
                  caseRecord.RecordTypeId = caseDelRegistratnRT;
                  caseRecord.Status = 'Open';
                  caseRecord.Opportunity_Title__c = newopp.id;
                  caseRecord.Priority='High';
                  caseRecord.Description = 'Approval Request has been sent to Enterprise Sales Team';
                  caseRecord.Subject='Request for Deal Approval';
                }
                newCaseList.add(caseRecord) ;
            }
        }
        System.debug('*** New Cases: '+ newCaseList);

        If( newCaseList.size() > 0 ){
         TriggerExecutionController.setSkipAllTriggers(true);
          Database.UpsertResult[] srList = Database.upsert(newCaseList, false);
         TriggerExecutionController.setSkipAllTriggers(false);

          Set<Id> caseIdSet = new Set<Id>();
          // Iterate through each returned result
          for (Database.UpsertResult sr : srList) {
              if (sr.isSuccess()) {
                  // Operation was successful, so get the ID of the record that was processed
                  System.debug('Successfully inserted Case. Case ID: ' + sr.getId());
                  caseIdSet.add(sr.getId());
              }
              else {
                  // Operation failed, so get all errors                
                  for(Database.Error err : sr.getErrors()) {
                      System.debug('The following error has occurred.');                    
                      System.debug(err.getStatusCode() + ': ' + err.getMessage());
                  }
              }
          }

          If( caseIdSet.size() > 0 ){

             /* Commented by Venkateswarlu Chirala on 23-Jan-2017 added below code instead of this by using Custom Labels 
              map<Id, Case> caseMap = new map<Id, Case>([Select Id, OwnerId, Opportunity_Title__c, Opportunity_Title__r.AccountId from Case where Id IN: caseIdSet]);

               List<Account> accountList = new List<Account>();
               accountList = [SELECT Id, 
                                      (SELECT Id, AccountId, CaseAccessLevel, TeamMemberRole, UserId 
                                       FROM AccountTeamMembers 
                                       WHERE (TeamMemberRole = 'Account Executive' OR TeamMemberRole = 'ISR(District manager)' ))
                              FROM Account 
                              WHERE Id IN: accIdSet];
               
               map<Id, List<AccountTeamMember>> accountTeamMembersMap = new map<Id, List<AccountTeamMember>>();
               for(Account acc: accountList){
                   accountTeamMembersMap.put(acc.Id, acc.AccountTeamMembers);      
               }
               System.debug('***Account Team Members Map: '+ accountTeamMembersMap);
               
               List<CaseTeamRole> caseTeamRoles = new List<CaseTeamRole>();
               caseTeamRoles = [SELECT AccessLevel, Id, Name 
                                FROM CaseTeamRole 
                                WHERE Name = 'Account Executive' OR Name = 'ISR(District manager)'];
               
               Map<String, CaseTeamRole> caseRoleMap = new Map<String, CaseTeamRole>();
               for(CaseTeamRole caseTeam: caseTeamRoles){
                   caseRoleMap.put(caseTeam.Name, caseTeam);
               }
               
               List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
               
               for(Id idCase: caseIdSet){
                   for(AccountTeamMember accTeam: accountTeamMembersMap.get(caseMap.get(idCase).Opportunity_Title__r.AccountId)){
                      CaseTeamMember ctmAdd = new CaseTeamMember();
                      ctmadd.ParentId = idCase;
                      ctmadd.MemberId = accTeam.UserId;
                      ctmadd.TeamRoleId = caseRoleMap.get(accTeam.TeamMemberRole).Id; 
                      caseTeamMembers.add(ctmadd);
                   }
               }
               
               Database.SaveResult[] accTeamList = Database.insert(caseTeamMembers, false); 
              
           */
               // Added by Venkateswarlu Chirala  on 23-Jan-2017 , getting accountCaseTeamRoles by using "Custom Labels" 
               if (String.isNotBlank(System.Label.Account_Case_TeamRoles) && System.Label.Account_Case_TeamRoles.toUpperCase() != 'NULL' ) { // Begin the custom label check
                 map<Id, Case> caseMap = new map <Id, Case>([Select Id, OwnerId, Opportunity_Title__c, Opportunity_Title__r.AccountId FROM Case WHERE ID IN: caseIdSet]);
                 List<String> accountCaseTeamRoles = new List<String>();
                 
                 for(String accCaseLabel:System.Label.Account_Case_TeamRoles.split(','))
                         if(String.isNotBlank(accCaseLabel.trim()))
                                accountCaseTeamRoles.add(accCaseLabel);
            
                 map<Id, List<AccountTeamMember>> accountTeamMembersMap = new map<Id, List<AccountTeamMember>>();
                 Map<String, CaseTeamRole> caseRoleMap = new Map<String, CaseTeamRole>();
            
                 List<Account> accList =[SELECT Id,
                                                     (SELECT Id, AccountId, CaseAccessLevel, TeamMemberRole, UserId FROM AccountTeamMembers WHERE(TeamMemberRole != NULL AND TeamMemberRole IN: accountCaseTeamRoles))
                                                 FROM Account WHERE Id IN: accIdSet];// SOQL=> Get AccountTeamMembers from Account IDs
                     if (!accList.isEmpty()) {
                         for (Account acc: accList) {
                             accountTeamMembersMap.put(acc.Id, acc.AccountTeamMembers);
                            }
                            
                         List<CaseTeamRole> caseTeamList= [SELECT AccessLevel, Id, Name FROM CaseTeamRole 
                                                                    WHERE Name != NULL AND Name IN: accountCaseTeamRoles] ;// // SOQL=> Get CaseTeamRoles from Custom Labels
                             if (!caseTeamList.isEmpty()) {
                                 for (CaseTeamRole caseTeam: caseTeamList)
                                     caseRoleMap.put(caseTeam.Name.toUpperCase(), caseTeam);
            
                                 If(!accountTeamMembersMap.isEmpty() && !caseRoleMap.isEmpty()) {
                                     List<CaseTeamMember> caseTeamMembers = new List<CaseTeamMember>();
                                     for (Id idCase: caseIdSet){
                                             if (caseMap.containsKey(idCase) ? (caseMap.get(idCase).Opportunity_Title__c !=NULL ? (caseMap.get(idCase).Opportunity_Title__r.AccountId != NULL ? TRUE : FALSE) : FALSE) : FALSE)
                                                 for (AccountTeamMember accTeam: accountTeamMembersMap.get(caseMap.get(idCase).Opportunity_Title__r.AccountId)) 
                                                         if (caseRoleMap.containsKey(accTeam.TeamMemberRole.toUpperCase())) 
                                                                 caseTeamMembers.add(new CaseTeamMember(ParentId = idCase, MemberId = accTeam.UserId, TeamRoleId = caseRoleMap.get(accTeam.TeamMemberRole.toUpperCase()).Id));
                                      }                                             
                                     if(!caseTeamMembers.isEmpty())
                                             Database.SaveResult[] accTeamList = Database.insert(caseTeamMembers, false); // DML Operation => Insert caseTeamMembers
                                 }
            
                             }     // End of Case List if()                  
                     }   // End of Account Teams if()           
             } // End the custom label check
               
               
               
              // Notify Case team members 
               List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
               List<Case> caseList = new List<Case>(); 
               caseList = [select id,owner.email,(select id,memberid,member.email,parentid from TeamMembers) from case where id IN :caseIdSet];  

               map<Id, List<CaseTeamMember>> caseIdtoCaseTeamMap = new map<Id, List<CaseTeamMember>>();
               map<Id, string> caseIdtoOwnerEmailMap = new map<Id,string>();
              
               for(case temp: caseList){
                caseIdtoCaseTeamMap.put(temp.id, temp.TeamMembers);
                caseIdtoOwnerEmailMap.put(temp.id,temp.owner.email);
                }
               system.debug('****caseIdtoCaseTeamMap****' +caseIdtoCaseTeamMap);
               
              for(ID caseID : caseIdSet ){
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                      list<CaseTeamMember> CaseTeamMem = new list<CaseTeamMember>();
                      List <Id> targetObjectIds = new List <Id>();
                      List<String> toAddresses = new List<String>();
                      String[] ccAddresses = new String[] {caseIdtoOwnerEmailMap.get(caseID)};
                      CaseTeamMem = caseIdtoCaseTeamMap.get(caseID);
                  if(CaseTeamMem.size() > 0){
                      for(CaseTeamMember temp: CaseTeamMem){
                           toAddresses.add(temp.member.email);
                           mail.setTargetObjectId(temp.memberid);
                      }
                         system.debug('**toAddress**' +toAddresses);
                         //  mail.setTargetObjectIds(targetObjectIds);
                          mail.setReplyTo(System.Label.Case_update_Email_Service_ID); // Added by Venkateswarlu for Defect#2765634
                           mail.setToAddresses(toAddresses);
                           mail.setccAddresses(ccAddresses);
                           mail.setWhatId(caseID);
                           mail.setTemplateId( Id.valueOf(System.Label.EMC_email_template_id_for_case_notifcation));
                          // mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.EMC_org_wide_addressid_for_case_mailbox)); // Commented by Venkateswarlu on 1/2/2017 added below line (for Dell_EMC_deal_reg_orgwideID)
                           if (!Test.isRunningTest())  mail.setOrgWideEmailAddressId(Id.valueOf(System.Label.Dell_EMC_deal_reg_orgwideID));
                           mail.saveAsActivity = false;  
                           mail.setTreatTargetObjectAsRecipient(false); 
                           mails.add(mail);
                 }
              }
                 if(mails.size()>0){
                     if (!Test.isRunningTest()) 
                        messaging.sendEmail(mails); 
                 }
           }
        }
    }
}