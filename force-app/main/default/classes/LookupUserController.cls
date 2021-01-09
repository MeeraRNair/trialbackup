/************************************************************************

Author        : Rahul Mishra
Description   : Controller class to fetch the user records matching
name with search text entered on lookupUser lightning component
Last Revised  : 30 Nov 2017


*************************************************************************/

public class LookupUserController {
    
    // Method to fetch the searched account
    
    @AuraEnabled
    public static List < User > fetchUser(String searchKeyWord) {
        
        String strSearchKey = searchKeyWord + '%';
        List < User > listUser = new List < User > ();
        List < User > listOfUser = [select id, Name, Email from User where Name LIKE: strSearchKey limit 10];
        
        for (User usr: listOfUser) {
            listUser.add(usr);
        }
        return listUser;
    }
}