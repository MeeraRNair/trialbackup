/*
Description: Utility module for AccountTeam Member Deletion
- method deleteAccountTeamMembers: Delete AccountTeam Members of Inactive accounts
Version: 1.0

Author: Karthika V / Krishnaprasad P

History:
1.0 - 28-mar-2008: Creation, to be released 

*/
         
public class AccountTeamDeletion {
	
	
	public static String getFailedAccountListstr(list<Id>  allAccountIdList, Id failedAccounIdPivot){

		boolean boolFoundPivotInList = false;
		Integer sizeOfList = allAccountIdList.size();
		String strFailedAccountList='';
		for(integer i=0;i < sizeOfList; i++){
			if(allAccountIdList[i]==failedAccounIdPivot){
				boolFoundPivotInList=true;
			}
			if(boolFoundPivotInList){
				strFailedAccountList = strFailedAccountList +  ', ' + allAccountIdList[i];
	 		}
      	} // end of loop

     	if(boolFoundPivotInList)
	 			return strFailedAccountList;
      	else
         		return 'Sorry, the Account ID List could not be extracted !';	  

	} //end of method getFailedAccountListstr
	
  	// CR#1081
  	//public static void deleteAccountTeamMembers(List<Account> acc){
  	@future
 	public static void deleteAccountTeamMembers(List<Id> inactiveAccountId){
		Integer almostDMLRows;
		Integer iteration_index=0;
		system.debug('##KP: Now, we are in deleteAccountTeamMembers method...');			
		
		try{

			inactiveAccountId.sort(); 
	
	                // Query for all the Account Team Members of the Inactive Account.
			// Loop Query (SOQL for loop), should process 200 records per iteration
	  
			for (List<AccountTeamMember> accTeamMembers : [SELECT id,accountid 
															FROM AccountTeamMember 
															WHERE accountid in :inactiveAccountId
															AND account.Calculated_Status__c='Inactive'
															ORDER BY accountid]){
																
			system.debug('##KP: No: of records in the Account Team list-'+accTeamMembers.size());
			
			if(accTeamMembers.size()>0){
				//KV: some debug info
			    system.debug('##KP: Limits.getDMLStatements()-'+ Limits.getDMLStatements());
			    system.debug('##KP: Limits.getLimitDMLStatements()-'+Limits.getLimitDMLStatements());
			    system.debug('##KP: Limits.getDMLRows()-'+ Limits.getDMLRows());
		            system.debug('##KP: Limits.getLimitDMLRows()-'+ Limits.getLimitDMLRows());
				
			    //KV: check the DML limits and throw an error
			    almostDMLRows = Limits.getDMLRows() + accTeamMembers.size();
			    system.debug('##KP: almostDMLRows -' + almostDMLRows);
			    if (Limits.getDMLStatements() == Limits.getLimitDMLStatements() || almostDMLRows >= Limits.getLimitDMLRows()) {
															
				//throw an informative error like the list of all the accounts for which the AccountTeamMember deletion was failed.
										
				system.debug('##KP:From deleteAccountTeamMembers method :Exceeded the DML limits!!  Account Team Member Deletion failed for the Account Ids :'+ getFailedAccountListstr(inactiveAccountId,accTeamMembers[0].accountid));
				throw new dellUtil.DellException('- deleteAccountTeamMembers method :Exceeded the DML limits!! Account Team Member Deletion failed for the Account Ids :'+ getFailedAccountListstr(inactiveAccountId,accTeamMembers[0].accountid));
					
		            }
	 
		            try{
				system.debug('##CS: About to Delete Number ' + accTeamMembers.size());
				delete accTeamMembers;   // deletes the AccountTeamMembers

		            }catch (System.DmlException e){
				system.debug('##KP: Caught DML exception During deletion-'+e.getMessage());
				throw new dellUtil.DellException('DML Excecution failed during AccountTeamMember-deletion operation for Inactivated Accounts !!'+e.getDmlMessage(iteration_index));  

		            }catch (Exception e){
				system.debug('##KP: Caught APEX exception'+e.getMessage());  
				throw new dellUtil.DellException(' Caught exception: Excecution failed during AccountTeamMember-deletion operation for Inactivated Accounts !!'+e.getMessage());  
													
		            }
		        }// end of accTeamMembers.size()-if block

	        }//end of AccountTeamMember query loop
	}catch  (Exception e){
	     system.debug('##KP: Caught APEX exception'+e.getMessage());
             throw new dellUtil.DellException(' Caught APEX exception:'+e.getMessage());
	     //dellUtil.sendSupportEmail(e.getMessage(), 'sfdc_integration@dell.com');
						
	}  
				
 } //end of method deleteAccountTeamMembers
 
 }// end class AccountTeamDeletion