/*
 * Author   : 
 * Purpose  : 
 * 
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0
 * 2.0      CR12402     17.02       18-12-2015      Mohammad        Combine queries to avoid SOQL101 issue.
 * 3.0                  0103        08-11-2016      Krishnakumar    Resolve single email message error on Support Request  
 */

public class SM_SpecialistEngagementEmail {
    public static void SpecialistEngagementEmail(Support_Request__c sr) {
        List<User> salesUser = new List<User>();
        List<User> specialist = new List<User>();
        List<User> specialistManager = new List<User>();
        List<Opportunity> opportunity = new List<Opportunity>();
        String baseURL = System.URL.getSalesforceBaseURL().getHost();
        System.debug('#### baseURL: ' + baseURL);
                       
        salesUser = new List<User>();         //2.0 [SELECT Name, Email FROM User WHERE Id = :sr.CreatedById];
        specialist = new List<User>();        //2.0 [SELECT Name, Email, IsActive, ManagerId FROM User WHERE Id = :sr.Specialist_Name__c];
        //2.0 specialistManager = new List<User>(); [SELECT Name, Email FROM User WHERE Id = :specialist[0].ManagerId];
        for(user u : [SELECT Id, Name, Email,IsActive, ManagerId FROM User WHERE Id = :sr.CreatedById or Id = :sr.Specialist_Name__c]){
            if(u.id == sr.CreatedById){
                salesUser.add(u);
            }
            if(u.id == sr.Specialist_Name__c){
                specialist.add(u);
            }
        }
        //2.0-end 
        
        opportunity = [SELECT Name FROM Opportunity WHERE Id = :sr.Opportunity__c];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(specialist[0].IsActive == true){
            //mail.setToAddresses(new String[] {specialist[0].Email});        //3.0  
            mail.setTargetObjectId(specialist[0].id);          
            mail.setSubject('New engagement request for ' + opportunity[0].Name + ' deal');        
            mail.setHtmlBody('<font face="Verdana, Helvetica, sans-serif" size="2">' +
            '<div>' + salesUser[0].Name + ' is requesting your engagement for the deal: ' + opportunity[0].Name + '</div>'+
            '<div><br />Requestor Comments:</div><div>' + sr.Requestor_Comments__c + '</div>' +
            '<div><br />Please open the Request in SFDC from the link below. Once you open the form in SFDC you should:</div>' +
            '<div><br />- Update the Status field to indicate if you accept, reject or prefer to reassign the request, and</div>' +
            '<div>- Add comments for the Requestor to see.</div>' +
            '<div><br /><a href="https://' + baseURL + '/' + sr.Id + '">https://' + baseURL + '/' + sr.Id + '</a></div></font>'
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } ,false);  //3.0  Added false
        }
        /*else{
            mail.setToAddresses(new String[] {specialistManager[0].Email});
            mail.setSubject('An engagement request for ' + specialist[0].Name + ' was sent in SFDC');
            mail.setHtmlBody('<font face="Verdana, Helvetica, sans-serif" size="2">' +
            '<div>This automatic email notification was sent to you to let you know that an engagement request was sent to ' + specialist[0].Name + ' who appears in the system as no longer working in Dell.</div>' +
            '<div><br />Would you advice the requestor who to engage instead?</div>' +
            '<div><br />Requestor: ' + salesUser[0].Name + '</div>' +
            '<div>Deal: ' + opportunity[0].Name + '</div>' +
            '<div>Region: ' + sr.Region_F__c + '</div>' +
            '<div>Business Unit: ' + sr.Business_Unit__c + '</div>' +
            '<div><br />Requestor Comments: </div><div>' + sr.Requestor_Comments__c + '</div>' +
            '<div><br /><a href="https://' + baseURL + '/' + sr.Id + '">https://' + baseURL + '/' + sr.Id + '</a></div></font>'
            ); 
        }
        System.debug('### before send');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('### after sent');*/
    }
    
    public static void SpecialistRespondEmail(Support_Request__c sr, Support_Request__c sro) {  
        List<User> salesUser = new List<User>();
        List<User> specialist = new List<User>();
        List<User> oldSpecialist = new List<User>();
        List<User> specialistManager = new List<User>();
        List<Opportunity> opportunity = new List<Opportunity>();
        
        String baseURL = System.URL.getSalesforceBaseURL().getHost();
        System.debug('#### baseURL: ' + baseURL);
              
        //2.0 salesUser = [SELECT Name, Email FROM User WHERE Id = :sr.CreatedById];
        //2.0 specialist = [SELECT Name, Email, IsActive, ManagerId FROM User WHERE Id = :sr.Specialist_Name__c];
        //2.0 oldSpecialist = [SELECT Name, Email, IsActive, ManagerId FROM User WHERE Id = :sro.Specialist_Name__c];
        //2.0 specialistManager = [SELECT Name, Email FROM User WHERE Id = :specialist[0].ManagerId];
        //2.0
        for(user u : [SELECT Id, Name, Email,IsActive, ManagerId FROM User WHERE Id = :sr.CreatedById or Id = :sr.Specialist_Name__c or Id = :sro.Specialist_Name__c]){
            if(u.id == sr.CreatedById){
                salesUser.add(u);
            }
            if(u.id == sr.Specialist_Name__c){
                specialist.add(u);
                oldSpecialist.add(u);
            }
        }   
        //2.0-end
        opportunity = [SELECT Name FROM Opportunity WHERE Id = :sr.Opportunity__c];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //if(UserInfo.getUserId() == sr.Specialist_Name__c || UserInfo.getUserId() == specialist[0].ManagerId){
        if(UserInfo.getUserId() == sro.Specialist_Name__c && sr.Receive_Notification__c == 'Yes'){
            if(sr.Status__c == 'Accept' || sr.Status__c == 'Reject' || sr.Status__c == 'Reassigned'){
                //mail.setToAddresses(new String[] {salesUser[0].Email});    //3.0  
                mail.setTargetObjectId(salesUser[0].id);
                mail.setSubject('Engagement request response from ' + oldSpecialist[0].Name);        
                mail.setHtmlBody('<font face="Verdana, Helvetica, sans-serif" size="2">' +
                '<div>' + oldSpecialist[0].Name + ' just responded your Engagement Request.</div>' +
                '<div><br />Specialist response: ' + sr.Status__c + '</div>' +
                '<div>Comments: ' + sr.Specialist_Comments__c + '</div>' +
                '<div><br />Link to open the Request in SFDC:</div>' +
                '<div><br /><a href="https://' + baseURL + '/' + sr.Id + '">https://' + baseURL + '/' + sr.Id + '</a></div></font>'
                );
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail },false);   //3.0  Added false
            }
        }
        //3.0 - Start
        /*if(sr.Status__c == 'Engagement complete'){
            mail.setToAddresses(new String[] {salesUser[0].Email, specialist[0].Email});            
            mail.setSubject('Engagement for ' + opportunity[0].Name + ' deal was indicated as Completed in SFDC');        
            mail.setHtmlBody('<font face="Verdana, Helvetica, sans-serif" size="2">' +
            '<div>The Engagement Request below was indicated in SFDC as completed.</div>' +
            '<div><br />' + opportunity[0].Name + '</div>' +
            '<div><br />Requestor Comments:</div>' +
            '<div>' + sr.Requestor_Comments__c + '</div>' +
            '<div><br />Specialist Comments:</div>' +
            '<div>' + sr.Specialist_Comments__c + '</div></font>'
            );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }*/
        if(sr.Status__c == 'Engagement complete'){
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail1;
            List<ID> userId = new List<ID>();
            userId.add(salesUser[0].Id);
            userId.add(specialist[0].Id);            
            for(Integer x=0;x<userId.size();x++){
                mail1 = new Messaging.SingleEmailMessage();
                mail1.setTargetObjectId(userId.get(x));
                mail1.setSubject('Engagement for ' + opportunity[0].Name + ' deal was indicated as Completed in SFDC');        
                mail1.setHtmlBody('<font face="Verdana, Helvetica, sans-serif" size="2">' +
                '<div>The Engagement Request below was indicated in SFDC as completed.</div>' +
                '<div><br />' + opportunity[0].Name + '</div>' +
                '<div><br />Requestor Comments:</div>' +
                '<div>' + sr.Requestor_Comments__c + '</div>' +
                '<div><br />Specialist Comments:</div>' +
                '<div>' + sr.Specialist_Comments__c + '</div></font>'
                );
                allmsg.add(mail1);
            }
            Messaging.sendEmail(allmsg,false);
        }
        //3.0 End
    }
}