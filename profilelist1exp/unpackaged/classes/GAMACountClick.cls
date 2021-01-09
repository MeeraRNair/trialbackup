/*****************************************************************************************************************
* Name          : GAMACountClick
* Description   : Metrics tracking on C360 Dashboard & GAMA Links.
* ---------------------------------------------------------
* Revision  Name                Date            Description
* 1.0       Sazleen             3 Oct 2016      CR 13543: Story 2411886:Metrics tracking on C360 Dashboard & GAMA Links
* 2.0       Sazleen             03-Jan-2017     CR13871:Story 2726819:Update SF1 Adoption object Region field.
* 3.0       Jessie Tan          16-Feb-2017     CR14002:Story 2905821:GAMA UI Themes Homepage Issue
* 4.0       SinLin              04-Aug-2018     CR16275:Story 5415829 Lightning Critical Update Fix - Theme
******************************************************************************************************************/

public class GAMACountClick {
    
    public String objectType {get; set;}
    public String recordId {get; set;}
    public String oppRegion {get; set;}
    public String AccRegion {get; set;}
    public String sPlatform {get; set;}
    public String GAMA_Url {get; set;}
    public String oppAffinity {get; set;}
    public String AccAffinity {get; set;}
    
    
    public GAMACountClick(){
    
        objectType = ApexPages.currentPage().getParameters().get('obj');
        System.debug('### objectType : '+objectType);
        
        //v3.0 - start
        //remove characters other than alpha (a-z)
        objectType = objectType.replaceFirst('[^a-zA-Z]+','');        
        System.debug('### Object Type without Special Char : '+ objectType );        
        //v3.0 - end 
        
        if(objectType != 'Homepage'){
            getOpportunityRegion();
            getAccountRegion();
        }
        generateLink();
    }
    
    public PageReference redirectGAMA(){
        
        countClick();
        
        try{
            
            System.debug('### GAMA_Url--- '+GAMA_Url);
            
            return new PageReference(GAMA_Url);
            
        }catch(Exception e){System.debug(e.getMessage());}
        return null;
    }
    
    public void getOpportunityRegion(){
        recordId = ApexPages.currentPage().getParameters().get('id');
        
        if (objectType == 'Opportunity'){
            Opportunity oppObj = [Select Account.Regional_Parent_Name_lookup__c, Affinity_ID__c from Opportunity where id = :recordId];
             if(oppObj != null){
                 oppAffinity = oppObj.Affinity_ID__c;
                 oppRegion = oppObj.Account.Regional_Parent_Name_lookup__c;}
         } //end if
         system.debug('### oppRegion======='+oppRegion);
    }
    
    public void getAccountRegion(){
        if (objectType == 'Account'){
            Account accObj = [Select Regional_Parent_Name_lookup__c, Account_ID__c from Account where id = :recordId];
             if(accObj != null){
                 AccAffinity = accObj.Account_ID__c;
                 AccRegion = accObj.Regional_Parent_Name_lookup__c;}
         } //end if
         system.debug('### AccRegion==============='+AccRegion);
    }
        
    public void countClick(){
        SF1_Adoption__c obj = new SF1_Adoption__c();
        obj.Object_Name__c = objectType;
        
        if(obj.Object_Name__c == 'Homepage'){
            obj.Region__c =  '';
            obj.Record_ID__c = '';
        }else if (obj.Object_Name__c == 'Opportunity') {
            if(oppRegion!=null){
                obj.Region__c =  oppRegion;    
            }
            obj.Record_ID__c = recordId; 
        }else if (obj.Object_Name__c == 'Account') {                
            if(AccRegion!=null){
                obj.Region__c =  AccRegion;    
            }
            obj.Record_ID__c = recordId;
        } 
                 
        obj.Source__c = 'GAMA';
        obj.User_Action__c = '';
        obj.User_Edited_Date__c = Datetime.now();
        obj.User_Name__c = UserInfo.getUserId(); 
                    
        sPlatform = userinfo.getUiTheme();
        System.debug('### sPlatform========='+sPlatform);
        
        if (sPlatform == 'Theme1' || sPlatform == 'Theme2' || sPlatform == 'Theme3'){
            obj.Platform__c = 'Salesforce Classic';
        }else if (sPlatform == 'Theme4d' || sPlatform == 'Theme4u'){
            obj.Platform__c = 'Salesforce Lightning';
        }else if (sPlatform == 'Theme4t'){
            obj.Platform__c = 'Salesforce1 Mobile';
        }
        
        try{
            //Save data for tracking purpose (clicks count)
            insert obj;
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
    }
      
    public void generateLink(){
        if(objectType == 'Homepage'){
            GAMA_Url = System.Label.GAMA_Link;
        }else if (objectType == 'Opportunity') {
            GAMA_Url = System.Label.GAMA_Link + '?&accountId='+oppAffinity+'&hierarchyType=SALES&securityToken=aff@d3ll';
        }else if (objectType == 'Account') {   
            GAMA_Url = System.Label.GAMA_Link + '?accountId='+AccAffinity+'&hierarchyType=SALES&securityToken=aff@d3ll';
        }         
        System.debug('### checking GAMA_Url========'+GAMA_Url);        
    }
}