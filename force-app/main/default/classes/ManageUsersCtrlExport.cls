/*
* Controller logic for export functionality on ManageUsers Page
* 
* In ManageUsers page we have diffrent types of action. 
* This controller logic is to export the excel file of Selected User and also All Users on click of export button.
* 
* Story       CR Number   Release No      Date            Created By     Modified By     Description
* --------    ---------   ----------      -----------     ------------   -----------     -----------
* #5680717                FY20-0402       21-Jan-2019     Mounika                         Export selected users/ExportAll file from the ManageUsers page 
*/

public class ManageUsersCtrlExport {
  public String strExportConId{get;set;}
  public String strUserID{get;set;}
   public String strOfContactquery{get;set;}
  public user loggedInUser{get;set;}
  public map<id,Contact> mapOfContact ;
  Public List<contactWrapperForExport> listOfConExportWrap {get; set;}  
  public Map<String,string> mapOfFieldsExprtWarp {get; set;}  
  Public List<String> listOfToolAccess{get; set;} 
  public String strDateLabel{get; set;}  
  public String strToolAcc;
  public String strAllEg;
  public String strConStatus;
  public String strcontentType {get;set;}
  Public string strfilename{get;set;}
  public Id masterAccountRecordTypeId;//Getting masteraccountrecordtype and assigned
    public string strQuerydata { get; set;} 
    public ManageUsersCtrlExport (){
    if(!Test.isRunningTest()){
        StrQuerydata = apexpages.currentPage().getCookies().get('value').getValue(); 
        system.debug('>>>StrQuerydata '+StrQuerydata );}
        else if (Test.isRunningTest()){
            StrQuerydata= ' Partner_User_Active__c = True ORDER BY LastName ASC LIMIT 10';
        }
         Date d = date.today();
         strDateLabel = DateTime.newInstance(d.year(),d.month(),d.day()).format('MM/dd/YYYY');
          masterAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Master_Account_Record_Type_Name).getRecordTypeId();
         
         system.debug('strDateLabel!!!'+strDateLabel);
        strfilename= system.Label.Users +'_'+ strDateLabel ;
        // strfilename= 'dell-emc-users_03_03_2019';
       // strcontentType = 'application/vnd.ms-excel#strfilename().xls';
         listOfConExportWrap = new List<contactWrapperForExport>();
         list<string> listOfConIDsToExprt = new list<string>();
         map<id,Contact> mapOfContact = new map<id,Contact>();
        
        strExportConId = apexpages.currentpage().getparameters().get('selectedConIDToExport');
        strOfContactquery = apexpages.currentpage().getparameters().get('strOfContactquery');
        if(String.isNotBlank((Label.Export_Limit).trim())){
            String strLimit = 'LIMIT ' + (Label.Export_Limit).trim();
          //  strOfContactquery = strOfContactquery.replaceAll('LIMIT\\s*1000\\s*$', strLimit); 
        }
        
        strUserID = apexpages.currentpage().getparameters().get('loggedInUsr');
        system.debug('strUserID!!!'+strUserID);
        system.debug('strExportConId!!!'+strExportConId);
        system.debug('strOfContactquery!!!'+strOfContactquery);
        
        if(String.isNotBlank(strExportConId)){
            for(String strConIdsExprt: strExportConId.split(',')){
                system.debug('strConIdsExprt!!!'+strConIdsExprt);
                listOfConIDsToExprt.add(strConIdsExprt);
            }
        }   
        
        if(String.isNotBlank(strUserID)){
        loggedInUser =  [SELECT Id,contact.accountId,Enable_Partner_Admin__c,
                        Enable_as_Partner_Group_Administrator__c,
                        contact.EligibleTracks__c,Enable_Partner_Deal_Registration__c,OSC_Create_Quote__c,OSC_Create_Order__c,OSC_Specialty_Product_Create_Quote__c,OSC_Specialty_Product_Create_Order__c,
                        Enable_Partner_Lead_Management__c,Enable_As_Partner_Lead_Super_User__c,
                        contact.Premier_Partner__c,contact.Enable_User_for_MyRewards__c,
                        contact.Allow_RFP_and_Proposal_Express_Tool__c,contact.Allow_Partner_Central_User__c,
                        contact.Allow_Program_Tracker__c,contact.Is_MDF_User__c,contact.Is_Rebate_User__c,ContactId
                        FROM User WHERE Id =: strUserID];
        system.debug('userConid^^^^^^^^^^^^:'+loggedInUser.contact.accountId);
        }
        
        List<String>  listOfConEgTracksIds = new List<String>();
        List<String> listOfConEgTrackIdsFinal =  new List<String>();
        List<String> listOfLoggedInUserEgTracksIds = new List<String>();
        map<Id,Set<String>> mapOfConIDWithSelConEgTracksContainsLoggedInUserEgT = new map<Id,Set<String>>();
        
       if(strExportConId ==null){
        system.debug('>>>> in If');
            String strquery = 'Select id, Name,Partner_User__r.Email,Phone,FirstName,LastName,EligibleTracks__c,Partner_User_Active__c,Partner_User__r.Enable_Partner_Deal_Registration__c,Partner_User__r.OSC_Create_Quote__c,Partner_User__r.OSC_Create_Order__c,Partner_User__r.OSC_Specialty_Product_Create_Quote__c,Partner_User__r.OSC_Specialty_Product_Create_Order__c,Premier_Partner__c,Enable_User_for_MyRewards__c,Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,Allow_Program_Tracker__c,Is_MDF_User__c,Is_Rebate_User__c,Partner_User__r.Enable_Partner_Lead_Management__c,Partner_User__r.Enable_As_Partner_Lead_Super_User__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MobilePhone, Partner_User_Partner_Admin__c, Enable_as_Partner_Group_Administrator__c from Contact where';
                                                            strquery =strquery  + strQuerydata;
                                                            system.debug('>>>>>>>strquery'+strquery);
                    List<Contact> listcon   = Database.query(strquery);
                    system.debug('>>>>>listcon   in if '+listcon   ); 
                    
                    for(contact cons: listcon ){
                    system.debug('>> in for loop: '+ cons);
                        mapOfContact.put(cons.id,cons);
                    }
                   // mapOfContact.put(listcon);  
                    system.debug('>>>>>mapOfContact in if '+mapOfContact );                                   
            }
        
        else{
         system.debug('>>>> in Else');
        List<Contact> listcon   = ([Select id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Partner_User_Partner_Admin__c, Enable_as_Partner_Group_Administrator__c,mobilePhone,Name,Partner_User__r.Email,Phone,FirstName,LastName,EligibleTracks__c,
                                                            Partner_User_Active__c,Partner_User__r.Enable_Partner_Deal_Registration__c,Partner_User__r.OSC_Create_Quote__c,Partner_User__r.OSC_Create_Order__c,Partner_User__r.OSC_Specialty_Product_Create_Quote__c,Partner_User__r.OSC_Specialty_Product_Create_Order__c,
                                                            Partner_User__r.Enable_Partner_Lead_Management__c,Partner_User__r.Enable_As_Partner_Lead_Super_User__c,
                                                            Premier_Partner__c,Enable_User_for_MyRewards__c,
                                                            Allow_RFP_and_Proposal_Express_Tool__c,Allow_Partner_Central_User__c,
                                                            Allow_Program_Tracker__c,Is_MDF_User__c,Is_Rebate_User__c 
        from Contact where id =: listOfConIDsToExprt ORDER BY LastName ASC]);
        for(contact cons: listcon ){
                        mapOfContact.put(cons.Id, cons);
                    }
        
        system.debug('>>>>>mapOfContact in else'+mapOfContact ); 
        
        }
                                                           
                                                        
                                                            
        System.debug('>>>>>mapOfContact Outside'+mapOfContact);
                                                            
        for(Contact con: mapOfContact.values()){
            // system.debug('con!!!'+con);
            listOfConEgTracksIds = new List<String>();
            Set<String> setOfSelConEgTracksContainsLoggedInUserEgT =new Set<String>();
            
            if(String.isNotBlank(loggedInUser.contact.EligibleTracks__c)){
                if(String.ValueOf(loggedInUser.contact.EligibleTracks__c).contains(';')){
                    listOfLoggedInUserEgTracksIds = loggedInUser.contact.EligibleTracks__c.split(';');
                    system.debug('listOfLoggedInUserEgTracksIds '+listOfLoggedInUserEgTracksIds);
                }else{
                    listOfLoggedInUserEgTracksIds.add(loggedInUser.contact.EligibleTracks__c); 
                    
                } 
            }
            
            if(String.isNotBlank(con.EligibleTracks__c)){
                if(String.ValueOf(con.EligibleTracks__c).contains(';')){
                    listOfConEgTracksIds = con.EligibleTracks__c.split(';');
                    system.debug('listOfConEgTracksIds !!!'+listOfConEgTracksIds);
                }else{
                    listOfConEgTracksIds.add(con.EligibleTracks__c);  
                }
            }    
            
            for(String strEgTrackId: listOfConEgTracksIds){
                system.debug('strEgTrackId '+strEgTrackId);
                if(listOfLoggedInUserEgTracksIds.contains(strEgTrackId)){
                    listOfConEgTrackIdsFinal.add(strEgTrackId);
                    setOfSelConEgTracksContainsLoggedInUserEgT.add(strEgTrackId);
                }
                //system.debug('listOfConEgTrackIdsFinal'+listOfConEgTrackIdsFinal);
                //system.debug('setOfSelConEgTracksContainsLoggedInUserEgT'+setOfSelConEgTracksContainsLoggedInUserEgT);
            } 
            mapOfConIDWithSelConEgTracksContainsLoggedInUserEgT.put(con.id, setOfSelConEgTracksContainsLoggedInUserEgT);  
        }
        
        
        map<id,Partner_Track__c> mapOfPartnerTrack =new map<id,Partner_Track__c>([SELECT Id,Name,Track_Name__c,Partner_Track_Name__c,Track_Id__c
                                                                              FROM Partner_Track__c WHERE Id IN: listOfConEgTrackIdsFinal]);
        //system.debug('mapOfPartnerTrack'+mapOfPartnerTrack);
        
        for(Id conId: mapOfConIDWithSelConEgTracksContainsLoggedInUserEgT.keySet()){
            String strAllEg ='';
            String strToolAcc =''; 
            mapOfFieldsExprtWarp = new Map<String,string>();
            listOfToolAccess = new List<String>();
            List<String> listOfContactEgTrackNames = new List<String>();    
            Partner_Track__c partnerTrack = new Partner_Track__c();
            Contact con = mapOfContact.get(conId);
            //system.debug(con.Name+'  id===con=== :'+'Partner Tracks'+mapOfConIDWithSelConEgTracksContainsLoggedInUserEgT.get(conId));
            
            for(String strOfEligibleIds: mapOfConIDWithSelConEgTracksContainsLoggedInUserEgT.get(conId)){
            if(!mapOfPartnerTrack.isEmpty()){
                partnerTrack = mapOfPartnerTrack.get(strOfEligibleIds);
                
                system.debug('partnerTrack!!!'+partnerTrack);
                if(String.isNotBlank(partnerTrack.Track_Name__c)){
                    listOfContactEgTrackNames.add(partnerTrack.Track_Name__c);
                }
              }
              system.debug('contactid:'+con.id+'listOfContactEgTrackNames!!!'+listOfContactEgTrackNames.size());  
            }
            
            strAllEg = string.join(listOfContactEgTrackNames,',');
            //system.debug('strAllEg!!!'+strAllEg);
            
            mapOfFieldsExprtWarp.put('EligibleTracksNames',strAllEg);
            //system.debug(con.Name+' data!!!'+con.Partner_User_Deal_Registration__c);
            
            if(con.Partner_User__r.Enable_Partner_Deal_Registration__c == True && loggedInUser.Enable_Partner_Deal_Registration__c  == True){
                listOfToolAccess.add(label.Deal_Registration);
                
            }
            if(con.Partner_User__r.Enable_Partner_Lead_Management__c == True && loggedInUser.Enable_Partner_Lead_Management__c  == True){
                listOfToolAccess.add(label.Lead_Management);
                
            }
            if(con.Partner_User__r.Enable_As_Partner_Lead_Super_User__c == True && loggedInUser.Enable_As_Partner_Lead_Super_User__c  == True){
                listOfToolAccess.add(label.Lead_Super_User);
                
            }
            if(con.Is_MDF_User__c == True && loggedInUser.contact.Is_MDF_User__c == True){
                listOfToolAccess.add(label.MDF);
                
            }
           if(con.Enable_User_for_MyRewards__c == True && loggedInUser.contact.Enable_User_for_MyRewards__c == True){
                listOfToolAccess.add(label.MyRewards);
                
            }
             if(con.Allow_Partner_Central_User__c == True && loggedInUser.contact.Allow_Partner_Central_User__c == True){
                listOfToolAccess.add(label.Partner_Central);
                
            }
            if(con.Premier_Partner__c == True && loggedInUser.contact.Premier_Partner__c == True){
                listOfToolAccess.add(label.Premier);
                
            }
            if(con.Allow_Program_Tracker__c == True && loggedInUser.contact.Allow_Program_Tracker__c == True){
                listOfToolAccess.add(label.Program_Tracker);
                
            }
            if(con.Is_Rebate_User__c == True && loggedInUser.contact.Is_Rebate_User__c == True){
                listOfToolAccess.add(label.Rebates);
                
            }
            if(con.Allow_RFP_and_Proposal_Express_Tool__c  == True && loggedInUser.contact.Allow_RFP_and_Proposal_Express_Tool__c == True){
                listOfToolAccess.add(label.RFP_Proposal_Express_Tool);
                
            }
            //Added as part of 6335018 [SFDC] ISG Enablement: Channel 2 Tier: Retrofit Manage User Partner Admin Search filters for create quote/order
            if(con.Partner_User__r.OSC_Create_Quote__c == True && loggedInUser.OSC_Create_Quote__c  == True){
              listOfToolAccess.add(label.OSC_Create_Quote);
            }
            if(con.Partner_User__r.OSC_Create_Order__c == True && loggedInUser.OSC_Create_Order__c  == True){
              listOfToolAccess.add(label.OSC_Create_Order);
            }
            if(con.Partner_User__r.OSC_Specialty_Product_Create_Quote__c == True && loggedInUser.OSC_Specialty_Product_Create_Quote__c  == True){
              listOfToolAccess.add(label.OSC_SP_Create_Quote);
            }
            if(con.Partner_User__r.OSC_Specialty_Product_Create_Order__c == True && loggedInUser.OSC_Specialty_Product_Create_Order__c  == True){
              listOfToolAccess.add(label.OSC_SP_Create_Order);
            }
            
            strToolAcc = String.join(listOfToolAccess,',');
            //system.debug('strToolAcc '+strToolAcc);
            
            mapOfFieldsExprtWarp.put('toolAccess',strToolAcc);
            //system.debug('mapOfFieldsExprtWarp!!!'+mapOfFieldsExprtWarp);
            //system.debug(con.name+' : Name : '+con.Partner_User_Active__c);
            if(con.Partner_User_Active__c == True){
                strConStatus = 'Active';
                
            }else{
                strConStatus = 'Inactive';
            }
            
            mapOfFieldsExprtWarp.put('StatusOfContact',strConStatus);
            system.debug('mapOfFieldsExprtWarp!!!'+mapOfFieldsExprtWarp);
            
            listOfConExportWrap.add(new contactWrapperForExport(con, mapOfFieldsExprtWarp));
            system.debug('listOfConExportWrap!!!'+listOfConExportWrap.size());
            
        }
        system.debug('listOfConExportWrap!!!'+listOfConExportWrap);
      }
 
    
    //  Wrapper class
    public class contactWrapperForExport{
        public Contact con {get; set;}       
        public Map<String,string> mapOfFieldsExprtWarp {get; set;}
       
        // Contructor method 
        public contactWrapperForExport(Contact cont, Map<String,string> mapOfFieldsExprtWarp) {
            this.con = cont;
            this.mapOfFieldsExprtWarp= mapOfFieldsExprtWarp;
           
        }
    }
  
}