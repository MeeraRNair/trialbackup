/************************************************************************

Author        : Rahul Mishra
Description   : Controller class to fetch the account records matching
account name with search text entered on lookup lightning component
Last Revised  : 30 Nov 2017


*************************************************************************/ 

public class LookUpController {
    
    // Method to fetch the searched account
    
    @AuraEnabled
    public static List < account > fetchAccount(String searchKeyWord) {
        
        String strSearchKey = searchKeyWord + '%';
        List < Account > listAccount = new List < Account > ();
        List < Account > listOfAccount = [select id, Name, LastModifiedDate from account where Name LIKE: strSearchKey order by LastModifiedDate DESC limit 10];
        
        for (Account acc: listOfAccount) {
            listAccount.add(acc);
        }
        return listAccount;
    }
}