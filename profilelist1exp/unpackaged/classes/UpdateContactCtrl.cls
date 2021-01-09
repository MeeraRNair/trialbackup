/*
* Controller logic to avoid mixed DML exception
* 
* Story     CR Number   Release No     Date            Created By    Modified By    Description
* --------  ---------   ----------    -----------     -----------    -----------   -----------
* #5680698              FY20-0402     07-Mar-2019     Varsha                        While update tools or status in contact to avoid mixed DML exception 
* #6327986              FY20-0402     13-Mar-2019                     Varsha        While remove tracks for Group Admin contact, making user as track admin           
*/
public class UpdateContactCtrl {
    //To update tools for contact
    @future (callout=true)
    public static void updateContactToolAccess(String listConTools){
        list<Contact> listUpdateConTools = new list<Contact>();
        
        listUpdateConTools.addAll((list<Contact>) JSON.deserialize(listConTools, list<Contact>.class));
        system.debug('**listupdatetools'+listUpdateConTools);
        try{
            if(listUpdateConTools!=null && listUpdateConTools.size()>0){
                update listUpdateConTools;
            }
        }
        catch(Exception e){
            system.debug('**updatecontacttools'+e);
        }
    }
    
    //Updating contact status
    @future (callout=true)
    public static void updateContactStatus(String strConId){
        Contact con = [SELECT Id, Status__c,Partner_User_Active__c,Partner_User__c,Partner_User__r.IsActive FROM Contact WHERE Id =: strConId];
        System.debug('con'+con);
        if(con.Partner_User__r.IsActive){
           con.Status__c = Label.Customer; 
        }
        else{
            con.Status__c = Label.Invalid_No_Longer_With_Company;
        }
        try{
            if(con!=null){
                update con;
            }
        }
        catch(Exception e){
            system.debug('**updatecontactstatus'+e);
        }
    }
    
    //To update user when tracks are removed for group admin contact, making user track admin
    @future (callout=true)
    public static void updateUser(String listUser){
        list<User> listUpdateUser = new list<User>();
        
        listUpdateUser.addAll((list<User>) JSON.deserialize(listUser, list<User>.class));
        system.debug('**listupdateuser'+listUpdateUser);
        try{
            if(listUpdateUser!=null && listUpdateUser.size()>0){
                update listUpdateUser;
            }
        }
        catch(Exception e){
            system.debug('**updateusergroupadmin'+e);
        }
    }
    
}