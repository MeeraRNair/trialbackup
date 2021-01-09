public with sharing class UserUtils {

   @future
   public static void updateUserCurrency(List<string> userObjectList, string currencyValue){

     try {
            List<User> userList = [select Id,OSPCurrency__c from User where Id in: userObjectList];
            system.debug('######## userList  ' + userList );
            List<User> updateUsers = new List<User>();
            for(User usr : userList){
                usr.OSPCurrency__c = currencyValue;
                updateUsers.add(usr);
                
                system.debug('######## usr' + usr);
            }
            update(updateUsers);
        } catch(System.DMLException e) {
            system.debug('######## ERROR DMLException ' + e);
        }

   }


}