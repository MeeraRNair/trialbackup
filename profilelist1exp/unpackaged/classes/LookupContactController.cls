/************************************************************************

Author        : Rahul Mishra
Description   : Controller class to fetch the contact records matching
name with search text entered on lookupcontact lightning component
Last Revised  : 30 Nov 2017


*************************************************************************/

public class LookupContactController {
    
    // Method to fetch the searched account
    
    @AuraEnabled
    public static List < Contact > fetchContact(String searchKeyWord, String parentIds) {
        
        String strSearchKey = searchKeyWord + '%';
        List < Contact > listContact = new List < Contact > ();
        List < Contact > listOfContact = new List<Contact>();
        
        if(String.isNotBlank(parentIds)) {
            listOfContact = [select id, FirstName, LastName, Name, AccountId, LastModifiedDate from Contact where (LastName LIKE: strSearchKey OR
                                                                                                 FirstName LIKE: strSearchKey) AND AccountId =: parentIds Order by LastModifiedDate DESC limit 10];
        }
        else {
            listOfContact = [select id, FirstName, LastName, Name, LastModifiedDate from Contact where LastName LIKE: strSearchKey OR
                             FirstName LIKE: strSearchKey  Order by LastModifiedDate DESC limit 10];
        }
        
        system.debug('Parent Id from apex class'+parentIds);
        for (Contact con: listOfContact) {
            listContact.add(con);
        }
        return listContact;
    }
}