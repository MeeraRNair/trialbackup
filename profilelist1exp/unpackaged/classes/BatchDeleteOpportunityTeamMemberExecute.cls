/* 
Author: Raymond Yip

History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0     26-OCT-2010     Raymond Yip     Created for CR4435
*/
global class BatchDeleteOpportunityTeamMemberExecute implements Schedulable{        

    private static boolean isTest = false;
    
    global static void execute(SchedulableContext sc){
        
        executeBatch();
    }


    public static void executeBatch() {
        BatchDeleteOpportunityTeamMember buDeleteOTM = new BatchDeleteOpportunityTeamMember();
        
        if(!isTest) {
            buDeleteOTM .queryString = 'SELECT Id,User.Name, User.Title, Opportunity.Account.Type, TeamMemberRole' 
                                        + ' FROM OpportunityTeamMember' 
                                        + ' WHERE' 
                                        + ' (Opportunity.Account.Type = \'OEM\' AND (NOT User.Title LIKE \'OEM%\'))' 
                                        + ' OR (Opportunity.Account.Type = \'MSG\' AND (NOT User.Title LIKE \'MSG%\'))';
        } else {
            buDeleteOTM .queryString = 'SELECT Id,User.Name, User.Title, Opportunity.Account.Type, TeamMemberRole' 
                                        + ' FROM OpportunityTeamMember' 
                                        + ' WHERE User.LastName = \'BatchDeleteACT Test\''                              
                                        + ' AND ((Opportunity.Account.Type = \'OEM\' AND (NOT User.Title LIKE \'OEM%\'))' 
                                        + ' OR (Opportunity.Account.Type = \'MSG\' AND (NOT User.Title LIKE \'MSG%\')))';
        }
                                                                                
        ID batchprocessid = Database.executeBatch(buDeleteOTM ,1000);
    }
    
    public static void executeBatchForTest() {
        isTest = true;
        executeBatch();
    }
    
}