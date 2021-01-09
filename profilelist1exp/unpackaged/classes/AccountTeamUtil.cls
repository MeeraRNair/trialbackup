/*
Description: Utility module for various functions related to Account Teams
- method deleteAcctTeamMembers:
- method upsertAccountTeam:

Version: 0.1

Author: Albert Lou

History:
0.1 Created
*/
/**
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 2.0      13477       FY17-DCS-1002   07-Sep-2016     Fenny           Summer '16 seasonal release that has been causing Account team owner and members to have Ready only access to their Accounts and Related objects.
 * 3.0      18167       FY20-DCS-0102(STORY 7381183)    Shubham Bhatt   Territory Assignments- Change in Opportunity Owner - Prod Fix
**/

global class AccountTeamUtil {


    public static List<AccountTeamMember> newlyAddedAccTeamList = new List<AccountTeamMember>();

    public static void deleteATM (List<AccountTeamMember> delArray) {
        // Declare variables
        List<CustomResult> crDeleteATMResults = new List<CustomResult>();

        // Check the limits
        DBUtils.CheckLimits(delArray, false);

        // Delete the account team members
        try {
            crDeleteATMResults = DBUtils.DatabaseDelete(delArray, 'AccountTeamMember', false);
        } catch (Exception e) {
            throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage() + ' The input array was ' + delArray);
        }

    }   // End function deleteATM()

    public static void assembleATMDelArray (List<DellTeamMember> ATMDelArray) {
        // Declare variables
        Integer iDelRecords = 0;
        Integer delDTMArraySize = ATMDelArray.size();
        Integer rem = math.mod(delDTMArraySize, 100);
        Integer j = 0;
        Double iLoops = (delDTMArraySize/100);
        List<AccountTeamMember> batchDelArray = new List<AccountTeamMember>();
        List<AccountTeamMember> remDelArray = new List<AccountTeamMember>();
        List<Id>remAID = new Id[100];
        List<Id>remUID = new Id[100];
        
        List<AccountTeamMember> testbatchDelArray = new List<AccountTeamMember>();
        List<AccountTeamMember> testbatchDelArray100 = new List<AccountTeamMember>();
        List<AccountTeamMember> testremDelArray = new List<AccountTeamMember>();

        Integer f = 0;
        String iQuery = ' ';
        Integer x = 0;
        if (iLoops >= 1 || Test.isRunningTest()) {
            for(Integer i=0; i<=(iLoops-1); i++) {
                for(Integer k =0;k<=99;k++) {
                    iQuery = iQuery+' (AccountId =\''+ATMDelArray[(i*100)+k].AccountId+'\' and UserId =\''+ATMDelArray[(i*100)+k].UserId+'\' and IsDeleted = False) OR';   
                }
                x++;
            }
            if(iQuery != ' ' && iQuery != null)
            {
                iQuery = iQuery.removeEnd('OR');
                String query = 'select Id, AccountId, UserId from AccountTeamMember where'+iQuery;
                testbatchDelArray = database.query(query);
                // Delete the account team member records
                if (testbatchDelArray.size() > 0) {
                    try {
                        deleteATM(testbatchDelArray);
                    } catch (Exception e) {
                        throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage());
                    }

                }
                testbatchDelArray.clear(); 
            }
        }

        // Process the remaining records using integer j
        if (rem > 0) {
            // Set the values for the remaining records
            for (Integer k=0; k<rem; k++) {
                remAID.set(k, ATMDelArray[(j*100)+k].AccountId);
                remUID.set(k, ATMDelArray[(j*100)+k].UserId);
                // Increment the counter
                f++;
            }

            // Initialize the variables for account Id and user Id
            for (Integer m=f; m<100; m++) {
                remAID.set(m, null);
                remUID.set(m, null);
            }
            String iQuery2 = '';
        for(Integer k=0; k<rem; k++) {
            iQuery2 = iQuery2+' (AccountId =\''+remAID[k]+'\' and UserId =\''+remUID[k]+'\' and IsDeleted = False) OR';   
        }
        if(iQuery2 != null && iQuery2 != '') {
            iQuery2 = iQuery2.removeEnd('OR');
            String query2 = 'select Id, AccountId, UserId from AccountTeamMember where'+iQuery2;
            testremDelArray = database.query(query2);
        }
        // Delete the account team member records
        if (testremDelArray.size() > 0) {
            try {
                deleteATM(testremDelArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('deleteATM() Exception: ' + e.getMessage());
            }
        }
        // Clear the remainder deletion array
        remDelArray.clear();
        // Clear the Id storage arrays
        remAID.clear();
        remUID.clear();
        }   // End if (rem > 0)
    }   // End function assembleATMDelArray()

    public static void updateATM (List<AccountTeamMember> AcctTeamUpdate) {
        // Declare variables
        List<CustomResult> crUpdateATMResults = new List<CustomResult>();
        // Check limits
        DBUtils.CheckLimits(AcctTeamUpdate, false);

        // Add account team members
        try {
            crUpdateATMResults = DBUtils.DatabaseInsert(AcctTeamUpdate, 'AccountTeamMember', false, false);
        } catch (Exception e) {
            throw new dellUtil.DellException('updateATM() Exception: ' + e.getMessage() + ' The input array was ' + AcctTeamUpdate);
        }
        newlyAddedAccTeamList.addAll(AcctTeamUpdate);
    }   // End function updateATM

    public static void updateOTM (List<OpportunityTeamMember> OppTeamUpdate) {
        // Declare variables
        List<CustomResult> crUpdateOTMResults = new List<CustomResult>();

        // Check limits
        DBUtils.CheckLimits(OppTeamUpdate, false);

        // Add opportunity team members
        try {
            crUpdateOTMResults = DBUtils.DatabaseInsert(OppTeamUpdate, 'OpportunityTeamMember', false, false);
        } catch (Exception e) {
            throw new dellUtil.DellException('updateOTM() Exception: ' + e.getMessage() + ' The input array was ' + OppTeamUpdate);
        }
    }   // End function updateOTM


    public static void updateOpp(List<Opportunity> OppUpdate) {
        // Declare variables
        List<CustomResult> crUpdateOppResults = new List<CustomResult>();
        // Check limits
        DBUtils.CheckLimits(OppUpdate, false);

        // Display number of opportunities to update
        try {
            crUpdateOppResults = DBUtils.DatabaseUpdate(OppUpdate, 'Opportunity', false);
        } catch (Exception e) {
            throw new dellUtil.DellException('updateOpp() Exception: ' + e.getMessage() + ' The input array was ' + OppUpdate);
        }
    }   // End function updateOpp

    public static void deleteAccountTeamMembers (List<DellTeamMember> DTMDelArray) {
        // Delete the account team members
        try {
            assembleATMDelArray(DTMDelArray);
        } catch (Exception e) {
            throw new dellUtil.DellException('assembleATMDelArray() Exception: ' + e.getMessage());
        }
    }   // End function deleteAccountTeamMembers

    public static void deleteSalesTeamMembers (List<DellTeamMember> stDTMDelArray, Set<Id> stDTMAcctIDs, Set<Id> stDTMUserIDs) {
        // Declare variables
        List<OpportunityTeamMember> OppTeamDeleteArray = new List<OpportunityTeamMember>();
        List<Opportunity> OppUpdateArray = new List<Opportunity>();
		List<OpportunitySplit> OppSplitDeleteArray = new List<OpportunitySplit>();
        // Create a map of account and team members
        Map<ID, List<DellTeamMember>> mapAcctDelDTMs = new Map<ID, List<DellTeamMember>>();

        // Initialize the map with values
        for (ID stDTMAcctID : stDTMAcctIDs) {
            mapAcctDelDTMs.put(stDTMAcctID, null);
        }   // End for (ID stDTMAcctID : stDTMAcctIDs)

        for (DellTeamMember stDTMDelArrayInd : stDTMDelArray) {
            List<DellTeamMember> lstDelDTM = new List<DellTeamMember>();
            lstDelDTM = mapAcctDelDTMs.get(stDTMDelArrayInd.accountId);
            if (lstDelDTM == null) {
                lstDelDTM = new List<DellTeamMember>();
            }
            lstDelDTM.add(stDTMDelArrayInd);
            mapAcctDelDTMs.put(stDTMDelArrayInd.accountId, lstDelDTM);
        }   // End for (DellTeamMember stDTMDelArrayInd : stDTMDelArray)

		OppSplitDeleteArray = [SELECT Id, OpportunityId, SplitOwnerId from OpportunitySplit where SplitOwnerId IN :stDTMUserIDs AND SplitType.DeveloperName = 'Overlay'];

        // Build the Opportunity Team and Opportunity Share deletion arrays
        For (List<Opportunity> opptyToUpdList : [select Id, AccountId,Source_System__c,type,recordtypeid,  OwnerId, Account.OwnerId from Opportunity where (Account.Id in :stDTMAcctIDs) and (IsClosed = False and IsWon = False) and Direct_Team_Sync__c = 'True']) {
            For (Opportunity opptyToUpd : opptyToUpdList) {
                // Get the list of DellTeamMembers to be deleted
                List<DellTeamMember> lstOppDTMs = new List<DellTeamMember>();
                lstOppDTMs = mapAcctDelDTMs.get(opptyToUpd.AccountId);

                if (lstOppDTMs != null) {
                    For (DellTeamMember lstOppDTM : lstOppDTMs) {
                        // Add the member to the OpportunityTeamMember deletion array
                        OpportunityTeamMember otmDel = new OpportunityTeamMember();

                        otmDel.OpportunityId = opptyToUpd.Id;
                        otmDel.UserId = lstOppDTM.UserId;

                        OppTeamDeleteArray.add(otmDel);

                        // If the member to be deleted is also the opportunity
                        // owner, add the opportunity to the opportunity
                        // update array And assign ownership to the account owner
                        If (lstOppDTM.UserId == opptyToUpd.OwnerId) {
                            // Re-asign opportunity ownership only if Account owner Is Not Gbl Data Admin
                            If ((opptyToUpd.Account.OwnerId!= '00530000000nY2dAAE') && (opptyToUpd.Account.OwnerId != '00530000000nY2d') &&
                                !((opptyToUpd.recordtypeid == RenewalsConstants.aposRecordTypeId) && (opptyToUpd.Source_System__c == RenewalsConstants.strsourceSystemEMCCore || opptyToUpd.Source_System__c == RenewalsConstants.strsourceSystemRenewalsEBIA ||opptyToUpd.type == RenewalsConstants.strtypeEMCRenewalsDirect || opptyToUpd.type == RenewalsConstants.strtypeEMCRenewalsInDirect))) {
                                    opptyToUpd.OwnerId = opptyToUpd.Account.OwnerId;
                                    OppUpdateArray.add(opptyToUpd);
                                }   // End
                        }   // End if (lstOppDTM.UserId == opptyToUpd.OwnerId)

                        if ((OppTeamDeleteArray.size() > 0) && (OppTeamDeleteArray.size() == 1000)) {
                            // Delete opportunity team members
                            try {
                                OppSplitUtilHelper.assembleOSDelArray(OppSplitDeleteArray);
                                AccountTeamUtilHelper.assembleOTMDelArray(OppTeamDeleteArray);
                            } catch (Exception e) {
                                throw new dellUtil.DellException('AccountTeamUtilHelper.assembleOTMDelArray() Exception: ' + e.getMessage());
                            }

                            // Clear the deletion array
                            OppTeamDeleteArray.clear();
                        }   // End if ((OppTeamDeleteArray.size() > 0) and (OppTeamDeleteArray.size() == 1000))

                        if ((OppUpdateArray.size() > 0) && (OppUpdateArray.size() == 200)) {
                            // Update the opportunities with new ownership
                            try {
                                updateOpp(OppUpdateArray);
                            } catch (Exception e) {
                                throw new dellUtil.DellException('updateOpp() Exception: ' + e.getMessage());
                            }

                            // Clear the update array
                            OppUpdateArray.clear();
                        }   // End if ((OppUpdateArray.size() > 0) and (OppUpdateArray.size() == 200))

                    }   // End For (DellTeamMember lstOppDTM : lstOppDTMs)

                }   // End if (lstOppDTMs != null)

            }   // End For (Opportunity opptyToUpd : opptyToUpdList)

        }   // End For (List<Opportunity> opptyToUpdList : [select query])

        // Delete remaining records
        if (OppTeamDeleteArray.size() > 0) {
            try {
                OppSplitUtilHelper.assembleOSDelArray(OppSplitDeleteArray);
                AccountTeamUtilHelper.assembleOTMDelArray(OppTeamDeleteArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('AccountTeamUtilHelper.assembleOTMDelArray() Exception: ' + e.getMessage());
            }
            // Clear objects
            OppTeamDeleteArray.clear();
        }

        // Update remaining records
        if (OppUpdateArray.size() > 0) {
            // Update the opportunities with new ownership
            try {
                updateOpp(OppUpdateArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('updateOpp() Exception: ' + e.getMessage());
            }
            // Clear the update array
            OppUpdateArray.clear();
        }   // End if (OppUpdateArray.size() > 0)
    }   // End function deleteSalesTeamMembers



    public static void updateAccountTeamAndShare (List<DellTeamMember> dellTeamMembers, Set<Id> DTMAcctIDs, Set<Id> DTMUserIDs, Map<Id, User> mapActiveUsers) {
        // Declare variables
        List<AccountTeamMember> AcctTeamUpdateArray = new List<AccountTeamMember>();

        // Create a map of active accounts and owners
        Map<ID, ID> mapOwnerAndAccount = new Map<ID, ID>();

        // Create object of active account record IDs and owner IDs
        List<Account> accountsToUpdate = [select Id, OwnerId from Account where Id in :DTMAcctIDs];

        // Populate the map of active accounts and owners
        For (Account acctToUpd : accountsToUpdate) {
            mapOwnerAndAccount.put(acctToUpd.Id, acctToUpd.OwnerId);
        }

        // Build the Account Team and Account Share update arrays
        For (DellTeamMember dtm : dellTeamMembers) {
            // If user is active and account is active . . .
            if (mapActiveUsers.containsKey(dtm.UserId) && mapOwnerAndAccount.containsKey(dtm.AccountId)) {

                // Add the member to the AccountTeamMember update array
                AccountTeamMember atm = new AccountTeamMember();

                atm.AccountId = dtm.AccountId;
                atm.UserId = dtm.UserId;
                atm.TeamMemberRole = dtm.TeamMemberRole;
                // 2.0: START
                atm.AccountAccessLevel = dtm.AccountAccessLevel;
                atm.OpportunityAccessLevel = dtm.OpportunityAccessLevel;
                atm.CaseAccessLevel = dtm.CaseAccessLevel;
                // 2.0: END

                AcctTeamUpdateArray.add(atm);
            }   // End if (mapActiveUsers.containsKey(dtm.UserId) && mapOwnerAndAccount.containsKey(dtm.AccountId)) 

            // Update the account team in batches of 200
            if ((AcctTeamUpdateArray.size() > 0) && (AcctTeamUpdateArray.size() == 200)){
                try {
                    updateATM(AcctTeamUpdateArray);
                } catch (Exception e) {
                    throw new dellUtil.DellException('updateATM() Exception: ' + e.getMessage());
                }
                // Clear the account team update array
                AcctTeamUpdateArray.clear();
            }   // End if ((AcctTeamUpdateArray.size() > 0) && (AcctTeamUpdateArray.size() = 200))
        }   // End For (DellTeamMember dtm : dellTeamMembers)

        // Update remaining account team records
        if (AcctTeamUpdateArray.size() > 0) {

            try {
                updateATM(AcctTeamUpdateArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('updateATM() Exception: ' + e.getMessage());
            }

            // Clear the account team update array
            AcctTeamUpdateArray.clear();
        }   // End if (AcctTeamUpdateArray.size() > 0)

        // Clear objects
        mapOwnerAndAccount.clear();
        accountsToUpdate.clear();

        //clears the list after processing
        newlyAddedAccTeamList.clear();

    } // End function updateAccountTeamAndShare



    public static void updateSalesTeamsAndShares (List<DellTeamMember> stDellTeamMembers, Set<Id> stDTMAcctIDs, Set<Id> stDTMUserIDs, Map<Id, User> stMapActiveUsers) {
        // Declare variables
        List<OpportunityTeamMember> OppTeamUpdateArray = new List<OpportunityTeamMember>();
        Integer OppTeamDMLRows = 0;
        Integer OppShareDMLRows = 0;

        Map<ID, List<DellTeamMember>> mapAcctIDAndTeams = new Map<ID, List<DellTeamMember>>();

        // Build a map of account IDs and corresponding account teams
        for (ID stDTMAcctID : stDTMAcctIDs) {
            mapAcctIDAndTeams.put(stDTMAcctID, null);
        }

        for (DellTeamMember stDellTeamMember : stDellTeamMembers) {

            if (stMapActiveUsers.containsKey(stDellTeamMember.userId)) {

                List<DellTeamMember> lstDellTeamMem = new List<DellTeamMember>();
                lstDellTeamMem = mapAcctIDAndTeams.get(stDellTeamMember.accountId);

                if (lstDellTeamMem == null) {
                    lstDellTeamMem = new List<DellTeamMember>();
                }

                lstDellTeamMem.add(stDellTeamMember);

                mapAcctIDAndTeams.put(stDellTeamMember.accountId, lstDellTeamMem);

            }   // End if (stMapActiveUsers.containsKey(stDellTeamMember.userId))

        }   // End for (DellTeamMember stDellTeamMember : stDellTeamMembers)


        // Build the Opportunity Team and Opportunity Share update arrays
        For (List<Opportunity> oppToUpdList : [select Id, AccountId, OwnerId from Opportunity where (Account.Id in :stDTMAcctIDs) and (IsClosed = false and IsWon = false) and Direct_Team_Sync__c = 'True' and Owner.IsActive = true]) {
            For (Opportunity oppToUpd : oppToUpdList) {
                // Get the account team for the opportunity's account
                List<DellTeamMember> lstSalesTeam = new List<DellTeamMember>();
                lstSalesTeam = mapAcctIDAndTeams.get(oppToUpd.AccountId);

                if (lstSalesTeam != null) {

                    For (DellTeamMember lstSalesTeamMember : lstSalesTeam) {

                        // Add the member to the OpportunityTeamMember update array
                        OpportunityTeamMember otm = new OpportunityTeamMember();

                        otm.OpportunityId = oppToUpd.Id;
                        otm.UserId = lstSalesTeamMember.userId;
                        otm.TeamMemberRole = lstSalesTeamMember.TeamMemberRole;
                        // 2.0: START
                        otm.OpportunityAccessLevel = lstSalesTeamMember.OpportunityAccessLevel;
                        // 2.0: END

                        OppTeamUpdateArray.add(otm);

                        // If opportunity team member array has 200 elements,
                        // perform a batch update
                        if ((OppTeamUpdateArray.size() > 0) && (OppTeamUpdateArray.size() == 200)) {

                            try {
                                updateOTM(OppTeamUpdateArray);
                            } catch (Exception e) {
                                throw new dellUtil.DellException('updateOTM() Exception: ' + e.getMessage());
                            }

                            OppTeamUpdateArray.clear();
                        }   // End if ((OppTeamUpdateArray.size() > 0) && (OppTeamUpdateArray.size() == 200))

                    }   // End For (DellTeamMember lstSalesTeamMember : lstSalesTeam)

                }   // End if (lstSalesTeam != null)

            }   // End For (Opportunity oppToUpd : oppToUpdList)

        }   // End For (List<Opportunity> oppToUpdList : [select query])

        // Add remaining opportunity team members
        if (OppTeamUpdateArray.size() > 0) {
            try {
                updateOTM(OppTeamUpdateArray);
            } catch (Exception e) {
                throw new dellUtil.DellException('updateOTM() Exception: ' + e.getMessage());
            }

            OppTeamUpdateArray.clear();
        }   // End if (OppTeamUpdateArray.size() > 0)

    } // End function updateSalesTeamsAndShares

} // End global class AccountTeamUtil