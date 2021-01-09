/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010   	Raymond Yip     Created for CR4435
*/
global class BatchDeleteAccountTeamMemberExecute implements Schedulable{		

	private static boolean isTest = false;
	
	global static void execute(SchedulableContext sc){
		/*
        BatchDeleteAccountTeamMember buDeleteACT = new BatchDeleteAccountTeamMember();
		
        buDeleteACT.queryString = 'SELECT Id,User.Name, User.Title, Account.Type, TeamMemberRole' 
									+ ' FROM AccountTeamMember' 
									+ ' WHERE' 
									+ ' (Account.Type = \'OEM\' AND (NOT User.Title LIKE \'OEM%\'))' 
									+ ' OR (Account.Type = \'MSG\' AND (NOT User.Title LIKE \'MSG%\'))';
                                                    
        ID batchprocessid = Database.executeBatch(buDeleteACT,1000);
        */
        
        executeBatch();
	}


	public static void executeBatch() {
		BatchDeleteAccountTeamMember buDeleteACT = new BatchDeleteAccountTeamMember();
		
		if(!isTest) {
	        buDeleteACT.queryString = 'SELECT Id,User.Name, User.Title, Account.Type, TeamMemberRole' 
										+ ' FROM AccountTeamMember' 
										+ ' WHERE' 
										+ ' (Account.Type = \'OEM\' AND (NOT User.Title LIKE \'OEM%\'))' 
										+ ' OR (Account.Type = \'MSG\' AND (NOT User.Title LIKE \'MSG%\'))';
		} else {
	        buDeleteACT.queryString = 'SELECT Id,User.Name, User.Title, Account.Type, TeamMemberRole' 
										+ ' FROM AccountTeamMember' 
										+ ' WHERE User.LastName = \'BatchDeleteACT Test\'' 								
										+ ' AND ((Account.Type = \'OEM\' AND (NOT User.Title LIKE \'OEM%\'))' 
										+ ' OR (Account.Type = \'MSG\' AND (NOT User.Title LIKE \'MSG%\')))';
		}
									                                            
        ID batchprocessid = Database.executeBatch(buDeleteACT,1000);
	}
	
	public static void executeBatchForTest() {
		isTest = true;
		executeBatch();
	}
	
}