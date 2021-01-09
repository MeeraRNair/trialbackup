/*

Name            Date                    Purpose
Rahul Mishra    10th July-2018          Code Reduce!

*/


public with sharing class CallPlan_NewEventCntlr {

    public List<Call_Plan_Template__c> templates {get;set;} 
    Map<String, Call_Plan_Template__c> mapOfTemplates = new Map<String,Call_Plan_Template__c>();
    Map<String, List<Call_Plan_Template__c>> mapOfTemplatesWFolder = new Map<String,List<Call_Plan_Template__c>>();
    public String selectedTemplateId{get;set;}
    public Event evRec{get;set;}
    public Call_Plan_Template__c callPlan{get;set;}
    String oppId;
    String callPlanRTid;
    public boolean displayPopup{get;set;}
    public boolean isTemplate{get;set;} 
    string retUrl;
    public integer reminder {get;set;}
    public boolean chkReminder {get; set;}
    public boolean blnShowTemplates {get; set;}
    private datetime stDate;
    public string whoType {get; set;}
    public boolean disableInpWhatId {get; set;}
    public string LeadPhone {get; set;}
    public string LeadEmail {get; set;}
            
    public void setstDate(datetime d) {
        stDate = d;
    }
            
    public datetime getstDate() {
        return stDate;
    }
     
    public CallPlan_NewEventCntlr(ApexPages.StandardController controller){
        disableInpWhatId = false;
        
        String whoId = ApexPages.currentPage().getParameters().get('who_id');
       
        oppId = ApexPages.currentPage().getParameters().get('what_id');
        callPlanRTid = ApexPages.currentPage().getParameters().get('RecordType');
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        templates = new List<Call_Plan_Template__c>();
        callPlan = new Call_Plan_Template__c(); 
        displayPopup = false;
        
        evRec = new Event();
        evRec.RecordTypeId = callPlanRTid ;        
        evRec.ShowAs = 'busy'; 
        evRec.OwnerId = UserInfo.getUserId();
        
        datetime currDate = datetime.now();
        datetime sDate = datetime.newInstance (currDate.year(), currDate.month(), currDate.day(), currDate.hour()+1 , 0, 0) ;
        evRec.StartDateTime = sDate;        
        evRec.EndDateTime = sDate.addhours(1);
        
       if (oppId != ''){
            evRec.WhatId = oppId;           
        }
        try{        
            if (whoId != '' && oppId == ''){                
                evRec.whoId = whoId;  
                List<Contact> con = [select id,accountid from contact where id =:whoid LIMIT 1];
                if(con!= null)                
                evRec.WhatId = con[0].AccountId;              
              //  disableInpWhatId = true;       
                list<Lead> l = [select email, phone from Lead where id = :whoId];
                if ( l != null ){
                    LeadEmail = l[0].email;
                    LeadPhone = l[0].Phone;
                }
            }
        }
        catch(System.Exception e){
        } 
        chkReminder =true;       
        blnShowTemplates = true;
    }

    public PageReference showTemplates(){     
        mapOfTemplates = new Map<String,Call_Plan_Template__c>();
        mapOfTemplatesWFolder = new Map<String,List<Call_Plan_Template__c>>();
        templates = new List<Call_Plan_Template__c>();  
        for(Call_Plan_Template__c temp: [SELECT Id, name, Description__c, folder__c 
                                            FROM Call_Plan_Template__c
                                            Where Folder__c = 'Public Call Plan Templates' 
                                            or (Folder__c <> 'Public Call Plan Templates' and OwnerId= :UserInfo.getUserId() )]){
            mapOfTemplates.put(temp.id,temp);
            if(mapOfTemplatesWFolder.containsKey(temp.folder__c)){
                mapOfTemplatesWFolder.get(temp.folder__c).add(temp);
            }else{
                mapOfTemplatesWFolder.put(temp.folder__c, new List<Call_Plan_Template__c>{temp});
            }                    
        }//end of for
        templates = mapOfTemplatesWFolder.get('Public Call Plan Templates');
        if (templates == null)
            blnShowTemplates = false;
        else
            blnShowTemplates = true;
            
        callPlan.Folder__c = 'Public Call Plan Templates';      
        displayPopup = true;        
        return null;
    }

    public PageReference refreshPage(){     
        
        templates = mapOfTemplatesWFolder.get(callPlan.folder__c);
        if (templates == null)
            blnShowTemplates = false;
        else
            blnShowTemplates = true;
        return null;
    }

    public PageReference selectTemplate(){
        isTemplate = false;     
        if(mapOfTemplates.containsKey(selectedTemplateId)){            
            Call_Plan_Template__c cptRec = [select id, name, OwnerId,  Agenda__c, Call_Rating__c, Description__c, Draft_your_email__c, End_in_Mind__c, Folder__c,
                            How_will_you_respond_1__c, How_will_you_respond_2__c, How_will_you_respond_3__c, How_will_you_respond_4__c,
                            Key_Belief_1__c, Key_Belief_2__c, Key_Belief_3__c, Key_Belief_4__c, Key_Belief_5__c, Key_Belief_6__c, Key_Belief_7__c, Key_Belief_8__c,
                            Key_Belief_Action_1__c, Key_Belief_Action_2__c, Key_Belief_Action_3__c, Key_Belief_Action_4__c, Key_Belief_Action_5__c, Key_Belief_Action_6__c,
                            Key_Belief_Action_7__c, Key_Belief_Action_8__c,
                            Location__c, Next_Steps__c, Opening_Statement__c, Outcome__c, Questions_They_Might_Ask_You_1__c, Questions_They_Might_Ask_You_2__c,
                            Questions_They_Might_Ask_You_3__c, Questions_They_Might_Ask_You_4__c, Questions_You_Want_to_Ask_1__c, Questions_You_Want_to_Ask_2__c,
                            Questions_You_Want_to_Ask_3__c, Questions_You_Want_to_Ask_4__c, Type__c, 
                            Yellow_Light_1__c, Yellow_Light_2__c, Yellow_Light_3__c,Yellow_Light_4__c,
                            Yellow_Light_5__c, Yellow_Light_6__c, Yellow_Light_7__c, Yellow_Light_8__c,
                            Yellow_Light_Response_1__c, Yellow_Light_Response_2__c,Yellow_Light_Response_3__c,Yellow_Light_Response_4__c,
                            Yellow_Light_Response_5__c,Yellow_Light_Response_6__c,Yellow_Light_Response_7__c,Yellow_Light_Response_8__c
                         from Call_Plan_Template__c
                         where id = :selectedTemplateId ];                 
                                
            evRec.OwnerId = UserInfo.getUserId();  
            evRec.Location =  cptRec.Location__c;           
            evRec.Type = cptRec.Type__c;            
            evRec.End_in_Mind__c = cptRec.End_in_Mind__c;
            evRec.Next_Steps__c = cptRec.Next_Steps__c;
            evRec.Opening_Statement__c = cptRec.Opening_Statement__c;
            evRec.Outcome__c = cptRec.Outcome__c;
            evRec.Agenda__c = cptRec.Agenda__c;
            evRec.Call_Rating__c = cptRec.Call_Rating__c;
            evRec.Draft_your_email__c = cptRec.Draft_your_email__c ;
            evRec.How_will_you_respond_1__c = cptRec.How_will_you_respond_1__c;
            evRec.How_will_you_respond_2__c = cptRec.How_will_you_respond_2__c;
            evRec.How_will_you_respond_3__c = cptRec.How_will_you_respond_3__c;
            evRec.How_will_you_respond_4__c = cptRec.How_will_you_respond_4__c;
            
            evRec.Key_Belief_1__c = cptRec.Key_Belief_1__c;
            evRec.Key_Belief_2__c = cptRec.Key_Belief_2__c;
            evRec.Key_Belief_3__c = cptRec.Key_Belief_3__c;
            evRec.Key_Belief_4__c = cptRec.Key_Belief_4__c;
            evRec.Key_Belief_5__c = cptRec.Key_Belief_5__c;
            evRec.Key_Belief_6__c = cptRec.Key_Belief_6__c;
            evRec.Key_Belief_7__c = cptRec.Key_Belief_7__c;
            evRec.Key_Belief_8__c = cptRec.Key_Belief_8__c;
            
            evRec.Key_Belief_Actions_1__c = cptRec.Key_Belief_Action_1__c;
            evRec.Key_Belief_Actions_2__c = cptRec.Key_Belief_Action_2__c;
            evRec.Key_Belief_Actions_3__c = cptRec.Key_Belief_Action_3__c;
            evRec.Key_Belief_Actions_4__c = cptRec.Key_Belief_Action_4__c;
            evRec.Key_Belief_Actions_5__c = cptRec.Key_Belief_Action_5__c;
            evRec.Key_Belief_Actions_6__c = cptRec.Key_Belief_Action_6__c;
            evRec.Key_Belief_Actions_7__c = cptRec.Key_Belief_Action_7__c;
            evRec.Key_Belief_Actions_8__c = cptRec.Key_Belief_Action_8__c;
            
            
            evRec.Questions_They_Might_Ask_You_1__c = cptRec.Questions_They_Might_Ask_You_1__c;
            evRec.Questions_They_Might_Ask_You_2__c = cptRec.Questions_They_Might_Ask_You_2__c;
            evRec.Questions_They_Might_Ask_You_3__c = cptRec.Questions_They_Might_Ask_You_3__c;
            evRec.Questions_They_Might_Ask_You_4__c = cptRec.Questions_They_Might_Ask_You_4__c;
            
            evRec.Questions_You_Want_to_Ask_1__c = cptRec.Questions_You_Want_to_Ask_1__c;
            evRec.Questions_You_Want_to_Ask_2__c = cptRec.Questions_You_Want_to_Ask_2__c;
            evRec.Questions_You_Want_to_Ask_3__c = cptRec.Questions_You_Want_to_Ask_3__c;
            evRec.Questions_You_Want_to_Ask_4__c = cptRec.Questions_You_Want_to_Ask_4__c;
            
            evRec.Yellow_Light_1__c = cptRec.Yellow_Light_1__c;
            evRec.Yellow_Light_2__c = cptRec.Yellow_Light_2__c;
            evRec.Yellow_Light_3__c = cptRec.Yellow_Light_3__c;
            evRec.Yellow_Light_4__c = cptRec.Yellow_Light_4__c;
            evRec.Yellow_Light_5__c = cptRec.Yellow_Light_5__c;
            evRec.Yellow_Light_6__c = cptRec.Yellow_Light_6__c;
            evRec.Yellow_Light_7__c = cptRec.Yellow_Light_7__c;
            evRec.Yellow_Light_8__c = cptRec.Yellow_Light_8__c;
            
            evRec.Yellow_Light_Response_1__c = cptRec.Yellow_Light_Response_1__c;
            evRec.Yellow_Light_Response_2__c = cptRec.Yellow_Light_Response_2__c;
            evRec.Yellow_Light_Response_3__c = cptRec.Yellow_Light_Response_3__c;
            evRec.Yellow_Light_Response_4__c = cptRec.Yellow_Light_Response_4__c;
            evRec.Yellow_Light_Response_5__c = cptRec.Yellow_Light_Response_5__c;
            evRec.Yellow_Light_Response_6__c = cptRec.Yellow_Light_Response_6__c;
            evRec.Yellow_Light_Response_7__c = cptRec.Yellow_Light_Response_7__c;
            evRec.Yellow_Light_Response_8__c = cptRec.Yellow_Light_Response_8__c;
                        
            evRec.Template_Id__c = selectedTemplateId;
            evRec.Call_Plan_Template_Name__c = mapOfTemplates.get(selectedTemplateId).Name;
             
            displayPopup = false;
            templates.clear();
        }
        return null;
    }
    
    public PageReference closePopup(){
        displayPopup = false;
        if (templates != null) 
            templates.clear();
        return null;
    }

    public PageReference cancel(){
        return new PageReference(retUrl);
    }
    
    public void saveRec(){
         if (chkReminder == true){
            evRec.ReminderDateTime = evRec.StartDateTime.addMinutes((0-reminder ));
            evrec.IsReminderSet = true;
        }                      
        
        try{
            upsert(evRec);
        }
        catch(DMLException ex){
            evRec.whoid = null;
            upsert(evRec);
        }
    }
     public PageReference save() {
      
        try {
            if (disableInpWhatId == true)
                evRec.whatId = null;
            saveRec();     
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);            
        }      
        //return (new ApexPages.StandardController(evRec)).view();    
        return new PageReference(retUrl);
    }      
    
    public PageReference saveAndNewTask(){
        
        try {
            saveRec();
            if (oppId == '')
                oppId = evRec.WhatId;
            Schema.DescribeSObjectResult describeResult = Task.getSObjectType().getDescribe();
            PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Task&retURL=' + retUrl 
                                                    + '&save_new_url=%2F' + describeResult.getKeyPrefix()
                                                    + '%2Fe%3Fwho_id%3D' +  evRec.OwnerId
                                                    + '%26what_id%3D' +  oppId
                                                    + '%26retURL%3D' + pageUtils.encodeVariable(retUrl));
            pr.setRedirect(true);
            return pr;   
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);    
            return null;        
        }     
    }
    
    public PageReference saveAndNewEvent(){
        try {
            saveRec();
             if (oppId == '')
                oppId = evRec.WhatId;
            Schema.DescribeSObjectResult describeResult = Event.getSObjectType().getDescribe();            
            //PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Event&retURL=' + retUrl+ '&save_new_url=' + describeResult.getKeyPrefix() + '&what_id=' + oppId);
            PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp?ent=Event&retURL=' + retUrl 
                                                    + '&save_new_url=%2F' + describeResult.getKeyPrefix()
                                                    + '%2Fe%3Fwho_id%3D' +  evRec.OwnerId
                                                    + '%26what_id%3D' +  oppId
                                                    + '%26retURL%3D' + pageUtils.encodeVariable(retUrl));
            pr.setRedirect(true);
            return pr;   
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);    
            return null;        
        }     
    }
    
    public PageReference RefreshEndDateTime(){
        evRec.EndDateTime =  stDate.addhours(1);
        return null;
    }
    
    public PageReference RefreshWhoType(){
        if (whoType == 'Lead')
            disableInpWhatId = true;
        else{
            disableInpWhatId = false;
            //evRec.whoid = null;
        }
        return null;
    } 

}