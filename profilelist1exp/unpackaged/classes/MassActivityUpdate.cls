/***********************************************************
* Name          : MassActivityUpdate
* Description   : Controller for MassActivityUpdate
* Created By    : Krishnakumar Manoharan. User Story SIMP 1300 and SIMP 1250   
*/
public with sharing class MassActivityUpdate{

private List<ActivityDTO> activityParent;
public List<ActivityDTO> activityList25 {get;set;}
    
private Map<id,Task> taskMap;
private Map<id,Event> eventMap;    

public Boolean showTable {get; set;}
public integer totalRec {get;set;} 

//Pagination...
private integer pageSize=25;    
public integer totalPages {get;set;}    
public Integer pageNum{get;set;} 
public Boolean showPagination {get;set;}
private Boolean isSavedSuccessfully = true;    

    public MassActivityUpdate() {
        initParent();       
    }
    
    private void initParent(){
        List<Task> taskList = [SELECT ActivityDate,Description,Id,OwnerId,Status,Subject,Type,WhatId,owner.name,what.name FROM Task where IsClosed=false and ownerId= :UserInfo.getUserId() order by activityDate];
        List<Event> eventList = [SELECT ActivityDate,Description,Id,OwnerId,Subject,Type,WhatId,owner.name,what.name,StartDateTime,IsAllDayEvent FROM Event where StartDateTime >= TODAY and ownerId= :UserInfo.getUserId() order by StartDateTime];
        showPagination = false;
        if(taskList.isempty() && eventList.isEmpty()){
        showTable = false; 
        totalRec = 0;        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records to display.'));   
        }else{
            ActivityDTO activityDTO;
            activityParent = new List<ActivityDTO>();
            activityList25 = new List<ActivityDTO>();
            showTable = true; 
            pageNum=1;
            for(Task taskObj:taskList){
                activityDTO = new ActivityDTO(taskObj,null,true,false,false,taskObj.ActivityDate);
                activityParent.add(activityDTO);
            }
            for(Event eventRec:eventList){
                activityDTO = new ActivityDTO(null,eventRec,false,false,false,eventRec.StartDateTime.date());
                activityParent.add(activityDTO);
            }
            if(activityParent.size()>0){
                totalRec = activityParent.size();
                activityParent.sort();
                if(totalRec>pageSize){
                    showPagination = true;
                }
                initActivity25();
            }
            Decimal dtotalPages;
            dtotalPages = totalRec/pageSize;
            dtotalPages = Math.floor(dtotalPages) + ((Math.mod(totalRec, pageSize)>0) ? 1 : 0);
            totalPages = Integer.valueOf(dtotalPages);
        }
    }
    
    public void initActivity25(){
        Integer startingRec = getStartPageRecords();
        Integer endingRec = getEndPageRecords();
        activityList25.clear();
        ActivityDTO actObj = null;        
        for(Integer x=startingRec;x<=endingRec;x++){
            actObj = new ActivityDTO();
            actObj.taskRec = activityParent.get(x-1).taskRec;
            actObj.eventRec = activityParent.get(x-1).eventRec;
            actObj.isTask = activityParent.get(x-1).isTask;
            actObj.sortinDate = activityParent.get(x-1).sortinDate;
            actObj.isError = false;
            actObj.isModified = false;
            activityList25.add(actObj);
        }
    }
    
    public Integer getStartPageRecords(){
            Integer StartPageRecords;
            if(pageNum == 1){
                StartPageRecords = 1;
            }
            else{
                StartPageRecords = ((pageNum-1) * pageSize) + 1;
            }
                                      
            return StartPageRecords;  
    }
    
    public Integer getEndPageRecords(){ 
        integer EndPageRecords;
        EndPageRecords = pageNum*pageSize;
        if(this.totalRec < EndPageRecords){
           EndPageRecords = this.totalRec;
        }  
        return EndPageRecords; 
    }

    public PageReference cancelAndReturn() {
        /*string retURL = ApexPages.currentPage().getParameters().get('retURL');
        string nonce = ApexPages.currentPage().getParameters().get('nonce');
        string iframeOrg = ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin');
        string isdtp = ApexPages.currentPage().getParameters().get('isdtp');    
        system.debug('---isdtp'+isdtp);
        system.debug('---nonce--'+nonce);
        system.debug('---sfdcIFrameOrigin-'+iframeOrg);

        PageReference newPage =new PageReference('/apex/ActivitiesTab'); 
        if(nonce !=null)
        newPage.getParameters().put('nonce', nonce);
        if(iframeOrg !=null)
        newPage.getParameters().put('sfdcIFrameOrigin', iframeOrg); 
        if(isdtp != null)
        newPage.getParameters().put('isdtp', 'nv'); */
        PageReference newPage =new PageReference('/apex/ActivitiesTab'); 
        newPage.setRedirect(true);
        return newPage;
    }

    public PageReference saveAndReturn(){
        try{
            List<Sobject> dtoList = new List<Sobject>();
            Map<ID,Boolean> successIds = new Map<ID,Boolean>(); 
            Boolean gblError = false;
            Boolean reqError = false;
            isSavedSuccessfully = true;
            for(ActivityDTO dtoObj:activityList25){
                if(dtoObj.isModified){
                    gblError = false;
                    if(dtoObj.isTask){
                        if(String.isEmpty(dtoObj.taskRec.type)){
                            dtoObj.taskRec.type.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Type: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                        if(String.isEmpty(dtoObj.taskRec.Subject)){
                            dtoObj.taskRec.Subject.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subject: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                        if(dtoObj.taskRec.ActivityDate==null){
                            dtoObj.taskRec.ActivityDate.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Due Date: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                        if(!gblError){
                            dtoList.add(dtoObj.taskRec);
                        }else{
                            isSavedSuccessfully = false;
                            reqError = true;
                        }
                     }else{
                        //system.debug('StartDateTime for all day event---'+dtoObj.eventRec.StartDateTime+'--'+dtoObj.eventRec.ActivityDate);
                        if(dtoObj.eventRec.IsAllDayEvent){
                            dtoObj.eventRec.StartDateTime=dtoObj.eventRec.ActivityDate;
                        }
                        if(String.isEmpty(dtoObj.eventRec.type)){
                            dtoObj.eventRec.type.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Type: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                        if(String.isEmpty(dtoObj.eventRec.Subject)){
                            dtoObj.eventRec.Subject.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subject: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                        if(dtoObj.eventRec.StartDateTime==null){
                            dtoObj.eventRec.StartDateTime.addError('You must enter a value');
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Due Date: You must enter a value'));
                            gblError = true;
                            dtoObj.isError=true;
                        }
                         if(!gblError){
                             dtoList.add(dtoObj.eventRec);
                         }else{
                             isSavedSuccessfully = false;
                             reqError = true;
                         }                              
                    }
                }
            }
            system.debug('****No. of records got modified'+dtoList.size());
            if(!dtoList.isEmpty()){
                Database.SaveResult[] results = Database.update(dtoList,false);
                for(Integer i=0; i < results.size();i++){
                    if (!results.get(i).isSuccess()) {
                        isSavedSuccessfully = false;
                        for(Database.Error err : results.get(i).getErrors()) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
                        }
                        successIds.put(results.get(i).getId(),false);
                    }else{
                            system.debug('Record successfully saved...'+results.get(i).getId());
                            successIds.put(results.get(i).getId(),true);
                        //activityList25.get(i).isModified = false;
                        //activityList25.get(i).isError = false;
                     }   
                }
                System.debug('Required Error is there--'+reqError);
                System.debug(successIds);
                                
                if(isSavedSuccessfully && !reqError){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success: All modified records have been updated successfully. To return to your Activities Home Page, click Cancel, or to continue with Mass Updates, choose another page of records.'));
                }
            }
            if(!successIds.isEmpty()){
                    refreshTable(successIds);
             }

        } catch(Exception e){
                system.debug('Exeception occured--'+e.getLineNumber()+'--'+e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, + e.getMessage()));
            }   
       return null;
    }

    public class ActivityDTO implements Comparable{
        public Task taskRec {get;set;}
        public Event eventRec {get;set;}
        public Boolean isTask {get;set;}
        public Boolean isModified {get;set;}
        public Boolean isError {get;set;}
        private Date sortinDate {get;set;}
        
        private ActivityDTO(){
            
        }
        public ActivityDTO(Task taskObj,Event evntObj,Boolean isItTask, Boolean isModified,Boolean isError,Date sortinDate){
            this.taskRec=taskObj;
            this.eventRec=evntObj;
            this.isTask=isItTask;
            this.isModified=isModified;
            this.isError=isError;
            this.sortinDate=sortinDate;
        }
        
        public Integer compareTo(Object o) {
            ActivityDTO wrapObj= (ActivityDTO) o;
            if (this.sortinDate > wrapObj.sortinDate) return 1;
            else return -1;            
        }   
        
    }
    
    
    private void refreshTable(Map<id,Boolean> modifiedIds){
       for(ActivityDTO dtoObj:activityList25){
           if(dtoObj.isTask && modifiedIds.containsKey(dtoObj.TaskRec.id)){
               if(modifiedIds.get(dtoObj.TaskRec.id)){
                   dtoObj.isModified = false;
                   dtoObj.isError = false;
               }else{
                   dtoObj.isModified = true;
                   dtoObj.isError = true;
               }
              system.debug('Modified Ids--'+dtoObj.TaskRec.id+' Modified-'+dtoObj.isModified+'--Error--'+dtoObj.isError);               
           }else if(!dtoObj.isTask && modifiedIds.containsKey(dtoObj.EventRec.id)){
               if(modifiedIds.get(dtoObj.EventRec.id)){
                   dtoObj.isModified = false;
                   dtoObj.isError = false;
               }else{
                   dtoObj.isModified = true;
                   dtoObj.isError = true;
               }
           }              
       }
    }
    
    public Component.Apex.outputPanel getPageNumLinks1(){
        return getPageNumLinks();
    }
    
    public Component.Apex.outputPanel getPageNumLinks() {
        if(!showPagination){
            return null;
        }
        Component.Apex.outputPanel opPanel = new Component.Apex.outputPanel();

        Integer page1 = 1;
        Integer page2 = 2;
        Integer page3 = 3;
        
        if(pageNum <=2){
            page1 = 1;
        }else if(pageNum == totalPages){
            page1 = pageNum-2;
        }else{
            page1 = pageNum-1;
        }
        
        if(pageNum == 1) {
            page2=2;
        }else if(pageNum == totalPages && totalPages !=2){
            page2=totalPages-1;
        }else{
            page2=pageNum;
        } 
        
        if(pageNum == 1){
            page3= 3;
        }else if(pageNum == totalPages){
            page3 = totalPages;
        }else{
            page3 = pageNum + 1;
        }

        if ( pageNum > 3) { 
            Component.Apex.outputText endDot = new Component.Apex.outputText();
            endDot.value = '... | ';        
            opPanel.childComponents.add(endDot);
        }
        
        for (integer i=0;i<3;i++) {
            if(i>3){
                Component.Apex.outputText startDot = new Component.Apex.outputText();
                startDot.value = '...';        
                opPanel.childComponents.add(startDot);
            }
            Component.Apex.commandLink lnk = new Component.Apex.commandLink();

            if(i==0){
                lnk.value = page1;
                lnk.onclick = 'javascript:selectedPageNum('+page1+');return false;';
                lnk.rendered = true;
            }else if(i==1){
                lnk.value = page2;
                lnk.onclick = 'javascript:selectedPageNum('+page2+');return false;';
                lnk.rendered = true;
            }else if(i==2){
                lnk.value = page3;
                lnk.onclick = 'javascript:selectedPageNum('+page3+');return false;';
                if(totalPages >2){
                    lnk.rendered = true;
                }else{
                    lnk.rendered = false;
                }                
            }
            
            //lnk.immediate=true;

            opPanel.childComponents.add(lnk);
            if(i !=2 ){
                Component.Apex.outputText pipeSym = new Component.Apex.outputText();
                pipeSym.value = '  |  ';        
                opPanel.childComponents.add(pipeSym);    
            }
        }

        if ( pageNum < totalPages-1 && totalPages >3) { 
            Component.Apex.outputText endDot = new Component.Apex.outputText();
            endDot.value = '...';        
            opPanel.childComponents.add(endDot);
        }
        return opPanel;
    }    
    
    public Component.Apex.outputPanel getPageNaviLinks1() {
        return getPageNaviLinks();
    }
    
    public Component.Apex.outputPanel getPageNaviLinks() {
        if(!showPagination){
            return null;
        }
        Component.Apex.outputPanel opPanel = new Component.Apex.outputPanel();

        if(pageNum !=1){
            Component.Apex.commandLink firstLink = new Component.Apex.commandLink();
            firstLink.value = 'First';
            firstLink.rendered = true;
            //firstLink.immediate= true;
            //firstLink.expressions.action = '{!First}';
            firstLink.onclick = 'javascript:setFirstPage();return false;';
            opPanel.childComponents.add(firstLink);
            
            Component.Apex.outputText pipeSym = new Component.Apex.outputText();
            pipeSym.value = '  |  ';        
            opPanel.childComponents.add(pipeSym); 
            
            Component.Apex.commandLink prevLink = new Component.Apex.commandLink();
            prevLink.value = 'Previous';
            prevLink.rendered = true;
            //prevLink.immediate= true;
            //prevLink.expressions.action = '{!Previous}';
            prevLink.onclick = 'javascript:setPrevPage();return false;';
            opPanel.childComponents.add(prevLink);
            if ( pageNum < totalPages) { 
                Component.Apex.outputText pipeSym1 = new Component.Apex.outputText();
                pipeSym1.value = '  |  ';       
                opPanel.childComponents.add(pipeSym1);
            }
        }
        
        if(pageNum !=totalPages){
            Component.Apex.commandLink nextLink = new Component.Apex.commandLink();
            nextLink.value = 'Next';
            nextLink.rendered = true;
            //nextLink.immediate= true;
            //nextLink.expressions.action = '{!Next}';
            nextLink.onclick = 'javascript:setNextPage();return false;';
            opPanel.childComponents.add(nextLink);            
            
            Component.Apex.outputText pipeSym = new Component.Apex.outputText();
            pipeSym.value = '  |  ';        
            opPanel.childComponents.add(pipeSym);
            
            Component.Apex.commandLink lastLink = new Component.Apex.commandLink();
            lastLink.value = 'Last';
            lastLink.rendered = true;
            //lastLink.immediate= true;
            //lastLink.expressions.action = '{!Last}';
            lastLink.onclick = 'javascript:setLastPage();return false;';
            opPanel.childComponents.add(lastLink);
            
        }
        return opPanel;
    }
    
    public PageReference First(){
        system.debug('First page is called.');
        pageNum = 1;
        initActivity25();
        return null;        
    }

    public PageReference Last(){
        system.debug('Last page is called.');
        pageNum = totalPages;
        initActivity25();
        return null;        
    }

    public PageReference Next(){
        system.debug('Next page is called.');
        pageNum = pageNum+1;
        initActivity25();
        return null;        
    }

    public PageReference Previous(){
        system.debug('Previous page is called.');
        pageNum = pageNum-1;
        initActivity25();
        return null;        
    }    

    public PageReference refreshGrid() { //user clicked a page number    
        initActivity25();
        return null;
    }
    
    public PageReference SaveAndRefresh() { //user clicked a page number        
        string pageNo = Apexpages.currentPage().getParameters().get('pageNumber');
        saveAndReturn();
        system.debug('Is it saved succesfully--'+isSavedSuccessfully);
        if(isSavedSuccessfully){
            if('NEXT'.equalsIgnoreCase(pageNo)){
                pageNum = pageNum+1;
            }else  if('FIRST'.equalsIgnoreCase(pageNo)){
                pageNum = 1;
            }else  if('LAST'.equalsIgnoreCase(pageNo)){
                pageNum = totalPages;
            }else  if('PREV'.equalsIgnoreCase(pageNo)){
                pageNum = pageNum-1;
            }else{
                pageNum = Integer.valueOf(pageNo);
            }
            initActivity25();
        }  
        
        return null;
    }
}