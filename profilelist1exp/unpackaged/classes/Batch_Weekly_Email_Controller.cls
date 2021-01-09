public class Batch_Weekly_Email_Controller{
    public Id thisUserId {get;set;} 
    public string thistypeOfEmail{get;set;}
    public List<tableData> thisUserLeads = new List<tableData>();
    public class tableData{
        public string campName{get;set;}
        public string campOwner{get;set;}
        public Integer leadSize{get;set;}
        public string partnUsr{get;set;}
        public string partnUsrAcc{get;set;}
        public tableData(string campName,string campOwner,Integer leadSize,string partnUsr,string partnUsrAcc){
          this.campName =campName;
          this.campOwner=campOwner;
          this.leadSize=leadSize;
          this.partnUsr=partnUsr;
          this.partnUsrAcc=partnUsrAcc;
        }
    }
    public List<tableData> getThisUserLeads() {  
        Map<Id,Set<Id>> mapCamp = new Map<Id,Set<Id>>();
        Map<Id,Integer> mapCampLeadCount = new Map<Id,Integer>();
        String cdtTime10_formatedDt;
        String cdtMinus24_formatedDt;
        if(thistypeOfEmail =='today'){
            Integer scheduleTime = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_Time) - 8; 
            DateTime cdtTime10 = Datetime.newInstance(System.today(), Time.newInstance(scheduleTime, 0, 0, 0)); // 10PM CDT
            cdtTime10_formatedDt = cdtTime10.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            Integer hourRange = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_HourRange);
            Datetime cdtMinus24 = cdtTime10.addHours(-hourRange);
            cdtMinus24_formatedDt = cdtMinus24.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        else if(thistypeOfEmail =='twoDay'){
            Integer scheduleTime = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_Time)-8;
            Integer hourRange = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_HourRange);  
            Date currentDate = System.today().addDays(-2);
            DateTime cdtTime10 = Datetime.newInstance(currentDate, Time.newInstance(scheduleTime, 0, 0, 0)); // 10PM CDT
            cdtTime10_formatedDt = cdtTime10.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            Datetime cdtMinus24 = cdtTime10.addHours(-hourRange);
            cdtMinus24_formatedDt = cdtMinus24.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        else if(thistypeOfEmail =='fiveDay'){
            Integer scheduleTime = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_Time)-8;
            Integer hourRange = Integer.ValueOf(System.Label.CMAP_PartnerDailySummaryBatch_HourRange);  
            Date currentDate = System.today().addDays(-5);
            DateTime cdtTime10 = Datetime.newInstance(currentDate, Time.newInstance(scheduleTime, 0, 0, 0)); // 10PM CDT
            cdtTime10_formatedDt = cdtTime10.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            Datetime cdtMinus24 = cdtTime10.addHours(-hourRange);
            cdtMinus24_formatedDt = cdtMinus24.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
        string query;
        if(thisUserId != null){
            if(Test.isRunningTest()){
            query = 'Select Id,Owner.Name, Owner.Email,Partner_User__c, Campaign__c,Campaign__r.Name,Campaign__r.Owner.Name From Lead Where Partner_User__c= \''+ thisUserId +'\' and Status = \'Assigned to Channel partner\'';
            }
            else{
            query = 'Select Id,Owner.Name, Owner.Email,Partner_User__c, Campaign__c,Campaign__r.Name,Campaign__r.Owner.Name From Lead Where Partner_User__c= \''+ thisUserId +'\' and Status = \'Assigned to Channel partner\' and Lead_Assigned_Date__c >= ' + cdtMinus24_formatedDt + ' and Lead_Assigned_Date__c <= ' + cdtTime10_formatedDt + ' order by Campaign__c';
            }
            //Campaign Id and Lead Size
            Map<Id,String> mapUserToAccName = new Map<Id,String>();
            Map<Id,String> mapUserToAccName_Dup = new Map<Id,String>();
            Map<Id,String> mapUserIdToName = new Map<Id,String>();
            Map<Id,String> mapCampIdToName = new Map<Id,String>();
            Map<Id,String> mapCampIdToOwner = new Map<Id,String>();
            Map<Id,String> mapUserIdToEmail = new Map<Id,String>();
            for(Lead obj:Database.Query(query)){
               if(!mapCamp.containsKey(obj.Campaign__c)){
                  mapCamp.put(obj.Campaign__c,new Set<Id>{obj.Id});
               }
               else{
                 mapCamp.get(obj.Campaign__c).add(obj.Id);
               }
               mapCampIdToName.put(obj.Campaign__c,obj.Campaign__r.Name);
               mapCampIdToOwner.put(obj.Campaign__c,obj.Campaign__r.Owner.Name);
               
            } 
            for(User objUsr:[Select Id,Name,AccountId from User Where IsActive = true and Id=:thisUserId]){
               mapUserIdToName.put(objUsr.Id,objUsr.Name);
               mapUserToAccName.put(objUsr.Id,objUsr.AccountId);
            }
            for(Account objAcc:[Select Id,Name from Account Where Id IN:mapUserToAccName.values()]){
               mapUserToAccName_Dup.put(objAcc.Id,objAcc.Name);
            }               
            for(Id objCm:mapCamp.keyset()){
              mapCampLeadCount.put(objCm,mapCamp.get(objCm).size());
            }
            for(Id objCm_R:mapCamp.keyset()){
               thisUserLeads.add(new tableData(mapCampIdToName.get(objCm_R),mapCampIdToOwner.get(objCm_R),mapCampLeadCount.get(objCm_R),mapUserIdToName.get(thisUserId),mapUserToAccName_Dup.get(mapUserToAccName.get(thisUserId))));
            } 
        }         
        return thisUserLeads;    
    }
}