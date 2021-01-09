public class SnPCustomEditController{
    public ApexPages.StandardController controller;
    public S_P_Vendors__c svRec;
    public List<String> contactList {get; set;}
    public Map<String, Contact> accountContactMap {get; set;}
    public List<SelectOption> contactOptionList {get; set;}
    public boolean isEmptyContact {get{
                                return this.contactList.isEmpty();  
                            } set;}
    public String userProfileName;
    
    public SnPCustomEditController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.svRec = (S_P_Vendors__c)this.controller.getRecord();
        contactList = new List<String>();
        accountContactMap = new Map<String, Contact>();
        contactOptionList = new List<SelectOption>();
        String conName;
        
        if(this.svRec.S_P_Vendors_Name__c == 'VMware' && this.svRec.Customer_Name__c == null)
            defaultToResellerVMware();
        else if(this.svRec.S_P_Vendors_Name__c == 'Microsoft')
            defaultToSelectPlusMS();
            
        for(Contact con : [SELECT Name, Phone, Email, Job_Function_Role__c, Status__c FROM Contact 
                           WHERE AccountId = :svRec.Opportunity__r.AccountId LIMIT 1000]){
            if(!con.Status__c.contains('Invalid')){
                if(!con.Name.contains('"')) {
                    contactList.add('\"' + con.Name + '\"');
                    accountContactMap.put(con.Name, con);
                    contactOptionList.add(new SelectOption(con.Name, con.Name)); 
                } else {
                    conName = '';
                    for(integer i = 0; i < con.Name.length(); i++){
                        if(con.Name.substring(i, i + 1) != '"')
                            conName += con.Name.substring(i, i + 1);
                        else
                            conName += '\'';
                    }
                    contactList.add('\"' + conName + '\"');
                    accountContactMap.put(conName, con);
                    contactOptionList.add(new SelectOption(conName, con.Name)); 
                }               
            }
        }
        contactList.sort();
        contactOptionList.sort();
    }
    
    public PageReference assignContact(){
        String conName = Apexpages.currentPage().getParameters().get('conName');
        
        if(this.accountContactMap.get(conName) != null){
            this.svRec.Phone__c = this.accountContactMap.get(conName).Phone;
            this.svRec.Email__c = this.accountContactMap.get(conName).Email;
            this.svRec.Role__c = this.accountContactMap.get(conName).Job_Function_Role__c;
        }
        
        return null;
    }
    
    public PageReference save(){
        if(this.svRec.S_P_Deal_Status__c == 'Sent to Vendor' && !(getProfileName(UserInfo.getProfileId()).equalsIgnoreCase('GBL Manage S&P – Non SSO'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The current record is locked'));
            return null;
        }
        
        return this.controller.save();
    }
    
    public PageReference saveF5(){        
        if(this.svRec.S_P_Deal_Status__c == 'Sent to Vendor' && !(getProfileName(UserInfo.getProfileId()).equalsIgnoreCase('GBL Manage S&P – Non SSO'))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The current record is locked'));
            return null;
        }
        
        PageReference pageRef = new PageReference('/apex/SnPF5DealRegistrationPage?id=' + this.svRec.Id);
        update this.svRec;
        
        return pageRef;
    }
    
    public String getProfileName(Id profileId){
        return [SELECT Id, Name FROM Profile WHERE Id = :profileId].Name;
    }
    
    // Method for VMware Program Type defaults
    public PageReference defaultToResellerVMware(){
        String progType = Apexpages.currentPage().getParameters().get('progType');
        
        if(progType != ''){
            if(progType == 'EPP Post-Sale Burn-Down')
                this.svRec.Your_primary_involvement_in_the_deal__c = '';
            else
                this.svRec.Your_primary_involvement_in_the_deal__c = 'Reseller';
        }        
        return null;
    }
    
    // Method for Microsoft License Program default
    public PageReference defaultToSelectPlusMS(){
        String ea = Apexpages.currentPage().getParameters().get('ea');
        if(ea == 'No' && this.svRec.Licensing_Program__c == null)
            this.svRec.Licensing_Program__c = 'Select Plus';
        return null;
    }
    
    public PageReference reRenderPanel(){
        return null;
    }
}