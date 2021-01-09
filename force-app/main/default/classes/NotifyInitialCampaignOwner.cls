/*
 * Author   : Anwar
 * Purpose  : Email notification to campaign owners whenever there is change to Opportunities/Leads associated to their Campaign.
 *  Commenting code to Stop Email trigger
 *          
 * 
 * Revision CR Number   Release No      Date            Created By     
 * -------- ---------   ----------      -----------     ------------    
 * 1.0      CR11602     16.06(MIN-S-10) 14-June-2015      Anwar          
 * -------- ---------   ----------      -----------     ------------    
 */

public class NotifyInitialCampaignOwner  {
    public static void sendEmailTocampaignowner(Map<Id, Opportunity> mapNewOpportunities, Map<Id, Opportunity> mapOldOpportunities) {
            map<Id, Id> mapOppCamIds = new map<Id, Id>();
           
            for(Opportunity newOpportunity : mapNewOpportunities.values()) {
                Opportunity oldOpportunity = mapOldOpportunities.get(newOpportunity.Id);
                system.debug('oldOpportunityCampaignId' +oldOpportunity.CampaignId);
                system.debug('newOpportunityCampaignId' +newOpportunity.CampaignId);
                
                if(oldOpportunity.CampaignId != null && oldOpportunity.CampaignId != newOpportunity.CampaignId){
                    mapOppCamIds.put(newOpportunity.Id, oldOpportunity.CampaignId);
                }
            }
            system.debug('mapOppCamIds' +mapOppCamIds);
            // To Stop the sending Email to Campaign Owner
        /*
            if(!mapOppCamIds.isEmpty()) {
                map<Id, String> mapOppnewCampOwneremail = new map<Id, String>();
                for(Opportunity Listoppidnewcam : [select Id, Campaign.Owner.Email from Opportunity where Id in :mapOppCamIds.keySet()]) {
                    mapOppnewCampOwneremail.put(Listoppidnewcam.Id, Listoppidnewcam.Campaign.Owner.Email);
                }
                system.debug('mapOppnewCampOwneremail' + mapOppnewCampOwneremail);
                map<Id, Id> mapCampOwnerId = new map<Id, Id>();
                for(Campaign camp : [select Id, OwnerId from Campaign where Id in :mapOppCamIds.values()]) {
                    mapCampOwnerId.put(camp.Id, camp.OwnerId);
                }
                 map<Id, List<Relationship_Lead__c>> mapRLOppty = new map<Id, List<Relationship_Lead__c>>();
                 Map<Id, Opportunity> mapOppIdToOpp = new Map<Id, Opportunity>([select (select id, Name from Lead_Generations__r), ID from Opportunity where Id =: mapOppCamIds.keySet()]);
                 Map<Id, List<Relationship_Lead__c>> mapOppIdToRL = new Map<Id, List<Relationship_Lead__c>>();
                 
                 for(Opportunity RLofOppty : mapOppIdToOpp.values())
                 {
                    List<Relationship_Lead__c> lstRL = new List<Relationship_Lead__c>();
                    for(Relationship_Lead__c objRL : RLofOppty.Lead_Generations__r)
                    {
                        lstRL.add(objRL);
                    }
                    mapRLOppty.put(RLofOppty.Id, lstRL);
                 }
                 
                 EmailTemplate et = [SELECT Id, Subject, HtmlValue, Body, Markup FROM EmailTemplate WHERE DeveloperName = :'NotifyCampaignOwner' LIMIT 1];
                 List<Messaging.SingleEmailMessage> lstSAVONotificationEmails = new List<Messaging.SingleEmailMessage>();
                 List<Messaging.SendEmailResult> sendResult = new List<Messaging.SendEmailResult>();
                     for(Id Opp : mapOppCamIds.keySet()) {
                           
                              Opportunity newOpportunity = mapNewOpportunities.get(Opp);
                              Id campOwnerId = mapCampOwnerId.get(mapOppCamIds.get(Opp));
                              string newcampaignemail = mapOppnewCampOwneremail.get(newOpportunity.Id);
                              List<Relationship_Lead__c> OppRls = mapRLOppty.get(newOpportunity.Id);
                              system.debug('newcampaignemail ' +newcampaignemail );
                              String body = '' ;
                               //Creating tabular format for the RL details
                              body = BodyFormat(OppRls);               
              
                              List<String> lstToEmailAddress = new List<String>();
                              Messaging.SingleEmailMessage mail = null;
                              String htmlBody = null;
                              String plainBody = null;
                              string Oppytd = String.valueOf(Opp);
                              string OppyCampaignID = String.valueOf(newOpportunity.CampaignId);
                              string LastmodifyOppyUserID = String.valueOf(newOpportunity.LastModifiedById);
                              system.debug('Oppytd' + Oppytd);
                                   
                              if(!OppRls.isEmpty()){ 
                               htmlBody = et.HtmlValue.replace('#RlrecordLink#', body);
                               plainBody = et.Body.replace('#RlrecordLink#', body);
                               }
                               else {
                              htmlBody = et.HtmlValue.replace('#RlrecordLink#', 'NO Relationship lead records');
                              plainBody = et.Body.replace('#RlrecordLink#', 'NO Relationship lead records');
                               }
                              htmlBody = htmlBody.replace('#OpportunityrecordLink#', 'https://' + URL.getSalesforceBaseUrl().getHost() + '/'+ Oppytd);
                              htmlBody = htmlBody.replace('#UserrecordLink#', 'https://' + URL.getSalesforceBaseUrl().getHost() +'/'+ LastmodifyOppyUserID);
                              if(OppyCampaignID != null) {
                              htmlBody = htmlBody.replace('#CampaignrecordLink#', 'https://' + URL.getSalesforceBaseUrl().getHost() +'/'+ OppyCampaignID);
                              }
                              else {
                                htmlBody = htmlBody.replace('#CampaignrecordLink#', 'No Campaign Id'); 
                              }
                                  mail = new Messaging.SingleEmailMessage();
                                  mail.saveAsActivity = false;
                                  mail.setReplyTo('No_Reply@Dell.com');
                                  mail.setTargetObjectId(campOwnerId);
                                  mail.setCcAddresses(new String[] {newcampaignemail}); 
                                  mail.setSubject(et.Subject);
                                  mail.setHtmlBody(htmlBody);
                                  mail.setPlainTextBody('Test');
                                   lstSAVONotificationEmails.add(mail);
          
                            
                        }
                        sendResult = Messaging.sendEmail(lstSAVONotificationEmails, false);
            }
        */
   }
     /*   
     public static String BodyFormat(List<Relationship_Lead__c> lstRL)
     {
       String str = '' ;
       for(Relationship_Lead__c rl: lstRL)
       {
           str += '<tr><td><a href="'+ URL.getSalesforceBaseUrl().getHost() +'/'+ rl.ID +'">' + rl.Name +'</a></td>'+'</tr>' ;
       }
       str = str.replace('null' , '') ;
       String finalStr = '' ;
       finalStr = '<table border="1"> <td> RLID</td> ' + str +'</table>' ;
       return finalStr ;
     }
     */
}