/*****************************************************************************************************************
* Name          : Channel_Manager_and_Profile
* Description   : Used in Channel_Manager_and_Profile S-control
* ---------------------------------------------------------
* Revision  Name               Date             Description
* 1.0       Yeswanth         19-June-2018    CR 16067: Display Selected salesmotion account details in the Welcome screen
******************************************************************************************************************/

global without sharing class Channel_Manager_and_Profile {
    
    Webservice static List<user> fetchAccountdetails(){
        List<user> listaccts = new List<user>();
        try{
            listaccts = [Select u.ContactId, u.Contact.AccountId,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__c,
                     u.Contact.Selected_Track__c,u.Contact.Selected_Track__r.Partner_Track_Name__c,u.Contact.Selected_Track_Account__c, u.Contact.Name, 
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Name, u.Contact.Selected_Track_Account__r.Name,u.Contact.Account.Owner.Name,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Owner.Name,u.Contact.Selected_Track_Account__r.Owner.Name,
                     u.Contact.Selected_Track_Account__r.Partner_Track__r.Partner_Track_Name__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Owner.Email,u.Contact.Selected_Track_Account__r.Owner.Email,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Partner_Relationship__c,u.Contact.Selected_Track_Account__r.Partner_Relationship__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Purchasing_Model__c,u.Contact.Selected_Track_Account__r.Purchasing_Model__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Partner_Tier__c,u.Contact.Selected_Track_Account__r.Partner_Tier__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Partner_Type__c,u.Contact.Selected_Track_Account__r.Partner_Type__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Account_Country__c,u.Contact.Selected_Track_Account__r.Account_Country__c,
                     u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Account_Country_Code__c,u.Contact.Selected_Track_Account__r.Account_Country_Code__c 
                     from User u where u.id = :userinfo.getUserId() limit 1]; 
            //     listaccts = [Select u.ContactId, u.Contact.AccountId,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__c,u.Contact.Selected_Track__c,u.Contact.Selected_Track__r.Partner_Track_Name__c,u.Contact.Name, u.Contact.Account.Name, u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Name,u.Contact.Account.Owner.Name,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Owner.Name,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Owner.Email,u.Contact.Account.Partner_Relationship__c,u.Contact.Selected_Track__r.Partner_Program_Tier__c, u.Contact.Account.Purchasing_Model__c,u.Contact.Selected_Track__r.Speciality_Product_Purchase_Path__c ,u.Contact.Account.Partner_Tier__c,u.Contact.Selected_Track__r.Purchase_Path__c,u.Contact.Account.Partner_Type__c,u.Contact.Selected_Track__r.Primary_SMAffinity_Account__r.Partner_Type__c,u.contact.account.Account_Country__c,u.contact.Selected_Track__r.Primary_SMAffinity_Account__r.Account_Country__c,u.contact.account.Account_Country_Code__c,u.contact.Selected_Track__r.Primary_SMAffinity_Account__r.Account_Country_Code__c from User u where u.id = :userinfo.getUserId() limit 1];
            system.debug('Accounts' +listaccts);
        }catch(exception ex){
            system.debug('Exception Occured in fetchAccountdetails method:' +ex.getMessage()) ;             
        }
        return listaccts;
    }
    
    Webservice static List<Disti_Relationship__c> fetchDistiRelationDetails(ID accountId){
        List<Disti_Relationship__c> listdistiRelation = new List<Disti_Relationship__c>();
        system.debug('accountid****' +accountId);
        try{
            listdistiRelation = [Select Id,Distributor_Account_Name_text__c,Secondary_Distributor_Account_Name_text__c,Enabled_for_2_Contracted_Disti_s__c,Onboarding_Distributors__c,Distributor_Switch__c from Disti_Relationship__c where Reseller_Account__c = :accountId limit 1];
        }catch(exception ex){
            system.debug('Exception Occured in fetchDistiRelationDetails method:' +ex.getMessage()) ;             
        } 
        return listdistiRelation;
    }
}