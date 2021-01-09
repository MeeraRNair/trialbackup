/**
* Controller logic for granting or revoking access to sales motion accounts.
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
*                       FY20-0402     11-March-2019     Sneha         Logic to implement insertion of Account Share
*                       
*/
global class UserSMAccess implements Database.batchable<SObject>{
    // To capture the account share records.
    global List<AccountShare> listAcctShareInsert;
    
    global String strOperationType;
     
     // To By pass Duplicate ids Exception
    map<id,AccountShare> mapAccShareIns = new map<id,AccountShare>(); 
    map<id,AccountShare> mapAccShareDel = new map<id,AccountShare>(); 
    
    global UserSMAccess(List<AccountShare> listAccountShareInsert, String strOperation){
        listAcctShareInsert =listAccountShareInsert;
        strOperationType = strOperation;
    }
    
    global Iterable<SObject> start(Database.BatchableContext bc){
        return listAcctShareInsert;
    }
    
    global void execute(Database.BatchableContext bc, List<AccountShare> listAccShare){
        System.debug('execute'+listAcctShareInsert.size());
        System.debug('Operation Type::'+strOperationType);
        System.debug('listAcctShareInsert'+listAccShare.size());
        if(listAccShare.size() > 0){
       
            if(strOperationType == System.Label.Grant_Access_Type){
             mapAccShareIns.putAll(listAccShare);
            Database.SaveResult[] listSR = Database.insert(listAccShare,false);
            for (Database.SaveResult sr : listSR) {
                if(sr.isSuccess()){
                    System.debug('Inserted Successfully'+sr.id);
                }
                else {
                 ExceptionHandlingCtrl.exceptionHandlingMethod(listSR , 'AccountShare', 'Accont Share Insertion', 'Exception', mapAccShareIns.values());
                }
                
            }
            }
            else if(strOperationType == System.Label.Revoke_Access_Type){
            mapAccShareDel.putAll(listAccShare);
                Database.DeleteResult[] listDelSR= Database.delete(listAccShare,false);
                for (Database.DeleteResult sr : listDelSR) {
                if(sr.isSuccess()){
                    System.debug('Delete Successfully');
                }
                else {
                    ExceptionHandlingCtrl.exceptionHandlingMethodDel(listDelSR, 'AccountShare', 'Accont Share Deletion', 'Exception', mapAccShareDel.values());
                }
                
            }
            }
            
        }
        
    }
    global void finish(Database.BatchableContext bc){}
    
}