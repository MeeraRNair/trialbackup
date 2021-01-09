/*
 * Author   : Abhishek Vishwakarma
 * Purpose  : Calculate number of Active Contacts to Account field 
 
 * Revision CR Number       Release No      Date            Modified By     Description
 * -------- ---------       ----------      -----------     ------------    -----------
 * 1.0                      Fy20 0802       10-July-2019     Abhishek       Number of Active Contacts to Account field 
 */
 
public class DCSEActiveContactsHandlerAU implements AfterUpdate{
    
    public void handleAfterUpdate(List<sObject> listNew, Map<Id, sObject> mapOld){
        DCSEActiveContacts.updateContactCount(listNew, (map<Id, Contact>)mapOld);
    }  
}