public class ContactTableController {
    
    //To return initial contact records
    @AuraEnabled
    public static ContactWrapper getActiveContactAssociatedToSM(Integer initialRows,String strMG, String strPT,Integer rowOffset){
        ContactWrapper contactWrapper= new ContactWrapper();
        Set<String> setConIds = new Set<String>();
        System.debug('initialRows::'+initialRows+'strMG::'+strMG+'strPT'+strPT);
        List<String> listACS = System.Label.Active_Contact_Status.split(';');
        System.debug('listACS'+listACS); 
        //Getting all contacts based on masteraccountid
        for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name 
                              FROM Contact 
                              WHERE AccountId =: strMG AND
                              Status__c  IN:listACS
                              ORDER BY Name ASC  
                              ]){
                                 //System.debug(con.Id+'strPT'+con.EligibleTracks__c.contains(strPT)+'con.EligibleTracks__c'+con.EligibleTracks__c);
                                if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                    System.debug('count'+con); 
                                    setConIds.add(con.Id);
                                 }
                              }
            for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c 
                              FROM Contact 
                              WHERE Id IN: setConIds 
                              AND AccountId =: strMG 
                              AND Status__c  IN:listACS
                              ORDER BY Name ASC LIMIT :initialRows 
                              OFFSET :rowOffset]){
                                 System.debug('con entered'+con); 
                                  if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                      contactWrapper.contactsActiveList.add(con);
                                       System.debug('con'+con);
                                   }
                              }
            

            if(setConIds.size() > 0){
              contactWrapper.totalActiveRecords=setConIds.size();  
              System.debug('totalActiveRecords '+contactWrapper.totalActiveRecords);
            	contactWrapper.message = 'records found';
            	contactWrapper.success = true;
            }
            else{
                contactWrapper.totalActiveRecords = 0;
                System.debug('totalActiveRecords '+contactWrapper.totalActiveRecords);
            contactWrapper.message = 'records found';
            contactWrapper.success = true;
            }
            
            
            
        
        return contactWrapper;
    }
    
    //For InActive Contacts 
    @AuraEnabled
    public static ContactWrapper getInActiveContactAssociatedToSM(Integer initialRows,String strMG, String strPT,Integer rowOffset){
        ContactWrapper contactWrapper= new ContactWrapper();
        Set<String> setConIds = new Set<String>();
        System.debug('initialRows::'+initialRows+'strMG::'+strMG+'strPT'+strPT);
        List<String> listInACS = System.Label.InActive_Contact_Status.split(';');
        System.debug('listACS'+listInACS);
        for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name
                              FROM Contact 
                              WHERE AccountId =: strMG AND
                              Status__c IN:listInACS
                              ORDER BY Name ASC ]){
                                  
                                  if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                      setConIds.add(con.Id);
                                      
                                  }
                              }
            //Getting all contacts based on masteraccountid
            for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c 
                              FROM Contact 
                              WHERE Id IN: setConIds
                              AND AccountId =: strMG AND
                              Status__c IN:listInACS
                              ORDER BY Name ASC LIMIT :initialRows 
                              OFFSET :rowOffset]){
                                  
                                  if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                      System.debug('con'+con);
                                      contactWrapper.contactsInactiveList.add(con);
                                      
                                  }
                              }
            

            if(setConIds.size() > 0){
                contactWrapper.totalInActiveRecords = setConIds.size();
                System.debug('totalInActiveRecords'+contactWrapper.totalInActiveRecords);
            	contactWrapper.message = 'records found';
            	contactWrapper.success = true;
            }
            else{
                contactWrapper.totalInActiveRecords = 0;
                System.debug('totalInActiveRecords'+contactWrapper.totalInActiveRecords);
            	contactWrapper.message = 'records found';
            	contactWrapper.success = true;
            }
             
            
        
        return contactWrapper;
    }
    //To return additional records based on offset
    @AuraEnabled
    public static List<Contact> loadContactRecords(String tabset,String strMG,String strPT,Integer rowLimit,Integer rowOffset){
        List<Contact> contactsActiveList = new List<Contact>();
        List<Contact> contactsInactiveList = new List<Contact>();
        if(tabset == 'Active'){
            System.debug('rowLimit'+rowLimit+'rowOffset'+rowOffset);
            ContactWrapper conwrap = new ContactWrapper();
            conwrap = getActiveContactAssociatedToSM(rowLimit,strMG,strPT,rowOffset);
            contactsActiveList = conwrap.contactsActiveList;
            return contactsActiveList; 
        }
        else{
            ContactWrapper conwrap = new ContactWrapper();
            conwrap = getInActiveContactAssociatedToSM(rowLimit,strMG,strPT,rowOffset);
            contactsInactiveList = conwrap.contactsInactiveList;
            return contactsInactiveList; 
          }
    }
    // wrapper class
    public class ContactWrapper{
            @AuraEnabled
            public Integer totalActiveRecords = 0;
            @AuraEnabled
            public Integer totalInActiveRecords = 0;
            @AuraEnabled
            public List<Contact> contactsActiveList = new List<Contact>();
            @AuraEnabled
            public List<Contact> contactsInactiveList = new List<Contact>();
            @AuraEnabled
            public String message ='';
            @AuraEnabled
            public Boolean success;
        }
    
    @AuraEnabled
    public static ContactWrapper findByName(String tabset,String searchKey,String strMG, String strPT){
            
            ContactWrapper contactWrapper= new ContactWrapper();
            System.debug('searchKey' + searchKey);
            List<String> listACS = System.Label.Active_Contact_Status.split(';');
            List<String> listInACS = System.Label.InActive_Contact_Status.split(';');
            String name = '%' + searchKey + '%';
            if(tabset == 'Active'){
                for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c 
                                  FROM Contact 
                                  WHERE AccountId =: strMG 
                                  AND Name LIKE :name 
                                  AND Status__c  IN:listACS
                                  ORDER BY Name ASC  
                                 ]){
                                     if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                         contactWrapper.contactsActiveList.add(con);
                                     } 
                                      
                                 }
                if(contactWrapper.contactsActiveList.size() > 0){
                                     contactWrapper.totalActiveRecords = contactWrapper.contactsActiveList.size();
                                     System.debug('totalActiveRecords '+contactWrapper.totalActiveRecords);
                                     contactWrapper.message = 'contacts found';
                                     contactWrapper.success = true;
                }
               else{
                                         contactWrapper.totalActiveRecords = contactWrapper.contactsActiveList.size();
                                         System.debug('totalActiveRecords'+contactWrapper.totalActiveRecords);
                                         contactWrapper.message = 'contacts found';
                                         contactWrapper.success = true;
              }
            }
            else{
                for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Enable_as_Partner_Group_Administrator__c, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c 
                                  FROM Contact 
                                  WHERE AccountId =: strMG 
                                  AND Name LIKE :name
                                  AND Status__c IN:listInACS
                                  ORDER BY Name ASC 
                                 ]){
                                     if(String.isNotBlank(con.EligibleTracks__c) && con.EligibleTracks__c.contains(strPT)){
                                         contactWrapper.contactsInactiveList.add(con);
                                     }
                                 }
                if(contactWrapper.contactsInactiveList.size() > 0){
                    contactWrapper.totalInActiveRecords = contactWrapper.contactsInactiveList.size();
                    System.debug('totalInActiveRecords'+contactWrapper.totalInActiveRecords);
                    contactWrapper.message = 'contact found';
                    contactWrapper.success = true;
                }
                else{
                    contactWrapper.totalInActiveRecords = contactWrapper.contactsInactiveList.size();
                    System.debug('totalInActiveRecords'+contactWrapper.totalInActiveRecords);
                    contactWrapper.message = 'contacts found';
                    contactWrapper.success = true;
                }
                
                
            }
            
            return contactWrapper;
            
        }
        
    }