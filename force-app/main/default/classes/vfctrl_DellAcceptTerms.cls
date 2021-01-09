/*********************************
This class in Used to capture the time stamp and updated fields in Account Object when User Clicks on Accept
Button
**********************************/
global class vfctrl_DellAcceptTerms{

    public Contact con {get;set;}
    public Boolean ShowButton {get;set;}
    public Boolean showCompleteSection  {get;set;}
    public vfctrl_DellAcceptTerms(){
        ShowButton  = True;
        showCompleteSection  = true;
        System.debug('>>>>>>>>>>>>>> '+UserInfo.getUserId());
        User usr = [select id,contactId from User where id=:UserInfo.getUserId() ]; 
        con = [select id,name,AccountId ,Partner_User_Partner_Admin__c,Selected_Track__r.DELLEMC_Ts_and_Cs_agreed_date__c,Selected_Track__r.DELLEMC_Ts_and_Cs_agreement__c from Contact where id =: usr.contactId ];

        if(con.Selected_Track__r.DELLEMC_Ts_and_Cs_agreement__c){
        ShowButton =False;
        }
        if(!con.Partner_User_Partner_Admin__c ){
            showCompleteSection  =false;
        }
    }
  @RemoteAction
 global static Boolean newAcceptTerms(String conid){
            
       Contact con = [select id,name,AccountId ,Partner_User_Partner_Admin__c,Selected_Track__c,Selected_Track__r.DELLEMC_Ts_and_Cs_agreed_date__c,Selected_Track__r.DELLEMC_Ts_and_Cs_agreement__c,Selected_Track__r.DELLEMC_Ts_and_Cs_agreement_User__c from Contact where id =: conid];
                
        partner_track__c Ptr = new partner_track__c(id = con.Selected_Track__c,
                                  DELLEMC_Ts_and_Cs_agreement__c = True,
                                  DELLEMC_Ts_and_Cs_agreement_User__c =con.Id,
                                  DELLEMC_Ts_and_Cs_agreed_date__c = System.now());
                                  
        Database.SaveResult saveAcclist = Database.update(Ptr , false);
          return saveAcclist.isSuccess();
    }

}