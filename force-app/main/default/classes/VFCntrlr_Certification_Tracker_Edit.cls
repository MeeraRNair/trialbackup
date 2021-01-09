/******************************************************************************** 
Name        : VFCntrlr_Certification_Tracker_Edit 
Description : Used in NetExam App to allow cert admin to edit Dell Certificaiton Area including master program names.               
---------------------------------------------------------* 
  Revision  Name            Date           CR#     Description
* 1.0       Sudhapriya M.   24th Nov 2012  CR       
* 2.0       Kishore D       06th Oct 2015  11993   changing the order as per the acceptance criteria

************************************************************************************/
public with sharing class VFCntrlr_Certification_Tracker_Edit {
    private Certification_Tracker__c ct;            
       
    public Boolean preferredDate_IsReadOnly {get; private set;}
    public Boolean premierDate_IsReadOnly {get; private set;}
    
    public List<String> selAvailableList {get; set;} // options selected in Available picklist to move to Selected list
    public List<String> selSelectList {get; set;}   // options selected in Selected picklist to move to Available list
    
    Set<String> selList = new Set<String>() ;
    Set<String> AvalList = new Set<String>() ;
    Set<String> mpList = new Set<String>() ;
    
        
    public VFCntrlr_Certification_Tracker_Edit(ApexPages.StandardController controller) {
        Id id = ApexPages.currentPage().getParameters().get('id');
      
        ct = (id == null) ? new Certification_Tracker__c() : 
                    [select Account_Name__c, Account_country__c, Qualified_as_Dell_Preferred_Partner__c,
                        Training_Criteria_Met__c, Qualified_as_Dell_Premier_Partner__c,                       
                         Demo_Unit_Criteria_Met__c, Dell_Certification_Areas__c,
                         Contractual_Agreement__c, Certification_completed__c,
                         Approved_Business_Plan__c, Demo_Units_Purchased__c, Evaluate_criteria__c,
                         Certification_Changed_Date__c,Previous_Partner_Relationship_Type__c,Certification_Date__c,
                         Date_Qualified_as_Dell_Preferred_Partner__c,De_Certification_Date__c,Date_Qualified_as_Dell_Premier_Partner__c,
                         Audit_Date__c,Last_Evaluation_Date__c,Current_QTR__c,Rev_External_Id__c,Current_QTD_Ent_Rev__c,QTD_Updated_Date__c,
                         Current_QTD_Total_Rev__c,QTR_Updated_Date__c,Back_4_QTRs_Ent_Rev__c,CurrencyIsoCode,Back_3_QTRs_Ent_Rev__c,Back_4_QTRs_Total_Rev__c,
                         Back_2_QTRs_Ent_Rev__c,Back_3_QTRs_Total_Rev__c,Back_1_QTRs_Ent_Rev__c,Back_2_QTRs_Total_Rev__c,Back_1_QTRs_Total_Rev__c, DemoAlert__c, Certification_Admin_Mailbox__c, Deployment_Certification__c, Deployment_Certification_Date__c, Deployment_Certifications_Completed__c
                         from Certification_Tracker__c
                         where id = :id ];
        
        //.... get all valid Dell Certification Areas from the picklist values        
        Schema.DescribeFieldResult availableList_field = Certification_Tracker__c.Dell_Certification_Areas__c.getDescribe();
        AvalList.clear();
        for (Schema.PicklistEntry f : availableList_field.getPicklistValues()){           
            AvalList.add(f.getLabel());
        }  
       
        for (Master_Program_Setup__c mp : [select id,Master_Program_Name__c 
                                                    from Master_Program_Setup__c 
                                                    where Active__c = true] ){
            AvalList.add(mp.Master_Program_Name__c);   
            mpList.add(mp.Master_Program_Name__c);
        }      
        
        selList.clear();
        if(ct.Dell_Certification_Areas__c != null){
            for(string s : ct.Dell_Certification_Areas__c.split(';')){
                selList.add(s);
                
                if ( AvalList.contains(s)){
                    AvalList.remove(s);
                }
            }
        }
        
        preferredDate_IsReadOnly = false;
        premierDate_IsReadOnly = false;
       
        List<Profile> certProfile = [select id from profile 
                                        where name='GBL PRM Certification Admin' 
                                           OR name='GBL PRM Certification Admin - Non SSO' ];
        
        Set<ID> profileIds = new Set<ID>();
        for (Profile p : certProfile){
            profileIds.add(p.Id);
        }
        if(profileIds.contains(UserInfo.getProfileId() )){
           if (ct.Date_Qualified_as_Dell_Preferred_Partner__c != null){
                preferredDate_IsReadOnly = true; 
           }           
           if (ct.Date_Qualified_as_Dell_Premier_Partner__c != null){
                premierDate_IsReadOnly = true; 
           } 
        }
    }
       
    public List<SelectOption> getAvailableList(){
        //.... get all valid Certification Names and Master Program Name from the picklist values 
        List<SelectOption> options = new List<SelectOption>();
        for (String f : AvalList){
            options.add(new SelectOption(f,f));           
        }
        // below line is an comment for to show the order of dellcompetencies values as per the acceptence criteria--kishore D
        //options.sort();
        return options;
     }
          
    public List<SelectOption> getSelectedList() {
        List<SelectOption> selectedOptions = new List<SelectOption>();
        for(String s: selList ){
            selectedOptions.add(new SelectOption(s, s));              
        }
        return selectedOptions;
    }  
     
    //code for right and left button
    public void availableToSelected(){
        try{
            if(selAvailableList != null){ 
                for(string s : selAvailableList ){
                   if(! selList.contains(s))
                       selList.add(s);
                       
                   if ( AvalList.contains(s)){
                       AvalList.remove(s);
                   }
                }               
            }
          }
          catch(Exception e){
            System.debug('Exception : ' + e);
          }
      }
       
    public void unSelectToAvailable() {
        try{
            if(selSelectList != null){ 
                for(string s : selSelectList ){
                   if(! AvalList.contains(s))
                       AvalList.add(s);  
                                       
                   if (selList.contains(s)){
                       selList.remove(s);
                   }
                }               
            }
         }
        catch(Exception e){
            System.debug('Exception : ' + e);
        }
    }
    //end tag for right and left button
    
    public Certification_Tracker__c getct() {
        return ct;
    }    
   
    public PageReference save() {
        try {
            string cert_mpNames = '';
            String certArea='';
            for(string s : selList){
                if (certArea == '')
                    certArea = s;
                else
                    certArea = certArea + ';' + s;
                    
                if (mpList.contains(s)){
                    if (cert_mpNames == '')
                        cert_mpNames =  s;
                    else
                        cert_mpNames = cert_mpNames + '; ' + s;
                }
                
            }
            ct.Dell_Certification_Areas__c = certArea;
            ct.Certification_Area_MasterProgramNames__c = cert_mpNames;
            upsert(ct);
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }       
        return (new ApexPages.StandardController(ct)).view();      
    }      
}