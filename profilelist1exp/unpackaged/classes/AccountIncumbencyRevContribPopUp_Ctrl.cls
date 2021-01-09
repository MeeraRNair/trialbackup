public class AccountIncumbencyRevContribPopUp_Ctrl {
    public Id accId{get;set;}
     
    public String incumbencyType{get;set;}
    public boolean displayPopup {get; set;}     
    public String partner1name{get; set;}  
    public String partner2name{get; set;}  
    public Decimal partner1rev{get; set;}  
    public Decimal partner2rev{get; set;} 
    public String affinityID {get;set;} 
    
   public PageReference closePopup() {
        displayPopup = false;
        return new PageReference('/' + accId);
    }

    public AccountIncumbencyRevContribPopUp_Ctrl(Apexpages.StandardController ctrl) {
        accid = ApexPages.currentPage().getParameters().get('id');
        incumbencyType = ApexPages.currentPage().getParameters().get('incumbencytype');
        affinityID = ApexPages.currentPage().getParameters().get('AffinityID');
        displayPopup = false;
        // List<Account> accID= [select id,Name,Account_ID__c from Account where ID=:accid ];
         List < LOBi_Order_Revenue__c > ac = new List < LOBi_Order_Revenue__c >();
      try{
         ac = [SELECT Affinity_ID__c, Client_Partner1__c, Client_Partner2__c, Client_Partner1_Rev__c, Client_Partner2_Rev__c,
            Networking_Partner1_Rev__c, Networking_Partner2_Rev__c, Networking_Partner_Name_1__c, Networking_Partner_Name_2__c,
            Server_Partner1__c, Server_Partner2__c, Server_Partner2_Rev__c, Server_Partner1_Rev__c,
            Storage_Partner1__c, Storage_Partner2__c, Storage_Partner2_Rev__c, Storage_Partner1_Rev__c FROM LOBi_Order_Revenue__c WHERE Affinity_ID__c =: affinityID
        ];
        }catch(exception ex){
        
        }

        if (String.isNotBlank(incumbencytype) && ac.size()!=0) {   
            if (incumbencytype == 'Client') {
                partner1name = ac[0].Client_Partner1__c;
                partner2name = ac[0].Client_Partner2__c;
                partner1rev = ac[0].Client_Partner1_Rev__c;
                partner2rev = ac[0].Client_Partner2_Rev__c;
                 if (partner1name != NULL && partner1rev != NULL ) displayPopup = true;
            }
            if (incumbencytype == 'Networking') {
                partner1name = ac[0].Networking_Partner_Name_1__c;
            //    if (partner1name != NULL) displayPopup = true;
                partner2name = ac[0].Networking_Partner_Name_2__c;
                partner1rev = ac[0].Networking_Partner1_Rev__c;
                partner2rev = ac[0].Networking_Partner2_Rev__c;
                if (partner1name != NULL && partner1rev != NULL ) displayPopup = true;
            }
            if (incumbencytype == 'Server') {
                partner1name = ac[0].Server_Partner1__c;
             //   if (partner1name != NULL) displayPopup = true;
                partner2name = ac[0].Server_Partner2__c;
                partner1rev = ac[0].Server_Partner1_Rev__c;
                partner2rev = ac[0].Server_Partner2_Rev__c;
                if (partner1name != NULL && partner1rev != NULL ) displayPopup = true;
            }
            if (incumbencytype == 'Storage') {
                partner1name = ac[0].Storage_Partner1__c;
              //  if (partner1name != NULL) displayPopup = true;
                partner2name = ac[0].Storage_Partner2__c;
                partner1rev = ac[0].Storage_Partner1_Rev__c;
                partner2rev = ac[0].Storage_Partner2_Rev__c;
                if (partner1name != NULL && partner1rev != NULL ) displayPopup = true;
            }
        }
    }
}