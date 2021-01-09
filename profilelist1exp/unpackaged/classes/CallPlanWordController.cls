public class CallPlanWordController {

	
    private Event targetEvent;
    private Id eventId;

    public integer KeyBeliefMaxIndex {get; set;}
    public integer QuestionMaxIndex {get; set;}
    public integer YellowLightMaxIndex {get; set;}
    public string accountName;
    public string inviteesList;
    public string relatedToStr;

    Map<String, String> params = new Map<String, String>();

    //WARNING - Change before deploying to Production
    private string CALL_PLAN_RT_ID = IdLookupUtils.getRecordtypeId('Call Plan', 'Event', true);

    public CallPlanWordController(ApexPages.StandardController controller) {

        CALL_PLAN_RT_ID = IdLookupUtils.getRecordtypeId('Call Plan', 'Event', true);
        CALL_PLAN_RT_ID = CALL_PLAN_RT_ID.substring(0,15);

        params = ApexPages.currentPage().getParameters();

        for(string key : params.keySet())
            system.debug('########### Keys are ' + key);

        string whoId = params.get('who_id');

        if(whoId != null && whoId != '') {
            if(!params.get('who_id').startswith('003') && !params.get('who_id').startswith('00Q')) {
                system.debug('###DEBUG INVALID WHOID');
                params.put('who_id', '');
            }
        }


        targetEvent = (Event)controller.getRecord();
       // system.debug(targetEvent.What.Name + '    %%%%%%%%%%%%%%%%%%%%%%%%       ' + targetEvent.What.Type);
        targetEvent.OwnerId = UserInfo.getUserId();
        //targetEvent.StartDateTime = System.Now();
        eventId = targetEvent.Id;
        setInviteesList(eventId);
        //targetEvent.EndDateTime = System.Now();
        setAccountName(targetEvent.Id);
        setRelatedToStr(targetEvent);
        resetFieldSetIndexes();
    }

    public PageReference redirectForView() {
        System.debug('###DEBUG### RedirectForView' );
        params.remove('sfdc.override');
        params.remove('save_new');
        String paramsString = MapUtils.joinMap(params,'=','&');

        PageReference standardURL;
        if(targetEvent.Id == null) {
            standardURL = new PageReference('/00U?nooverride=1');
        } else {

            standardURL = new PageReference('/' + targetEvent.Id + '?nooverride=1&' + paramsString );
        }

        standardURL.setRedirect(true);

        //WARNING - Change before deploying to Production
        if(targetEvent.RecordTypeID != CALL_PLAN_RT_ID) {
            return standardURL;
        }

        return null;

    }

    public PageReference redirectForWord() {
        System.debug('###DEBUG### RedirectForWord' );
        //params.remove('sfdc.override');
        //params.remove('save_new');
       // String paramsString = MapUtils.joinMap(params,'=','&');

        PageReference standardURL;
        if(targetEvent.Id == null) {
            //change this
            standardURL = new PageReference('/apex/apex/CallPlanWordTest?Id=' + targetEvent.Id);
        } else {

            standardURL = new PageReference('/apex/CallPlanWordTest?Id=' + targetEvent.Id);
            system.debug('#########DEBUG STANDARD URL ' + standardURL.getUrl());
        }

        standardURL.setRedirect(true);

        //WARNING - Change before deploying to Production
        if(targetEvent.RecordTypeID != CALL_PLAN_RT_ID) {
            return standardURL;
        }

        return standardURL;

    }

    public PageReference redirectForEdit() {
        System.debug('###DEBUG### RedirectForEdit' );
        params.remove('sfdc.override');
        params.remove('save_new');

        String paramsString = MapUtils.joinMap(params,'=','&');
        PageReference standardURL;


        if(targetEvent.Id == null) {
            System.debug('###DEBUG### TargetEvent ID is NULL');
            //WARNING - Change before deploying to Production
            standardURL = new PageReference('/00U/e?nooverride=1&' + paramsString );

            if(params.get('RecordType') == null || params.get('RecordType') != CALL_PLAN_RT_ID) {
                return standardURL;
            }
        } else {
            System.debug('###DEBUG### RecordTypeId Mismatch - ' + targetEvent.RecordTypeID);
            standardURL = new PageReference('/' + targetEvent.Id  + '/e?nooverride=1&' + paramsString );
            //WARNING - Change before deploying to Production
            if(StringUtils.left(targetEvent.RecordTypeID,15) != CALL_PLAN_RT_ID) {
                return standardURL;
            }

        }

        return null;

    }

    public PageReference getPrint(){
        return redirectForWord();
    }

    public PageReference showMoreKeyBeliefFieldSet() {
        KeyBeliefMaxIndex  += 1;

        return null;
    }

    public PageReference showMoreQuestionFieldSet() {
        QuestionMaxIndex  += 1;

        return null;
    }

    public PageReference showMoreYellowLightFieldSet() {
        YellowLightMaxIndex  += 1;

        return null;
    }

    public void resetFieldSetIndexes() {
        /*
        if(targetEvent == null) {
            KeyBeliefMaxIndex = 1;
            QuestionMaxIndex = 1;
            YellowLightMaxIndex = 1;

            return;
        }
        */



        if(targetEvent.Id == null) {
            KeyBeliefMaxIndex = 1;
            QuestionMaxIndex = 1;
            YellowLightMaxIndex = 1;
        } else {
            List<Event> eventFieldsetList ;

            eventFieldsetList = [SELECT
                                Key_Belief_1__c,
                                Key_Belief_Actions_1__c,
                                Key_Belief_2__c,
                                Key_Belief_Actions_2__c,
                                Key_Belief_3__c,
                                Key_Belief_Actions_3__c,
                                Key_Belief_4__c,
                                Key_Belief_Actions_4__c,
                                Key_Belief_5__c,
                                Key_Belief_Actions_5__c,
                                Key_Belief_6__c,
                                Key_Belief_Actions_6__c,
                                Key_Belief_7__c,
                                Key_Belief_Actions_7__c,
                                Key_Belief_8__c,
                                Key_Belief_Actions_8__c,
                                Questions_They_Might_Ask_You_1__c,
                                Questions_You_Want_to_Ask_1__c,
                                How_will_you_respond_1__c,
                                Questions_They_Might_Ask_You_2__c,
                                Questions_You_Want_to_Ask_2__c,
                                How_will_you_respond_2__c,
                                Questions_They_Might_Ask_You_3__c,
                                Questions_You_Want_to_Ask_3__c,
                                How_will_you_respond_3__c,
                                Questions_They_Might_Ask_You_4__c,
                                Questions_You_Want_to_Ask_4__c,
                                How_will_you_respond_4__c,
                                Yellow_Light_1__c,
                                Yellow_Light_Response_1__c,
                                Yellow_Light_2__c,
                                Yellow_Light_Response_2__c,
                                Yellow_Light_3__c,
                                Yellow_Light_Response_3__c,
                                Yellow_Light_4__c,
                                Yellow_Light_Response_4__c,
                                Yellow_Light_5__c,
                                Yellow_Light_Response_5__c,
                                Yellow_Light_6__c,
                                Yellow_Light_Response_6__c,
                                Yellow_Light_7__c,
                                Yellow_Light_Response_7__c,
                                Yellow_Light_8__c,
                                Yellow_Light_Response_8__c
                            FROM Event
                            WHERE Id = :targetEvent.Id];

            if(eventFieldsetList .size() > 0) {
                //set yellow light
                if(targetEvent.Yellow_Light_8__c != null || targetEvent.Yellow_Light_Response_8__c != null) {
                    YellowLightMaxIndex = 8;
                } else if(targetEvent.Yellow_Light_7__c != null || targetEvent.Yellow_Light_Response_7__c != null) {
                    YellowLightMaxIndex = 7;
                } else if(targetEvent.Yellow_Light_6__c != null || targetEvent.Yellow_Light_Response_6__c != null) {
                    YellowLightMaxIndex = 6;
                } else if(targetEvent.Yellow_Light_5__c != null || targetEvent.Yellow_Light_Response_5__c != null) {
                    YellowLightMaxIndex = 5;
                } else if(targetEvent.Yellow_Light_4__c != null || targetEvent.Yellow_Light_Response_4__c != null) {
                    YellowLightMaxIndex = 4;
                } else if(targetEvent.Yellow_Light_3__c != null || targetEvent.Yellow_Light_Response_3__c != null) {
                    YellowLightMaxIndex = 3;
                } else if(targetEvent.Yellow_Light_2__c != null || targetEvent.Yellow_Light_Response_2__c != null) {
                    YellowLightMaxIndex = 2;
                } else {
                    YellowLightMaxIndex = 1;
                }

                //set key belief
               if(targetEvent.Key_Belief_8__c != null || targetEvent.Key_Belief_Actions_8__c != null) {
                   KeyBeliefMaxIndex = 8;
               } else if(targetEvent.Key_Belief_7__c != null || targetEvent.Key_Belief_Actions_7__c != null) {
                   KeyBeliefMaxIndex = 7;
               } else if(targetEvent.Key_Belief_6__c != null || targetEvent.Key_Belief_Actions_6__c != null) {
                   KeyBeliefMaxIndex = 6;
               } else if(targetEvent.Key_Belief_5__c != null || targetEvent.Key_Belief_Actions_5__c != null) {
                   KeyBeliefMaxIndex = 5;
               } else if(targetEvent.Key_Belief_4__c != null || targetEvent.Key_Belief_Actions_4__c != null) {
                   KeyBeliefMaxIndex = 4;
               } else if(targetEvent.Key_Belief_3__c != null || targetEvent.Key_Belief_Actions_3__c != null) {
                   KeyBeliefMaxIndex = 3;
               } else if(targetEvent.Key_Belief_2__c != null || targetEvent.Key_Belief_Actions_2__c != null) {
                   KeyBeliefMaxIndex = 2;
               } else {
                   KeyBeliefMaxIndex = 1;
               }

               //set question max key
               if(targetEvent.Questions_They_Might_Ask_You_4__c != null || targetEvent.Questions_You_Want_to_Ask_4__c != null || targetEvent.How_will_you_respond_4__c != null) {
                   QuestionMaxIndex = 4;
               } else if(targetEvent.Questions_They_Might_Ask_You_3__c != null || targetEvent.Questions_You_Want_to_Ask_3__c != null || targetEvent.How_will_you_respond_3__c != null) {
                   QuestionMaxIndex = 3;
               } else if(targetEvent.Questions_They_Might_Ask_You_2__c != null || targetEvent.Questions_You_Want_to_Ask_2__c != null || targetEvent.How_will_you_respond_2__c != null) {
                   QuestionMaxIndex = 2;
               } else {
                   QuestionMaxIndex = 1;
               }


            }

        }

    }

    public string getAccountName(){
        return accountName;
    }

    public String getDisplayProperty(string isDisplay)
   {
       return (isDisplay == null || isDisplay == '') ? 'none' : '';
   }

    public void setAccountName(string eventId){
        string accountId = '';
        List<Event> eventAccountIdList = [Select e.Id, e.AccountId From Event e where e.Id = : eventId];
        if(eventAccountIdList!= null && eventAccountIdList.size() > 0){
            accountId = eventAccountIdList.get(0).AccountId ;
        }
        system.debug('%%%%%%%%%%%%%%5 Account Id is   ' + accountId);
        List<Account> accList = [Select a.Name, a.Id From Account a where a.Id = :accountId];
        if(accList != null && accList.size() > 0){
            system.debug('%%%%%%%%%%%%%%5 Account Name is   ' + accList.get(0).Name);
            this.accountName = accList.get(0).Name;
        }


    }

    public string getInviteesList(){
        return this.inviteesList;
    }

    public void setInviteesList(string eventId){

        List<EventAttendee> inviteesList = [Select e.Id, e.EventId, e.AttendeeId From EventAttendee e where e.EventId = :eventId];
        List<string> invIdList = new List<string>();
        string invitees = '';
        if(inviteesList != null && inviteesList.size() > 0){
            for(EventAttendee attendee : inviteesList){
                invIdList.add(attendee.AttendeeId);
                system.debug('############ Invitee Id ' + attendee.AttendeeId);
            }
            List<Contact> invList = [Select c.Name, c.Id From Contact c where c.Id in :invIdList];
            Integer i = 0;
            if(invList != null && invList.size() > 0){
                for(Contact attendee : invList ){
                    system.debug('#################### Invitee Name   ' + attendee.Name);
                    if(i == 0){
                        invitees = attendee.Name;
                    } else{
                        invitees = invitees + ';'+ attendee.Name;
                    }
                    for(Integer j = 0 ; j < invIdList.size() ; j++){
                        if(invIdList.get(j) == attendee.Id){
                            invIdList.remove(j);
                        }
                    }
                    i++;
                }
            }

            {
                List<User> invUserList = [Select u.Name, u.Id From User u where u.Id in :invIdList];
                if(invUserList != null && invUserList.size() > 0){
                for(User attendee : invUserList ){
                    system.debug('#################### Invitee Name   ' + attendee.Name);
                    if(i == 0){
                        invitees = attendee.Name;
                    } else{
                        invitees = invitees + ';'+ attendee.Name;
                    }
                    i++;
                }
             } else {
                    system.debug('########## Both the Lists are Null');
                }

        }

        this.inviteesList = invitees;
    }

    }

    public void setRelatedToStr(Event targetEvent){
        string relatedToObjectType = targetEvent.What.Type;
        string relatedToObjectName = targetEvent.What.Name;


        system.debug('#####################   ' + relatedToObjectType  + '   ##################   ' + relatedToObjectName);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<String,String> keyPrefixMap = new Map<String,String>{};
        string objectName = '';
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet){

           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           String tempLabel = r.getLabel();
           string tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           //if(objId.substring(0, 3) == tempPrefix)
           if( relatedToObjectType == tempName)
           {
                objectName = tempLabel + '  ' + relatedToObjectName;
           }
           System.debug('Processing Object['+tempName + '] with Prefix ['+ tempPrefix+'] +   object Prefix ' + relatedToObjectName + '      ' + relatedToObjectType);
           keyPrefixMap.put(tempPrefix,tempLabel);
        }

        this.relatedToStr = objectName;

    }

    public string getRelatedToStr(){
        return this.relatedToStr;
    }


}