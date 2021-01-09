public with sharing class VFCntrlr_CertCriteria_AddEdit {
    private Certification_Criteria_Setup__c ccSetup; 
    public Integer OptionNum{get;set;}
    public boolean chkSelectAll {get; set;} 
    
    //Table Row Class for initiallising values.
    public class TableRow{      
        public string crOption{get;set;}        
        public Boolean isSelected{get;set;}
        public integer OptionNumber{get; set;}
        public String Course_code {get;set;}
        
        public TableRow(String cr,string code, boolean sel, integer cnt){
            crOption = cr;           
            Course_code =code;
            isSelected = sel;
            OptionNumber = cnt;
        }
    }
    List<TableRow> certCriteria {get; set;}
    
    public List<TableRow> getCertTraining(){     
        certCriteria = new List<TableRow>(); 
        Integer cnt = 1;          
        if (ccSetup.Certification_Criteria_Value__c != null){        
             if (ccSetup.Criteria_Value_Ids__c != null){  
                list<String> cCodeLst = ccSetup.Criteria_Value_Ids__c.split(';');        
                for (String str : ccSetup.Certification_Criteria_Value__c.split(';')){
                    if (str.trim() != ''){
                        //String s = str.remove('\'');
                        str = str.replace(' [OR] ',' OR ');
                        str = str.replace(' [AND] ',' AND ');
                        certCriteria.Add(new TableRow(str,cCodeLst.get(cnt-1), false, cnt));
                        cnt++;
                    }
                }  
            }
            else{
                certCriteria.Add(new TableRow(ccSetup.Certification_Criteria_Value__c ,ccSetup.Certification_Criteria_Value__c , false, cnt));
            }
        }
        return certCriteria;        
    }    
    public VFCntrlr_CertCriteria_AddEdit(ApexPages.StandardController stdController){
        Id id = ApexPages.currentPage().getParameters().get('id');       
        ccSetup = (id == null) ? new Certification_Criteria_Setup__c() : 
                    [select name,Certification_Requirement_Setup__c,
                         Certification_Criteria_Order__c, Certification_Criteria_Name__c,                       
                         Certification_Criteria_Value__c, Condition__c,
                         Criteria_Value_Ids__c, Number_of_Demo_Units__c 
                         from Certification_Criteria_Setup__c
                         where id = :id ];
             
        if (id == null){
            String lkid = null; 
            lkid = ApexPages.currentPage().getParameters().get('retURL');
            try{
              if (lkid != null && lkid != ''){            
                lkid = lkid.substring(1, lkid.length());    
                  ccSetup.Certification_Requirement_Setup__c =  lkid ;
                }
            }
            catch(Exception e){
            }           
        }
        chkSelectAll = false;
    }   
    public void SaveCriteria(){
        try {
            if (ccSetup.condition__c == null)
                ccSetup.condition__c.addError('The Field, \"Condition\" should not be Null.');
            else
                upsert(ccSetup);
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);            
        }      
    }
    public PageReference save() {
        SaveCriteria();
        return null;   
    } 
    public PageReference saveClose() {
        SaveCriteria();
        return (new ApexPages.StandardController(ccSetup)).view();      
    }      
    public PageReference deleteCourse() {     
        string tmp='';
        string tmpCode='';            
        for (Integer i =0; i < certCriteria.size();i++) {       
            if(certCriteria.get(i).isSelected){
                //System.debug('true');                                             
            }
            else{                
                if(tmp==''){           
                    tmp = certCriteria.get(i).crOption;                  
                    tmpCode= certCriteria.get(i).Course_code ;                  
                }
                else{
                    tmp = tmp + ';' + certCriteria.get(i).crOption;
                    tmpCode= tmpCode+ ';' + certCriteria.get(i).Course_code ;
                }
            }            
        }
        ccSetup.Certification_Criteria_Value__c = tmp;  
        ccSetup.Criteria_Value_Ids__c = tmpCode;     
        chkSelectAll = false;       
        return null;    
    }
    public pageReference delCourse(){
        string tmp='';
        string tmpCode='';                
        //compare option number and cnt
        for (Integer i =0; i < certCriteria.size();i++) {
            if(i == (OptionNum-1)){
                //system.debug('true' +i);
            }
            else{                
                if(tmp==''){           
                    tmp = certCriteria.get(i).crOption;                  
                    tmpCode= certCriteria.get(i).Course_code ;                  
                }
                else{
                    tmp = tmp + ';' + certCriteria.get(i).crOption;
                    tmpCode= tmpCode+ ';' + certCriteria.get(i).Course_code ;
                }
            }
        }
        ccSetup.Certification_Criteria_Value__c = tmp;  
        ccSetup.Criteria_Value_Ids__c = tmpCode;        
        chkSelectAll = false;
        return null;
    }    
    public Certification_Criteria_Setup__c getccSetup() {
        return ccSetup;
    }
}