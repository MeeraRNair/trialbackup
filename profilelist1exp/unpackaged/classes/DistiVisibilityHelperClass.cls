/***************************************************************************************************************************************************************
* 
* Name          : DistiVisibilityHelperClass
* Description   : Helper class to identify logged in users partner type 
* -------------------------------------------------------------------------------------------------------------------------
* Revision      Name            Date                 CR                                         Description
* 1.0          Yeswanth      26.10.2017         Story 3989864                            Deal Reg: GC 2.0 - Remove GC logic
* 2.0          Yeswanth      12.10.2018                                                  PAM: Modified existing logic to check criteria based on selected sales motion instead of master groupping
* 3.0          Yeswanth      06.12.2018                                                  PAM: Added logic to fetch the active contacts associated to salesmotion account
***************************************************************************************************************************************************************/

public without sharing class DistiVisibilityHelperClass{
    
    // Static Method to find the PartnerType -  Distributor/Tier2/Tier1 - based on Loggedin User
    public static string getPartnerType(Id userId) {
        User u = [Select Id,contact.account.Partner_Type__c,contact.account.Partner_Tier__c,contact.selected_track_account__r.Partner_Type__c, contact.selected_track_account__r.Partner_Tier__c, contact.selected_track_account__r.Partner_Relationship__c from User where Id = : userId];
        String strpartnerType = '';
        // Setting Partner Type of Selected Track account if Selected Track Account is not Null
        If( u.contact != NULL &&  u.contact.selected_track_account__c != NULL){
            If( u.contact.selected_track_account__r.Partner_Type__c != NULL && (u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL OEM DISTRIBUTOR') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('DISTRIBUTOR (GCC)') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('OEM DISTRIBUTOR') || (u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('COMMERCIAL DISTRIBUTOR')) || (u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL DISTRIBUTOR')))) {
                // Check If Distributor
                strpartnerType = 'Distributor';
                
            }else If(u.contact.selected_track_account__r.Partner_Type__c != NULL && (u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('SUB DISTRIBUTOR')))
            {
                strpartnerType = 'Sub Distributor';
            }

            else If(u.contact.selected_track_account__r.Partner_Type__c != NULL && u.contact.selected_track_account__r.Partner_Tier__c != NULL && (u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals ('COMMERCIAL GENERAL') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('SOLUTION PROVIDER') ||  u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL CLOUD SERVICE PROVIDER') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL OEM') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SOLUTION PROVIDER') ||u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SYSTEMS INTEGRATOR') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL SOLUTION PROVIDER') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('FEDERAL SYSTEMS INTEGRATOR') || u.contact.selected_track_account__r.Partner_Type__c.toUpperCase().equals('US FEDERAL')) && 
                      (u.contact.selected_track_account__r.Partner_Tier__c == 'Tier 2' || u.contact.selected_track_account__r.Partner_Tier__c == 'Tier2'  || u.contact.selected_track_account__r.Partner_Tier__c == 'Indirect Partner Purchase' || u.contact.selected_track_account__r.Partner_Tier__c == 'Distribution')) { strpartnerType = 'Tier2';
                           } else { strpartnerType = 'Tier1';
                      }
        }
        // Setting Partner Type of Master Group account if Selected Track Account is Null
        If( u.contact != NULL &&  u.contact.selected_track_account__c == NULL){
            If( u.contact.account.Partner_Type__c != NULL && (u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM DISTRIBUTOR') || u.contact.account.Partner_Type__c.toUpperCase().equals('DISTRIBUTOR (GCC)') || u.contact.account.Partner_Type__c.toUpperCase().equals('OEM DISTRIBUTOR') || (u.contact.account.Partner_Type__c.toUpperCase().equals('COMMERCIAL DISTRIBUTOR')) || (u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL DISTRIBUTOR')))) {strpartnerType = 'Distributor';
                
            }else If(u.contact.account.Partner_Type__c != NULL && (u.contact.account.Partner_Type__c.toUpperCase().equals('SUB DISTRIBUTOR'))){strpartnerType = 'Sub Distributor';
            } 
           else If(u.contact.account.Partner_Type__c != NULL && u.contact.account.Partner_Tier__c != NULL && (u.contact.account.Partner_Type__c.toUpperCase().equals ('COMMERCIAL GENERAL') || u.contact.account.Partner_Type__c.toUpperCase().equals('SOLUTION PROVIDER') || u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL CLOUD SERVICE PROVIDER') || u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM') ||u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SOLUTION PROVIDER') ||u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SYSTEMS INTEGRATOR') ||u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL SOLUTION PROVIDER') || u.contact.account.Partner_Type__c.toUpperCase().equals('FEDERAL SYSTEMS INTEGRATOR') || u.contact.account.Partner_Type__c.toUpperCase().equals('US FEDERAL')) && 
                      (u.contact.account.Partner_Tier__c == 'Tier 2' || u.contact.account.Partner_Tier__c == 'Tier2'  || u.contact.account.Partner_Tier__c == 'Indirect Partner Purchase' ||  u.contact.account.Partner_Tier__c == 'Distribution')) {
                          // Check If Tier 2
                          strpartnerType = 'Tier2';
                          
                      } else {strpartnerType = 'Tier1';
                      }
        }
        
                    system.debug('------63----'+strpartnerType);

        return strpartnerType;
        
    } 
    
    // Static Method to find the PartnerType -  Distributor/Tier2/Tier1 - based on Account
    public static string getPartnerTypeFromAccount(Id AccId) {
        Account account = [Select Id, Partner_Type__c, Partner_Tier__c, Partner_Relationship__c from Account where Id = : AccId];
        String strpartnerType = '';
        
        If(account.Partner_Type__c != NULL && (account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM DISTRIBUTOR') || account.Partner_Type__c.toUpperCase().equals('DISTRIBUTOR (GCC)')  || account.Partner_Type__c.toUpperCase().equals('OEM DISTRIBUTOR') || account.Partner_Type__c.toUpperCase().equals('COMMERCIAL DISTRIBUTOR') || account.Partner_Type__c.toUpperCase().equals('FEDERAL DISTRIBUTOR'))) {
            // Check If Distributor
            strpartnerType = 'Distributor';
            
        } else If(account.Partner_Type__c != NULL && (account.Partner_Type__c.toUpperCase().equals('SUB DISTRIBUTOR')))
        {
            strpartnerType = 'Sub Distributor';
            
        }
        else If( account.Partner_Type__c != NULL && (account.Partner_Type__c.toUpperCase().contains('COMMERCIAL')  || account.Partner_Type__c.toUpperCase().contains('SOLUTION PROVIDER') || account.Partner_Type__c.toUpperCase().equals('FEDERAL CLOUD SERVICE PROVIDER') || account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM') ||account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SOLUTION PROVIDER') ||account.Partner_Type__c.toUpperCase().equals('FEDERAL OEM SYSTEMS INTEGRATOR') ||account.Partner_Type__c.toUpperCase().equals('FEDERAL SOLUTION PROVIDER') || account.Partner_Type__c.toUpperCase().equals('FEDERAL SYSTEMS INTEGRATOR') ||account.Partner_Type__c.toUpperCase().contains('US FEDERAL')) && 
                  (account.Partner_Tier__c == 'Tier 2' || account.Partner_Tier__c == 'Tier2' || account.Partner_Tier__c == 'Indirect Partner Purchase' || account.Partner_Tier__c == 'Distribution' )) {strpartnerType = 'Tier2';
                      
                  } else {
                      // Check If Tier 1
                      strpartnerType = 'Tier1';
                  }
        return strpartnerType;
    }
    
    // Method to fetch active contacts for a give sales motion ID
    public static list<id> getContactsUnderSalesMotion(Account salesAccountObj){
        List<String> listeligibleTracksId;
        List<Id> listsalesMotionActiveConList = new List<ID>();
        //Getting all contacts based on masteraccountid
        for(Contact con: [SELECT Id, AccountId, EligibleTracks__c, Name, Partner_User_Partner_Admin__c, Decision_Making_Role__c, NPS_Qualified_Status__c, Primary_Contact_for_Service_Type__c, Partner_User_Active__c, Email, Status__c, Phone, Partner_User_Deal_Registration__c FROM Contact WHERE AccountId =: salesAccountObj.Master_Group_Id__c]){listeligibleTracksId = new List<String>();
            if(String.isNotBlank(con.EligibleTracks__c)){
                //This will execute if eligible tracks has one or more id's
                //One id with semicolon it will work
                //If more than one id, in ending if there is no semicolon will work
                //If one value with out semicolon, else block executes
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){listeligibleTracksId = con.EligibleTracks__c.split(';');
                    //TODO:Remove
                    system.debug('listeligibleTracksId if block:'+listeligibleTracksId);
                    if(listeligibleTracksId.contains(salesAccountObj.Partner_Track__c) && (con.Status__c == 'Customer' || con.Status__c == 'Active' || con.Status__c == 'Prospect' || con.Status__c == 'Marketing Suspect' || con.Status__c == 'INTERNAL - Crisis Mgmt')){listsalesMotionActiveConList.add(con.id);}
                }
                //TODO: Based on data, need to remove 
                else{
                    listeligibleTracksId.add(con.EligibleTracks__c);
                    system.debug('listeligibleTracksId else block:'+listeligibleTracksId);
                    if(listeligibleTracksId.contains(salesAccountObj.Partner_Track__c) && (con.Status__c == 'Customer' || con.Status__c == 'Active' || con.Status__c == 'Prospect' || con.Status__c == 'Marketing Suspect' || con.Status__c == 'INTERNAL - Crisis Mgmt')){listsalesMotionActiveConList.add(con.id);}
                }   }
        }
        return listsalesMotionActiveConList;
    }
    
    public static set<id> getMasterGroupAccnts(String strsearchemail){
        set<id> setmgAccountIds =new set<id>();
        for(User usr : [select contact.accountid from user where IsActive = true AND Enable_Partner_Deal_Registration__c = true and contact.account.recordtype.name = 'Master Account' and email Like  :'%' +strsearchemail +'%' limit 49000]){setmgAccountIds.add(usr.contact.accountid);}return setmgAccountIds;
        }  
   
}