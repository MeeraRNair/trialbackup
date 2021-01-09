/*
REVISION HISTORY
================
Version     Author      Date            Release#       CR#     Description
-------     ------      ----            --------       ----    ------------
1.0         Suresh      18-Sep-2018     FY19-DCE-1101         Story 5586705: Stor Acel: Dell Main: Route to Market section re-layout and add new PoR fields
2.0         Pavan       11-nov-2018     FY19                  Story 5785430: Stor Acel: Dell Main: Route to Market section add new Origination Program fields
3.0         Pavan       5-Dec-2018      FY19                  Story 5870323: Stor Acel:Dell Main:  POR field mandatory
*/

public class vfnctrl_RouteToMarketReAccountPage {
      public Account accRecord  {get;set;}
      public boolean bdetailSection {get;set;}
      public boolean beditSection {get;set;}
      public Boolean bisEditButtonVisible {get;set;}
  
      public String strclientErrorMessage {get;set;}
      public String strstorageErrorMessage {get;set;}
      public String strserverErrorMessage {get;set;}
      public String strnetworkErrorMessage {get;set;}
      ApexPages.StandardController controller;
     
      public boolean bisvisible {get;set;}
      public String strmode;
      public Boolean brefreshPage {get;set;}
      
      public String strclientPORMSg {get;set;}
      public String strstoragePORMSg {get;set;}
      public String strserverPORMSg {get;set;}
      public String strnetworkPORMSg {get;set;}


   public Vfnctrl_RouteToMarketReAccountPage(ApexPages.StandardController c){
       strmode = ApexPages.currentPage().getParameters().get('strmode');
      bisEditButtonVisible = false;
      bisvisible = false;
      brefreshPage =false;
    try{       
    
      user loggedInuser = [select id,profile.name from user where id = :Userinfo.getUserId()];
      List<PermissionSetAssignment> listUserPermissionSet = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()
                                                            and PermissionSet.Name = 'Route_To_Market_Edit_Permission'];
                                                            
       if(loggedInuser.profile.name == 'System Administrator'){
           bisEditButtonVisible = true;
           
       }if((loggedInuser.profile.name.contains('Integration') || loggedInuser.profile.name.contains('GBL PRM Operations') || loggedInuser.profile.name.contains('IT')) && listUserPermissionSet.size() > 0){
           bisvisible = true;
           bisEditButtonVisible = true;
       } 
       if(loggedInuser.profile.name.contains('Integration') || loggedInuser.profile.name.contains('GBL PRM Operations') || loggedInuser.profile.name.contains('IT')){
           bisvisible = true;
       }
       else{

           if(listUserPermissionSet.size() > 0){
           
               bisEditButtonVisible = true;
              
           }
                                                                
       }
       
        if(strmode=='edit'){
              beditSection = true;
              bdetailSection = false;
          }
          else{
              beditSection = false;
              bdetailSection = true;
          }        
        if(c != null && c.getRecord() != null && c.getRecord() instanceof Account){
            this.accRecord = (Account)c.getRecord();
            accRecord = [select CSG_Direct_Preference__c,LOBi_Preferred_Partner_of_Record__c,Client_Revenue_Contributing_Partners__c,Storage__c,Storage_Revenue_Contributing_Partners__c,LOBi_Preferred_Partner_of_Record_Network__r.Name,LOBi_Preferred_Partner_of_Record_Server__r.Name,LOBi_Preferred_Partner_of_Record_Storage__r.Name,  
                         Server__c,Origination_Program_Client__c,Origination_Program_Networking__c,Origination_Program_Server__c,Origination_Program_Storage__c,Server_Revenue_Contributing_Partners__c,LOBi_Preferred_Partner_of_Record__r.name,Networking__c,Networking_Revenue_Contributing_Partners__c,name,Account_ID__c,Sales_Channel__r.name,owner.name 
                         from account where  id = :accRecord.id];
            controller = c;
             
        }
        
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
         
        }

        
    }
      
    public void editAction(){

          beditSection = true;
          bdetailSection = false;
          strclientErrorMessage = '';
          strserverErrorMessage ='';
          strstorageErrorMessage = '';
          strnetworkErrorMessage = '';
    }
     public void saveAction(){         
         Boolean bisvalid=true;                                               
         accRecord = (Account)controller.getRecord();                        
          if(accRecord.CSG_Direct_Preference__c==false && accRecord.CSG__c == true && accRecord.LOBi_Preferred_Partner_of_Record__c == null && accRecord.CSG_Direct_Preference__c == false){
             bisvalid = false;
             beditSection = true;
             bdetailSection = false;
             strclientPORMSg = 'Error: You must enter a value in the Partner of Record field';
         }else{
             strclientPORMSg ='';
         }                         
         if(accRecord.Storage__c==true && accRecord.LOBi_Preferred_Partner_of_Record_Storage__c == null){
             bisvalid = false;
             beditSection = true;
             bdetailSection = false;
             strstoragePORMSg = 'Error: You must enter a value in the Partner of Record field';
         }  
         else{strstoragePORMSg = '';
         }
         if(accRecord.Server__c == true && accRecord.LOBi_Preferred_Partner_of_Record_Server__c == null){
             bisvalid = false;
             beditSection = true;
             bdetailSection = false;
             strserverPORMSg = 'Error: You must enter a value in the Partner of Record field';
         } else{
             strserverPORMSg ='';
         }
         if(accRecord.Networking__c == true && accRecord.LOBi_Preferred_Partner_of_Record_Network__c == null){
             bisvalid = false;
             beditSection = true;
             bdetailSection = false;
             strnetworkPORMSg = 'Error: You must enter a value in the Partner of Record field';
         }else{
             strnetworkPORMSg ='';
         }                           
         if(accRecord.LOBi_Preferred_Partner_of_Record__c!=null && accRecord.Origination_Program_Client__c == null){  
             bisvalid = false;                     
             beditSection = true;
             bdetailSection = false;
             strclientErrorMessage = 'Error:Please Select Origination Program value';     
         }else{strclientErrorMessage ='';
         }
         if(accRecord.LOBi_Preferred_Partner_of_Record_Storage__c!=null && accRecord.Origination_Program_Storage__c == null){     
             
             bisvalid=false;                    
             beditSection = true;
             bdetailSection = false; 
             strstorageErrorMessage = 'Error:Please Select Origination Program value';
         }else{
          
             strstorageErrorMessage ='';
         }
         if(accRecord.LOBi_Preferred_Partner_of_Record_Server__c!=null && accRecord.Origination_Program_Server__c == null){   
              
             bisvalid = false;                                              
             beditSection = true;
             bdetailSection = false; 
             strserverErrorMessage = 'Error:Please Select Origination Program value';
             
         }else{
           
             strserverErrorMessage ='';
         }
           if(accRecord.LOBi_Preferred_Partner_of_Record_Network__c!=null && accRecord.Origination_Program_Networking__c == null){       
             bisvalid = false;               
             beditSection = true;
             bdetailSection = false; 
             strnetworkErrorMessage = 'Error:Please Select Origination Program value';                         
         }
         else{strnetworkErrorMessage ='';                                                 
         } 
         if(bisvalid){
           controller.save();
           beditSection = false;
           bdetailSection = true;
           brefreshPage = true;                         
         
         }else{
            brefreshPage = false;
            beditSection = true;
            bdetailSection = false;
         }
         
         }           

    public void cancelAction(){   
    
         beditSection = false;
         bdetailSection = true;
        
    }
    
    public void click(){ 
     
           accRecord = (Account)controller.getRecord();
           accRecord.LOBi_Preferred_Partner_of_Record_Storage__c = null;           
           accRecord.LOBi_Preferred_Partner_of_Record__c = null;
           accRecord.LOBi_Preferred_Partner_of_Record_Server__c = null;
           accRecord.LOBi_Preferred_Partner_of_Record_Network__c = null;
           accRecord.Origination_Program_Client__c = '';
           accRecord.Origination_Program_Storage__c= '';
           accRecord.Origination_Program_Server__c= '';
           accRecord.Origination_Program_Networking__c= '';
                  
     }
}