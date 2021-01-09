/*
REVISION HISTORY
========================================================================================================
Version     Author          Date            Release#        CR#         Description
-------     ------          ----            --------        ---         -----------
1.0         Harikrishna     August-2013     14.10           8400        Start versioning.
1.1         Sree Prakash    17 Jan 2014     15.03           9042        Modified code for Competency - Master Program Setup with AND/OR functionality.
1.2         Kishore D       01Oct 2015      16.10           11993       Add the new 3 competencies values for all competencies drop down values with acceptencies order
1.3         Kishore D       02Oct 2015      16.10           11952       removing the 5 competencies values for all competencies drop down values with acceptencies order
======================================================================================================== 
*/

global class SelectComptncyNameControler {
    public List<competencyWrapper> competencyList{get;set;}
    public List<competencyAddWrapper> competencyAdd{get;set;}
    public Boolean operatorRender{get;set;}
    public String operatorSelected{get;set;}
    public String selectedTab{get;set;}
    private string recordId;
    public List<selectOption> competencyOperator{get;set;}
    public Boolean renderPanel{get;set;}
    public boolean delay = false;
    set<string> competenciesAdded=new set<string>();
    
    public SelectComptncyNameControler (){
        operatorRender=false;
        
        competencyAdd=new List<competencyAddWrapper>();
        recordId=ApexPages.currentPage().getParameters().get('id');
        selectedTab=ApexPages.currentPage().getParameters().get('tab');
        competencyOperator=new List<SelectOption>();
        competencyOperator.add(new SelectOption('OR','OR'));
        competencyOperator.add(new SelectOption('AND','AND'));
       // renderPanel=recordId==null?false:true;
       
       if(recordId==null){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'Pass the Master Setup Program record id to view the Page!!'));
           return ;           
       }
       renderPanel=true;
        
       if(selectedTab=='modify'){
            String competencyValue=[select CompetencyName2__c from Master_Program_Setup__c where Id=:recordId].CompetencyName2__c;
            system.debug('---#####-----'+competencyValue);
            list<string> splitCompetencyWithOperator;
            
            if(   competencyValue!='' && competencyValue!=null){
            List<string> splitCompetencyValues=competencyValue.split(';');
            string compName;
            
                for(String str:splitCompetencyValues){
                    system.debug('--------------------'+str);
                   if(str.contains(' AND') || str.contains(' OR')){
                       if(str.contains(' AND')){
                          compName=str.subString(0,str.indexOf(' AND'));                      
                          competencyAdd.add(new competencyAddWrapper(compName,'AND')); 
                       }
                       else{
                          compName=str.subString(0,str.indexOf(' OR'));
                          competencyAdd.add(new competencyAddWrapper(compName,'OR')); 
                       }
                       competenciesAdded.add(compName.trim());                       
                   }
                   else{    
                       // with no operator
                       competencyAdd.add(new competencyAddWrapper(str.trim(),''));  
                       competenciesAdded.add(str.trim());
                   }               
                }
            }
        }
        if(competencyList==null){
            competencyList=new List<competencyWrapper>();
            Master_Program_Setup__c lst=[Select id, Apply_Requirement_To__c, Region__c from Master_Program_Setup__c where id =: recordId];
            fillCompetencyList(lst.Apply_Requirement_To__c, lst.Region__c);
        }
    }

    public PageReference close(){
        if(recordId!=null && recordId!='')
            //return new PageReference('/'+recordId);
            return new PageReference('/apex/MasterProgramSetup?id='+recordId);
            return null;
    }

    public PageReference saveandclose(){
       saveCompetency();
       if(recordId!=null && recordId!='')
            //return new PageReference('/'+recordId);
            return new PageReference('/apex/MasterProgramSetup?id='+recordId);
            return null;
    }

    public PageReference save(){
        saveCompetency();
        return null;
    }
    
    public PageReference add(){
    
        if(competencyList.size()>0){
            List<competencyWrapper> tempCompWrapper=competencyList;
            competencyList=new List<competencyWrapper>();
            boolean compChecked = false;
            for(competencyWrapper cmWrap:tempCompWrapper){
                if(cmWrap.selected){
                     competencyAdd.add(new competencyAddWrapper(cmWrap.competencyName,''));
                     compChecked = true;
                     //continue;
                }
                cmWrap.selected = false;
                competencyList.add(cmWrap);               
            }
            
            system.debug('Test--competencyAdd.size() : ' + competencyAdd.size());
            
            if(competencyAdd.size() == 0 || compChecked == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Please select a Competency'));
            }

            system.debug('----list render on page-----'+competencyAdd);
            if(competencyAdd.size()>0 && competencyAdd!=null)
                operatorRender=true;
        }
        return null;
    }
    
    global class competencyWrapper implements Comparable{
        public Boolean selected{get;set;}
        public String competencyName{get;set;}
        public competencyWrapper(Boolean selected,String competencyName){
            this.selected=selected;
            this.competencyName=competencyName;
        }
         
        global Integer compareTo(Object objToCompare){
            return competencyName.compareTo(((competencyWrapper)objToCompare).competencyName);
        }
    }
    
    global class competencyAddWrapper{
        public String competencyName{get;set;}
        public String operator{get;set;} 
        public Boolean isSelected{get;set;}
        
        public competencyAddWrapper(String competencyName,String operator){
            competencyName = competencyName.replace('(', '');
            competencyName = competencyName.replace(')', ''); 
            competencyName = competencyName.replace('\'', '');           
            this.competencyName = competencyName;            
            this.operator=operator;
            this.isSelected=false;
       }      
    }
    
    public void saveCompetency(){
        Master_Program_Setup__c masterProg=new Master_Program_Setup__c();
        string competencyName='', competencyNamewithoutOperand='', competencyEndsWith = '';
        Integer counter=0,wrapperSize=competencyAdd.size();

        if(wrapperSize == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Please select a Competency'));
        }
                
        for(competencyAddWrapper compAdd:competencyAdd){
            counter++;
            system.debug('Test--compAdd.competencyName : '+compAdd.competencyName);
            system.debug('Test--compAdd.operator : '+compAdd.operator);
            system.debug('Test--compAdd.competencyName : '+ compAdd.operator + compAdd.competencyName + compAdd.operator );
            system.debug('Test--competencyName : '+ competencyName);

            
            if(counter != wrapperSize){
                if(compAdd.operator == 'AND'){
                    competencyName += ' (' + compAdd.competencyName + ' ' + compAdd.operator + '; ';
                }
                
                else if(competencyName.contains('AND') && competencyName.endsWith('AND; ') == true){
                    competencyName += compAdd.competencyName + ') ' + ' ' + compAdd.operator + '; ';
                }
            
                else{
                    competencyName += '\'' + compAdd.competencyName + '\'' + ' ' + compAdd.operator + '; ';
                }
                competencyNamewithoutOperand += compAdd.competencyName + ';';
            }
            else{
                if(competencyName.endsWith('AND; ') == true){
                    competencyName += compAdd.competencyName + ')';
                    competencyNamewithoutOperand+=compAdd.competencyName;
                }
                else{
                    competencyName += '\'' + compAdd.competencyName + '\'' + '';
                    competencyNamewithoutOperand+=compAdd.competencyName;                    
                }
            }
        }
        system.debug(competencyName + '4444444444' + competencyNamewithoutOperand);

        if(!competencyName.contains('AND')){
            competencyName = competencyName.replace(')', ' ');
        }
        if(competencyName.contains('AND;  (')){
            competencyName = competencyName.replace('AND;  (', 'AND; ');
        }
        
        competencyName = competencyName.replace('  ', ' ');        
        competencyName = competencyName.replace('( ', '(');
        competencyName = competencyName.replace('\'\'', '\'');
        competencyName = competencyName.replace('OR; \' ', 'OR; \'');
        competencyNamewithoutOperand = competencyNamewithoutOperand.replace('\'', '');
        system.debug(competencyName + '4444444444' + competencyNamewithoutOperand);

        
        if(competencyName!=null && competencyNamewithoutOperand!=null){
            try
            {
               // Update for first formula field SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(CompetencyName1, 'AND;', 'AND'), 'OR;', 'OR'), "'", "")    
               string competencyF1= competencyName;                        
               competencyF1=competencyF1.replaceAll('AND;', 'AND');
               competencyF1=competencyF1.replaceAll('OR;', 'OR');
               competencyF1=competencyF1.replaceAll('\'', '');
               competencyF1=competencyF1.replaceAll('\'', '');
               
                // Update for second formula field SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(CompetencyName1, 'AND;', ';'), 'OR;', ','), "(", "'"), ")", "'")   
                string competencyF2= competencyName; 
                competencyF2=competencyF2.replaceAll('AND;', ';');
                competencyF2=competencyF2.replaceAll('OR;', ',');
                competencyF2=competencyF2.replaceAll('\\(', '\'');
                competencyF2=competencyF2.replaceAll('\\)', '\'');
                             
               update new Master_Program_Setup__c(Id=recordId, CompetencyName2__c=competencyName, 
                            Certification_Name__c=competencyNamewithoutOperand,Competency_FName__c=competencyF1, Competency_F1Name__c= competencyF2);
           
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,e.getMessage()));
            }            
        }
        

    }
    
    public PageReference doDelete(){
        List<competencyAddWrapper> tempcompetencyAdd=competencyAdd;
        competencyAdd=new List<competencyAddWrapper>();
        
        boolean compChecked = false;
        
        for(competencyAddWrapper cmAdd:tempcompetencyAdd){
            if(cmAdd.isSelected){
                //competencyList.add(new competencyWrapper(false,cmAdd.competencyName));
                compChecked = true;
                continue;
            }
            competencyAdd.add(cmAdd);
        }
        
        if(compChecked == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Please select a Competency'));
        }
        
        competencyList.sort();        
        return null;
    }
    
    public PageReference doReplace(){
        // Iterate over competency which is added
        string newCompetency = '';
        boolean compChecked = false;
        for(competencyWrapper cmWrap:competencyList){
            if(cmWrap.selected){
                newCompetency=cmWrap.competencyName;
                compChecked = true;
                break;
            }
        }

        if(compChecked == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Please select a Competency'));
        }
        
        // now replace the competency with added list
        string backToListString='';
        
        for(competencyAddWrapper compAdd:competencyAdd){
            if(compAdd.isSelected){
                backToListString=compAdd.competencyName;
                if(newCompetency!='')
                    compAdd.competencyName=newCompetency;
                    compAdd.isSelected=false;
                    break;
            }
        }          
           
        for(competencyWrapper cmWrap:competencyList){
            if(cmWrap.selected){
                if(backToListString!='')
                    cmWrap.competencyName=backToListString;
                    cmWrap.selected=false;
                    break;
            }
        }       

        
        return null;
    }
    
    public PageReference refreshList(){
        if(competencyList!=NULL){
            for(competencyWrapper cmWrap:competencyList){
                cmWrap.Selected=false;
            }        
        }
        if(competencyAdd!=NULL){
            for(competencyAddWrapper cm:competencyAdd){
                cm.isSelected=false;
            }        
        }
        return null;
    
    }
    
    public void fillCompetencyList(String applyRequirement, String region){
        system.debug('$$$$$$$$$$$'+competenciesAdded);
        /*adding and removing the competencies values with acceptencies order --kishore D*/
        if(applyRequirement=='Global' || applyRequirement=='Country'){
            string[] competencyArray=new string[]{'Storage',
                                                    'Server',
                                                    'Data Center Networking',
                                                    'Cloud Client-Computing',
                                                    'Cloud solutions',
                                                    'Client Solutions',
                                                    'Workstation',
                                                    'Microsoft Platform Management',
                                                    'Endpoint Management',
                                                    'Network Security',
                                                    'Identity and Access Management',
                                                    'Data Protection',
                                                    'PS Series Storage Deployment',
                                                    'SC Series Storage Deployment',        
                                                    'Networking',
                                                    'Big Data and Analytics',
                                                    'Solutions',
                                                    'EMEA-EM - Preferred Partner',
                                                    'Onboarding - LA English',
                                                    'Onboarding - LA Portuguese',
                                                    'Onboarding - LA Spanish',
                                                    'Client Deployment Services Competency',
                                                    'PowerEdge Servers Deployment Services Competency',
                                                    'Modular Infrastructure Deployment Services Competency',
                                                    'Client Data Security',
                                                    'OEM Solutions' ,
                                                    'Entry Level Storage',
                                                    'Campus Networking'};
                                                  
            for(integer i=0;i<competencyArray.size();i++){
                 if(!competenciesAdded.contains(competencyArray[i]))
                     competencyList.add(new competencyWrapper(false,competencyArray[i]));
            }
        }
        /*adding and removing the competencies values with acceptencies order --kishore D*/
        if(applyRequirement=='Region'){
            if(region=='APJ' || region=='Canada' || region=='EMEA' || region == 'US'){
                 string[] regionCompetencyArray=new string[]{'Storage',
                                                                'Server',
                                                                'Data Center Networking',
                                                                'Cloud Client-Computing',
                                                                'Cloud solutions',
                                                                'Client Solutions',
                                                                'Workstation',
                                                                'Microsoft Platform Management',
                                                                'Endpoint Management',
                                                                'Network Security',
                                                                'Identity and Access Management',
                                                                'Data Protection',
                                                                'PS Series Storage Deployment',
                                                                'SC Series Storage Deployment',        
                                                                'Networking',
                                                                'Big Data and Analytics',
                                                                'Solutions',
                                                                'Client Deployment Services Competency',
                                                                'PowerEdge Servers Deployment Services Competency',
                                                                'Modular Infrastructure Deployment Services Competency',
                                                                'Client Data Security',
                                                                'OEM Solutions',
                                                                'Entry Level Storage',
                                                                'Campus Networking'};
            
                for(integer i=0;i<regionCompetencyArray.size();i++){
                    if(!competenciesAdded.contains(regionCompetencyArray[i]))
                         competencyList.add(new competencyWrapper(false,regionCompetencyArray[i]));
                }
            }
            /*adding and removing the competencies values with acceptencies order --kishore D*/
            else 
            if(region=='EMEA-EM'){
                string[] emeaComp=new string[]{'Storage',
                                                'Data Center Networking',
                                                'Cloud Client-Computing',
                                                'Cloud solutions',
                                                'Client Solutions',
                                                'Workstation',
                                                'Microsoft Platform Management',
                                                'Endpoint Management',
                                                'Network Security',
                                                'Identity and Access Management',
                                                'Data Protection',
                                                'PS Series Storage Deployment',
                                                'SC Series Storage Deployment',        
                                                'Networking',
                                                'Big Data and Analytics',
                                                'EMEA-EM - Preferred Partner',
                                                'Client Deployment Services Competency',
                                                'PowerEdge Servers Deployment Services Competency',
                                                'Modular Infrastructure Deployment Services Competency',
                                                'Client Data Security',
                                                'OEM Solutions',
                                                'Entry Level Storage',
                                                'Campus Networking'};
            
                for(integer i=0;i<emeaComp.size();i++){
                     if(!competenciesAdded.contains(emeaComp[i]))
                         competencyList.add(new competencyWrapper(false,emeaComp[i]));
                }
            }
            /*adding and removing the competencies values with acceptencies order --kishore D*/
            else
            if(region=='LATAM'){
                string[] LATMComp=new string[]{'Storage',
                                                'Server',
                                                'Data Center Networking',
                                                'Cloud Client-Computing',
                                                'Client Solutions',
                                                'Microsoft Platform Management',
                                                'Endpoint Management',
                                                'Network Security',
                                                'Identity and Access Management',
                                                'Data Protection',
                                                'PS Series Storage Deployment',
                                                'SC Series Storage Deployment',        
                                                'Networking',
                                                'Big Data and Analytics',
                                                'Onboarding - LA English',
                                                'Onboarding - LA Portuguese',
                                                'Onboarding - LA Spanish',
                                                'Client Deployment Services Competency',
                                                'PowerEdge Servers Deployment Services Competency',
                                                'Modular Infrastructure Deployment Services Competency',
                                                'Client Data Security',
                                                'OEM Solutions',
                                                'Entry Level Storage',
                                                'Campus Networking'};
                                              
            
                for(integer i=0;i<LATMComp.size();i++){
                     if(!competenciesAdded.contains(LATMComp[i]))
                         competencyList.add(new competencyWrapper(false,LATMComp[i]));
                }              
            }        
        }
    }
}