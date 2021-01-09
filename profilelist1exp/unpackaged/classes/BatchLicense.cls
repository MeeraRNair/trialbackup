/********************************************************************************************* 
     Author Name   : Adityareddy Pulagam.
     Description   : Sending Emails to IT Directors for intimating Organigation  Licenses.
     Release       : 14.5 Maintanance Release.
     Date          : 25-4-2013.   
     BR#            : 034
     CR#            : 8009
     

*2.0     Devika      CR8970          Added SalesConsole User License Limit
*3.0     Kavitha     Stroy5650501    Remove hard code prod URL, use custom label
***********************************************************************************************/


global class BatchLicense implements Database.Batchable<sObject>,Database.Stateful{
    global   string  query;
    global   Map<String,Integer> licenseMap;
    global   Map<String,Integer>  licenselabels = new Map<String,Integer>();
    global   Map<String,Integer>  sendmaillist =new Map<String,Integer>();
    global   set<string> licenseset = new set<string>();

    global BatchLicense(){
         licenseMap=new map<string,integer>();
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
   
        licenselabels.put('Salesforce',integer.valueof(Label.Total_Salesforce_License));
        licenselabels.put('Strategic Partner',integer.valueof(Label.Total_Strategic_Partner_License));
        licenselabels.put('Chatter Only',integer.valueof(Label.Total_Chatter_Only_License));
        licenselabels.put('High Volume Customer Portal',integer.valueof(Label.Total_High_Volume_Customer_Portal_License));
        licenseset=licenselabels.keyset();
        query = 'SELECT License_Used__c  FROM user where isactive = true and License_Used__c in:licenseset';
        if(Test.isRunningTest())
           query = 'SELECT License_Used__c  FROM user where isactive = true and License_Used__c in:licenseset Limit 200';
           //list<user> listUsers = Database.query(query);
           return Database.getQueryLocator(query);
        }
   
    global void execute(Database.BatchableContext BC, List<sobject> scope){
 
        list<user> usersList=(list<user>)scope;
        for(User u:usersList) {
             if(licenseMap.containsKey(string.valueOf(u.License_Used__c))) {
                integer counter= licenseMap.get(u.License_Used__c);
                counter++;
                licenseMap.put(string.valueof(U.License_Used__c),counter);
             }
             else{
                licenseMap.put(string.valueof(U.License_Used__c),1);
             }
          }
      }
    global void finish(Database.BatchableContext BC){
         integer min = integer.valueof(Label.License_Minimum_Limit);
         integer max = integer.valueof(Label.License_Maximum_Limit);
         for(string license :licenseset){
             if(licensemap.get(license)!=null){
                integer count = licenselabels.get(license)-licensemap.get(license);
                
                if((count< max && license !='High Volume Customer Portal')||(count < min && license =='High Volume Customer Portal')){
                    sendmaillist.put(license,count);
                 }
             }
         }
         
         /** 2.0 ***/
         //Sales Console License
         PermissionSetLicense  ps = [SELECT TotalLicenses,UsedLicenses,DeveloperName FROM PermissionSetLicense where Id = :System.Label.SalesConsole_PermissionSetLicenseId];        
         if ((ps.TotalLicenses - ps.UsedLicenses) <= Integer.valueOf(System.Label.SalesConsole_License_Limit)){
           sendmaillist.put(ps.DeveloperName,ps.TotalLicenses - ps.UsedLicenses);
         }
         list<string> toaddressSalesConsole = new list<string>(Label.SalesConsole_License_Email_Recipient.trim().split(';'));                  
         system.debug(toaddressSalesConsole);
         /** 2.0 ***/

         
                        list<string> toaddress = new list<string>(Label.License_Email_Recipient.split(',')); 
                        String batchLicDellLogoLabel = Label.BatchLicense_DellLogo_URL; //v3.0                 
                    if(sendmaillist.size()>0){
                       for(string license : sendmaillist.keyset()){
                            integer i = sendmaillist.get(license);
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            
                            /**** 2.0 ***/
                            if(license == 'SalesConsoleUser'){
                              email.setSubject('Sales Console User is nearing the License Limit');
                              email.setHtmlBody('<font face="Courier New">Dear Team,'+
                                      +'<br/><br/> Please note that that Sales Console User is nearing the License Limit (Remaining License:'+ i +').Please take necessary steps to increase the Sales Console User license  accordingly.'+
                                      +'<br/><br/> Thanks,<br/>Dell SFDC Support.</font>');
                              email.setToAddresses(toaddressSalesConsole);
                            }else{/**** 2.0 ***/                               
                              email.setSubject('User License:'+ license +' is nearing the License Limit');
                              //email.setHtmlBody('<img src="https://c.na7.content.force.com/servlet/servlet.ImageServer?id=015A0000000Teqz&oid=00D300000006urq&lastMod=1334556028000"'+  //v3.0
                              email.setHtmlBody('<img src="'+ batchLicDellLogoLabel+'"'+                                   
                                      +'alt="Company Logo" height="64" width="64" align="left"/><br/><br/><br/><br/>'+
                                      +'<font face="Courier New"> Hi IT Team,'+
                                      +'<br/><br/> Please note that User License:  \"'+license +'\" is nearing the License Limit (Remaining License: \"'+ i +'\").Please take necessary steps to increase the User license accordingly.'+
                                      +'<br/><br/> Thanks,<br/>Dell SFDC Support.</font>');
                              email.setToAddresses(toaddress);
                            }                             
                            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email}); 
 }
}

        String seconds, minutes, hours, dayOfMonth, month, dayOfWeek, year;            
        // add 2 days before scheduling the next job      
        datetime todayNow = system.now().addDays(2);
        seconds = '0'; 
        minutes = '30'; 
        hours = '12'; 
        dayOfMonth = todayNow.format('d'); 
        month = todayNow.format('M'); 
        dayOfWeek = '?'; 
        year = todayNow.format('yyyy'); 

        //Seconds Minutes Hours Day_of_month Month Day_of_week optional_year    
        String schTime = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
        System.schedule('Batch License Schedule '+ schTime, schTime, new BatchlicenseScheduleExecute());
    }
}