public class FAP_EditShowcaseControllerExt{

    //======================================================
    // PAGE LOAD ERROR CODES
    //======================================================

    public String eRRORNOACCOUNTID  { get{ return 'ERROR_NO_ACCOUNT_ID' ; }}
    
    //======================================================
    // PROPERTIES
    //======================================================
    public Partner_Showcase__c showcase {get;set;}
    public String errorCode {get;private set;}
    public Boolean isIE{get{return FAP_PageUtils.isIE();}}  
    public Boolean isFirefox{get {return FAP_PageUtils.isFirefox();}} 
    public Boolean isChrome{get {return FAP_PageUtils.isChrome();}} 
      
    private ApexPages.StandardController controller;
    private PageReference retURL;
    private PageReference cancelURL;
       
    //==================================================
    // CONSTRUCTOR  
    //==================================================
    public FAP_EditShowcaseControllerExt(ApexPages.StandardController controller) {
       
        this.controller = controller;
         
        if(this.controller.getRecord()!=null && this.controller.getRecord() instanceof Partner_Showcase__c){
                this.showcase = (Partner_Showcase__c) this.controller.getRecord();
               // system.debug('**mythis.showcase1'+this.showcase);
        } else {
                this.showcase = new Partner_Showcase__c();
                //system.debug('**mythis.showcase2'+this.showcase);
        }
   }
        
    public PageReference doOnLoad(){
        
        try{
            /*if(this.showcase.id!= null){
            
                this.showcase = Database.query(new FAP_SoqlBuilder()
                    .selectx(new Set<Object>{
                    'Id','Account__c','ShowCase_Title__c','ShowCase_Title_Url__c','Short_Description__c','Long_Description__c'})
                    .fromx('Partner_Showcase__c')
                    .wherex(new FAP_FieldCondition('Id',showcase.id))
                    .toSoql());             
                    system.debug('**mythis.showcase2'+this.showcase);
            } */
            // Added by Neeti on 12/12/2018 to remove refernce to SOQL builder class
            If(showcase.Id != null){
                this.showcase = [select Id,Account__c,ShowCase_Title__c,
                ShowCase_Title_Url__c,Partner_Track__c ,
                Short_Description__c,Long_Description__c
                                 FROM Partner_Showcase__c
                                 WHERE Id =: showcase.Id];
            }    
            //system.debug('**mythis.showcase2'+this.showcase);
         } catch(QueryException e){
             FAP_PageUtils.addError(Label.failed_to_load_record + e.getMessage());
         }
                                                                                         
       
       // this.retURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('retURL')) ? FAP_PageUtils.redirect('/'+showcase.Account__c) : FAP_PageUtils.redirect(FAP_PageUtils.param('retURL')+'?returnTab=Showcase');     
       // this.cancelURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('cancelURL')) ? FAP_PageUtils.redirect('/'+showcase.Account__c) : FAP_PageUtils.redirect(FAP_PageUtils.param('cancelURL')+'?returnTab=Showcase');

        this.retURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('retURL')) ? FAP_PageUtils.redirect('/'+showcase.partner_track__c) : FAP_PageUtils.redirect(FAP_PageUtils.param('retURL')+'?returnTab=Showcase');     
        this.cancelURL = FAP_StringUtils.isBlank(FAP_PageUtils.param('cancelURL')) ? FAP_PageUtils.redirect('/'+showcase.partner_track__c) : FAP_PageUtils.redirect(FAP_PageUtils.param('cancelURL')+'?returnTab=Showcase');
                
        return null;
      }        
    
     
    public PageReference saveDetail(){
        system.debug('showcase in in showcase-------'+showcase);
        if(showcase != null){
          Database.upsertresult scResult = null;
            try{
                ID partnerAccountId = getPartnerAccountID();
                system.debug('partnerAccountId in showcase-------'+partnerAccountId);

                if(this.showcase.id == null){
                       
                       if(partnerAccountId == null){
                            return error(eRRORNOACCOUNTID);
                       } 
                       else {
                            //showcase.Account__c = partnerAccountId;
                            showcase.partner_track__c = partnerAccountId;
                       }
                    //add a similar use case for partner track too
               }
               
               if(showcase.Long_Description__c != null){
                   if(showcase.Long_Description__c.contains('<img') ){
                       apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR,Label.Image_Error));
                       return null;
                   }
                     
               }
                
                //Added below method to update date of profile field when any changes happens on edit showcase
                FAP_PageUtils.dateOfProfileUpdate(partnerAccountId);
               
                scResult = Database.upsert(showcase);
               
            }catch(Exception e){
                 return null;
            }
        }
        return retURL;
    }
    
    public PageReference doCancel(){
           
        return this.cancelURL;
        
    }
    
    public Boolean errorOccurred {get{ return FAP_StringUtils.isNotEmpty(this.errorCode); }}
    
/*    public static ID getPartnerAccountID(){
        list<User> lstUsers = [select id, AccountId from user where id = :UserInfo.getUserId() and UserRoleId != null and AccountId != null];
        if(lstUsers == null){
            return null;
        }
        return lstUsers[0].AccountId;
    }
*/
    public static ID getPartnerAccountID(){
        final List < User > userList = [
            select id, ContactId, Contact.AccountId, Contact.Account.id,Contact.Selected_Track__c, Contact.Account.name, userrole.name
            from user where id =: UserInfo.getUserId()
        ];
        system.debug('userList--showcase---------------'+userList);
        if (userList.isEmpty() ||
            userList.get(0).userrole == null ||
            FAP_StringUtils.isBlank(userList.get(0).userrole.name) ||
            userList.get(0).contact == null ||
            userList.get(0).contact.id == null ||
            ((FAP_Configuration.keyValue=='Account__r.' && userList.get(0).Contact.AccountId == null) ||
            (FAP_Configuration.keyValue=='Partner_Track__r.' && userList.get(0).Contact.Selected_Track__c==null))) {
            return null;
        }
        //return userList.get(0).Contact.AccountId;
        return FAP_Configuration.keyValue=='Account__r.'?userList.get(0).Contact.AccountId:userList.get(0).Contact.Selected_Track__c;
    }
    
    private PageReference error(String errorCode){
        this.errorCode = errorCode;
        return null;
    }
    
    public List<String> getMessages(){
        List<String> msgList= new List<String>();
        for(ApexPages.Message msg:ApexPages.getMessages()){
            msgList.add(msg.getSummary());
        }
        return msgList;
    }
    
      
   }