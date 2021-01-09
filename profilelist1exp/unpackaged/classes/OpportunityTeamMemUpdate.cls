/**************************************************************************************************************************************************************
 * Revision CR Number   Release No      Date            Modified By               Description
 * -------- ---------   ----------      -----------     -----------------         -----------
 * 1.0       CR#14962   FY18-1101       22-Sep-2017     Venkateswarlu Chirala      OpportunityTeamMemUpdate:If a account is re-partented the new team should be added
                                                                                                           to the opportunity team and the old team are removed.
 *                                                                                ** Test Class for this class is: OpportunityTeamMemUpdateTest  
 * 
 *     
 ***************************************************************************************************************************************************************/
 
public class OpportunityTeamMemUpdate {

    /** 
         * @author Venkateswarlu Chirala
         * @date  22-Sep-2017
         * @description updateOppTeamMemWhenEndAccChange method when EnduserAccount Changes on Opportunity
       
                * Re Parenting happens at the beginning of a new quarter and Direct sales team should be blocked from closing a deal regristration before it expires. 
                * If a account is re-partented the new team should be added to the opportunity team and the old team are removed.
                * Update of Lost/ cancelled validation rule to include direct teams when an account has been Re Parented.
                
                 
         *      1) Prepare the collections Set/Map (OldEndAccountIDS, NewAccountID & PartnerAccountIDS ) if any When End user Account change on opportunities
         *      2) Get the all the list of all AccountTeamMembers based on above Collections & prepare the collections for each AccountID respective Team Members
         *      3) Get the all the list of OpptyTeamMembers with filters oldEndAccountTeamMem present in OpportunityTeamMembers
                    Prepare the Deletion of OpportunityTeamMembers as well as updation of OpptyTeamMem if any user preset in both EndAccount & PartnerAccount
         *      4) Iterate over  NewEnduserAccountOpporyntity collection > get respective AccountTeamMem > prepare the insert in OpportunityTeamMembers
         *      5) DML operations: Delete opptyTeamMembers & prepare final insert of update opptyTeamMemv+ New Insert OpportunityTeamMembers
         *
         *
         *
         *@param pass the oldOppMap & newOppMap
      */

    public static void updateOppTeamMemWhenEndAccChange(Map < ID, Opportunity > oldOppMap, Map < ID, Opportunity > newOppMap) {

        if (!oldOppMap.isEmpty() && !newOppMap.isEmpty()) {

            Map <ID, ID> oppNewEndAccIdMap = new Map <ID, ID>();
            Set <ID> oldEndAccIdsSet = new Set <ID>();
            Set <ID> parAccIdsSet = new Set <ID>();

            Map <ID, set <ID>> oldEndAccID_TemMemMap = new Map <ID, set <ID>>();
            Map <ID, Set <ID>> newEndAccID_TemMemMap = new Map <ID, Set <ID>>();
            Map <ID, Set <ID>> partAccID_TemMemMap = new Map <ID, Set <ID>>();

            Set <ID> oldEnduserAccUserIDs = new set <ID>();
            Map <String, AccountTeamMember > newAccID_UserID_AccTeam = new Map < String, AccountTeamMember > ();


            Map <String, OpportunityTeamMember> oppMem_UpsertMap = new Map <String, OpportunityTeamMember>();
            Map <ID, OpportunityTeamMember> oppTeamMem_DeleteMap = new Map <ID, OpportunityTeamMember>();

            // 1) Prepare the collections Set/Map (OldEndAccountIDS, NewAccountID & PartnerAccountIDS ) if any When End user Account change on opportunities
            for (Opportunity o: newOppMap.values()) {
                if ((oldOppMap.get(o.ID).AccountID != NULL && newOppMap.get(o.ID).AccountID != NULL && (oldOppMap.get(o.ID).AccountID != newOppMap.get(o.ID).AccountID)) &&
                    ((String.isNotBlank(newOppMap.get(o.ID).Deal_Registration_Status__c)) && newOppMap.get(o.ID).Deal_Registration_Status__c == 'Approved') &&
                    ((String.isNotBlank(newOppMap.get(o.ID).StageName)) && newOppMap.get(o.ID).StageName != 'Lost, Cancelled - 0%') &&
                    ((String.isNotBlank(newOppMap.get(o.ID).Deal_Reg_Oppty__c)) && newOppMap.get(o.ID).Deal_Reg_Oppty__c == 'Yes')) {
                    oldEndAccIdsSet.add(oldOppMap.get(o.ID).AccountID);
                    oppNewEndAccIdMap.put(o.ID, newOppMap.get(o.ID).AccountID);
                    if (oldOppMap.get(o.ID).PartnerAccountID != NULL) parAccIdsSet.add(oldOppMap.get(o.ID).PartnerAccountID);
                }
            }

            // System.debug('---------->oldEndAccIdsSet' + oldEndAccIdsSet);
            // System.debug('---------->oppNewEndAccIdMap' + oppNewEndAccIdMap);
            // System.debug('---------->parAccIdsSet' + parAccIdsSet);

            // 2) Get the all the list of all AccountTeamMembers based on above Collections & prepare the collections for each AccountID respective Team Members
            if (!oppNewEndAccIdMap.isEmpty()) {
                // SOQL=> Get AccountTeamMembers from Account IDs
                Map < ID, AccountTeamMember > accTeamMemMap = new Map < ID, AccountTeamMember > ([SELECT Id, AccountId, UserId, OpportunityAccessLevel, TeamMemberRole, Title FROM AccountTeamMember
                                                                                                  WHERE(AccountID != NULL) AND
                                                                                                  (AccountID IN: oldEndAccIdsSet OR AccountID IN: oppNewEndAccIdMap.values() OR AccountID IN: parAccIdsSet) ]);
                // System.debug('=========>>accTeamMemMap' + accTeamMemMap);

                if (!accTeamMemMap.isEmpty()) {
                    for (AccountTeamMember atm: accTeamMemMap.values()) {

                        if (oldEndAccIdsSet.contains(atm.AccountID)) {
                            oldEnduserAccUserIDs.add(atm.userID);
                            if (!oldEndAccID_TemMemMap.isEmpty() && oldEndAccID_TemMemMap.containsKey(atm.AccountID))
                                (oldEndAccID_TemMemMap.get(atm.AccountID)).add(atm.UserId);
                            else oldEndAccID_TemMemMap.put(atm.AccountID, new set < ID > {atm.UserId});
                        }


                        if (new Set < ID > (oppNewEndAccIdMap.values()).contains(atm.AccountID)) {
                            newAccID_UserID_AccTeam.put(atm.AccountID + '/' + atm.userID, atm);
                            if (!newEndAccID_TemMemMap.isEmpty() && newEndAccID_TemMemMap.containsKey(atm.AccountID))
                                newEndAccID_TemMemMap.get(atm.AccountID).add(atm.UserId);
                            else newEndAccID_TemMemMap.put(atm.AccountID, new set < ID > {atm.UserId});
                        }

                        if (!parAccIdsSet.isEmpty() && parAccIdsSet.contains(atm.AccountID)) {
                            if (!partAccID_TemMemMap.isEmpty() && partAccID_TemMemMap.containsKey(atm.AccountID))
                                partAccID_TemMemMap.get(atm.AccountID).add(atm.UserId);
                            else partAccID_TemMemMap.put(atm.AccountID, new set < ID > {atm.UserId});
                        }
                    }

                    // System.debug('---------->oldEndAccID_TemMemMap' + oldEndAccID_TemMemMap);
                    // System.debug('---------->newEndAccID_TemMemMap' + newEndAccID_TemMemMap);
                    // System.debug('---------->partAccID_TemMemMap' + partAccID_TemMemMap);


                    /*  3) Get the all the list of OpptyTeamMembers with filters oldEndAccountTeamMem present in OpportunityTeamMembers
                               Prepare the Deletion of OpportunityTeamMembers as well as updation of OpptyTeamMem if any user preset in both EndAccount & PartnerAccount
                       */

                    if (!oldEnduserAccUserIDs.isEmpty()) {
                        // SOQL=> Get OpportunityTeamMembers from opportunityId, End_User_Acc_Memver & UserID
                        Map <ID, OpportunityTeamMember> oppTeamMemMap = new Map <ID, OpportunityTeamMember>([SELECT Id, OpportunityId, opportunity.AccountID, opportunity.PartnerAccountID, UserId,
                                                                                                            TeamMemberRole, End_User_Acct_Member__c, Partner_Account_Member__c FROM OpportunityTeamMember
                                                                                                            WHERE OpportunityId IN: oppNewEndAccIdMap.keySet() AND
                                                                                                            End_User_Acct_Member__c = TRUE AND(UserID IN: oldEnduserAccUserIDs)]);
                        //System.debug('---------->oppTeamMemMap '+ oppTeamMemMap);
                        if (!oppTeamMemMap.isEmpty()) {
                            for (OpportunityTeamMember otm: oppTeamMemMap.values()) {
                                if (otm.opportunity.PartnerAccountID != NULL && partAccID_TemMemMap.containsKey(otm.opportunity.PartnerAccountID)) {
                                    Set < ID > tempCheck = partAccID_TemMemMap.get(otm.opportunity.PartnerAccountID);
                                    if (!tempCheck.isEmpty() && tempCheck.contains(otm.userID)) {
                                        otm.End_User_Acct_Member__c = FALSE;
                                        oppMem_UpsertMap.put(otm.OpportunityId + '/' + otm.opportunity.AccountID + '/' + otm.UserID, otm);

                                    } else oppTeamMem_DeleteMap.put(otm.ID, otm);
                                } else oppTeamMem_DeleteMap.put(otm.ID, otm);

                            }
                            //  System.debug('---------->oppMem_UpsertMap' + oppMem_UpsertMap);
                            //  System.debug('---------->oppTeamMem_DeleteMap' + oppTeamMem_DeleteMap);
                        }
                    }


                    // 4) Iterate over  NewEnduserAccountOpporyntity collection > get respective AccountTeamMem > prepare the insert in OpportunityTeamMembers
                    List <OpportunityTeamMember> insert_OppMem = new List <OpportunityTeamMember>();
                    for (ID oppID: oppNewEndAccIdMap.keySet()) {
                        // System.debug('--------->>>oppNewEndAccIdMap.get(oppID)' + oppNewEndAccIdMap.get(oppID));

                        if (oppID != NULL && oppNewEndAccIdMap.get(oppID) != NULL && newEndAccID_TemMemMap.get(oppNewEndAccIdMap.get(oppID))!=null && !(newEndAccID_TemMemMap.get(oppNewEndAccIdMap.get(oppID))).isEmpty()  ) {
                            Set < ID > userSet = newEndAccID_TemMemMap.get(oppNewEndAccIdMap.get(oppID));
                           // System.debug('---------------->>userSet' + userSet);
                            for (ID u: userSet) {
                                if (!oppMem_UpsertMap.isEmpty() && oppMem_UpsertMap.containsKey(oppID + '/' + oppNewEndAccIdMap.get(oppID) + '/' + u))
                                    (oppMem_UpsertMap.get(oppID + '/' + oppNewEndAccIdMap.get(oppID) + '/' + u)).End_User_Acct_Member__c = TRUE;

                                else if (!newAccID_UserID_AccTeam.isEmpty() && newAccID_UserID_AccTeam.containsKey(oppNewEndAccIdMap.get(oppID) + '/' + u)) {
                                    AccountTeamMember acct = newAccID_UserID_AccTeam.get(oppNewEndAccIdMap.get(oppID) + '/' + u);
                                    insert_OppMem.add(new OpportunityTeamMember(OpportunityID = oppID, OpportunityAccessLevel = acct.OpportunityAccessLevel, TeamMemberRole = acct.TeamMemberRole, UserID = u, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
                                }
                            }
                        }
                    }


                    // 5) DML operations: Delete opptyTeamMembers & prepare final insert of update opptyTeamMemv+ New Insert OpportunityTeamMembers
                    List <OpportunityTeamMember> final_Insert_OppTeamMem = new List <OpportunityTeamMember>();

                    if (!oppMem_UpsertMap.isEmpty()) final_Insert_OppTeamMem.addAll(oppMem_UpsertMap.values());
                    if (!insert_OppMem.isEmpty()) final_Insert_OppTeamMem.addAll(insert_OppMem);

                    // System.debug('----------->>oppTeamMem_DeleteMap.values()' + oppTeamMem_DeleteMap.values());
                    // System.debug('----------->>final_Insert_OppTeamMem' + final_Insert_OppTeamMem);

                    if (!oppTeamMem_DeleteMap.isEmpty())
                        delete oppTeamMem_DeleteMap.values(); // DML:Delete OpprtunityTeamMem

                    if (!final_Insert_OppTeamMem.isEmpty())
                        insert final_Insert_OppTeamMem; // DML: Insert OpprtunityTeamMem- Note: Internally SFDC will do Upsert operation on OppryTeamMemberobject. 

                } // End of AccTeamMemMap
            } // End of oppNewEndAccIdMap if..
        } // End of oldMap & newMapopp check
    } // End of method
} // End of class