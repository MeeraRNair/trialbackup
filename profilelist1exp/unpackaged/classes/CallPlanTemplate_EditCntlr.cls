public with sharing class CallPlanTemplate_EditCntlr {

     public Call_Plan_Template__c ctRec {get; set;}
     Id EventId ;
     private ApexPages.StandardController sController;
     private String queryString;
     public boolean ErrorFlag {get; set;}
     private string retURL ='';
     
     public CallPlanTemplate_EditCntlr(ApexPages.StandardController controller){
        ErrorFlag = false;
        sController = controller;
        List<string> pageUrl = ApexPages.currentPage().getUrl().split('\\?');  
        queryString = pageUrl[1];
        
        EventId = ApexPages.currentPage().getParameters().get('eventId');
        String ct = ApexPages.currentPage().getParameters().get('templateId');
        string act = ApexPages.currentPage().getParameters().get('action');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if ((retURL == null || retURL == '') && EventId != null){
            retURL = string.valueof(EventId);            
        }
        
        id ctid;
        if (ct != '' && ct != null){
            ctid =  string.valueof(ct) ;
            List<UserRecordAccess> uList = [select recordid from UserRecordAccess 
                                              Where UserId = :UserInfo.getUserId()
                                              And recordid = :ctid
                                              And HasEditAccess = true];
              if (uList.isEmpty()){
                  ErrorFlag = true;
              }
        }
        else{
            if ( ! Schema.sObjectType.Call_Plan_Template__c.isCreateable())
                ErrorFlag = true;
        }
                       
        system.debug ('#### DEBUG ### : Template Id : ' + ctid);
        
        if (ctid == null ){
            ctRec  = new Call_Plan_Template__c() ;
        }
        else{
        
            List<Call_Plan_Template__c>  ctRecList = [select name, OwnerId,  Agenda__c, Call_Rating__c, Description__c, Draft_your_email__c, End_in_Mind__c, Folder__c,
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
                         where id = :ctid ];  
            if (! ctRecList.isEmpty())
                 ctRec = ctRecList.get(0);
          }
                         
          Event evRec = [select Agenda__c, Call_Rating__c,  Draft_your_email__c, End_in_Mind__c, type,Location,
                            How_will_you_respond_1__c, How_will_you_respond_2__c, How_will_you_respond_3__c, How_will_you_respond_4__c,
                            Key_Belief_1__c, Key_Belief_2__c, Key_Belief_3__c, Key_Belief_4__c, Key_Belief_5__c, Key_Belief_6__c, Key_Belief_7__c, Key_Belief_8__c,
                            Key_Belief_Actions_1__c, Key_Belief_Actions_2__c, Key_Belief_Actions_3__c, Key_Belief_Actions_4__c, 
                            Key_Belief_Actions_5__c, Key_Belief_Actions_6__c,
                            Key_Belief_Actions_7__c, Key_Belief_Actions_8__c,
                             Next_Steps__c, Opening_Statement__c, Outcome__c, Questions_They_Might_Ask_You_1__c, Questions_They_Might_Ask_You_2__c,
                            Questions_They_Might_Ask_You_3__c, Questions_They_Might_Ask_You_4__c, Questions_You_Want_to_Ask_1__c, Questions_You_Want_to_Ask_2__c,
                            Questions_You_Want_to_Ask_3__c, Questions_You_Want_to_Ask_4__c,  
                            Yellow_Light_1__c, Yellow_Light_2__c, Yellow_Light_3__c,Yellow_Light_4__c,
                            Yellow_Light_5__c, Yellow_Light_6__c, Yellow_Light_7__c, Yellow_Light_8__c,
                            Yellow_Light_Response_1__c, Yellow_Light_Response_2__c,Yellow_Light_Response_3__c,Yellow_Light_Response_4__c,
                            Yellow_Light_Response_5__c,Yellow_Light_Response_6__c,Yellow_Light_Response_7__c,Yellow_Light_Response_8__c
                            from Event
                         where id = :Eventid ];
            
            if (ctRec != null){
            
                ctRec.Agenda__c =   evRec.Agenda__c;
                ctRec.type__c =   evRec.type;
                 ctRec.Location__c =   evRec.Location;
                ctrec.Call_Rating__c = evrec.Call_Rating__c;
                ctRec.Draft_your_email__c =   evRec.Draft_your_email__c;
                ctRec.End_in_Mind__c =   evRec.End_in_Mind__c;            
                ctRec.How_will_you_respond_1__c =   evRec.How_will_you_respond_1__c;
                ctRec.How_will_you_respond_2__c =   evRec.How_will_you_respond_2__c;
                ctRec.How_will_you_respond_3__c =   evRec.How_will_you_respond_3__c;
                ctRec.How_will_you_respond_4__c =   evRec.How_will_you_respond_4__c;
                ctRec.Key_Belief_1__c =   evRec.Key_Belief_1__c;
                ctRec.Key_Belief_2__c =   evRec.Key_Belief_2__c;
                ctRec.Key_Belief_3__c =   evRec.Key_Belief_3__c;
                ctRec.Key_Belief_4__c =   evRec.Key_Belief_4__c;
                ctRec.Key_Belief_5__c =   evRec.Key_Belief_5__c;
                ctRec.Key_Belief_6__c =   evRec.Key_Belief_6__c;
                ctRec.Key_Belief_7__c =   evRec.Key_Belief_7__c;
                ctRec.Key_Belief_8__c =   evRec.Key_Belief_8__c;
                
                ctRec.Key_Belief_Action_1__c =   evRec.Key_Belief_Actions_1__c;
                ctRec.Key_Belief_Action_2__c =   evRec.Key_Belief_Actions_2__c;
                ctRec.Key_Belief_Action_3__c =   evRec.Key_Belief_Actions_3__c;
                ctRec.Key_Belief_Action_4__c =   evRec.Key_Belief_Actions_4__c;
                ctRec.Key_Belief_Action_5__c =   evRec.Key_Belief_Actions_5__c;
                ctRec.Key_Belief_Action_6__c =   evRec.Key_Belief_Actions_6__c;
                ctRec.Key_Belief_Action_7__c =   evRec.Key_Belief_Actions_7__c;
                ctRec.Key_Belief_Action_8__c =   evRec.Key_Belief_Actions_8__c;
                
                ctRec.Yellow_Light_1__c =   evRec.Yellow_Light_1__c;
                ctRec.Yellow_Light_2__c =   evRec.Yellow_Light_2__c;
                ctRec.Yellow_Light_3__c =   evRec.Yellow_Light_3__c;
                ctRec.Yellow_Light_4__c =   evRec.Yellow_Light_4__c;
                ctRec.Yellow_Light_5__c =   evRec.Yellow_Light_5__c;
                ctRec.Yellow_Light_6__c =   evRec.Yellow_Light_6__c;
                ctRec.Yellow_Light_7__c =   evRec.Yellow_Light_7__c;
                ctRec.Yellow_Light_8__c =   evRec.Yellow_Light_8__c;
                
                ctRec.Yellow_Light_Response_1__c =   evRec.Yellow_Light_Response_1__c;
                ctRec.Yellow_Light_Response_2__c =   evRec.Yellow_Light_Response_2__c;
                ctRec.Yellow_Light_Response_3__c =   evRec.Yellow_Light_Response_3__c;
                ctRec.Yellow_Light_Response_4__c =   evRec.Yellow_Light_Response_4__c;
                ctRec.Yellow_Light_Response_5__c =   evRec.Yellow_Light_Response_5__c;
                ctRec.Yellow_Light_Response_6__c =   evRec.Yellow_Light_Response_6__c;
                ctRec.Yellow_Light_Response_7__c =   evRec.Yellow_Light_Response_7__c;
                ctRec.Yellow_Light_Response_8__c =   evRec.Yellow_Light_Response_8__c;
                
                
                ctRec.Questions_They_Might_Ask_You_1__c =   evRec.Questions_They_Might_Ask_You_1__c;
                ctRec.Questions_They_Might_Ask_You_2__c =   evRec.Questions_They_Might_Ask_You_2__c;
                ctRec.Questions_They_Might_Ask_You_3__c =   evRec.Questions_They_Might_Ask_You_3__c;
                ctRec.Questions_They_Might_Ask_You_4__c =   evRec.Questions_They_Might_Ask_You_4__c;
                ctRec.Questions_You_Want_to_Ask_1__c =   evRec.Questions_You_Want_to_Ask_1__c;
                ctRec.Questions_You_Want_to_Ask_2__c =   evRec.Questions_You_Want_to_Ask_2__c;
                ctRec.Questions_You_Want_to_Ask_3__c =   evRec.Questions_You_Want_to_Ask_3__c;
                ctRec.Questions_You_Want_to_Ask_4__c =   evRec.Questions_You_Want_to_Ask_4__c;
                
                ctRec.Next_Steps__c =   evRec.Next_Steps__c;
                ctRec.Opening_Statement__c =   evRec.Opening_Statement__c;
                ctRec.Outcome__c =   evRec.Outcome__c;
            }            
     }
     
     public Pagereference SaveAndNew(){
         try {
            upsert(ctRec);
            Schema.DescribeSObjectResult describeResult = sController.getRecord().getSObjectType().getDescribe();
            PageReference pr = new PageReference('/apex/CallPlanTemplate_edit?eventId='+Eventid
                                                    + '&action=New');
                            
            pr.setRedirect(true);
            return pr;   
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);    
            return null;        
        }     
        
        
        //return (new ApexPages.StandardController(new Call_Plan_Template__c())).edit();      
     }
     
     public PageReference save() {
        try {
            upsert(ctRec);
            return new PageReference('/' + ctRec.id + '?retURL='+ retURL);
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);            
        }      
        //return (new ApexPages.StandardController(ctRec)).view();     
        return null;
    }      
    
     public PageReference cancel() {
         return new PageReference('/' + Eventid );                    
    }  
     
     
}