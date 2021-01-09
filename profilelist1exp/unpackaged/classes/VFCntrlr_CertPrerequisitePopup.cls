public class VFCntrlr_CertPrerequisitePopup {
    public String CrValue_fromMnPg{get;set;}
    public String CrId_fromMnPg {get;set;}
    public String selCriteriaValue{get;set;}
    public String selCriteriaId {get;set;}
    public String RowType {get;set;}
    public String RowType_modify {get;set;}
    
    public String isSave {get; set;} 
    public String fromPage{get;set;}    
    public integer optionNumber {get;set;}  
    public String search_course{get;set;}
    public String search_course_Modify{get;set;}   
    public boolean chkSelectAll {get; set;}
    public boolean NoRecordsFound_add {get;set;}
    public boolean NoRecordsFound_modify {get;set;}
         
    //Table Row Class for initiallising values.
    public class TableRow{          
        public Course__c Course {get;set;}
        public Certification_Requirement_Setup__c CertReq {get;set;}
        public string trName{get;set;}        
        public string trCode{get;set;}        
        public Boolean isSelected{get;set;}
        public String RowType{get;set;}
                
        public TableRow(Course__c c, boolean sel){   
            Course = c;
            CertReq = null;
            isSelected = sel;
            RowType = 'Course';
            trName = c.Course_Name__c;
            trCode = 'CC_' + c.Course_Code__c;           
        }
        public TableRow(Certification_Requirement_Setup__c c, boolean sel){   
            Course = null;
            CertReq = c;
            isSelected = sel;
            RowType = 'Certification';    
            trName = c.name;
            trCode = 'CR_' + c.id;
        }          
        public TableRow(String opd){
            isSelected = false;  
            RowType = 'Operand';
            trName = opd;
            trCode = opd;     
            course = null;          
            CertReq = null;
        }
        public TableRow(String cName,String cCode, boolean sel, String rType){
            isSelected = sel;   
            RowType = rType;
            trName = cName;
            trCode = cCode;
            course = null;
            CertReq = null;
        }       
    }
    list<TableRow> SearchTableRows = new list<TableRow>();
    list<TableRow> SearchTableRows_modify = new list<TableRow>();
    
    list<TableRow> SelectedCourseTableRows = new list<TableRow>();
    list<TableRow> SelectedCourseTableRows_del = new list<TableRow>();
    list<TableRow> SelectedCourseTableRows_Add = new list<TableRow>();    

    public VFCntrlr_CertPrerequisitePopup(){        
        try{                         
            isSave = '';
           fromPage = ApexPages.currentPage().getParameters().get('mode');  
            CrValue_fromMnPg = ApexPages.currentPage().getParameters().get('crValue');
            CrId_fromMnPg = ApexPages.currentPage().getParameters().get('crId');            
           
            if (fromPage == 'Edit')
                optionNumber = integer.valueOf(ApexPages.currentPage().getParameters().get('cnt'));  
            else
                optionNumber = -1;        
                 
            setCrList();
            chkSelectAll = false;
        }
        catch(Exception e){  
            ApexPages.addmessages(e);   
        } 
    }
    
    public pageReference setCrList(){  
        if (CrValue_fromMnPg == null)
            return null;
                        
        ExpressionUtils ExpUtils = new ExpressionUtils();
        SelectedCourseTableRows = new list<TableRow>();
       
        List<String> lst_crOption = CrValue_fromMnPg.split(';');
        List<String> lst_crOptionId = CrId_fromMnPg.split(';');                
       
        for (integer icnt = 0 ; icnt < lst_crOption.size();icnt++ ){                  
            if (icnt+1 == optionNumber){
                List<String> lst_crtieriaValue = lst_crOption.get(icnt).trim().split(' ');
                List<String> lst_crtieriaId = lst_crOptionId.get(icnt).trim().split(' ');                                 
                
                integer cntCVal=0;                
                for (integer i = 0 ; i < lst_crtieriaId.size(); ){                   
                    if (ExpUtils.isOperator(lst_crtieriaId.get(i))){
                        SelectedCourseTableRows.Add(new TableRow(lst_crtieriaId.get(i)));
                        cntCVal++; 
                        i++;
                    }
                    else{   
                        //if course code has space in between
                        String cCode_tmp = '';
                        while (! ExpUtils.isOperator(lst_crtieriaId.get(i))){                      
                            cCode_tmp = cCode_tmp + ' ' + lst_crtieriaId.get(i).trim();
                            i++;
                            if (i == lst_crtieriaId.size() ){                              
                                break;
                            }
                        }                               
                                        
                        string rType='';
                        if (cCode_tmp.startsWith('CC_'))
                            rType= 'Course';
                        else
                            rType = 'Certification';
                    
                        String cVal = '';
                        //while (! ExpUtils.isOperator(lst_crtieriaValue.get(cntCVal))){                      
                        while (! ( lst_crtieriaValue.get(cntCVal) == '[OR]' || lst_crtieriaValue.get(cntCVal) == '[AND]')){                      
                            cVal = cVal + ' ' + lst_crtieriaValue.get(cntCVal).trim();
                            //cVal = lst_crtieriaValue.get(cntCVal).trim();
                            cntCVal++;
                            if (cntCVal == lst_crtieriaValue.size() ){                              
                                break;
                            }
                        }                           
                        if (cVal != '')               
                            SelectedCourseTableRows.Add(new TableRow(cVal,cCode_tmp,false,rType));
                    }
                }               
            } //if            
        }//for 1        
        MakeSame_SelectedTables('Modify');    
        return null;
    }
    
    public pageReference addSelectedCourses(){          
        try{
            integer rowCnt = 0;
            for(TableRow tr : SearchTableRows){
                if(tr.isSelected){                      
                    if(! SelectedCourseTableRows.isEmpty())
                        SelectedCourseTableRows.Add(new TableRow('OR'));
                        
                    SelectedCourseTableRows.Add(new TableRow(tr.trName,tr.trCode, false, tr.RowType));
                    rowCnt++;
                    tr.isSelected = false;
                }
            }

            if(rowCnt == 0){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterAddError));
            }
            MakeSame_SelectedTables('Modify');
        }
        catch(Exception e){
            ApexPages.addmessages(e);       
        }       
        chkSelectAll = false;
        return null;
    }  

    public pageReference saveCriteria_close(){
        isSave = 'Save_Close';
        saveSelCriteria('Modify');
        return null;
    }
    public pageReference saveCriteria(){
        isSave = 'Save';
        saveSelCriteria('Modify');
        return null;
    }
    public pageReference saveCriteria_addTab(){
        isSave = 'Save';
        saveSelCriteria('Add');
        return null;
    }
    public pageReference saveCriteria_close_addTab(){
        isSave = 'Save_Close';
        saveSelCriteria('Add');
        return null;
    }
    public void saveSelCriteria(String tabName){
        try{        
            selCriteriaValue = '';
            selCriteriaId = '';
            
            if (tabName == 'Add')
                MakeSame_SelectedTables('Add');             
            else
                MakeSame_SelectedTables('Modify');  
            
            for(TableRow row : SelectedCourseTableRows){    
                    if (selCriteriaValue == '')
                        selCriteriaValue = row.trName;  
                    else{
                        if (row.RowType == 'Operand')
                            selCriteriaValue = selCriteriaValue + ' [' + row.trName + ']';
                        else
                            selCriteriaValue = selCriteriaValue + ' ' + row.trName ;                
                         
                    }
                    
                    if (row.RowType == 'Operand')
                        selCriteriaId = selCriteriaId + ' ' + row.trName;   
                    else
                        selCriteriaId = selCriteriaId + ' ' + row.trCode;   
            }   
                
            if (fromPage == 'Add' && optionNumber == -1){
                if (CrValue_fromMnPg != ''){
                    CrValue_fromMnPg = CrValue_fromMnPg + ' ; '+ selCriteriaValue;
                    CrId_fromMnPg = CrId_fromMnPg + ' ; '+ selCriteriaId;
                }
                else{
                    CrValue_fromMnPg =  selCriteriaValue;
                    CrId_fromMnPg = selCriteriaId;
                }
                
                optionNumber = CrValue_fromMnPg.split(';').size();
            }
            else{
            
                List<String> lst_crOption = CrValue_fromMnPg.split(';');
                List<String> lst_crOptionId = CrId_fromMnPg.split(';');
                
                CrValue_fromMnPg = '';
                CrId_fromMnPg = '';                          
                for (integer icnt = 0 ; icnt < lst_crOption.size();icnt++ ){                    
                    if (icnt+1 == optionNumber ){
                        if (CrValue_fromMnPg != ''){
                            CrValue_fromMnPg = CrValue_fromMnPg + ' ; ' + selCriteriaValue;
                            CrId_fromMnPg = CrId_fromMnPg + ' ; ' + selCriteriaId;
                        }
                        else{
                            CrValue_fromMnPg =  selCriteriaValue;
                            CrId_fromMnPg = selCriteriaId;
                        }                       
                    }
                    else{
                        if (CrValue_fromMnPg != ''){
                            CrValue_fromMnPg = CrValue_fromMnPg + ' ; ' + lst_crOption.get(iCnt);
                            CrId_fromMnPg = CrId_fromMnPg + ' ; ' + lst_crOptionId.get(iCnt);
                        }
                        else{
                            CrValue_fromMnPg =  lst_crOption.get(iCnt);
                            CrId_fromMnPg = lst_crOptionId.get(iCnt);
                        }                               
                    }                  
                }//for 1
            }       
        }
        catch(Exception e){
            ApexPages.addMessages(e);        
        }
        chkSelectAll = false;
    }        
    public pageReference doSearch(){ 
        SearchTableRows = new List<TableRow>();
        if(search_course != ''){
            string queryName = '%' + search_course + '%';
            if(RowType == 'Course'){  
                List<Course__c> course_results = [select id, Name, Course_Name__c, Course_Type__c, Course_Modality__c,
                                                    Course_Description__c, Course_Id__c,Course_Code__c
                                                    from Course__c
                                                    where Course_Name__c like :queryName
                                                    and Course_Code__c <> 'INVALID CODE'
                                                    limit 100];                
                
                if(!course_results.isEmpty()){
                    NoRecordsFound_add = false;
                    for(Course__c c : course_results)
                        SearchTableRows.add(new TableRow(c,false));                   
                }
                else{
                    NoRecordsFound_add = true;
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
                }
            }
            else {
                List<Certification_Requirement_Setup__c>  cert_results = [select id, name, Certification_Name__c, Prerequisites__c, 
                                                    Acquisition__c, Apply_Requirement_To__c                                                 
                                                    from Certification_Requirement_Setup__c
                                                    where Certification_Name__c like :queryName
                                                    limit 100];                             
                if(!cert_results.isEmpty()){                
                    NoRecordsFound_add = false;
                    for(Certification_Requirement_Setup__c c : cert_results)
                        SearchTableRows.add(new TableRow(c,false));
                }
                else{
                    NoRecordsFound_add = true;
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
                }
            }
        }
        else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterSearchError));
        }       
        chkSelectAll = false;
        return null;
    }
    
    public pageReference doSearch_Modify(){
        SearchTableRows_modify = new List<TableRow>();
        if(search_course_Modify != ''){
            string queryName = '%' + search_course_Modify + '%';
            if(RowType_modify == 'Course'){  
                List<Course__c> course_results = [select id, Name, Course_Name__c, Course_Type__c, Course_Modality__c,
                                                    Course_Description__c, Course_Id__c,Course_Code__c
                                                    from Course__c
                                                    where Course_Name__c like :queryName
                                                    and Course_Code__c <> 'INVALID CODE'
                                                    limit 100];
                if(!course_results.isEmpty()){   
                    NoRecordsFound_modify = false;
                    for(Course__c c : course_results)
                        SearchTableRows_modify.add(new TableRow(c,false));                   
                }
                else{
                    NoRecordsFound_modify = true;
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
                }
            }
            else{
                List<Certification_Requirement_Setup__c>  cert_results = [select id, name, Certification_Name__c, Prerequisites__c, 
                                                    Acquisition__c, Apply_Requirement_To__c                                                 
                                                    from Certification_Requirement_Setup__c
                                                    where Certification_Name__c like :queryName
                                                    limit 100];             
                
                if(!cert_results.isEmpty()){
                    NoRecordsFound_modify = false;
                    for(Certification_Requirement_Setup__c c : cert_results)
                        SearchTableRows_modify.add(new TableRow(c,false));
                }
                else{
                    NoRecordsFound_modify = true;
                    //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
                }
            }
        }
        else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterSearchError));

        } 
        chkSelectAll = false;
        return null;        
    }
  
    public pageReference delSelectedCourse(){   
        Set<integer> rowsToDelete  = new Set<integer>();
        integer cnt=0;        
        for(Integer i=0; i < SelectedCourseTableRows_del.size() ; i=i+2){
            if(SelectedCourseTableRows_del.get(i).isSelected){ 
                cnt=1;
                rowsToDelete.add(i);
                if(SelectedCourseTableRows_del.size()>1){                    
                    if(i==0)                     
                        rowsToDelete.add(i+1);  
                    else
                        rowsToDelete.add(i-1);  
                }                
            }       
        }
        if(cnt==0){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_CourseCert_Modify));
        }
        List<TableRow> DelTableRows = new List<TableRow>();
        DelTableRows = SelectedCourseTableRows_del;
         
        SelectedCourseTableRows_del = new List<TableRow>();
        for(Integer i=0 ; i < DelTableRows.size() ; i++){
            if(! rowsToDelete.contains(i)){
                SelectedCourseTableRows_del.add(DelTableRows.get(i));
            }
        }
        MakeSame_SelectedTables('Delete');    
        chkSelectAll = false;
        return null;
    }    
    public pageReference modSelectedCourse(){       
        TableRow selTRow ; 
        integer j=0,cnt=0;        
        for (TableRow tr : SearchTableRows_modify){              
            if (tr.isSelected){                
                selTRow = tr;
                j=1;
                tr.isSelected = false;
                break;
            }
        }       
        if(j==1){
            for(Integer i=0; i < SelectedCourseTableRows.size() ; i=i+2){
                if(SelectedCourseTableRows.get(i).isSelected){ 
                    cnt=1;
                    SelectedCourseTableRows.set(i, selTRow);
                    SelectedCourseTableRows.get(i).isSelected = false;
                }                
            }
            if(cnt==0){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_CourseCert_Modify));
            }           
            MakeSame_SelectedTables('Modify'); 
        }
        else{       
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterModifyError));
        }
        chkSelectAll = false;
        return null;
    }
    public void MakeSame_SelectedTables(string tabName){
        if (tabName == 'Modify'){
            SelectedCourseTableRows_del = new list<TableRow>();
            SelectedCourseTableRows_Add = new list<TableRow>();
            for (TableRow tr : SelectedCourseTableRows){
                SelectedCourseTableRows_del.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedCourseTableRows_Add.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }       
        }
        else if (tabName == 'Delete'){
            SelectedCourseTableRows = new list<TableRow>();
            SelectedCourseTableRows_Add = new list<TableRow>();
            for (TableRow tr : SelectedCourseTableRows_del){
                SelectedCourseTableRows.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedCourseTableRows_Add.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }
        }
        else{
            SelectedCourseTableRows = new list<TableRow>();
            SelectedCourseTableRows_del = new list<TableRow>();
            for (TableRow tr : SelectedCourseTableRows_Add){
                SelectedCourseTableRows.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedCourseTableRows_del.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }
        }
    }
    public List<TableRow> getSearchTableRows(){
        return SearchTableRows;
    }    
    public List<TableRow> getSearchTableRows_modify(){
        return SearchTableRows_modify;
    }    
    public boolean getSelectedCourseEmpty(){
        return SelectedCourseTableRows.isEmpty();
    }   
    public boolean getSearchCourseEmpty(){
        return SearchTableRows.isEmpty();
    }
    public boolean getSearchCourseModify_Empty(){     
        return SearchTableRows_modify.isEmpty();
    }
    public List<TableRow> getSelectedCourses(){ 
        return SelectedCourseTableRows;
    }
    public List<TableRow> getSelectedCourses_del(){     
        return SelectedCourseTableRows_del;
    }
    public List<TableRow> getSelectedCourses_Add(){         
        return SelectedCourseTableRows_Add;
    }
}