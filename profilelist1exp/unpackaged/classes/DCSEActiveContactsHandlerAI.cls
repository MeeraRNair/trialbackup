/*
 * Author   : Abhishek Vishwakarma
 * Purpose  : Calculate number of Active Contacts to Account field 
 
 * Revision CR Number       Release No      Date            Modified By     Description
 * -------- ---------       ----------      -----------     ------------    -----------
 * 1.0                      Fy20 0802       10-July-2019     Abhishek       Number of Active Contacts to Account field 
 */
 
public class DCSEActiveContactsHandlerAI implements AfterInsert{
    
    public void handleAfterInsert(List<sObject> listNew){
    
        System.debug('---inside contact handler After insert---');
        DCSEActiveContacts.updateContactCount(listNew, null);
    }  
}