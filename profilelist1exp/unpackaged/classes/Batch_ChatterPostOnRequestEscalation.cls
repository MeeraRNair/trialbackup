global  class Batch_ChatterPostOnRequestEscalation implements Database.Batchable < sObject > { 
 String CaseCreatedDate = System.Label.Case_created_Date;
 //Start 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String requestEscalationRec = 'select owner.name,id,ownerId,CaseNumber,Post_to_Chatter__c,Request_Escalation__c,recordtype.name from case where (RecordType.Name LIKE ' + '\'%' + 'Order Support' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'Deal Registration' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'On Boarding' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'Deal Registration - Internal only case types'+ '%\' OR RecordType.Name LIKE ' + '\'%' + 'On Boarding Internal' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'Distribution' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'Application Support' + '%\' OR RecordType.Name LIKE ' + '\'%' + 'Partner Program' + '%\') AND CreatedDate > '+ CaseCreatedDate +' AND Post_to_Chatter__c != True AND IsEscalated != True AND Request_Escalation__c = True AND status != ' + '\'' + 'completed' + '\'';
        return Database.getQueryLocator(requestEscalationRec);
    }
       
    global void execute(Database.BatchableContext BC, List < sObject > scope) {
        //Get queue members for DR record type
        Map<String,List<id>> queueVsMember =  new Map<String,List<id>>();
        List<Case_Chatter_Notification_Queues__c> ChatterallList =Case_Chatter_Notification_Queues__c.getall().values();
        //Added code to avoid query in "for" loop
        List<String> ChatterQnames=new list<String>();
        for(Case_Chatter_Notification_Queues__c queueN : ChatterallList) {
            ChatterQnames.add(string.valueOf(queueN.Queue_Name__c));
        }
        List<GroupMember> UserOrGroupIdlist=new list<GroupMember>([SELECT UserOrGroupId,Group.name FROM GroupMember WHERE Group.name in:ChatterQnames]);    
        for (String str:ChatterQnames) {
            queueVsMember.put(str,new List<id>());
        }
        for (GroupMember member : UserOrGroupIdlist) {          
            queueVsMember.get(member.Group.name).add(member.UserOrGroupId);         
        }
        List<FeedItem> feedList = new List<FeedItem>();
        List<case> postToChatterFlag= new list<case>();
        List<groupmember> groupUsers = new List<groupmember>();
        groupUsers= [SELECT UserOrGroupId,Group.name FROM GroupMember WHERE Group.name LIKE '%Cases - Order Support Global Group%'];

        for(SObject c: scope){
            Case cs = (case) C;
           if(!String.valueOf(cs.OwnerId).startsWith('00G')) {
            cs.Post_to_Chatter__c= True;
            postToChatterFlag.add(cs);
            FeedItem post = new FeedItem();
            post.ParentId = cs.ownerId;
            post.Body = cs.Recordtype.name+' case has been escalated :'+cs.CaseNumber+'. Below link will take you to the respective case';
            post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cs.Id;
            feedList.add(post);
           }else if((String.valueOf(cs.OwnerId).startsWith('00G')) && cs.Recordtype.name == 'Order Support'){
            cs.Post_to_Chatter__c= True;
            postToChatterFlag.add(cs);
            for(groupmember grp: groupUsers){
            FeedItem post = new FeedItem();
            post.ParentId = grp.UserOrGroupId;
            post.Body = cs.Recordtype.name+' case has been escalated :'+cs.CaseNumber+'. Below link will take you to the respective case';
            post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cs.Id;
            feedList.add(post);   
            }             
           }else if(String.valueOf(cs.OwnerId).startsWith('00G')){
            cs.Post_to_Chatter__c= True;
            postToChatterFlag.add(cs);
            if(queueVsMember.get(cs.owner.Name) != null) {
                for(Id userId: queueVsMember.get(cs.owner.Name)){
                FeedItem post = new FeedItem();
                post.ParentId = userId;
                post.Body = cs.Recordtype.name+' case has been escalated :'+cs.CaseNumber+'. Below link will take you to the respective case';
                post.LinkUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + cs.Id;
                feedList.add(post);   
            }   
            }          
           } 
        }
        Savepoint sp = Database.setSavepoint();
        try{
             if(feedList.size()>0){
             TriggerExecutionController.setSkipAllTriggers(True);
             insert feedList;
             update postToChatterFlag;
             TriggerExecutionController.setSkipAllTriggers(false);
            }
        }catch(DMLException DE){
             Database.rollback(sp);  
        }
    }
 //Stop   
    global void finish(Database.BatchableContext BC) { 
    }
}