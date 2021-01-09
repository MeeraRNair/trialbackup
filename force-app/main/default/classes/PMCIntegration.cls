public class PMCIntegration{    
    public static final Integer TIMEOUT=120000;
    public class address{
        public String addressLineOne;
        public String addressLineTwo;
        public String addressLineThree;
        public String addressLineFour;
        public String addressLineFive;
        public String city;
        public String provinceStateValue;
        public String zipPostalCode;        
    }
    
    public class partyAddress{
        public address           address;
    }    
    public class contractExtension{
        public String             salesChannel;
        public String             salesSegment;
        public String             profileType;
        public String             memberShipType;
        public String             sfdcid;
        public String             dunsid;
        public String             affinityId;
        public String             myAccountId;
        public String             preferenceArea;
        public String             taxId;
        public String             webSourceId;
        public String             customIdOne;
        public String             customIdTwo;
        public String             customIdThree;
    }
    public class party{
        public String             preferredLanguageValue;
        public String             displayName;
        public person             person;
        public organization       organization;
    }   
    public class person{
    
        public personName         personName;
    }
    
    public class personName{
    
        public String             givenNameOne;
        public String             middleInitial;
        public String             lastName;
        public String             prefix;
        public String             suffix;
    } 
    public class organizationName{
    
        public String             name;
    }

    public class organization{
    
        public organizationName   organizationName;
    }    
    
/*  This method does the post call to pmc and sends the data in json format   */

    @future (callout=true)              
    public static void pmcPostCallout(string contactid){
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(system.Label.PMC_endpoint);
        request.setMethod('POST');
        request.setHeader('x-dell-identity-key', system.Label.DAIS_Identity_Key);
        request.setHeader('x-dell-identity-restriction-api-key',system.Label.PMC_Restriction_API_Key);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setTimeout(TIMEOUT);

        String jsongen = generateJSONContent(contactid);
        request.setBody(jsongen);
        
        System.debug('###### PMC JSON Request is :'+jsongen);        
        
        HttpResponse response = http.send(request);
        
         System.debug('>>>>>>>>>>>> PMC Response is : '+response);
         if(!System.Label.StatusCodePMC.contains(String.ValueOf( response.getStatusCode())) || !response.getBody().contains('success')){
         try{
           if(System.Label.CreateExceptionPMC=='True'){  
            System.debug('inserting exception');
            //if Responce we got is not success insert a record in EXCEPTION Object
            //and Attach the Request JSON STRING As Attachment to That Particular Record
            
             Exception__c exc = new Exception__c();
             exc.Process_Name__c = 'PMC Integration';
             exc.Error_Messages__c  = String.valueOf(response.getStatusCode());
             exc.Object_type__c = 'Contact';
             exc.Object_ID__c = contactid;
             exc.Notes__c = response.getBody();
             
             insert exc;
            
             Attachment attachment = new Attachment();
             attachment.Body = Blob.valueOf(jsongen);
             attachment.Name = String.valueOf(contactid+'.txt');
             attachment.ParentId = exc.id; 
             insert attachment;
            }
            }catch(exception ex){
             System.debug('Failed to insert Exception');
             }
         
         }
    }  
    
/*  This method will convert the inner class to corresponding json format   */
    
   public static String generateJSONContent(String conid){
       String emailoptin;
       list<String> contactusagetypevar = new list<String>{'Email','HomePhone','WorkPhone','MobilePhone','SMS','Fax','address'};                   
       contact con =[select id,Name,salutation,firstname,lastname,Account.Name,Account.Billing_Address_CN__c,Account.Account_Country_Code__c,email,phone,mobilephone,Fax,LastModifiedDate,LastModifiedBy.name,CreatedDate,Email_Opt_In__c,LastModifiedBy.LANGUAGELOCALEKEY,account.BillingCity,account.BillingState,account.BillingPostalCode,Primary_Contact__c  from contact where id= :conid];            

        contractExtension contractExtensionobj = new contractExtension();
        organizationName organizationNameobj = new organizationName();
        organization organizationobj = new organization();
        personName personNameobj = new personName();
        person personobj = new person();
        party partyobj = new party();
        address addressobj = new address();
        partyAddress partyAddressobj = new partyAddress();
       
        JSONGenerator gen = JSON.createGenerator(true);         
        gen.writeStartObject();                
            gen.writeFieldName('contract');
            gen.writeStartObject(); 
                gen.writeStringField('contractLangValue', con.LastModifiedBy.LANGUAGELOCALEKEY);
                gen.writeDateTimeField('contractLastUpdateDate', con.LastModifiedDate);                 
                contractExtensionobj.salesSegment = 'PD';       
                if(con.Email_Opt_In__c == 'Yes'){  
                    emailoptin = 'Y';                                        
                }else if(con.Email_Opt_In__c == 'No'){
                     emailoptin = 'N';                   
                }else{
                    emailoptin = 'U';                   
                }       
                if(con.Primary_Contact__c){
                    contractExtensionobj.webSourceId  = '800002';        
                }else{
                    if(emailoptin == 'Y'){
                      contractExtensionobj.webSourceId  = '800004';     
                    }else if(emailoptin == 'N' || emailoptin == 'U' ){
                       contractExtensionobj.webSourceId  = '800005';  
                    }
                }                  
                gen.writeFieldName('contractExtension');            
                gen.writeObject(contractExtensionobj);
                gen.writeFieldName('contractComponent');
                gen.writeStartObject();
                    gen.writeFieldName('contractPartyRoleList');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            gen.writeStringField('contractRoleIdPK', con.id);
                            gen.writeStringField('sourceSystemCode', 'SFDC');
                            gen.writeDateTimeField('startDate', con.CreatedDate);
                            gen.writeDateTimeField('contractPartyRoleLastUpdateDate', con.LastModifiedDate);
                            gen.writeStringField('contractPartyRoleLastUpdateUser', con.LastModifiedBy.Name);
                            gen.writeStringField('country', con.Account.Account_Country_Code__c);
                            
                            organizationNameobj.name = con.Account.Name;
                            organizationobj.organizationName = organizationNameobj;
                            personNameobj.givenNameOne = con.FirstName;
                            personNameobj.lastName = con.LastName;
                            personNameobj.prefix = con.Salutation;            
                            personobj.personName = personNameobj;
                            partyobj.preferredLanguageValue = con.LastModifiedBy.LANGUAGELOCALEKEY;
                            partyobj.displayName = con.Name;
                            partyobj.person =  personobj;
                            partyobj.organization = organizationobj;
                            
                            gen.writeFieldName('party');
                            gen.writeObject(partyobj);
                            gen.writeFieldName('contractRoleLocationList');
                            gen.writeStartArray();
                                for (integer i=0;i<contactusagetypevar.size();i++){
                                    if(contactusagetypevar.get(i) == 'Email'){
                                        gen.writeStartObject();
                                            gen.writeDateTimeField('contractRoleLocationLastUpdateDate', con.CreatedDate);
                                            gen.writeStringField('marketingPreferenceFlag', emailoptin);
                                            gen.writeFieldName('partyContactMethod');
                                                gen.writeStartObject();
                                                    gen.writeStringField('contactMethodUsageType', 'Email');
                                                    gen.writeFieldName('contactMethod');
                                                        gen.writeStartObject();
                                                            gen.writeStringField('referenceNumber', con.Email);
                                                        gen.writeEndObject();
                                                gen.writeEndObject();
                                        gen.writeEndObject();                                        
                                    }                                    
                                }
                            gen.writeEndArray();
                        gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject(); 
            gen.writeEndObject();                                                 
        gen.writeEndObject();       

      return gen.getAsString();            
  }      
}