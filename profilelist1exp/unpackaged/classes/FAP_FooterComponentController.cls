/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#     Description
-------     ------      ----            --------    ---     -----------
1.0         Manju       27-JULY-2015                        Created for removing IFrame from FAP Page 
*/

public class FAP_FooterComponentController{
    public Boolean isIE{get{return FAP_PageUtils.isIE();}}  // Ver 2.3
    public Boolean isChrome{get {return FAP_PageUtils.isChrome();}} // Ver 2.3
    public Boolean isFirefox{get {return FAP_PageUtils.isFirefox();}} // Ver 2.3     
    public String thiscountryCode{get; set;}
    public String thisLanguage{get; set;}
    public Footer__mdt footerObj{get; set;}
    Footer__mdt dellURL=new Footer__mdt();
    Map<String, Footer__mdt> mapOfNameToFootObj = new Map<String, Footer__mdt>(); 
    
    public FAP_FooterComponentController(){
    }
    
    public void getFooterRecords(){
        
       
        
         try{
             
            if(thisLanguage != null && thisLanguage != '' && thiscountryCode != null && thiscountryCode != ''){
                for(Footer__mdt footObj : [select DeveloperName, C2014_Dell__c, About_Dell__c, Terms_and_Conditions__c,               
                                                        Unresolved_Issues__c, Privacy__c, Privacy_Settings__c,  Contact__c, Feedback__c, Site_Map__c from Footer__mdt 
                                                        WHERE DeveloperName =: thisLanguage.mid(0,2).toLowerCase() + '_' +  thiscountryCode.toLowerCase()]){
                    mapOfNameToFootObj.put(footObj.DeveloperName, footObj);
               }
                //system.debug('========mapOfNameToFootObj====='+mapOfNameToFootObj);
            }
        }catch (QueryException e) {
            System.debug('========exception==========='+e.getMessage());
        }
    }
    
    public String twoZeroOneFourDell{   
        get{  
            getFooterRecords();
            if(twoZeroOneFourDell != null){
                return twoZeroOneFourDell;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.C2014_Dell__c != null){
                            twoZeroOneFourDell = footObj.C2014_Dell__c;
                        }else{
                            twoZeroOneFourDell=null;
                        }
                    }                       
                }
              return twoZeroOneFourDell;
            }
        }
        set;                      
    }
    
    public String aboutDell{   
        get{  
            getFooterRecords();
            if(aboutDell != null){
                return aboutDell;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.About_Dell__c != null){
                            aboutDell = footObj.About_Dell__c;
                        }else{
                            aboutDell=null;
                        }
                    }                   
                }
              return aboutDell;
            }
        }
        set;                      
    }
    
    public String termsAndConditions{   
        get{  
            getFooterRecords();
            if(termsAndConditions != null){
                return termsAndConditions;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Terms_and_Conditions__c != null){
                            termsAndConditions = footObj.Terms_and_Conditions__c;
                        }else{
                            termsAndConditions=null;
                        }
                    }                   
                }
              return termsAndConditions;
            }
        }
        set;                      
    } 
     
    public String unresolvedIssues{   
        get{  
            getFooterRecords();
            if(unresolvedIssues != null){
                return unresolvedIssues;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Unresolved_Issues__c != null){
                            unresolvedIssues = footObj.Unresolved_Issues__c;
                        }else{
                            unresolvedIssues=null;
                        }
                    }                   
                }
              return unresolvedIssues;
            }
        }
        set;                      
    }
    
    public String privacy{   
        get{  
            getFooterRecords();
            if(privacy != null){
                return privacy;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Privacy__c != null){
                            privacy = footObj.Privacy__c;
                        }else{
                            privacy=null;
                        }
                    }                   
                }
              return privacy;
            }
        }
        set;                      
    }
    
    public String privacySettings{   
        get{  
            getFooterRecords();
            if(privacySettings != null){
                return privacySettings;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Privacy_Settings__c != null){
                            privacySettings = footObj.Privacy_Settings__c;
                        }else{
                            privacySettings=null;
                        }
                    }                   
                }
              return privacySettings;
            }
        }
        set;                      
    }
    
    public String contactUs{   
        get{  
            getFooterRecords();
            if(contactUs != null){
                return contactUs;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Contact__c != null){
                            contactUs = footObj.Contact__c;
                        }else{
                            contactUs=null;
                        }
                    }                   
                }
              return contactUs;
            }
        }
        set;                      
    }
    
    public String feedback{   
        get{  
            getFooterRecords();
            if(feedback != null){
                return feedback;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Feedback__c != null){
                            feedback = footObj.Feedback__c;
                        }else{
                            feedback=null;
                        }
                    }                   
                }
              return feedback;
            }
        }
        set;                      
    }
    
    public String siteMap{   
        get{  
            getFooterRecords();
            if(siteMap != null){
                return siteMap;             
            }
            else{
                for(String nm : mapOfNameToFootObj.keySet()){
                    if(nm == (thisLanguage.mid(0,2) + '_' +  thiscountryCode)){
                        Footer__mdt footObj = mapOfNameToFootObj.get(nm);
                        if(footObj.Site_Map__c != null){
                            siteMap = footObj.Site_Map__c;
                        }else{
                            siteMap=null;
                        }
                    }                   
                }
              return siteMap;
            }
        }
        set;                      
    }
      
}