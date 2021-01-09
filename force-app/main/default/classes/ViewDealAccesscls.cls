public class ViewDealAccesscls {

   
    
    public boolean bpiechartcls{get;set;}
    public string straccountName {get;set;} //select list selected account name
    public  list<account> listacclist{set;get;}
    
    public contact con {get ; set ;}
    public ContactOpportunityStages__c conopps  {get ; set ;}
     public Boolean bshowLabel {get;set;}
    
     public ViewDealAccesscls(ApexPages.StandardController controller) {
        bshowLabel = false;
        con = new contact();
        con  = (Contact)controller.getRecord();
        bpiechartcls = false;
        list<ContactOpportunityStages__c> listconopplist = [select id,SalesmotionAccount__c,contact__c,Opportunity_Stage__c
                                                       from ContactOpportunityStages__c where contact__c =: con.id ];
        system.debug('listconopplist'+listconopplist);
        
        
        map<id,id> mapacconmap = new map<id,id>();
        for(ContactOpportunityStages__c co : listconopplist){
            mapacconmap.put(co.SalesmotionAccount__c,co.contact__c);
        }
          
         listacclist = [select id,name,Account_ID__c from account where id IN:mapacconmap.keyset()];
        system.debug('===== listacclist ===>'+listacclist.size());
        
    }

    
    public List<SelectOption> getAccountList() {
         List<SelectOption> listaccounts = new List<SelectOption>();
         listaccounts.add(new SelectOption('None', '--None--'));
       
        for (Account acc : listacclist){
            string strss;
            if(acc.Account_ID__c != null){
               strss = string.valueOf(acc.Name)+'-'+string.valueOf(acc.Account_ID__c);
            }
            else{ strss = string.valueOf(acc.Name);}
            listaccounts.add(new SelectOption(acc.id,strss));
        }
        system.debug('========listaccounts==='+listaccounts);
        return listaccounts;      
   }
    
    public integer intcountstgs {get ; set ;}
     public void showOppStages(){
         if(straccountName == 'None'){ 
             bshowLabel = false;
             conopps.Opportunity_Stage__c = null;
             intcountstgs = null;
             system.debug('=====>In If bshowLabel ===>'+bshowLabel);
             return; 
         }else{
            bshowLabel = true;
            system.debug('=====>In If-else bshowLabel ===>'+bshowLabel);
         }
         
        intcountstgs =0;
         set<id> setOppidset = new set<id>();
         conopps = [select id,name,Opportunity_Stage__c,SalesmotionAccount__r.name 
                         from ContactOpportunityStages__c where SalesmotionAccount__c =: straccountName and contact__c =: con.id ]; 
         system.debug('=====> showOppStages conopps ===>'+conopps);
        
        List<string> liststgs = new list<string>(); 
        liststgs.add(conopps.Opportunity_Stage__c);
        List<Opportunity > liststagescount = [SELECT id,StageName 
                                    FROM Opportunity where partnerAccountid=:straccountName AND StageName IN : liststgs];  
         system.debug('=====> showOppStages stagecount opplist ===>'+liststagescount);
       
         if(liststagescount.size() > 0){
             intcountstgs = liststagescount.size(); 
              system.debug('===liststagescount.size==='+liststagescount.size());
         } 
           
        system.debug('===intcountstgs==='+intcountstgs);         
     }
    
    
     public List<PieWedgeData> getPieData() {
         bshowLabel = true;
        List<PieWedgeData> listdata = new List<PieWedgeData>(); 
        if(straccountName  != null){      
        list<AggregateResult> listag = [SELECT StageName, COUNT(Name) 
                                    FROM Opportunity where partnerAccountid=:straccountName  GROUP BY StageName];
        system.debug('>>>>>>>>>>'+straccountName  +'<<<<<<<<<<<<<<'+listag);
        if(listag != null){
        for(AggregateResult eachag:listag){
            system.debug('======Aggregateresult==');
            listdata.add(new PieWedgeData(String.valueOf(eachag.get('StageName')), (Integer)eachag.get('expr0')));
            system.debug('======Aggregateresult == listdata=='+listdata);
          } 
        }
       } 
        return listdata;
    }
    
      public class PieWedgeData {

        public String strName { get; set; } public Integer intdata { get; set; }

        public PieWedgeData(String strName, Integer intdata) { 
            this.strName = strName; this.intdata = intdata;
        }
    }
   
}