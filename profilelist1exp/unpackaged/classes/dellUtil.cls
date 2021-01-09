/*
Description: Utility module for various functions
- method setAccountShare: Fix web API bug for account team on account change owner

Version: 1.5

Author: Caleb Sidel/Christophe Pebre/Albert Lou

History:
1.0 - 17-oct-2007: Creation, to be released in 8.3
1.1 - 15-nov-2007: Add sendSupportEmail, update setAccountShare (check the DML limits), to be released in 8.3
1.2 - 29-nov-2007: CP - Add setSalesTeam and setOpportunityShare functions for Account Sweeper (Account Team/Sales Team sync)
1.3 - 26-feb-2008: AL - Updated logic to send separate array of members into the setOpportunityShare function
                   AL - Added logic to process only opportunities qualified by Direct Team Sync = "True"
1.4 - Apr-28-2008: AL - Batched the update of sales team members and opportunity shares
                   AL - Streamlined code by modularizing OTM and OS update functions
                   AL - Added try/catch statements to throw friendly message to designated email recipient
                   AL - Updated code with new account team mapping
1.5 - Aug-20-2008: CS - Updated the setSalesTeam code to be more efficent             
1.6 - Aug-20-2013: Ninie - Remove accShare Function as to avoid manual sharing issue. 
*/

global class dellUtil {
	
	public static Boolean forceTest = false;
	
    public static void updateAccountShares(List<AccountShare> accShares) {
        try{
            List<AccountShare> accountSharesToSaveArray = new List<AccountShare>(); 
            
            for (AccountShare ash : accShares) {
                
                ash.accountAccessLevel = 'Edit';
                ash.opportunityAccessLevel = 'Edit';
                ash.caseAccessLevel = 'Edit';
                accountSharesToSaveArray.add(ash);
            
                if (accountSharesToSaveArray.size() == 200 || forceTest == true) {
                        LimitSafeDMLOperations.databaseUpdateAccountShares(accountSharesToSaveArray);
                        // Remove all element of the list
                        accountSharesToSaveArray.clear();                       
                }
    
            } // end for
                
            if (accountSharesToSaveArray.size() > 0) {
                LimitSafeDMLOperations.databaseUpdateAccountShares(accountSharesToSaveArray);
            }
                    
        } catch (Exception e) {
            system.debug('dellUtil: setAccountShare: ' + e.getMessage());
            throw new DellException('dellUtil: setAccountShare: ' + e.getMessage());
        }
    }

    public static void setAccountShare(List<Account> acc) {
        
        system.debug('##CP: Now, we are in setAccountShare method...');
        
        try {
                        
            // Query for all of the AccountShares without Read/Write for those AccountIDs.
            Integer originalSize = acc.size();
            if (originalSize <= 200) {
                for(Integer i = acc.size(); i < 200; i++) {
                    Account acct = new Account(id=null,ownerid=null);
                    acc.add(acct);
                }
            }
            //List<AccountShare> accShares = new List<AccountShare>([select id, userorgroupid, accountaccesslevel, opportunityaccesslevel, caseaccesslevel from AccountShare where rowcause = 'Team' and accountaccesslevel <> 'Edit' and accountid in :acc]);
            List<AccountShare> accShares = new List<AccountShare>([
                                                                    select id, userorgroupid, accountaccesslevel, opportunityaccesslevel, caseaccesslevel 
                                                                    from AccountShare 
                                                                    where (AccountId = :acc[0].Id and UserOrGroupId = :acc[0].OwnerId)
                                                                    or (AccountId = :acc[0].Id and UserOrGroupId = :acc[0].OwnerId)
                                                                    or (AccountId = :acc[1].Id and UserOrGroupId = :acc[1].OwnerId)
                                                                    or (AccountId = :acc[2].Id and UserOrGroupId = :acc[2].OwnerId)
                                                                    or (AccountId = :acc[3].Id and UserOrGroupId = :acc[3].OwnerId)
                                                                    or (AccountId = :acc[4].Id and UserOrGroupId = :acc[4].OwnerId)
                                                                    or (AccountId = :acc[5].Id and UserOrGroupId = :acc[5].OwnerId)
                                                                    or (AccountId = :acc[6].Id and UserOrGroupId = :acc[6].OwnerId)
                                                                    or (AccountId = :acc[7].Id and UserOrGroupId = :acc[7].OwnerId)
                                                                    or (AccountId = :acc[8].Id and UserOrGroupId = :acc[8].OwnerId)
                                                                    or (AccountId = :acc[8].Id and UserOrGroupId = :acc[8].OwnerId)
                                                                    or (AccountId = :acc[9].Id and UserOrGroupId = :acc[9].OwnerId)
                                                                    or (AccountId = :acc[10].Id and UserOrGroupId = :acc[10].OwnerId)
                                                                    or (AccountId = :acc[11].Id and UserOrGroupId = :acc[11].OwnerId)
                                                                    or (AccountId = :acc[12].Id and UserOrGroupId = :acc[12].OwnerId)
                                                                    or (AccountId = :acc[13].Id and UserOrGroupId = :acc[13].OwnerId)
                                                                    or (AccountId = :acc[14].Id and UserOrGroupId = :acc[14].OwnerId)
                                                                    or (AccountId = :acc[15].Id and UserOrGroupId = :acc[15].OwnerId)
                                                                    or (AccountId = :acc[16].Id and UserOrGroupId = :acc[16].OwnerId)
                                                                    or (AccountId = :acc[17].Id and UserOrGroupId = :acc[17].OwnerId)
                                                                    or (AccountId = :acc[18].Id and UserOrGroupId = :acc[18].OwnerId)
                                                                    or (AccountId = :acc[19].Id and UserOrGroupId = :acc[19].OwnerId)
                                                                    or (AccountId = :acc[20].Id and UserOrGroupId = :acc[20].OwnerId)
                                                                    or (AccountId = :acc[21].Id and UserOrGroupId = :acc[21].OwnerId)
                                                                    or (AccountId = :acc[22].Id and UserOrGroupId = :acc[22].OwnerId)
                                                                    or (AccountId = :acc[23].Id and UserOrGroupId = :acc[23].OwnerId)
                                                                    or (AccountId = :acc[24].Id and UserOrGroupId = :acc[24].OwnerId)
                                                                    or (AccountId = :acc[25].Id and UserOrGroupId = :acc[25].OwnerId)
                                                                    or (AccountId = :acc[26].Id and UserOrGroupId = :acc[26].OwnerId)
                                                                    or (AccountId = :acc[27].Id and UserOrGroupId = :acc[27].OwnerId)
                                                                    or (AccountId = :acc[28].Id and UserOrGroupId = :acc[28].OwnerId)
                                                                    or (AccountId = :acc[29].Id and UserOrGroupId = :acc[29].OwnerId)
                                                                    or (AccountId = :acc[30].Id and UserOrGroupId = :acc[30].OwnerId)
                                                                    or (AccountId = :acc[31].Id and UserOrGroupId = :acc[31].OwnerId)
                                                                    or (AccountId = :acc[32].Id and UserOrGroupId = :acc[32].OwnerId)
                                                                    or (AccountId = :acc[33].Id and UserOrGroupId = :acc[33].OwnerId)
                                                                    or (AccountId = :acc[34].Id and UserOrGroupId = :acc[34].OwnerId)
                                                                    or (AccountId = :acc[35].Id and UserOrGroupId = :acc[35].OwnerId)
                                                                    or (AccountId = :acc[36].Id and UserOrGroupId = :acc[36].OwnerId)
                                                                    or (AccountId = :acc[37].Id and UserOrGroupId = :acc[37].OwnerId)
                                                                    or (AccountId = :acc[38].Id and UserOrGroupId = :acc[38].OwnerId)
                                                                    or (AccountId = :acc[39].Id and UserOrGroupId = :acc[39].OwnerId)
                                                                    or (AccountId = :acc[40].Id and UserOrGroupId = :acc[40].OwnerId)
                                                                    or (AccountId = :acc[41].Id and UserOrGroupId = :acc[41].OwnerId)
                                                                    or (AccountId = :acc[42].Id and UserOrGroupId = :acc[42].OwnerId)
                                                                    or (AccountId = :acc[43].Id and UserOrGroupId = :acc[43].OwnerId)
                                                                    or (AccountId = :acc[44].Id and UserOrGroupId = :acc[44].OwnerId)
                                                                    or (AccountId = :acc[45].Id and UserOrGroupId = :acc[45].OwnerId)
                                                                    or (AccountId = :acc[46].Id and UserOrGroupId = :acc[46].OwnerId)
                                                                    or (AccountId = :acc[47].Id and UserOrGroupId = :acc[47].OwnerId)
                                                                    or (AccountId = :acc[48].Id and UserOrGroupId = :acc[48].OwnerId)
                                                                    or (AccountId = :acc[49].Id and UserOrGroupId = :acc[49].OwnerId)
                                                                    or (AccountId = :acc[50].Id and UserOrGroupId = :acc[50].OwnerId)
                                                                    or (AccountId = :acc[51].Id and UserOrGroupId = :acc[51].OwnerId)
                                                                    or (AccountId = :acc[52].Id and UserOrGroupId = :acc[52].OwnerId)
                                                                    or (AccountId = :acc[53].Id and UserOrGroupId = :acc[53].OwnerId)
                                                                    or (AccountId = :acc[54].Id and UserOrGroupId = :acc[54].OwnerId)
                                                                    or (AccountId = :acc[55].Id and UserOrGroupId = :acc[55].OwnerId)
                                                                    or (AccountId = :acc[56].Id and UserOrGroupId = :acc[56].OwnerId)
                                                                    or (AccountId = :acc[57].Id and UserOrGroupId = :acc[57].OwnerId)
                                                                    or (AccountId = :acc[58].Id and UserOrGroupId = :acc[58].OwnerId)
                                                                    or (AccountId = :acc[59].Id and UserOrGroupId = :acc[59].OwnerId)
                                                                    or (AccountId = :acc[60].Id and UserOrGroupId = :acc[60].OwnerId)
                                                                    or (AccountId = :acc[61].Id and UserOrGroupId = :acc[61].OwnerId)
                                                                    or (AccountId = :acc[62].Id and UserOrGroupId = :acc[62].OwnerId)
                                                                    or (AccountId = :acc[63].Id and UserOrGroupId = :acc[63].OwnerId)
                                                                    or (AccountId = :acc[64].Id and UserOrGroupId = :acc[64].OwnerId)
                                                                    or (AccountId = :acc[65].Id and UserOrGroupId = :acc[65].OwnerId)
                                                                    or (AccountId = :acc[66].Id and UserOrGroupId = :acc[66].OwnerId)
                                                                    or (AccountId = :acc[67].Id and UserOrGroupId = :acc[67].OwnerId)
                                                                    or (AccountId = :acc[68].Id and UserOrGroupId = :acc[68].OwnerId)
                                                                    or (AccountId = :acc[69].Id and UserOrGroupId = :acc[69].OwnerId)
                                                                    or (AccountId = :acc[70].Id and UserOrGroupId = :acc[70].OwnerId)
                                                                    or (AccountId = :acc[71].Id and UserOrGroupId = :acc[71].OwnerId)
                                                                    or (AccountId = :acc[72].Id and UserOrGroupId = :acc[72].OwnerId)
                                                                    or (AccountId = :acc[73].Id and UserOrGroupId = :acc[73].OwnerId)
                                                                    or (AccountId = :acc[74].Id and UserOrGroupId = :acc[74].OwnerId)
                                                                    or (AccountId = :acc[75].Id and UserOrGroupId = :acc[75].OwnerId)
                                                                    or (AccountId = :acc[76].Id and UserOrGroupId = :acc[76].OwnerId)
                                                                    or (AccountId = :acc[77].Id and UserOrGroupId = :acc[77].OwnerId)
                                                                    or (AccountId = :acc[78].Id and UserOrGroupId = :acc[78].OwnerId)
                                                                    or (AccountId = :acc[79].Id and UserOrGroupId = :acc[79].OwnerId)
                                                                    or (AccountId = :acc[80].Id and UserOrGroupId = :acc[80].OwnerId)
                                                                    or (AccountId = :acc[81].Id and UserOrGroupId = :acc[81].OwnerId)
                                                                    or (AccountId = :acc[82].Id and UserOrGroupId = :acc[82].OwnerId)
                                                                    or (AccountId = :acc[83].Id and UserOrGroupId = :acc[83].OwnerId)
                                                                    or (AccountId = :acc[84].Id and UserOrGroupId = :acc[84].OwnerId)
                                                                    or (AccountId = :acc[85].Id and UserOrGroupId = :acc[85].OwnerId)
                                                                    or (AccountId = :acc[86].Id and UserOrGroupId = :acc[86].OwnerId)
                                                                    or (AccountId = :acc[87].Id and UserOrGroupId = :acc[87].OwnerId)
                                                                    or (AccountId = :acc[88].Id and UserOrGroupId = :acc[88].OwnerId)
                                                                    or (AccountId = :acc[89].Id and UserOrGroupId = :acc[89].OwnerId)
                                                                    or (AccountId = :acc[90].Id and UserOrGroupId = :acc[90].OwnerId)
                                                                    or (AccountId = :acc[91].Id and UserOrGroupId = :acc[91].OwnerId)
                                                                    or (AccountId = :acc[92].Id and UserOrGroupId = :acc[92].OwnerId)
                                                                    or (AccountId = :acc[93].Id and UserOrGroupId = :acc[93].OwnerId)
                                                                    or (AccountId = :acc[94].Id and UserOrGroupId = :acc[94].OwnerId)
                                                                    or (AccountId = :acc[95].Id and UserOrGroupId = :acc[95].OwnerId)
                                                                    or (AccountId = :acc[96].Id and UserOrGroupId = :acc[96].OwnerId)
                                                                    or (AccountId = :acc[97].Id and UserOrGroupId = :acc[97].OwnerId)
                                                                    or (AccountId = :acc[98].Id and UserOrGroupId = :acc[98].OwnerId)
                                                                    or (AccountId = :acc[99].Id and UserOrGroupId = :acc[99].OwnerId)
                                                                    ]);
            
            List<AccountShare> accShares2 = new List<AccountShare>();
            if ( originalSize > 100 || forceTest == true) {
                                    accShares2 = new List<AccountShare>([
                                                                        select id, userorgroupid, accountaccesslevel, opportunityaccesslevel, caseaccesslevel 
                                                                        from AccountShare 
                                                                        where (AccountId = :acc[100].Id and UserOrGroupId = :acc[100].OwnerId)
                                                                        or (AccountId = :acc[101].Id and UserOrGroupId = :acc[101].OwnerId)
                                                                        or (AccountId = :acc[102].Id and UserOrGroupId = :acc[102].OwnerId)
                                                                        or (AccountId = :acc[103].Id and UserOrGroupId = :acc[103].OwnerId)
                                                                        or (AccountId = :acc[104].Id and UserOrGroupId = :acc[104].OwnerId)
                                                                        or (AccountId = :acc[105].Id and UserOrGroupId = :acc[105].OwnerId)
                                                                        or (AccountId = :acc[106].Id and UserOrGroupId = :acc[106].OwnerId)
                                                                        or (AccountId = :acc[107].Id and UserOrGroupId = :acc[107].OwnerId)
                                                                        or (AccountId = :acc[108].Id and UserOrGroupId = :acc[108].OwnerId)
                                                                        or (AccountId = :acc[109].Id and UserOrGroupId = :acc[109].OwnerId)
                                                                        or (AccountId = :acc[110].Id and UserOrGroupId = :acc[110].OwnerId)
                                                                        or (AccountId = :acc[111].Id and UserOrGroupId = :acc[111].OwnerId)
                                                                        or (AccountId = :acc[112].Id and UserOrGroupId = :acc[112].OwnerId)
                                                                        or (AccountId = :acc[113].Id and UserOrGroupId = :acc[113].OwnerId)
                                                                        or (AccountId = :acc[114].Id and UserOrGroupId = :acc[114].OwnerId)
                                                                        or (AccountId = :acc[115].Id and UserOrGroupId = :acc[115].OwnerId)
                                                                        or (AccountId = :acc[116].Id and UserOrGroupId = :acc[116].OwnerId)
                                                                        or (AccountId = :acc[117].Id and UserOrGroupId = :acc[117].OwnerId)
                                                                        or (AccountId = :acc[118].Id and UserOrGroupId = :acc[118].OwnerId)
                                                                        or (AccountId = :acc[119].Id and UserOrGroupId = :acc[119].OwnerId)
                                                                        or (AccountId = :acc[120].Id and UserOrGroupId = :acc[120].OwnerId)
                                                                        or (AccountId = :acc[121].Id and UserOrGroupId = :acc[121].OwnerId)
                                                                        or (AccountId = :acc[122].Id and UserOrGroupId = :acc[122].OwnerId)
                                                                        or (AccountId = :acc[123].Id and UserOrGroupId = :acc[123].OwnerId)
                                                                        or (AccountId = :acc[124].Id and UserOrGroupId = :acc[124].OwnerId)
                                                                        or (AccountId = :acc[125].Id and UserOrGroupId = :acc[125].OwnerId)
                                                                        or (AccountId = :acc[126].Id and UserOrGroupId = :acc[126].OwnerId)
                                                                        or (AccountId = :acc[127].Id and UserOrGroupId = :acc[127].OwnerId)
                                                                        or (AccountId = :acc[128].Id and UserOrGroupId = :acc[128].OwnerId)
                                                                        or (AccountId = :acc[129].Id and UserOrGroupId = :acc[129].OwnerId)
                                                                        or (AccountId = :acc[130].Id and UserOrGroupId = :acc[130].OwnerId)
                                                                        or (AccountId = :acc[131].Id and UserOrGroupId = :acc[131].OwnerId)
                                                                        or (AccountId = :acc[132].Id and UserOrGroupId = :acc[132].OwnerId)
                                                                        or (AccountId = :acc[133].Id and UserOrGroupId = :acc[133].OwnerId)
                                                                        or (AccountId = :acc[134].Id and UserOrGroupId = :acc[134].OwnerId)
                                                                        or (AccountId = :acc[135].Id and UserOrGroupId = :acc[135].OwnerId)
                                                                        or (AccountId = :acc[136].Id and UserOrGroupId = :acc[136].OwnerId)
                                                                        or (AccountId = :acc[137].Id and UserOrGroupId = :acc[137].OwnerId)
                                                                        or (AccountId = :acc[138].Id and UserOrGroupId = :acc[138].OwnerId)
                                                                        or (AccountId = :acc[139].Id and UserOrGroupId = :acc[139].OwnerId)
                                                                        or (AccountId = :acc[140].Id and UserOrGroupId = :acc[140].OwnerId)
                                                                        or (AccountId = :acc[141].Id and UserOrGroupId = :acc[141].OwnerId)
                                                                        or (AccountId = :acc[142].Id and UserOrGroupId = :acc[142].OwnerId)
                                                                        or (AccountId = :acc[143].Id and UserOrGroupId = :acc[143].OwnerId)
                                                                        or (AccountId = :acc[144].Id and UserOrGroupId = :acc[144].OwnerId)
                                                                        or (AccountId = :acc[145].Id and UserOrGroupId = :acc[145].OwnerId)
                                                                        or (AccountId = :acc[146].Id and UserOrGroupId = :acc[146].OwnerId)
                                                                        or (AccountId = :acc[147].Id and UserOrGroupId = :acc[147].OwnerId)
                                                                        or (AccountId = :acc[148].Id and UserOrGroupId = :acc[148].OwnerId)
                                                                        or (AccountId = :acc[149].Id and UserOrGroupId = :acc[149].OwnerId)
                                                                        or (AccountId = :acc[150].Id and UserOrGroupId = :acc[150].OwnerId)
                                                                        or (AccountId = :acc[151].Id and UserOrGroupId = :acc[151].OwnerId)
                                                                        or (AccountId = :acc[152].Id and UserOrGroupId = :acc[152].OwnerId)
                                                                        or (AccountId = :acc[153].Id and UserOrGroupId = :acc[153].OwnerId)
                                                                        or (AccountId = :acc[154].Id and UserOrGroupId = :acc[154].OwnerId)
                                                                        or (AccountId = :acc[155].Id and UserOrGroupId = :acc[155].OwnerId)
                                                                        or (AccountId = :acc[156].Id and UserOrGroupId = :acc[156].OwnerId)
                                                                        or (AccountId = :acc[157].Id and UserOrGroupId = :acc[157].OwnerId)
                                                                        or (AccountId = :acc[158].Id and UserOrGroupId = :acc[158].OwnerId)
                                                                        or (AccountId = :acc[159].Id and UserOrGroupId = :acc[159].OwnerId)
                                                                        or (AccountId = :acc[160].Id and UserOrGroupId = :acc[160].OwnerId)
                                                                        or (AccountId = :acc[161].Id and UserOrGroupId = :acc[161].OwnerId)
                                                                        or (AccountId = :acc[162].Id and UserOrGroupId = :acc[162].OwnerId)
                                                                        or (AccountId = :acc[163].Id and UserOrGroupId = :acc[163].OwnerId)
                                                                        or (AccountId = :acc[164].Id and UserOrGroupId = :acc[164].OwnerId)
                                                                        or (AccountId = :acc[165].Id and UserOrGroupId = :acc[165].OwnerId)
                                                                        or (AccountId = :acc[166].Id and UserOrGroupId = :acc[166].OwnerId)
                                                                        or (AccountId = :acc[167].Id and UserOrGroupId = :acc[167].OwnerId)
                                                                        or (AccountId = :acc[168].Id and UserOrGroupId = :acc[168].OwnerId)
                                                                        or (AccountId = :acc[169].Id and UserOrGroupId = :acc[169].OwnerId)
                                                                        or (AccountId = :acc[170].Id and UserOrGroupId = :acc[170].OwnerId)
                                                                        or (AccountId = :acc[171].Id and UserOrGroupId = :acc[171].OwnerId)
                                                                        or (AccountId = :acc[172].Id and UserOrGroupId = :acc[172].OwnerId)
                                                                        or (AccountId = :acc[173].Id and UserOrGroupId = :acc[173].OwnerId)
                                                                        or (AccountId = :acc[174].Id and UserOrGroupId = :acc[174].OwnerId)
                                                                        or (AccountId = :acc[175].Id and UserOrGroupId = :acc[175].OwnerId)
                                                                        or (AccountId = :acc[176].Id and UserOrGroupId = :acc[176].OwnerId)
                                                                        or (AccountId = :acc[177].Id and UserOrGroupId = :acc[177].OwnerId)
                                                                        or (AccountId = :acc[178].Id and UserOrGroupId = :acc[178].OwnerId)
                                                                        or (AccountId = :acc[179].Id and UserOrGroupId = :acc[179].OwnerId)
                                                                        or (AccountId = :acc[180].Id and UserOrGroupId = :acc[180].OwnerId)
                                                                        or (AccountId = :acc[181].Id and UserOrGroupId = :acc[181].OwnerId)
                                                                        or (AccountId = :acc[182].Id and UserOrGroupId = :acc[182].OwnerId)
                                                                        or (AccountId = :acc[183].Id and UserOrGroupId = :acc[183].OwnerId)
                                                                        or (AccountId = :acc[184].Id and UserOrGroupId = :acc[184].OwnerId)
                                                                        or (AccountId = :acc[185].Id and UserOrGroupId = :acc[185].OwnerId)
                                                                        or (AccountId = :acc[186].Id and UserOrGroupId = :acc[186].OwnerId)
                                                                        or (AccountId = :acc[187].Id and UserOrGroupId = :acc[187].OwnerId)
                                                                        or (AccountId = :acc[188].Id and UserOrGroupId = :acc[188].OwnerId)
                                                                        or (AccountId = :acc[189].Id and UserOrGroupId = :acc[189].OwnerId)
                                                                        or (AccountId = :acc[190].Id and UserOrGroupId = :acc[190].OwnerId)
                                                                        or (AccountId = :acc[191].Id and UserOrGroupId = :acc[191].OwnerId)
                                                                        or (AccountId = :acc[192].Id and UserOrGroupId = :acc[192].OwnerId)
                                                                        or (AccountId = :acc[193].Id and UserOrGroupId = :acc[193].OwnerId)
                                                                        or (AccountId = :acc[194].Id and UserOrGroupId = :acc[194].OwnerId)
                                                                        or (AccountId = :acc[195].Id and UserOrGroupId = :acc[195].OwnerId)
                                                                        or (AccountId = :acc[196].Id and UserOrGroupId = :acc[196].OwnerId)
                                                                        or (AccountId = :acc[197].Id and UserOrGroupId = :acc[197].OwnerId)
                                                                        or (AccountId = :acc[198].Id and UserOrGroupId = :acc[198].OwnerId)
                                                                        or (AccountId = :acc[199].Id and UserOrGroupId = :acc[199].OwnerId)
                                                                        ]);
            }
            
            system.debug('##CS: setAccountShare: accShares.size() = ' + accShares.size());
            system.debug('##CS: setAccountShare: accShares2.size() = ' + accShares2.size());
          //1.6   if(accShares.size() > 0) {
       //1.6         updateAccountShares(accShares);
             //1.6    if(accShares2.size() > 0 || forceTest == true) {
       //1.6             updateAccountShares(accShares2);
              //1.6   }
         //1.6    }

			system.debug('dellUtil: setAccountShare: no exceptions');
        } catch (Exception e) {
            system.debug('dellUtil: setAccountShare: ' + e.getMessage());
            throw new DellException('dellUtil: setAccountShare: ' + e.getMessage());
        }   
    }

// Exception inner class
public class DellException extends Exception {
    // Exception class member variable
    
    // Exception class constructor
    //DellException(String message) {
    // system.debug('##CP:' + message);
    //}

}

public class RowLockException extends Exception {
}

	public static void sendSupportEmail(String s, String recipient) { 
	    // Create a new single email message object
	    // that will send out a single email to the addresses in the To, CC & BCC list.
	    if(!(Environment.isSandbox() && recipient.contains('sfdc_integration'))){
	    	
	    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    // Strings to hold the email addresses to which you are sending the email.
		    String[] toAddresses = new String[] {recipient};
		    // Assign the addresses for the To and CC lists to the mail object.
		    mail.setToAddresses(toAddresses);
		    // Specify the address used when the recipients reply to the email.
		    mail.setReplyTo(recipient);
		    // Specify the name used as the display name.
		    mail.setSenderDisplayName('Salesforce Support');
		    // Specify the subject line for your email address.
		    mail.setSubject('Apex issue');
		    // Set to True if you want to BCC yourself on the email.
		    mail.setBccSender(false);
		    // Optionally append the salesforce.com email signature to the email.
		    // The email address of the user executing the Apex Code will be used.
		    mail.setUseSignature(false);
		    // Specify the text content of the email.
		    mail.setPlainTextBody('Problem: ' + s);
		    // Specify the html version of the content as well.
		    mail.setHtmlBody('Problem: ' + s);
		    // Send the email you have created.
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	    }
	    
	}//end of sendSupportEmail
	
}// End global class dellUtil