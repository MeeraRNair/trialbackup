/***************************************************************************************************************************************************************
 
* Name          : DistiRelationshipValidator 
* Description   : Class to Support Disti_Relationship__c Trigger 
* ---------------------------------------------------------------------------------------
* Revision  Name                 Date                 CR                            Description
* 1.0       Santhosh      
* 2.0       Rajashekar Kura      10.05.2017           14322                         Added Method to Populate Storage Preferred Distributor.
                                                                                    Method Name: AutoPopulateDistiAccount
***************************************************************************************************************************************************************/

public class DistiRelationshipValidator {
    
    // Validate Duplicate Disti Account 
    public static void validateDistiAccount(list<Disti_Relationship__c> lstNewDistis, map<Id, Disti_Relationship__c> mapOldDistis) {

        set<Id> distiIds = new set<Id>();
        set<Id> resellerIds = new set<Id>();
        for(Disti_Relationship__c  distiRelation : lstNewDistis) {
            If( distiRelation.Disti_Account__c != NULL && distiRelation.Reseller_Account__c != NULL){
                distiIds.add(distiRelation.Disti_Account__c);
                resellerIds.add(distiRelation.Reseller_Account__c);
            }
        }

        If( distiIds.size() > 0 && resellerIds.size() > 0 ){
            list<Disti_Relationship__c> duplicateDistis = [select Id, Disti_Account__c, Reseller_Account__c, Name from Disti_Relationship__c 
                                                           where Disti_Account__c IN: distiIds AND Reseller_Account__c IN: resellerIds];

            map<Id, Id> duplicateDistiIdMap = new map<Id, Id>();
            for(Disti_Relationship__c disti: duplicateDistis){
                duplicateDistiIdMap.put(disti.Disti_Account__c, disti.Reseller_Account__c);
            }
 
            for(Disti_Relationship__c newDisti : lstNewDistis) {
                If(mapOldDistis == null) {
                    // Insert Case
                    If( duplicateDistiIdMap.get(newDisti.Disti_Account__c) == newDisti.Reseller_Account__c ){
                        newDisti.addError('Disti Account & Reseller Account is already exists');
                    }   
                }else If(mapOldDistis != null) {
                    // Update case
                    Disti_Relationship__c oldDistiAccount = mapOldDistis.get(newDisti.Id);

                    If( oldDistiAccount.Disti_Account__c != newDisti.Disti_Account__c || oldDistiAccount.Reseller_Account__c != newDisti.Reseller_Account__c ){
                        If( duplicateDistiIdMap.get(newDisti.Disti_Account__c) == newDisti.Reseller_Account__c ){
                            newDisti.addError('Disti Account & Reseller Account is already exists');
                        }
                    }
                }
                /*for(Disti_Relationship__c duplicateDisti : duplicateDistis){
                    If( newDisti.Disti_Account__c == duplicateDisti.Disti_Account__c && newDisti.Reseller_Account__c == duplicateDisti.Reseller_Account__c ){
                        
                    }
                }
                If( newDistiAccount.Disti_Account__c != null ) {
                    If(mapOldDistis == null) {
                        // Insert Case
                        If(duplicateDistiIds.contains(newDistiAccount.Disti_Account__c)) {
                            newDistiAccount.Disti_Account__c.addError('Disti Account is already exists');
                        }
                    }else If(mapOldDistis != null){
                        // Update case
                        Disti_Relationship__c oldDistiAccount = mapOldDistis.get(newDistiAccount.Id);

                        If( oldDistiAccount.Disti_Account__c != newDistiAccount.Disti_Account__c ){
                            If(duplicateDistiIds.contains(newDistiAccount.Disti_Account__c)) {
                                newDistiAccount.Disti_Account__c.addError('Disti Account is already exists');
                            }
                        }
                    }
                } */
            }
        }
    }
    
    // Auto populate Disti Account 
/***************************************************************************************************************************************************************
Story 3271954:Deal Reg: Distribution Strategy: Auto Populate Storage Preferred Distributor from Partner Request
Author: Rajashekar Kura
Date  : 10.05.2017
Functionality: when the user inserts / updates the Disti Relationship record with Reseller Account, the Sponcering Distributor Account Field Populates. 
***************************************************************************************************************************************************************/
    public static void AutoPopulateDistiAccount(list<Disti_Relationship__c> lstNewDistis) {
    set<Id> resellerIds = new set<Id>();
    set<String> SponsoringDistributorset = new set<String>();
    Map<String, List<Id>> SponsoringDistributorMap = new Map<String, List<Id>>();
    Map<Id, Account> ResellerAccountmap;
    Map<Id, Account> DistiAccountmap;
    List<Disti_Relationship__c> Existingdistis;
    //Getting the List of Reseller Accounts
    for(Disti_Relationship__c  distiRelation : lstNewDistis) {
                resellerIds.add(distiRelation.Reseller_Account__c);
        }
    //Getting Sponsoring_Distributor__c from Partner Registration for all the Resellers
    if(resellerIds.size() != null)  
        ResellerAccountmap = new Map<Id, Account>([select Id, Partner_Registration__r.Sponsoring_Distributor__c from Account where Id IN: resellerIds AND Partner_Registration__c != null AND Partner_Registration__r.Sponsoring_Distributor__c != null]);      

    System.Debug(resellerIds);
    if(ResellerAccountmap.size() != null) {
    for(Account Acc : ResellerAccountmap.values()) {
                SponsoringDistributorset.add(Acc.Partner_Registration__r.Sponsoring_Distributor__c);
        }
    }
    System.Debug(SponsoringDistributorset);
    
    //Search on Account to get related Sponsoring Distributors which contains Storage & Distributor
    if(SponsoringDistributorset.size() != null) 
        DistiAccountmap = new Map<Id, Account>([select Id, Name from Account where Partner_Relationship__c like: '%'+Label.Disti_Partner_Relationship+'%' And Partner_Type__c like: '%'+Label.Disti_Partner_Type+'%' AND Calculated_Status__c = 'Active' AND Partner_Registration__c != null AND Name IN: SponsoringDistributorset]);
    if(DistiAccountmap.size() != null) {
    //Search on Disti Relationship to Check for the duplicate records
    Existingdistis = [select Id, Disti_Account__c, Reseller_Account__c, Name from Disti_Relationship__c where Disti_Account__c IN: 
                                                        DistiAccountmap.keyset() AND Reseller_Account__c IN: resellerIds];
    //Adding Sponcering Distributor, Accountid to Map to counting the Number of Accounts with same name
    for(Account Acc : DistiAccountmap.values()) {
                if(SponsoringDistributorMap.containskey(Acc.Name))
                {
                    List<Id> Accids = SponsoringDistributorMap.get(Acc.Name);
                    Accids.add(Acc.id);
                    SponsoringDistributorMap.put(Acc.Name, Accids);
                }
                else
                {
                    List<Id> Accids = new List<Id>();
                    Accids.add(Acc.id);
                    SponsoringDistributorMap.put(Acc.Name, Accids);
                }
        }
    }
    System.Debug(SponsoringDistributorMap);
    
    //Populate Storage Preferred Distributor with related Sponsoring Distributor Accounts
    for(Disti_Relationship__c Disti : lstNewDistis){
    //populate only when Storage Preferred Distributor is null
    if(Disti.Disti_Account__c == null)
    {
    try{
           if(SponsoringDistributorMap.containskey((ResellerAccountmap.get(Disti.Reseller_Account__c)).Partner_Registration__r.Sponsoring_Distributor__c))
            {
                Account RelatedResellerAcc = ResellerAccountmap.get(Disti.Reseller_Account__c);
                System.Debug('Copying Disti Account');
                List<Id> Accids = SponsoringDistributorMap.get(RelatedResellerAcc.Partner_Registration__r.Sponsoring_Distributor__c);
                //populate Storage Preferred Distributor only when Number of records found = 1
                if(Accids.size() == 1)
                {
                    System.debug(Accids[0]);
                    Disti.Disti_Account__c = Accids[0];
                }
                // Checking for the duplicates inorder to keep the unique records
                for(Disti_Relationship__c oldDisti : Existingdistis)
                {
                    //if there is a duplicate record, revert the Storage Preferred Distributor to null
                    if((oldDisti.Reseller_Account__c == Disti.Reseller_Account__c) && (oldDisti.Disti_Account__c == Disti.Disti_Account__c))
                    {
                        Disti.Disti_Account__c = null;
                        break;
                    }
                }
            }                          
        }
    catch(exception ex){
        System.debug(ex.getMessage());
        }
    }       
   }
 }
}