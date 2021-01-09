/*
 * Author   : Abhishek Vishwakarma
 * Purpose  : Calculate number of Active Contacts to Account field 
 
 * Revision CR Number       Release No      Date            Modified By     Description
 * -------- ---------       ----------      -----------     ------------    -----------
 * 1.0                      Fy20 0802       10-July-2019     Abhishek       Number of Active Contacts to Account field 
 */
 
public class DCSEActiveContactsHandlerAD implements AfterDelete{
    
    public void handleAfterDelete(List<sObject> listOld){     
        DCSEActiveContacts.updateContactCount(listOld, null);
    }  
}