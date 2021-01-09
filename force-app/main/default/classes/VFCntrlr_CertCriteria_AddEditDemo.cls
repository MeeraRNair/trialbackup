public class VFCntrlr_CertCriteria_AddEditDemo { 
    public String CrValue_fromMnPg{get;set;}
    public String CrId_fromMnPg {get;set;}
    public String selCriteriaValue{get;set;}
    public String selCriteriaId {get;set;}
    
    public String isSave {get; set;} 
    public String fromPage{get;set;}    
    public integer optionNumber {get;set;}  
    public String search_demo{get;set;}
    public String search_demo_Modify{get;set;}   
    public boolean chkSelectAll {get; set;}
    public boolean NoRecordsFound_add {get;set;}
    public boolean NoRecordsFound_modify {get;set;}
    
        
    //Table Row Class for initiallising values.
    public class TableRow{          
        public Demo_Unit_Setup__c demo {get;set;}
        public string trName{get;set;}        
        public string trCode{get;set;}
        public Boolean isSelected{get;set;}
        public String RowType{get;set;}
                
        public TableRow(Demo_Unit_Setup__c c, boolean sel){   

            demo = c;
            isSelected = sel;
            RowType = 'Demo';


            trName = c.name;
            trCode = c.id;           
        }   
        public TableRow(String cName,String cCode, boolean sel){
            isSelected = sel;
            RowType = 'Demo';
            trName = cName;
            trCode = cCode;  

            demo = null;
        }                
        public TableRow(String opd){
            isSelected = false;  
            RowType = 'Operand';
            trName = opd;
            trCode = opd;     

            demo = null;
        }
        public TableRow(String cName,String cCode, boolean sel, String rType){
            isSelected = sel;   
            RowType = rType;
            trName = cName;
            trCode = cCode;

            demo = null;
        }       
    }
    list<TableRow> SearchTableRows = new list<TableRow>();
    list<TableRow> SearchTableRows_modify = new list<TableRow>();
    
    list<TableRow> SelectedDemoTableRows = new list<TableRow>();
    list<TableRow> SelectedDemoTableRows_del = new list<TableRow>();
    list<TableRow> SelectedDemoTableRows_Add = new list<TableRow>();
    
    public VFCntrlr_CertCriteria_AddEditDemo(){        
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
            NoRecordsFound_add=false;
            NoRecordsFound_modify=false;
            
        }
        catch(Exception e){  
            ApexPages.addmessages(e);   
        } 
    }
    
    public PageReference setCrList(){       
        if (CrValue_fromMnPg == null)
            return null;
            
        ExpressionUtils ExpUtils = new ExpressionUtils();       
        SelectedDemoTableRows = new list<TableRow>();
        
        List<String> lst_crOption = CrValue_fromMnPg.split(';');
        List<String> lst_crOptionId = CrId_fromMnPg.split(';');     
        
        for (integer icnt = 0 ; icnt < lst_crOption.size();icnt++ ){                  
            if (icnt+1 == optionNumber){
                List<String> lst_crtieriaValue = lst_crOption.get(icnt).trim().split(' ');
                List<String> lst_crtieriaId = lst_crOptionId.get(icnt).trim().split(' ');    
                
                integer cntCVal=0;                
                for (integer i = 0 ; i < lst_crtieriaId.size();i++ ){
                    if (ExpUtils.isOperator(lst_crtieriaId.get(i))){
                        SelectedDemoTableRows.Add(new TableRow(lst_crtieriaId.get(i)));
                        cntCVal++;  
                    }
                    else{               
                        String cVal = '';
                        while (! ExpUtils.isOperator(lst_crtieriaValue.get(cntCVal))){                      
                            cVal = cVal + ' ' + lst_crtieriaValue.get(cntCVal).trim();
                            cntCVal++;
                            if (cntCVal == lst_crtieriaValue.size() ){                              
                                break;
                            }
                        }                           
                        if (cVal != '')               
                            SelectedDemoTableRows.Add(new TableRow(cVal,lst_crtieriaId.get(i),false));
                    }
                }               
            } //if            
        }//for 1
        MakeSame_SelectedTables('Modify');          
        return null;
    }
    
    public pageReference addSelectedDemo(){          
        try{

        Integer  rowCnt = 0;
            for(TableRow tr : SearchTableRows){
                if(tr.isSelected){                      


                    if(! SelectedDemoTableRows.isEmpty())
                        SelectedDemoTableRows.Add(new TableRow('OR'));
                    
                    SelectedDemoTableRows.Add(new TableRow(tr.trName,tr.trCode, false));                


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
            

            for(TableRow row : SelectedDemoTableRows){                           
                    selCriteriaValue = selCriteriaValue + ' ' + row.trName;  
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
        if(search_demo != ''){
            string queryName = '%' + search_demo + '%';

            List<Demo_Unit_Setup__c> demo_results = [select id, Name, Active__c                                               
                                                        from Demo_Unit_Setup__c
                                                        where Name like :queryName
                                                        limit 100];
        
            SearchTableRows = new List<TableRow>();
            if(!demo_results.isEmpty()){
                NoRecordsFound_add = false;
                for(Demo_Unit_Setup__c c : demo_results)
                    SearchTableRows.add(new TableRow(c,false));
            }
            else{
                NoRecordsFound_add = true;
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
            }
        }
        else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterSearchError));            
        }
        chkSelectAll = false;
        return null;
    }
    
    public pageReference doSearch_Modify(){        
        if(search_demo_Modify != ''){           
            string queryName = '%' + search_demo_Modify + '%';

            List<Demo_Unit_Setup__c> demo_results = [select id, Name, Active__c                                               
                                                        from Demo_Unit_Setup__c
                                                        where Name like :queryName
                                                        limit 100];
        
            SearchTableRows_modify = new List<TableRow>();
            if(!demo_results.isEmpty()){
                NoRecordsFound_modify = false;
                for(Demo_Unit_Setup__c c : demo_results)
                    SearchTableRows_modify.add(new TableRow(c,false));
            }
            else{
                NoRecordsFound_modify = true;
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_NoRecs));
            }
        }
        else{
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_MasterSearchError));
        }       
        chkSelectAll = false;
        return null;
    }
  
    public pageReference delSelecteddemo(){   
        Set<integer> rowsToDelete  = new Set<integer>(); 
        integer cnt=0;
        for(Integer i=0; i < SelectedDemoTableRows_del.size() ; i=i+2){
            if(SelectedDemoTableRows_del.get(i).isSelected){
                cnt=1;
                rowsToDelete.add(i);
                if(SelectedDemoTableRows_del.size()>1){                    
                    if(i==0)                     
                        rowsToDelete.add(i+1);  
                    else
                        rowsToDelete.add(i-1);  
                }                
            }       
        }
        if(cnt==0){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_Demo_Modify));
        }
        List<TableRow> DelTableRows = new List<TableRow>();
        DelTableRows = SelectedDemoTableRows_del;
         
        SelectedDemoTableRows_del = new List<TableRow>();
        for(Integer i=0 ; i < DelTableRows.size() ; i++){
            if(! rowsToDelete.contains(i)){
                SelectedDemoTableRows_del.add(DelTableRows.get(i));
            }
        }
        MakeSame_SelectedTables('Delete');    
        chkSelectAll = false;
        return null;
    }    
    public pageReference modSelecteddemo(){       
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
            for(Integer i=0; i < SelectedDemoTableRows.size() ; i=i+2){
                if(SelectedDemoTableRows.get(i).isSelected){
                    cnt=1;
                    SelectedDemoTableRows.set(i, selTRow);
                    SelectedDemoTableRows.get(i).isSelected = false;
                }                
            }
            if(cnt==0){
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,System.Label.NetExam_Demo_Modify));
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
            SelectedDemoTableRows_del = new list<TableRow>();
            SelectedDemoTableRows_Add = new list<TableRow>();

            for (TableRow tr : SelectedDemoTableRows){
                SelectedDemoTableRows_del.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedDemoTableRows_Add.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }       
        }
        else if (tabName == 'Delete'){
            SelectedDemoTableRows = new list<TableRow>();
            SelectedDemoTableRows_Add = new list<TableRow>();
            for (TableRow tr : SelectedDemoTableRows_del){
                SelectedDemoTableRows.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedDemoTableRows_Add.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }
        }
        else{
            SelectedDemoTableRows = new list<TableRow>();
            SelectedDemoTableRows_del = new list<TableRow>();
            for (TableRow tr : SelectedDemoTableRows_Add){
                SelectedDemoTableRows.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
                SelectedDemoTableRows_del.Add(new TableRow(tr.trName,tr.trCode,tr.isSelected,tr.RowType));
            }
        }
    }
    public List<TableRow> getSearchTableRows(){
        return SearchTableRows;
    }
    public List<TableRow> getSearchTableRows_modify(){
        return SearchTableRows_modify;
    }
    public boolean getSelecteddemoEmpty(){
        return SelectedDemoTableRows.isEmpty();
    }   
    public boolean getSearchdemoEmpty(){
        return SearchTableRows.isEmpty();
    }
    public boolean getSearchdemoModify_Empty(){     
        return SearchTableRows_modify.isEmpty();
    }
        public List<TableRow> getSelectedDemos(){ 

        return SelectedDemoTableRows;
    }
    public List<TableRow> getSelectedDemos_del(){     

        return SelectedDemoTableRows_del;
    }
    public List<TableRow> getSelectedDemos_Add(){     

        return SelectedDemoTableRows_Add;
    }
}