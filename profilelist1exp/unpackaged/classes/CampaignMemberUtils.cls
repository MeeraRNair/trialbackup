/***********************************************************

* Name          : CampaignMemberUtils 
* ---------------------------------------------------------
* Revision      Release     Name    Date            Description
* 1.0           12.7        MenMee  27.06.2011      CR6340 Convert Lead to CampaginMember  
* 1.1           12.7        Menmee  17.08.2011      defect72009 Associate Lead with existing CM
* 2.0           12.10       MenMee  09.08.2011      CR 6256 Populate Eloqua Id from Lead to CM/RL or from CM to RL
* 3.0           13.1        Jessie  18.01.2012      CR 6449 - Defect 22575 - Exclude CM that come from Lead with Lead Qualification to bring over the solution id to RL.
* 3.1           13.7        Jagadeesan 30.05.2012   CR 7178  Populate the Marketing comments and Sales Comments from Lead to CM
* 3.2           13.7        Jagadeesan 07.09.2012   REQ000007901671 - Flow of Marketing comments and Sales Comments from Lead to CM when the Lead status is 'Qualified - Pending Conversion'
*3.3            13.10       Jagadeesan 11.11.2012   CR7308 - Added 'Talk to Dell' RecordType for dupilcate leads identification to the existing process in getDuplicateLead function.
*4.0            14.2        Jagadeesan 30.11.2012   CR7850 - Added CM status value update when CM is created from lead
*5.0            14.2        Jagadeesan  21.03.2012  CR8109  - Changed the query logic in getDuplicateCM,getDuplicateRL and getDuplicateLead functions
*6.0            14.3        KP          19.04.2013  CR8239  - Updated the query filters to fix the Non-selective query issue.
*7.0            14.5        Anamika     15.4.2013   CR 8206 - populate Lead_Capture__c field from Lead to Lead_Capture__c field on CM 
*8.0            14.10       Anamika    07.08.2013  CR 8486 - added field mapping of Requested Call from Dell Rep from RL->CM [removed]
*9.0            14.10       Mukul      03.09.2013  CR 8489 - updated functionality of parent vehicle/cm status
*10.0           14.10       Anamika    18.09.2013   Defect 80395 - CM not created for PV= Other
*11.0           15.07       Meghana    09.05.2014   CR 9440 Rename picklist value 'Awaiting Follow-Up' to 'Attempted to Contact - Awaiting Response'
*11.1           15.07       Meghana    12.05.2014   CR 9445 Auto-populate CM Score if Lead record type is Lead Qualification
*12.0           15.10       HarryKam   09.09.2014   CR Added Telemarketing default CM status value 
*13.0           15.10       Meghana    10.09.2014   CR 10086 Replace Lead_Capture_Date with new datetime field
*14.0           16.03       Praveen    20.02.2015   CR 10959 updated functionality of parent vehicle/cm status 
*15.0           16.10       Azwanti    07.90.2015   CR11922 added function to track history on CM Status field
***********************************************************/

public class CampaignMemberUtils {

    public static void CreateNewCMFromLead(Map<Id, Set<Id>> campIdToContactIdMap, List<Lead> leadList, Set<Id> CampaignIdSet) {
        System.debug('##### 6340 CampaignMemberUtils:CreateNewCampaignMember');
        
        List<CampaignMember> createCMLIst = new List<CampaignMember>();
        List<String> errorMessageList = new List<String>();
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Map<Id, String> leadIdToErrorResultMap = new Map<Id, String>();
        Map<String, CampaignMember> campConIdToCMMap = new Map<String, CampaignMember>();
        
        List<Campaign> campaignList = [SELECT Type,Parent_Vehicle__c FROM Campaign WHERE Id in :CampaignIdSet];
        for (Campaign c : campaignList) {
            campaignMap.put(c.Id, c); 
        }
        
        campConIdToCMMap = getDuplicateCM(campIdToContactIdMap);
                
        for(Lead l:leadList) {
            String sKey = l.Campaign__c+':'+l.Contact__c;
            //String sKey = getKey(l.Campaign__c, l.Contact__c);  
            if (campConIdToCMMap!=null && campConIdToCMMap.containsKey(sKey)) {
                l.addError('This entity is already a member of this campaign');
            }
            else {
                CampaignMember cm = new CampaignMember(ContactId = l.Contact__c, Custom_Lead__c = l.Id, CampaignId = l.Campaign__c,score__c='Target (Contact attended event but did not self select online properties)', 
                                                    Campaign_Vehicle__c = campaignMap.get(l.Campaign__c).Type,
                                                    // rev 13.0 - Lead_Capture_Date__c = l.Lead_Capture_Date__c, // 7.0
                                                    Lead_Capture_DateTime__c = l.Lead_Capture_DateTime__c, 
                                                    Data_Center_Optimization__c = l.Data_Center_Optimization__c,CM_Status__c='Identified',
                                                    IT_Process_Simplification__c = l.IT_Process_Simplification__c, Dell_can_contact_me_in_the_future__c = l.Dell_can_contact_me_in_the_future__c, 
                                                    Decision_Making_Role__c = l.Decision_Making_Role__c, Employee__c = l.Employees__c, Dell_Existing_Customer__c = l.Dell_Existing_Customer__c,
                                                    Lead_Form_ID__c = l.Lead_Form_ID__c, End_user_Productivity__c = l.End_user_Productivity__c, Purchase_Timeframe__c = l.Purchase_Timeframe__c,
                                                    Purchase_Influence_Over__c = l.Purchase_Influence_Over__c, Questions_Comments__c = l.Questions_Comments__c,
                                                    Omniture_Visitor_ID__c = l.Omniture_Visitor_ID__c, Dell_Visitor_ID__c = l.Dell_Visitor_ID__c,
                                                    LiveBall_Respondent_ID__c = l.LiveBall_Respondent_ID__c, Eloqua_Id__c = l.Eloqua_ID__c, //Rev 2.0
                                                    sales_comments__c = l.sales_comments__c, marketing_comments__c = l.marketing_comments__c,    //Rev 3.2 : Jagadeesan
                                                    Form_url__c = l.form_url__c,form_Referrer__c = l.form_referrer__c); //Rev 4.0 : Jagadeesan 
                                                    
                
                /*if(cm.Campaign_Vehicle__C=='eDM/Email'){
                    cm.Cm_Status__c='Clicked';
                }else if(cm.Campaign_Vehicle__C=='Standalone Telemarketing'){
                    cm.Cm_Status__c='Contacted';
                }else if(cm.Campaign_Vehicle__C=='Multiple Vehicles' || cm.Campaign_Vehicle__C=='Online Advertising' || cm.Campaign_Vehicle__C=='Online Inbound'){
                    cm.Cm_Status__c='General comment';
                }else if(cm.Campaign_Vehicle__C=='Assessment (HW/Services)'){
                    cm.Cm_Status__c='Offered';
                }else if(cm.Campaign_Vehicle__C=='DM' || cm.Campaign_Vehicle__C=='Door Opener (High Value)' || cm.Campaign_Vehicle__C=='Door Opener (Value)'){
                    cm.Cm_Status__c='Sent';
                }else if(cm.Campaign_Vehicle__C=='Advisory Councils' || cm.Campaign_Vehicle__C=='CXO Events' || cm.Campaign_Vehicle__C=='Dell Day' ||
                   cm.Campaign_Vehicle__C=='eSeminar/Webcast/Webinar' || cm.Campaign_Vehicle__C=='Roadshow' || cm.Campaign_Vehicle__C=='Seminar/Conference' ||
                   cm.Campaign_Vehicle__C=='Special Events' || cm.Campaign_Vehicle__C=='Trade Show' || cm.Campaign_Vehicle__C=='Workshop'){
                    cm.Cm_Status__c='Attended';
                }*/
                if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Digital Media'){// start 9.0
                    cm.Cm_Status__c='Clicked';
                }else if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Traditional Owned Media'){
                    cm.Cm_Status__c='Contacted';
                }
                /*else if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Other'|| campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Digital'){
                    cm.Cm_Status__c='General comment';   //10.0
                }*/
                else if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Sales Incentives/Training/Plays' || campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Store Presence' || campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Solutions/Hardware Assessment'){
                    cm.Cm_Status__c='Offered';
                }else if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Content Development' || campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Traditional Paid Media' || campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Other'){
                    cm.Cm_Status__c='Sent';
                }else if(campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Events'/* || campaignMap.get(l.Campaign__c).Parent_Vehicle__c=='Digital'    //10.0  */){
                    cm.Cm_Status__c='Attended';
                }
                createCMLIst.add(cm);
            }//End 9.0
        }
        
        if (createCMList.size()>0) { 
            Database.Saveresult[] srl = database.insert(createCMList, false);
        }
        /*  
            if (srl != null) {
                for (integer i=0; i<srl.size(); i++) {
                    if (!srl[i].isSuccess()) {
                        Database.Error [] errors = srl[i].getErrors();
                        
                        for (Database.Error error :errors){     
                            System.debug('#####'+error.getStatusCode());                        
                            errorMessageList.add(''+error.getMessage());
                        }   
                        leadIdToErrorResultMap.put(LeadList[i].Id, StringUtils.joinStrings(errorMessageList, ','));
                    }                   
                }
            }   
        }
        return leadIdToErrorResultMap;  
        */  
    }
    
   /* public static void CreateNewCMFromRL(List<Relationship_Lead__c> rlList, Set<Id> CampaignIdSet) {
        System.debug('##### 6340 CampaignMemberUtils:CreateNewCMFromRL');
        
        List<CampaignMember> createCMLIst = new List<CampaignMember>();     
        Map<Id, Campaign> campaignMap = new Map<Id, Campaign>();
        Map<string,string> rLeadStatusCMStatusMap=new Map<string,string>{
                    'Requires Follow-Up'=>'Requires Follow-Up',
                    'Accepted - Completed Follow-Up'=>'Completed Follow-Up',
                    'Future Follow-Up'=>'Future Follow-Up',
                    'Rejected - Completed Follow-Up'=>'Completed Follow-Up', 
                   //Rev 11.0 - 'Awaiting Follow-Up'=>'Awaiting Follow-Up',
                    'Attempted to Contact - Awaiting Response'=>'Attempted to Contact - Awaiting Response',
                    'Opportunity not Created'=>'Opportunity Not Created',
                    'Opportunity not Linked'=>'Opportunity not Linked'
        };
        
        Map<string,string> rLeadStatusCMOpptyStatusMap=new Map<string,string>{
                    'New Opportunity'=>'New Opportunity', 
                    'Existing Opportunity'=>'Existing Opportunity',
                    'Run Rate Opportunity'=>'New Opportunity' 
        };
                     
        List<Campaign> campaignList = [SELECT Type FROM Campaign WHERE Id in :CampaignIdSet];
        for (Campaign c : campaignList) {
            campaignMap.put(c.Id, c);
        }
                
        for(Relationship_Lead__c rl:rlList) {
            CampaignMember cm = new CampaignMember(LeadId = rl.Lead_Id_do_not_edit__c, ContactId = rl.Contact__c, Custom_Lead__c = rl.Lead_Id_do_not_edit__c, CampaignId = rl.Campaign__c,
                                                    Campaign_Vehicle__c = campaignMap.get(rl.Campaign__c).Type, 
                                                    Data_Center_Optimization__c = rl.Data_Center_Optimization__c,
                                                    IT_Process_Simplification__c = rl.IT_Process_Simplification__c, Dell_can_contact_me_in_the_future__c = rl.Dell_can_contact_me_in_the_future__c, 
                                                    Decision_Making_Role__c = rl.Decision_Making_Role__c, Employee__c = rl.Employee__c, Dell_Existing_Customer__c = rl.Dell_Existing_Customer__c,
                                                    Relationship_Lead__c = rl.Id, Relationship_Lead_Created__c=true, CM_Status__c = rLeadStatusCMStatusMap.get(rl.Status__c),
                                                    End_user_Productivity__c = rl.End_user_Productivity__c, Purchase_Timeframe__c = rl.Purchase_Timeframe__c,
                                                    Purchase_Influence_Over__c = rl.Purchase_Influence_Over__c,Questions_Comments__c = rl.Questions_Comments__c,
                                                    Lead_Form_ID__c = rl.Lead_Form_ID__c, Omniture_Visitor_ID__c = rl.Omniture_Visitor_ID__c, 
                                                    Dell_Visitor_ID__c = rl.Dell_Visitor_ID__c, LiveBall_Respondent_ID__c = rl.LiveBall_Respondent_ID__c, 
                                                    Eloqua_Id__c = rl.Eloqua_ID__c, //Rev 2.0
                                                    sales_comments__c=rl.sales_comments__c,marketing_comments__c=rl.marketing_comments__c, //R3.1 Jagadeesan: Added fields for CR7178
                                                    Form_url__c = rl.form_url__c,form_Referrer__c = rl.form_referrer__c, /*Requested_call_from_Dell_rep__c=rl.Requested_call_from_Dell_rep__c, //8.0*/                                                   
                                                    //rev 13.0 Lead_Capture_Date__c=rl.Lead_Capture_Date__c
              /*                                      Lead_Capture_DateTime__c = rl.Lead_Capture_DateTime__c ); //7.0
                                                    
             if(
                (
                    (rl.Status__c=='Accepted - Completed Follow-Up'||rl.Status__c=='Rejected - Completed Follow-Up') && (rl.Opportunity__c==null)
                )|| 
                ((rl.Status__c=='Opportunity not Created')|| (rl.Status__c == 'Opportunity Not Linked'))
               ){                        
                    cm.Relationship_Lead_Opportunity_Status__c='No Opportunity';                                                  
            }
            else {
                cm.Relationship_Lead_Opportunity_Status__c=rLeadStatusCMOpptyStatusMap.get(rl.Opportunity_Status__c);                
            }                                                   
                                                
            createCMLIst.add(cm);
        }
        System.debug('---CM--'+createCMLIst);
        insert createCMList;        
        
    }*/
    
    public static Map<String, CampaignMember> getDuplicateCM(Map<Id, Set<Id>> campIdToContactIdMap){
        if(campIdToContactIdMap.Size()>0){
            Map<String, CampaignMember> campConIdToCMMap = new Map<String, CampaignMember>();
            Set<String> campaignContactKeySet = new Set<String>();
            Set<Id> contactIdSet = new Set<Id>();
            for(Id campId: campIdToContactIdMap.keySet()) {
                /*if (whereClause.length() > 1 )                   
                    whereClause += 'OR (';
                else
                    whereClause += '((';
                    
                whereClause += 'CampaignId=\''+ campId + '\' AND (';
                
                String contactIdWhereClause = '';
                for(Id contactId : campIdToContactIdMap.get(campId)) {
                    if (contactIdWhereClause.length() > 1) contactIdWhereClause += 'OR ';
                    contactIdWhereClause += 'ContactId=\'' + contactId + '\' ';
                }
                whereClause += contactIdWhereClause + ')) ';*/
                for(Id contactId : campIdToContactIdMap.get(campId)) {     //Rev5.0 starts : Jagadeesan
                    campaignContactKeySet.add(getKey(campId,contactId));    //Rev5.0 ends : Jagadeesan


                    contactIdSet.add(contactId);  //Rev 6.0 : KP
                }                                                         
                
            }
            //whereClause += ')';
            //System.debug('##### 6340 CM clause=='+whereClause);
            
            //Rev 1.1
            //Try to find CM with same contact and same campaign
            /*List<CampaignMember> cmList = [SELECT Id, CampaignId, ContactId, Relationship_Lead__c, Relationship_Lead__r.Lead_ID_Do_Not_Edit__c, 
                                            Relationship_Lead_Created__c, Custom_Lead__c FROM CampaignMember WHERE 
                                            campaigncontactkey__c in :campaignContactKeyStr];*/

            //v6.0  chnaged to contactID filter from campiD filter
            for(CampaignMember cm: [SELECT Id, CampaignId, ContactId, Relationship_Lead__c, Relationship_Lead__r.Lead_ID_Do_Not_Edit__c, 
                                    Relationship_Lead_Created__c, Custom_Lead__c, campaigncontactkey__c FROM CampaignMember WHERE 
                                    ContactId in :contactIdSet AND campaigncontactkey__c in :campaignContactKeySet]) {   
                String sKey = cm.CampaignId+':'+cm.ContactId;  
                
                campConIdToCMMap.put(sKey, cm);         
            }
            
            return campConIdToCMMap;
        }else{
            return null;
        }
    }
    
   /* public static Map<String, List<Relationship_Lead__c>> getDuplicateRL(Map<Id, Set<Id>> campIdToContactIdMap){
        Map<String, List<Relationship_Lead__c>> campConIdToRLMap = new Map<String, List<Relationship_Lead__c>>();
        Set<String> campaignContactKeySet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Id campId: campIdToContactIdMap.keySet()) {
            /*if (whereClause.length() > 1 )
                whereClause += 'OR (';
            else
                whereClause += '((';
                
            whereClause += 'Campaign__c=\''+ campId + '\' AND (';
            
            String contactIdWhereClause = '';
            for(Id contactId : campIdToContactIdMap.get(campId)) {
                if (contactIdWhereClause.length() > 1) contactIdWhereClause += 'OR ';
                contactIdWhereClause += 'Contact__c=\'' + contactId + '\' ';
            }
            whereClause += contactIdWhereClause + ')) ';*/
          /*  for(Id contactId : campIdToContactIdMap.get(campId)) {      //Rev5.0 starts : Jagadeesan
                campaignContactKeySet.add(getKey(campId,contactId));
                contactIdSet.add(contactId);                    //Rev 6.0
            }   

           
        }*/
       // whereClause += ')';
        //System.debug('##### 6340 RL clause=='+whereClause);
        
        /*List<Relationship_Lead__c> rlList = [SELECT Id, Campaign__c, Contact__c, CM_Source__c, Lead_Id_Do_Not_Edit__c FROM Relationship_Lead__c WHERE 
                                             campaignContactKey__c in :campaignContactKeyStr];*/
         //Database.query(query);      
        
        //Rev 6.0 changed filter from Campaign__c to Contact__c
       /* for(Relationship_Lead__c rl:[SELECT Id, Campaign__c, Contact__c, CM_Source__c, Lead_Id_Do_Not_Edit__c FROM Relationship_Lead__c WHERE 
                                      Contact__c in :contactIdSet AND campaigncontactkey__c in :campaignContactKeySet]) {
            String sKey = rl.Campaign__c+':'+rl.Contact__c;
            
            if (campConIdToRLMap.get(sKey) == null)
                campConIdToRLMap.put(sKey, new List<Relationship_Lead__c> {rl});
            else
                campConIdToRLMap.get(sKey).add(rl);
        }
        
        return campConIdToRLMap;
    }*/
    
    public static Map<String, Lead> getDuplicateLead(Map<Id, Set<Id>> campIdToContactIdMap, boolean isRLCreated){
        Map<String, Lead> campConIdToLeadMap = new Map<String, Lead>();
        Set<String> campaignContactKeySet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        //Id leadQualificationRT = IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true);
        Set<Id> leadRecTypeIds = new Set<Id>();                                                 //3.3 Start: Jagadeesan-Added Talk to Dell RecordType for dupilcate leads identification to the existing process.
        leadRecTypeIds.add(IdLookupUtils.getRecordTypeId('Lead Qualification', 'Lead', true));
        leadRecTypeIds.add(IdLookupUtils.getRecordTypeId('Talk to Dell', 'Lead', true));       //3.3 End
        
        for(Id campId: campIdToContactIdMap.keySet()) {
            /*if (whereClause.length() > 1 )
                whereClause += 'OR (';
            else
                whereClause += '((';
                
            whereClause += 'Campaign__c=\''+ campId + '\' AND (';
            
            String contactIdWhereClause = '';
            for(Id contactId : campIdToContactIdMap.get(campId)) {
                if (contactIdWhereClause.length() > 1) contactIdWhereClause += 'OR ';
                contactIdWhereClause += 'Contact__c=\'' + contactId + '\' ';
            }
            whereClause += contactIdWhereClause + ')) ';*/
            for(Id contactId : campIdToContactIdMap.get(campId)) {    //Rev5.0 starts : Jagadeesan
                campaignContactKeySet.add(getKey(campId,contactId));
                contactIdSet.add(contactId);   //Rev 6.0
            }  

            
        }
        //whereClause += ')';
        //System.debug('##### 6340 Lead clause=='+whereClause);
        
       // String query = 'SELECT Id, Campaign__c, Contact__c FROM Lead ' + 
                       //'WHERE RecordTypeId in :\''+leadRecTypeIds+'\' AND Relationship_Lead_Created__c = ' + isRLCreated + ' AND ' + whereClause +
                      // 'WHERE RecordTypeId in :leadRecTypeIds AND Relationship_Lead_Created__c = ' + isRLCreated + ' AND ' + whereClause +             //3.3 Jagadeesan :Edited the Query to check for both 'Talk To Dell' and 'Lead Qualification' Record Type Ids for Record Type
                       //'ORDER BY LastModifiedDate Desc';
        
        //Rev 6.0 changed filter from Campaign__c to Contact__c
        List<Lead> leadList = [ SELECT Id, Campaign__c, Contact__c, campaigncontactkey__c, 
                                RecordTypeId, Requested_call_from_Dell_rep__c , Campaign__r.Campaign_Vehicle__c //Rev 11.1
                                FROM Lead WHERE  Contact__c in :contactIdSet 
                                AND RecordTypeId in :leadRecTypeIds  AND Relationship_Lead_Created__c =:isRLCreated AND campaigncontactkey__c in :campaignContactKeySet           //3.3 Jagadeesan :Edited the Query to check for both 'Talk To Dell' and 'Lead Qualification' Record Type Ids for Record Type
                                //AND ConvertedAccountId = null AND ConvertedContactId = null //8486
                            ORDER BY LastModifiedDate Desc];
        System.debug('---campconkeyset---'+campaignContactKeySet);
        for(Lead l:leadList) {
            String sKey = l.Campaign__c+':'+l.Contact__c;
            //String sKey = l.campaigncontactkey__c;  
            if (campConIdToLeadMap.get(sKey) == null){            
                campConIdToLeadMap.put(sKey, l);
            }
        }
        
        return campConIdToLeadMap;
    }
    
    public static List<CampaignMember> filterAssociateCMToRLOrLead(Map<Id, Set<Id>> campIdToContactIdMap, List<CampaignMember> campMembListToBeFiltered) {
        System.debug('##### 6340 CampaignMemberUtils.filterAssociateCMToRLOrLead');
        
        Map<String, CampaignMember> cmMap = new Map<String, CampaignMember>();      
        List<Relationship_Lead__c> rlList = new List<Relationship_Lead__c>();
        Set<Id> lIdSet = new Set<Id>();
        
        for (CampaignMember cm: campMembListToBeFiltered) {
            cmMap.put(cm.CampaignId+':'+cm.ContactId, cm);//cmMap.put(getKey(cm.CampaignId, cm.ContactId), cm);   //Rev 6.0  used getKey
        }
        
        Map<String, Lead> lMap = getDuplicateLead(campIdToContactIdMap, true);
        for (String sKey : lMap.keySet()) {
            lIdSet.add(lMap.get(sKey).Id);
        }
        
        if (lIdSet.size() > 0) {
            //Query RL that associated with lead
            List<Relationship_Lead__c> tempRLList = [SELECT Id, Campaign__c, Contact__c, CM_Source__c FROM Relationship_Lead__c WHERE Lead_ID_Do_Not_Edit__c IN :lIdSet];
            
            for (Relationship_Lead__c rl: tempRLList) {
                String sKey = rl.Campaign__c +':'+rl.Contact__c;
                //String sKey = getKey(rl.Campaign__c, rl.Contact__c);   //Rev 6.0 used getKey
                if (cmMap.containsKey(sKey)) {          
                    rl.CM_Source__c = cmMap.get(skey).Id;
                    cmMap.remove(sKey);
                    rlList.add(rl);
                }
            }
            
            update rlList;
        }
        return cmMap.values();
    }
    
   /* public static void associateCMRLToLead(Map<Id, Set<Id>> campIdToContactIdMap, Map<String, Relationship_Lead__c> newRLList) {
        System.debug('##### 6340 CampaignMemberUtils.associateCMRLToLead');
        
        Map<String, Lead> lMap = getDuplicateLead(campIdToContactIdMap, false);
        
        for (string sKey:lMap.keySet()) {           
            Relationship_Lead__c rl = newRLList.get(sKey);
            rl.Lead_ID_Do_Not_Edit__c = lMap.get(sKey).Id;
            
            //Rev 11.1
            if (lMap.get(sKey).RecordTypeId == GlobalVariables.LEAD_QUALIFICATION_RECTYPE ){
                rl.Relationship_Lead_Score__c= RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(lMap.get(sKey).Requested_call_from_Dell_rep__c , lMap.get(sKey).Campaign__r.Campaign_Vehicle__c );
                if(rl.Relationship_Lead_Score__c == 'High Priority (Extremely hot Leads; SLA = 48 hours)' ) {                   
                    rl.due_date__c = system.today() + 2;
                }      
                else if(rl.Relationship_Lead_Score__c == 'TeleQualified Lead (Potential Opportunity; SLA = 48 hours)')  {                   
                    rl.due_date__c = system.today() + 2;
                }
                else if(rl.Relationship_Lead_Score__c =='Priority (Contact participated in Marketing program; SLA = 1 Week)'){                    
                    rl.due_date__c = system.today() + 7;
                }
            }           
            //Rev 11.1 - end
        }
    }*/
    
    /*public static void associateLeadToCMRL(Lead leadObj, Relationship_Lead__c relLeadObj) {
        
        System.debug('##### 6340 CampaignMemberUtils:associateLeadToCMRL');
        
        ID LeadQualification_Rectype = GlobalVariables.LEAD_QUALIFICATION_RECTYPE ;
        System.debug('##### leadObj.Requested_call_from_Dell_rep__c'+leadObj.Requested_call_from_Dell_rep__c);
        System.debug('##### leadObj.Campaign__r.Campaign_Vehicle__c'+leadObj.Campaign__r.Campaign_Vehicle__c);
        System.debug('##### (leadObj.RecordTypeId'+leadObj.RecordTypeId);
        
        List<CampaignMember> cmObj = [SELECT Id, Custom_Lead__c FROM CampaignMember WHERE Id =:relLeadObj.CM_Source__c];
        cmObj[0].Custom_Lead__c = leadObj.Id;
        if (leadObj.RecordTypeId == LeadQualification_Rectype ){
            cmObj[0].Score__c = RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(leadObj.Requested_call_from_Dell_rep__c , leadObj.Campaign__r.Campaign_Vehicle__c );                    
        }
        update cmObj;
        
        relLeadObj.Lead_ID_Do_Not_Edit__c = leadObj.Id;
        if (leadObj.RecordTypeId == LeadQualification_Rectype ){
            relLeadObj.Relationship_Lead_Score__c =  cmObj[0].Score__c;
        }
        update relLeadObj;
    }*/
    
    /*public static String associateLeadToCM(Lead leadObj, CampaignMember cmObj) {
        
        System.debug('##### 6340 CampaignMemberUtils:associateLeadToCM');
        //Rev 3.0 - start
        cmObj.Custom_Lead__c = leadObj.Id;      
        //Rev 3.0 - end 
        cmObj.CM_Status__c = 'Requires Follow-Up';
        //Rev 11.1
        if (leadObj.RecordTypeId == GlobalVariables.LEAD_QUALIFICATION_RECTYPE ){
            cmObj.Score__c = RelationshipLeadAccountPlayFollowUp.getLeadScore_LeadQualification(leadObj.Requested_call_from_Dell_rep__c , leadObj.Campaign__r.Campaign_Vehicle__c );
            
        }
        else                    
            cmObj.Score__c = 'High Priority (Extremely hot Leads; SLA = 48 hours)';
        //Rev 11.1 - end
        update cmObj;
        
        List<Relationship_Lead__c> rlList = [SELECT Id FROM Relationship_Lead__c WHERE CM_Source__c =:cmObj.Id];
        
        if (rlList != null && rlList.size() >0)
            return '/'+rlList[0].Id;
        else
            return null;
        
    }*/
    public static String getKey(String CampId, String ContactId){

        return get15charId(CampId)+':'+ get15charId(ContactId);

    }

    public static String  get15charId(String Guid){

        return StringUtils.defaultString(Guid).substring(0,15);

    }
    
    /*
    Revision    CR Number   Release No  Date            Modified By     Description
    --------    ---------   ----------  -----------     ------------    -----------
    1.0          CR11922    16.10       07-Sept-2015     Azwanti      to track field history of CampaignMember Status
    1.1         CR11922     16.10       23-Oct-2015     Azwanti         defect #205021: created override method to fix defect - CM Status history not captured via Convert Lead function
    */    
     
    public static void generateCMFieldHistory(Map<Id, sObject> objCM){
        set<Id> setCMIds = new set<Id>();
        List<sObject> newCMList = new List<sObject>();
        Map<Id, sObject> newCMMap = new Map<Id, sObject>();
        
        //get CampaignMemberId 
        for(Id cmId : objCM.keySet()) {
            
            setCMIds.add(cmId);   
        }
        
        //get all OpportunityLineItem fields then query
        Map<String, Schema.SObjectType> mapSObjectNameToSObjects = Schema.getGlobalDescribe();
        Schema.SObjectType source_ObjType = mapSObjectNameToSObjects.get('CampaignMember');
        Schema.DescribeSObjectResult source_DescribeResult = source_ObjType.getDescribe();
        Map<String, Schema.SObjectField> mapSourceFieldNameToFields = source_DescribeResult.fields.getMap();
        
        String query = 'SELECT ';
        
        for(String fieldName : mapSourceFieldNameToFields.keySet())
        {
            query = query + fieldName + ', ';
        }
        
        query = query.removeEnd(', ');
        query = query + ' FROM CampaignMember Where Id In (';
        
        for(string cmID: setCMIds)
        {
            query = query + '\'' + cmID + '\'';
            query = query + ', ';
        }
        query = query.removeEnd(', ');
        query = query + ')'; 
        
        newCMMap = new Map<Id, sObject>(Database.query(query));
        
        //create Campaign Member Field History
        CustomFieldHistoryTracker.trackFieldHistory('CampaignMember', 'Campaign_Member_Field_History__c', 'Campaign_Member_Field_Tracking__c', 'CampaignId', 'Campaign__c', trigger.oldMap, newCMMap);
    }

    //1.1
    public static void generateCMFieldHistory(Map<Id, sObject> objCM, Map<Id, sObject> oldObjCM){
        set<Id> setCMIds = new set<Id>();
        List<sObject> newCMList = new List<sObject>();
        Map<Id, sObject> newCMMap = new Map<Id, sObject>();
        
        //get CampaignMemberId 
        for(Id cmId : objCM.keySet()) {
            
            setCMIds.add(cmId);   
        }
        
        //get all OpportunityLineItem fields then query
        Map<String, Schema.SObjectType> mapSObjectNameToSObjects = Schema.getGlobalDescribe();
        Schema.SObjectType source_ObjType = mapSObjectNameToSObjects.get('CampaignMember');
        Schema.DescribeSObjectResult source_DescribeResult = source_ObjType.getDescribe();
        Map<String, Schema.SObjectField> mapSourceFieldNameToFields = source_DescribeResult.fields.getMap();
        
        String query = 'SELECT ';
        
        for(String fieldName : mapSourceFieldNameToFields.keySet())
        {
            query = query + fieldName + ', ';
        }
        
        query = query.removeEnd(', ');
        query = query + ' FROM CampaignMember Where Id In (';
        
        for(string cmID: setCMIds)
        {
            query = query + '\'' + cmID + '\'';
            query = query + ', ';
        }
        query = query.removeEnd(', ');
        query = query + ')'; 
        
        newCMMap = new Map<Id, sObject>(Database.query(query));
        
        //create Campaign Member Field History
        CustomFieldHistoryTracker.trackFieldHistory('CampaignMember', 'Campaign_Member_Field_History__c', 'Campaign_Member_Field_Tracking__c', 'CampaignId', 'Campaign__c', oldObjCM, newCMMap);
    }
    //-end 1.1
}