public with sharing class VFCntrlr_CertPrerequisite {
    private Certification_Prerequisites_Setup__c cpSetup;  
           
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
        
        if (cpSetup.Prerequisites__c!= null){
            list<String> cCodeLst = cpSetup.Prerequisites_Ids__c.split(';');           
            for (String str : cpSetup.Prerequisites__c.split(';')){
                if (str.trim() != ''){
                    //String s = str.remove('[');
                    //s = str.remove(']');
                    str = str.replace(' [OR] ',' OR ');
                    str = str.replace(' [AND] ',' AND ');
                    
                    certCriteria.Add(new TableRow(str,cCodeLst.get(cnt-1), false, cnt));
                    cnt++;
                }
            }           
        }
        return certCriteria;        
    }

    public VFCntrlr_CertPrerequisite(ApexPages.StandardController stdController){
        Id id = ApexPages.currentPage().getParameters().get('id');
              
        cpSetup = (id == null) ? new Certification_Prerequisites_Setup__c() : 
                    [select Name,Certification_Requirement_Setup__c,       
                         Prerequisites__c, Condition__c, Prerequisites_Ids__c
                         from Certification_Prerequisites_Setup__c
                         where id = :id ];
             
        if (id == null){
            String lkid = null; 
            lkid = ApexPages.currentPage().getParameters().get('retURL');
            try{
              if (lkid != null && lkid != ''){            
                lkid = lkid.substring(1, lkid.length());    
                  cpSetup.Certification_Requirement_Setup__c =  lkid ;
                }
            }
            catch(Exception e){
            }     
        }
        chkSelectAll = false;
    }
    public void SavePrerequisite(){
        try {
            upsert(cpSetup);
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);  
        } 
    }
    public PageReference save() {
        SavePrerequisite();        
        return null;   
    } 
    public PageReference saveClose() {
        SavePrerequisite();
        return (new ApexPages.StandardController(cpSetup)).view();      
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
        cpSetup.Prerequisites__c= tmp;  
        cpSetup.Prerequisites_Ids__c= tmpCode;                 
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
        cpSetup.Prerequisites__c= tmp;  
        cpSetup.Prerequisites_Ids__c= tmpCode;        
        chkSelectAll = false;  
        return null;
    }       
   //.............................
   public Certification_Prerequisites_Setup__c getcpSetup() {
        return cpSetup;

    } 

}