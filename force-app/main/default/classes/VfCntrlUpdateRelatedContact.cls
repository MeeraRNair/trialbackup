/***********************************************************
    * Name          : VfCntrlUpdateRelatedContact 
    * Description   : Enhance Contact from Lead
    * ---------------------------------------------------------
    * Revision  Name             Date         Description
    * 1.0       Kokilavani D     10-Sep-2014  CR 10083  - Enhance Contact from Lead
    * 2.0       Sakshi           26-Mar-2018  CR 15569  - Reduce code
************************************************************/
public with sharing class VfCntrlUpdateRelatedContact {   
    public Id leadId;
    public Id conId;
    public Contact conInstance;
    public Lead leadInstance;
    public String ConsentMsg {get; set;}
    
    public boolean errMsg {get; set;}    
    public List<Compare> leadToContact { get; set; }
   
    public class Compare { 
        public Compare (String label) { 
             Name = label;
        }
        
        public String Name { get; set; }
        public String contactAPIName {get; set; }
        public Boolean selectLead { get; set; }
        public Boolean selectContact { get; set; }
        public String leadVal { get; set; }
        public String conVal { get; set; }
        public boolean isSame {get; set;}
        
    }
    
    public VfCntrlUpdateRelatedContact() {
        ConsentMsg = '';
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        conId = ApexPages.currentPage().getParameters().get('ContactId');
        Map<String, Enhance_Contact_from_Lead__c> ecl = Enhance_Contact_from_Lead__c.getAll();
        
        errMsg = false;
        UserRecordAccess urec1 = [SELECT RecordId, HasReadAccess, HasEditAccess
                                    from UserRecordAccess 
                                    WHERE UserId = :UserInfo.getUserId()
                                        AND RecordId = :conId];
        if (urec1.HasReadAccess == false || uRec1.HasEditAccess == false){
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Insufficient Privileges: ' + '  ' +
                                  'You do not have the level of access necessary to perform the operation you requested.'));
             errMsg = true;
        }
            
        if (errMsg == false){
            String queryForLead = 'select Id, RecordTypeID ';    
            for(Enhance_Contact_from_Lead__c cs : ecl.values()){
                if (cs.Lead_Field_name__c != null)
                    queryForLead = queryForLead + ',' + cs.Lead_Field_name__c;
            }
            
            queryForLead += ' from Lead where Id = :leadId';
            list<Lead> lstLead = Database.query(queryForLead);
            if (lstLead != null && !lstLead.isEmpty())
                leadInstance = lstLead[0]; 
            else {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Unable to read lead data'));
                 errMsg = true;
            }
            getContactDetails();       
        }
        
        if (errMsg == false){
            leadToContact = new List<Compare>();
            Map<String, Schema.SObjectField> Contact_fieldmap = Schema.SObjectType.Contact.fields.getMap();
            
            set<Id> setRTIds = StaticDataUtils.getRecordTypeIdsByNames('Lead', new set<String>{'Channel Lead - Assignment Complete', 'Channel Lead - Cleansing & Scoring Complete', 'Channel Lead - Conversion'});
 
            for(Enhance_Contact_from_Lead__c CS : [SELECT Id, Name, Lead_Field_Name__c,Contact_Field_Name__c, order__c, Hide_Field__c from Enhance_Contact_from_Lead__c order by order__c ASC]) {
                  
                if(CS.Hide_Field__c == true && setRTIds.contains(leadInstance.RecordTypeId)) 
                    continue; 
                else {
                    if (CS.Lead_Field_Name__c ==null || CS.Lead_Field_Name__c == '' )
                        if(CS.Contact_Field_Name__c == 'CASL_Consent__c') {
                            ConsentMsg = (string) conInstance.get(CS.Contact_Field_Name__c);
                            if (ConsentMsg !=null && ConsentMsg !=''){
                                ConsentMsg = ConsentMsg.replace('\n','</br>');
                            }
                            leadToContact.add(createCompare( CS.Name, null, ConsentMsg, false, true, Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isAccessible() , Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isUpdateable(), CS.Contact_Field_Name__c, true));
                        }
                        else
                            leadToContact.add(createCompare( CS.Name, null, (string) conInstance.get(CS.Contact_Field_Name__c ), false, true, Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isAccessible() , Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isUpdateable(), CS.Contact_Field_Name__c, true));
                    else
                        leadToContact.add(createCompare( CS.Name, (string) leadInstance.get(CS.Lead_Field_Name__c), (string) conInstance.get(CS.Contact_Field_Name__c ), false, true, Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isAccessible() , Contact_fieldmap.get(CS.Contact_Field_Name__c ).getDescribe().isUpdateable(), CS.Contact_Field_Name__c,false));
                }
            }
        }
    }
    
    public void getContactDetails() {
        Map<String, Enhance_Contact_from_Lead__c> ecl = Enhance_Contact_from_Lead__c.getAll();
        String queryForContact  = 'select Id';
          
        for(Enhance_Contact_from_Lead__c cs : ecl.values()) {
            queryForContact = queryForContact + ',' + cs.contact_Field_name__c;
        }
        queryForContact +=' from contact where Id = :conId limit 1';
        list<Contact> lstContacts = Database.query(queryForContact);
        
        if (lstContacts != null && !lstContacts.isEmpty()){
            conInstance = lstContacts[0];
        }
        else {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,'Unable to read Contact data'));
             errMsg = true;
        }
    }
       
    private Compare createCompare(string label, String val1, String val2, Boolean isVal1, Boolean isVal2, boolean isReadable, boolean isEditable, string contactAPIName, boolean noLabel) { 
        Compare c = new Compare(label);       
        c.leadVal = val1;
        c.conVal = val2;
        c.selectLead = isVal1;
        c.selectContact = isVal2;
        c.contactAPIName = contactAPIName;
        
        if (isReadable == false)
            c.conVal = ''; 
        
        if (isEditable == false){
            c.isSame = true;
            c.selectLead = false;
        }
        else if (c.leadVal == null && c.conVal == null)
            c.isSame = true;
        else if (c.leadVal != null && c.conVal != null){
            if (c.leadVal.equalsIgnoreCase(c.conVal))
                c.isSame = true;
            else
                c.isSame = false;
        }
        
        if (noLabel == true){
            c.isSame = true;
            c.name = '';
        }
        return c;
    }
    
    public PageReference save() {
        try {
            for (Compare c: leadToContact){
                if (c.selectLead == true){
                    conInstance.put(c.contactAPIName, c.leadVal);
                }
            }   
            update conInstance;
            return new PageReference('/' +conId);  
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);
            getContactDetails();      
            return null;
        }  
    }
    
    public PageReference Cancel(){
        return new PageReference('/' +leadId);  
    }
}