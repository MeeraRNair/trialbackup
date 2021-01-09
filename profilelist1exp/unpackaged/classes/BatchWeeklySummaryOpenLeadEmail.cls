/*
 * Author   : Azwanti
 * Purpose  : The batch apex class to follow-up on open Leads.
 *        
 * Revision CR Number   Release No      Date            Modified By     Description
 * -------- ---------   ----------      -----------     ------------    -----------
 * 1.0      CR 11840    MAJ16.10        18-Aug-2015     Azwanti         send weekly summary on unfollowed (Open and Accepted) leads to Owners and Manager 
 * 1.1      CR 11920    MAJ16.10        02-SEPT-2015    Azwanti         revamp the email text and for Lead Owner sort Lead Age DESC. For Lead Owner Manager, add sorting on Lead Owner ASC
 * 2.0      CR 13068    FY17-DCS-0502   19-Apr-2016     Azwanti         INC000022127998 - SAR14004: added filter in SOQL to exclude Lead owned by Operation profiles and limit to 10,000 Lead only.         
 * 3.0      CR 13068    FY17-DCS-0602   04-May-2016     Gan             INC000022127998 - SAR14004 - rollback to implementation rev 1.1 and refactor  
 * 3.1      CR 13109    FY17-DCS-0602   04-May-2016     Shivam          Add additional column Days Since Last Owner Reassignment Date.
 * 3.2      CR 13109    FY17-DCS-0602   06-May-2016     Shivam          Display no of Days Since Last Owner Reassignment Date.
 * 3.3      CR 13068    FY17-DCS-0602   06-May-2016     Gan             Put the 10K limit of leads per email and limit records return by 50K
 * 4.0      CR 13386    FY17-DCS-1002   08-Aug-2016     Azwanti         LM2_17- Ensure lead owner manager is in synch with user card changes
 * 5.0      CR 13901    FY18-DCS-0302   10-Jan-2017     Sajith          Include Marketing Qualified Lead and Contacted statuses in weekly summary emails
 * 6.0      CR 14482    FY18-DCS-0702   08-Jun-2017     Sajith          Weekly summary emails to Sales Rep on leads -  Addition of more information
 * 7.0      CR 14879    FY18-DCS-1001   05-Sep-2017     Ashok           Weekly summary emails to exclude chairman and Non-Executive
 * 8.0      CR 14988    FY18-DCS-1101   27-Sep-2017     Ashok           Additional filter for Weekly summary emails
 * 9.0      CR 14988    FY18-DCS-1101   03-OCT-2017     Ashok           Optimization of Aggregate query 
 *10.0      CR 15110    FY18-DCS-0203   22-NOV-2017     Azwanti         Replace Status Open, Accepted, Contacted & Marketing Qualified Lead to New & Working, and remove Accepted Date column from table
 *11.0      CR 15892    FY19-DCS-0703   28-May-2018     Sakshi          Reduce Code
 *12.0      CR 16150    FY19-DCS-0802   11-Jul-2018     Kishore         Weekly summary emails to include only "Non-Executive"
 *13.0      CR 18099    FY20-DCS-1101   09-Sep-2019     Niveda          Weekly Summary email to reference Owner.Name
*/  

global class BatchWeeklySummaryOpenLeadEmail implements Database.Batchable<AggregateResult>, Database.Stateful {
    
    global Boolean bFirstBatch = true;
    global String strBaseUrl = '';
    global EmailTemplate ownerEmailTemplate = null;
    global EmailTemplate managerEmailTemplate = null;
    private Integer intHeapSizeLimit; 
    private Integer intHeapSizeMaxUsage;
    
    //v4.0
    public set<Id> setManagerIds;// = new set<Id>();
    public set<Id> excludePSUser = new set<Id>();
    public Map<Id, User> mapManagerInfo = new Map<Id, User>();
    
    public BatchWeeklySummaryOpenLeadEmail () {
        strBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        ownerEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'Lead Follow Up Email for Owner'];
        managerEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'Lead Follow Up Email for Manager'];
                
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC) {
        // Fetching all Open Leads owner managers and passing to execute method
        //5.0 Added 'Contacted','Marketing Qualified Lead' statuses to the query
        
        //7.0 - Exclude triggering emails to Non - executives and chairmans from the list
        List<String> ExcludeExecutiveCodes = System.Label.Exclude_Peoplesoft_Executive_Code.split(';');
        for(PeopleSoft_User_View__c ps1:[Select Id,Employee_Name__c,Badge_Number__c,Executive_Code__c from PeopleSoft_User_View__c where Executive_Code__c != '' AND Executive_Code__c NOT In :ExcludeExecutiveCodes]){ //12.0 Updated the query with blank check and added "Not" in the 2nd condition to consider only "Non-Executive"
          if(Ps1.Employee_Name__c!= null)
          excludePSUser.add(ps1.Employee_Name__c);
        }       
        //9.0
        string query = 'select ManagerId leadMngr from User where Id in '+
                                        '(Select OwnerId From Lead '+
                                            'Where '+
                                            'Lead_Owner_s_Manager__c != null '+
                                            'AND Status in (\'New\', \'Working\') '+ //10.0
                                            'and Record_Type__c = \'Direct Lead 2.0\' '+
                                            'and Lead_Type__c = \'Inbound\' '+
                                            'and owner.type = \'user\' '+
                                            'and isconverted= false '+
                                            'and (CreatedDate >= LAST_90_DAYS Or First_time_assigned_to_Sales__c >= LAST_90_DAYS) '+//8.0
                                            'and Owner.IsActive = TRUE '+
                                            'and Owner.Profile.Name not in ('+System.Label.LM2_OperationProfiles+')) '+
                                        'group by ManagerId';
       
        return new AggregateResultIterable(query);
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        //9.0
        setManagerIds = new set<Id>();
        //mapManagerInfo = new Map<Id, User>();
        
        for(sObject arResult : scope) {
              AggregateResult ar = (AggregateResult)arResult;
              setManagerIds.add((Id)ar.get('leadMngr'));
            
         }
         
         if(setManagerIds.isEmpty()) {
            setManagerIds.add(UserInfo.getUserId());
         }
         
         list<User> receipientManagers= [select Id, FirstName, Name,Badge_Number__c from User where Id in :setManagerIds]; //8.0
        //9.0 End
        //  v4.0
        for(User u: receipientManagers){  //cast User
            mapManagerInfo.put(u.Id, u);
        }
        
        if(mapManagerInfo != null) {
            Set<Id> setManagerId = mapManagerInfo.keySet();
        }     

        //end v4.0
        //6.0 Added Lead_Tracking_ID__c, Country fields to the query      
        String strQuery = 'select Id, OwnerId, Owner.Name, Owner.Email, Owner.FirstName,Last_Owner_Reassignment_Date__c, Lead_Owners__c, Lead_Owner_Name__c,Lead_Tracking_ID__c, Company, Country,CreatedDate, Lead_Accepted_Date__c, '
                    //v4.0 - value for Manager Email, Manager Name and Manager First Name is retrieve in Start method
                        + 'Status, Name, Lead_Owner_s_Manager__c '  //v4.0
                        + 'from Lead where ';
        if(bFirstBatch) {
            bFirstBatch = false;
            strQuery += '(Lead_Owner_s_Manager__c = null or Lead_Owner_s_Manager__c in :setManagerId) ';  
        }
        else {
            strQuery += 'Lead_Owner_s_Manager__c in :setManagerId ';    
        }
        
        strQuery += 'and Record_Type__c = \'Direct Lead 2.0\' ';  
        strQuery += 'and Lead_Type__c = \'Inbound\' ';
        strQuery += 'and Owner.Profile.Name not in (' + System.Label.LM2_OperationProfiles +') '; //v2.0
        strQuery += 'and owner.type = \'user\' '; //v3.0
        //5.0 Excluded converted leads and Added 'Contacted','Marketing Qualified Lead' statuses to the query
        strQuery += 'and isconverted= false '; 
        strQuery += 'and (CreatedDate >=LAST_90_DAYS Or First_time_assigned_to_Sales__c >=LAST_90_DAYS) '; //8.0
        strQuery += 'and Owner.IsActive = TRUE '; //8.0
        strQuery += 'and Status in (\'New\', \'Working\') and Lead_Owners__c != null order by Lead_Owner_s_Manager__c, Lead_Owners__c ASC, CreatedDate ASC limit 50000';  //v2.0 //3.0 //3.3  //4.0  //10.0   
        System.debug(LoggingLevel.Info,'@@@'+ strQuery);
        //3.3
        Integer intLeadLimitPerEmail = Integer.valueOf(System.Label.LM2_Limit_BatchWeeklySumEmail);
        //v3.0
        intHeapSizeLimit = Limits.getLimitHeapSize(); 
        intHeapSizeMaxUsage = intHeapSizeLimit * Integer.valueOf(System.Label.LM2_WeeklyEmail_HeapSizeMaxPercentage) / 100;

        Integer iOwnerLeadCount = 0;
        Integer iManagerLeadCount = 0;
        String strOwnerRows = '';
        String strManagerRows = '';
        String strOwnerContactedRows = ''; //5.0
        String strManagerContactedRows = ''; //5.0
        Lead prevLead = null;
        Lead curLead = null;  
      
        list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
        for(List<Lead> lstLeads: Database.query(strQuery)) {
            if(lstLeads != null && lstLeads.size() > 0){
                System.debug('ZY => start for loop heap size: ' + Limits.getHeapSize() + ',first owner :' + ((Lead)lstLeads[0]).OwnerId + ',lst count: ' + lstEmails.size()+ ', LeadOwnerMngr: '+ ((Lead)lstLeads[0]).Lead_Owner_s_Manager__c);
                for(Lead currentLead : lstLeads) {
                    curLead = currentLead;
                    if((prevLead != null && prevLead.OwnerId != currentLead.OwnerId)) {
                        addEmail(lstEmails, prevLead, iOwnerLeadCount, strOwnerRows, strOwnerContactedRows, false);
                        
                        iOwnerLeadCount = 0;
                        strOwnerRows = '';
                        strOwnerContactedRows=''; //5.0
                        
                      // v4.0
                        if(prevLead.Lead_Owner_s_Manager__c == null) {
                            iManagerLeadCount = 0;
                            strManagerRows = '';
                            strManagerContactedRows = ''; //5.0
                        } 
                    }
                
                   //  v4.0
                   if(prevLead != null && prevLead.Lead_Owner_s_Manager__c != currentLead.Lead_Owner_s_Manager__c) {
                        // Send email to managers
                        addEmail(lstEmails, prevLead, iManagerLeadCount, strManagerRows, strManagerContactedRows, true);
                        iManagerLeadCount = 0;
                        strManagerRows = '';
                        strManagerContactedRows = ''; //5.0
                    } 
                    long daysReassigned;
                    long daysDifference = currentLead.CreatedDate.date().daysBetween(System.today());
                    if (currentLead.Last_Owner_Reassignment_Date__c != null){
                        daysReassigned = currentLead.Last_Owner_Reassignment_Date__c.date().daysBetween(System.today());
                    }
                    //If Lead Status = Open, Accepted Date should be shown as blank
                    //10.0 : commented logic below since column Accepted Date is remove from table
                    /*string lead_AcceptedDt;
                    if(currentLead.Status != 'Working'){   //5.0 
                        lead_AcceptedDt = '';
                    }
                    else{
                        lead_AcceptedDt = string.valueOf(currentLead.Lead_Accepted_Date__c);
                    }
                    */
                    //Lead Owner Email : column
                    //if (ownerToSkip != null && ownerToSkip != currentLead.OwnerId)
                    String str = '<tr>'
                                + '<td>' + daysDifference  +'</a></td>' // Lead Age
                                + '<td>' + daysReassigned  +'</td>' // Days Since Last Owner Reassignment Date
                                + '<td><a href="'+ strBaseUrl +'/'+ currentLead.ID +'">' + currentLead.Name +'</a></td>' // Lead Contact Name
                                + '<td>'+ currentLead.Lead_Tracking_ID__c + '</td>' // 6.0 Lead Tracking ID
                                + '<td>'+ currentLead.Company +'</a></td>' // Company
                                + '<td>'+ ((currentLead.Country==null)?' ':currentLead.Country )+'</td>' // 6.0 Country
                                + '<td>'+ currentLead.Status +'</td>' // Lead Status
                              //10.0  + '<td>'+ lead_AcceptedDt +'</td>' // Accepted Date
                                + '</tr>';
                    if (iOwnerLeadCount < intLeadLimitPerEmail)
                    {
                        //5.0 Splitting Leads with Contacted status to a separate table
                        if (currentLead.Status.equals('Working')){ //10.0
                            strOwnerContactedRows += str;
                        }//5.0
                        else{
                            strOwnerRows += str;
                        }
                    }        
                           
                    //Lead Owner Manager Email : column
                    //if (managerToSkip != null && managerToSkip != currentLead.Lead_Owner_s_Manager__c)
                    if (iManagerLeadCount < intLeadLimitPerEmail)
                    {
                        String str1 = '<tr>'
                                + '<td>' + currentLead.Owner.Name  +'</a></td>'  //Lead Owner v13.0
                                + '<td>' + daysDifference  +'</a></td>' // Lead Age
                                + '<td>' + daysReassigned  +'</td>' // Days Since Last Owner Reassignment Date
                                + '<td><a href="'+ strBaseUrl +'/'+ currentLead.ID +'">' + currentLead.Name +'</a></td>' // Lead Contact Name
                                + '<td>'+ currentLead.Lead_Tracking_ID__c + '</td>' // 6.0 Lead Tracking ID
                                + '<td>'+ currentLead.Company +'</a></td>' // Company
                                + '<td>'+ ((currentLead.Country==null)?' ':currentLead.Country )+'</td>' // 6.0 Country
                                + '<td>'+ currentLead.Status +'</td>' // Lead Status
                             //10.0   + '<td>'+ lead_AcceptedDt +'</td>' // Accepted Date
                                + '</tr>';
                        //5.0 Splitting Leads with Contacted status to a separate table
                        if (currentLead.Status.equals('Working')){  //10.0
                            strManagerContactedRows += str1;
                        }
                        else{
                            strManagerRows += str1;
                        }
                    }
                           
                    iOwnerLeadCount++;
                    iManagerLeadCount++;
                  
                    prevLead = currentLead;
                     
                    if(Limits.getHeapSize() >= intHeapSizeMaxUsage)
                    {
                        sendEmail(lstEmails);   
                    }
                }
            }

        }
         
        //to process the last one if there is
        if(curLead != null) {
            addEmail(lstEmails, curLead, iOwnerLeadCount, strOwnerRows, strOwnerContactedRows, false);
            
         // v4.0
            if(curLead.Lead_Owner_s_Manager__c != null) {
                addEmail(lstEmails, curLead, iManagerLeadCount, strManagerRows, strManagerContactedRows, true);
            } 
            sendEmail(lstEmails);
        }
        //v4.0 clear the map
        mapManagerInfo.clear();
        
    }
    
    private void sendEmail(list<Messaging.SingleEmailMessage> lstEmails) {
        
        try{
            if(!lstEmails.isEmpty()) {
                Messaging.sendEmail(lstEmails);
                lstEmails.clear();
            }    
        }
        catch(Exception e){
            System.debug('ZY => Exception occurred during update of lead record.' + e);
        }
    }
    
    public void addEmail(list<Messaging.SingleEmailMessage> lstEmails, Lead objLead, 
                         Integer iLeadCount, String strRows, String strcntRows, Boolean bIsManager) { //5.0
        String firstName = '';
        String fullName = '';
        String ownerEmail;
        Id userId;
        EmailTemplate mailTemplate;
        if(bIsManager) {        
        //v4.0
            if(mapManagerInfo != null && mapManagerInfo.containsKey(objLead.Lead_Owner_s_Manager__c)){
                firstName = mapManagerInfo.get(objLead.Lead_Owner_s_Manager__c).FirstName;
                fullName = mapManagerInfo.get(objLead.Lead_Owner_s_Manager__c).Name;
            }
            //7.0
            if(!excludePSUser.IsEmpty() && !excludePSUser.contains(objLead.Lead_Owner_s_Manager__c)){ 
                userId = objLead.Lead_Owner_s_Manager__c;
            } 
            
            mailTemplate = managerEmailTemplate;
        }
        else {
            firstName = objLead.Owner.FirstName;
            fullName = objLead.Owner.Name;
            //7.0
            if(!excludePSUser.IsEmpty() && !excludePSUser.contains(objLead.OwnerId)){ 
                userId = objLead.OwnerId;
            }
            mailTemplate = ownerEmailTemplate;
        }
        
        if(firstName == null) {
            firstName = '';
        }
        
        
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        
        if(objLead.Owner.Email != null && objLead.Owner.Email.trim() != ''){
            
            if(userId != null && !string.valueOf(Invalid_Email_Address__c.getAll().values()).contains(objLead.Owner.Email)) {
                singleEmail.setReplyTo('No_Reply@Dell.com');
                singleEmail.setTargetObjectId(userId);  
                
                singleEmail.setSaveAsActivity(false);       
                String strSubject = mailTemplate.Subject.replace('{!FirstName}', firstName);
                singleEmail.setSubject(strSubject);
                
                String strBody = mailTemplate.Body.replace('{!Name}', fullName);
                strBody = strBody.replace('{!LeadCount}', String.valueOf(iLeadCount));
                strBody = strBody.replace('{!CaseLink}', '<a href="http://dell.force.com/GLMI"> Global Lead Management Intake</a>'); 
                strBody = strBody.replace('{!TableRows1}', strRows);  //5.0
                strBody = strBody.replace('{!TableRows2}', strcntRows); //5.0
                singleEmail.setHtmlBody(strBody);
                
                lstEmails.add(singleEmail);
            }
        }
    }    
  
    global void finish(Database.BatchableContext BC) {
        //v4.0 clear the map
        mapManagerInfo.clear();
    }
    
}