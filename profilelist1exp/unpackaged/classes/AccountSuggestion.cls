/*----------------------------------------------------
Description: Helper Class  for creating and sending AccountSuggestion to DST
CR #1378
Version:1.0 

History:
1.0 - 27-July-2009: Creation
2.0 - 27-July-2010: CR2574
3.0 - 27-Sept-2010: CR3482
4.0 - 17-Sept-2014: CR10476 (Modified by Jessie)  - Modified to convert hardcoded Data Power URL to Custom Label
Author: Meera Nair/Krishnaprasad P

------------------------------------------------------*/

public class AccountSuggestion{
    
    //Class Variables
    public static final Integer TIMEOUT = 60000;
    public static final String METHOD = 'POST';
    public static  boolean bAUTHENTICATIONREQUIRED = false;
    public static  String strUSERNAME;
    public static  String strPASSWORD;
    public static  String strENDPOINT;
    public static User currentUser;
    
    //Defining the result class
    public class SuggestionResponse {
        public String strOracleError;
        public String strErrorDescription;
        public String strID;
        public Boolean bIsAccountDuplicate;
    }   
    
    public static void getCurrentUser(){
        currentUser =  [SELECT Id, Badge_Number__c, FirstName, LastName, Email
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                        LIMIT 1];       
    }
    
    //Define maps for converting values of various picklist fields
    public static Map<String,String> mapSalesModelCode=new Map<String,String> {
        'Relationship'  =>  'REL',
            'Transactional'  =>  'TRANS',
            'Public Transaction Group'  =>  'PTG',
            'Large'  =>  'LG',
            'Medium'  =>  'MED',
            'Small'  =>  'SM',
            'Other'  =>  'O'};
                
                public static Map<String,String> mapMarketingClassCode=new Map<String,String> {
                    'Defense Air Force'  =>  'AF',
                        'Defense Army'  =>  'AR',
                        'Civilian Admin Agency'  =>  'CA',
                        'Civilian Cabinet'  =>  'CB',
                        'CIV EPP'  =>  'CE',
                        'Civilian Justice'  =>  'CJ',
                        'Civilian Legislature'  =>  'CL',
                        'Civilian Other'  =>  'CO',
                        'Civilian Quasi'  =>  'CQ',
                        'Civilian Space'  =>  'CS',
                        'Civilian Reseller'  =>  'CV',
                        'Defense EPP'  =>  'DE',
                        'Defense Reseller'  =>  'DV',
                        'HED Microcenter'  =>  'EM',
                        'HED Reseller'  =>  'EV',
                        'HED FSS'  =>  'FS',
                        'Federal Reseller'  =>  'FV',
                        'SLG Library'  =>  'GB',
                        'SLG County'  =>  'GC',
                        'SLG City'  =>  'GL',
                        'SLG Other'  =>  'GO',
                        'SLG State'  =>  'GS',
                        'SLG Reseller'  =>  'GV',
                        'BROADLANE PURCHASERS'  =>  'HB',
                        'Clinic & Doctor Office'  =>  'HC',
                        'Ehealth'  =>  'HE',
                        'Hospital'  =>  'HH',
                        'ISV Consultant'  =>  'HI',
                        'Nursing Home'  =>  'HN',
                        'Health Other'  =>  'HO',
                        'HPG Member'  =>  'HP',
                        'HCD Reseller'  =>  'HR',
                        'Health System IDN'  =>  'HS',
                        'Defense & Intelligence'  =>  'IN',
                        'K12 Boces Educ Svc Ctr Coop'  =>  'KB',
                        'K12 Private Catholic School'  =>  'KC',
                        'K12 DEA Reseller'  =>  'KD',
                        'K12 FSS'  =>  'KE',
                        'K12 Private Other'  =>  'KO',
                        'K12 Public School District'  =>  'KP',
                        'K12 Reseller'  =>  'KV',
                        'Defense Navy'  =>  'NV',
                        'HED Private Non-Profit'  =>  'PN',
                        'HED Private For-Profit'  =>  'PP',
                        'HED Public Institution'  =>  'PU',
                        'Internal ACCT_ID'  =>  'QX',
                        'Secretary of Defense'  =>  'SD'};
                            
                            public static Map<String,String> mapFunctionCategoryCode = new Map<String,String>{
                                'Army & Air Force Exchange Service'  =>  'AAFES',
                                    'Army Corp Of Engineers'  =>  'ACOE',
                                    'Adult Education'  =>  'ADED',
                                    'Admin & Finance'  =>  'ADFIN',
                                    'Administrative Agency'  =>  'ADMIN',
                                    'Air Force Air Station'  =>  'AFAIR',
                                    'Air Force Base'  =>  'AFBAS',
                                    'Air Force Europe'  =>  'AFEUR',
                                    'Air Force Headquarters'  =>  'AFHQ',
                                    'Air Force Middle East'  =>  'AFMID',
                                    'Air Force National Guard'  =>  'AFNG',
                                    'Air Force Other'  =>  'AFOTH',
                                    'Air Force Pacific'  =>  'AFPAC',
                                    'Air Force Programs'  =>  'AFPRG',
                                    'Air Force Reserve'  =>  'AFR',
                                    'Army Arsenals & Weapons Test'  =>  'AGUNS',
                                    'Airports'  =>  'AIRPT',
                                    'Army National Guard'  =>  'ANG',
                                    'Army Reserve'  =>  'AR',
                                    'Army Air Base'  =>  'ARAIR',
                                    'Army Base'  =>  'ARBAS',
                                    'American Red Cross'  =>  'ARC',
                                    'Army Command'  =>  'ARCOM',
                                    'Army Europe'  =>  'AREUR',
                                    'Army Headquarters'  =>  'ARHQ',
                                    'Army Research & Testing'  =>  'ARLAB',
                                    'Army Medical'  =>  'ARMED',
                                    'Army Other'  =>  'AROTH',
                                    'Army Pacific'  =>  'ARPAC',
                                    'Arts Humanities Museums'  =>  'ARTS',
                                    'Association & PTA'  =>  'ASSN',
                                    'Assisted Living'  =>  'ASST',
                                    'Banking & Monetary Policy'  =>  'BANK',
                                    'Specialty OBGYN'  =>  'BIRTH',
                                    'BOCES'  =>  'BOC',
                                    'Specialty Cancer'  =>  'CANC',
                                    'Private Catholic'  =>  'CATH',
                                    'DocResearch Univ Extensive'  =>  'CC215',
                                    'DocResearch Univ Intensive'  =>  'CC216',
                                    'Masters College and University I'  =>  'CC221',
                                    'Masters College and University II'  =>  'CC222',
                                    'Baccalaureate College Liberal Arts'  =>  'CC231',
                                    'Baccalaureate College General'  =>  'CC232',
                                    'Baccalaureate & Associate College'  =>  'CC233',
                                    'Associate Colleges'  =>  'CC240',
                                    'Specialized Inst Seminary'  =>  'CC251',
                                    'Specialized Inst Medical Sch & Ctr'  =>  'CC252',
                                    'Specialized Inst Other Health Prof'  =>  'CC253',
                                    'Specialized Inst Engineering & Tech'  =>  'CC254',
                                    'Specialized Inst Business & Mgmt'  =>  'CC255',
                                    'Specialized Inst Art Music & Design'  =>  'CC256',
                                    'Specialized Inst Law'  =>  'CC257',
                                    'Specialized Inst Teachers College'  =>  'CC258',
                                    'Specialized Inst Other'  =>  'CC259',
                                    'Tribal College & University'  =>  'CC260',
                                    'Central Intelligence Agency'  =>  'CIA',
                                    'Cooperative or Consortium'  =>  'COOP',
                                    'US Courts'  =>  'COURT',
                                    'Defense Contract Audit Agency'  =>  'DCAA',
                                    'Dell Education Alliance Reseller'  =>  'DEA',
                                    'Defense Finance & Accounting Services'  =>  'DFAS',
                                    'Health & Human Services'  =>  'DHHS',
                                    'Defense Intelligence Agency'  =>  'DIA',
                                    'Defense Information Systems Agency'  =>  'DISA',
                                    'Defense Logistics Agency'  =>  'DLA',
                                    'Commerce'  =>  'DOC',
                                    'OSD Dept Of Defense Education Activity'  =>  'DODEA',
                                    'Energy'  =>  'DOE',
                                    'Interior'  =>  'DOI',
                                    'Justice'  =>  'DOJ',
                                    'Labor'  =>  'DOL',
                                    'Transportation'  =>  'DOT',
                                    'Education'  =>  'EDUC',
                                    'Electric Power'  =>  'ELECT',
                                    'Elementary Only'  =>  'ELEM',
                                    'Emergency District'  =>  'EMERG',
                                    'Executive Office of the President'  =>  'EOP',
                                    'Employee Purchase'  =>  'EPP',
                                    'Exec Office'  =>  'EXEC',
                                    'Executive & Governor'  =>  'EXGOV',
                                    'Federal'  =>  'FED',
                                    'Federal Reserve'  =>  'FEDRS',
                                    'Firefighters'  =>  'FIRE',
                                    'Fire Other'  =>  'FIREO',
                                    'GAS Supply'  =>  'GAS',
                                    'General Services Administration'  =>  'GSA',
                                    'National Guard'  =>  'GUARD',
                                    'Water Supply'  =>  'H2OSP',
                                    'Water Transport & Terminals'  =>  'H2OTR',
                                    'Specialty Heart Lung'  =>  'HEART',
                                    'Health'  =>  'HLTH',
                                    'HMO/PPO'  =>  'HMO',
                                    'Hospital'  =>  'HOSP',
                                    'Housing & Comm Dev'  =>  'HOUSE',
                                    'Health System'  =>  'HSYS',
                                    'Housing'  =>  'HUD',
                                    'Human Services'  =>  'HUMAN',
                                    'Independent Delivery Network'  =>  'IDN',
                                    'Indian School'  =>  'IND',
                                    'Intelligence Other'  =>  'INOTH',
                                    'Intelligence Reseller'  =>  'INVAR',
                                    'Industry Software Vendor'  =>  'ISV',
                                    'Judicial & Courts'  =>  'JUDIC',
                                    'Laboratory'  =>  'LAB',
                                    'Labor & Econ Dev'  =>  'LABOR',
                                    'Legislature & Congress'  =>  'LEGIS',
                                    'Coop Library'  =>  'LIBCO',
                                    'State Library'  =>  'LIBGS',
                                    'Main Library'  =>  'LIBMA',
                                    'Library Systems'  =>  'LIBSY',
                                    'Marine Air Base'  =>  'MCAIR',
                                    'Marine Base'  =>  'MCBAS',
                                    'Marine Headquarters'  =>  'MCHQ',
                                    'Marines Other'  =>  'MCOTH',
                                    'Doctors Office'  =>  'MD',
                                    'MSA County'  =>  'MSAGC',
                                    'MSA City'  =>  'MSAGL',
                                    'Naval Air Station'  =>  'NAS',
                                    'Aeronautics & Space'  =>  'NASA',
                                    'Natural Resources'  =>  'NATRS',
                                    'Navy Computer Facility'  =>  'NCOMP',
                                    'Navy Arsenal & Weapons Test'  =>  'NGUNS',
                                    'National Imagery & Mapping Agency'  =>  'NIMA',
                                    'Navy Marine Corps Intranet'  =>  'NMCI',
                                    'National Reconnaissance Office'  =>  'NRO',
                                    'National Security Agency'  =>  'NSA',
                                    'Navy Shipyard'  =>  'NSHIP',
                                    'Navy Spawar'  =>  'NSPAW',
                                    'Nursing Home'  =>  'NURSE',
                                    'Navy Air Base'  =>  'NVAIR',
                                    'Navy Base'  =>  'NVBAS',
                                    'Navy Command'  =>  'NVCOM',
                                    'Navy Facilities'  =>  'NVFAC',
                                    'Navy Headquarters'  =>  'NVHQ',
                                    'Navy Research & Testing'  =>  'NVLAB',
                                    'Navy Medical'  =>  'NVMED',
                                    'Navy Other'  =>  'NVOTH',
                                    'Navy Security'  =>  'NVSEC',
                                    'Navy Submarine Facility'  =>  'NVSUB',
                                    'Navy Supply Center'  =>  'NVSUP',
                                    'OSD Other'  =>  'OSDO',
                                    'Other County'  =>  'OTHGC',
                                    'Other City'  =>  'OTHGL',
                                    'Other SLG'  =>  'OTHSL',
                                    'Outpatient Other'  =>  'OUTP',
                                    'Parks & Recreation'  =>  'PARKS',
                                    'Pentagon'  =>  'PENT',
                                    'Postal Service'  =>  'POST',
                                    'Preschool & Daycare'  =>  'PREK',
                                    'Prisoners'  =>  'PRIS',
                                    'Private Other'  =>  'PRVOT',
                                    'Public School District'  =>  'PUB',
                                    'Public Works'  =>  'PUBWK',
                                    'County or Regional Center'  =>  'REG',
                                    'Regulatory'  =>  'REGUL',
                                    'Rehabilitation Facility'  =>  'REHAB',
                                    'Religious Other'  =>  'RELIG',
                                    'Reserves'  =>  'RESRV',
                                    'Retirement'  =>  'RETIR',
                                    'Research'  =>  'RSCH',
                                    'Reseller'  =>  'RSLR',
                                    'Law & Public Safety'  =>  'SAFTY',
                                    'Science & Technology'  =>  'SCIEN',
                                    'OSD Headquarters'  =>  'SDHQ',
                                    'OSD Medical'  =>  'SDMED',
                                    'OSD Other'  =>  'SDOTH',
                                    'Selective Service'  =>  'SERV',
                                    'Sewerage'  =>  'SEWER',
                                    'State Library'  =>  'SLIBR',
                                    'Solid Waste'  =>  'SOLID',
                                    'Social Security'  =>  'SSA',
                                    'State Department'  =>  'ST',
                                    'State Dept Aid'  =>  'STAID',
                                    'State'  =>  'STATE',
                                    'State Dept Embassies & Consulates'  =>  'STEMB',
                                    'Streets & Highways'  =>  'STHWY',
                                    'State Dept Other'  =>  'STOTH',
                                    'Specialty Surgical'  =>  'SURG',
                                    'Transportation'  =>  'TPORT',
                                    'DOD Training/ Schools'  =>  'TRAIN',
                                    'Treasury'  =>  'TREAS',
                                    'Transit'  =>  'TRSIT',
                                    'United Nations'  =>  'UN',
                                    'Agriculture'  =>  'USDA',
                                    'Utility District'  =>  'UTIL',
                                    'Veterans Affairs'  =>  'VA',
                                    'Vocational & Technical'  =>  'VTECH',
                                    'Welfare'  =>  'WELF',
                                    'Public Works'  =>  'WORKS'};
                                        
                                        public static Map<String,String> mapSubMarketCode = new Map<String,String>{
                                            '4 Year Undergraduate'  =>  '4YR',
                                                'Administrative Agency'  =>  'ADMIN',
                                                'Army'  =>  'ARMY',
                                                'Association'  =>  'ASSOC',
                                                'Assisted Living'  =>  'ASST',
                                                'Municipal Authority'  =>  'AUTHO',
                                                'BOCES, Coop, Board of Ed, Regional Educ Service Ctr'  =>  'BOC',
                                                'Cabinet/Department'  =>  'CAB',
                                                'Community College/2 year'  =>  'CCOL',
                                                'Church Owned'  =>  'CHUR',
                                                'City Government'  =>  'CITY',
                                                'Clinic'  =>  'CLIN',
                                                'County Government'  =>  'COUNT',
                                                'US Courts'  =>  'COURT',
                                                'eHealth'  =>  'EHLTH',
                                                'Employee Purchase'  =>  'EPP',
                                                'Faculty/Student/Staff Purchase'  =>  'FSS',
                                                'Generic'  =>  'GENER',
                                                'Govt Owned'  =>  'GOVT',
                                                'Group Purchasing Organization'  =>  'GPO',
                                                'Graduate/Research'  =>  'GRAD',
                                                'Health Management'  =>  'HMGMT',
                                                'HMO'  =>  'HMO',
                                                'Home Health'  =>  'HOMEH',
                                                'Hospital'  =>  'HOSP',
                                                'Independent Delivery Network'  =>  'IDN',
                                                'Intelligence'  =>  'INTEL',
                                                'Industry Solutions Vendor'  =>  'ISV',
                                                'Judicial'  =>  'JUDIC',
                                                'Laboratory'  =>  'LAB',
                                                'Legislature'  =>  'LEGIS',
                                                'Library'  =>  'LIBRA',
                                                'City & County Govt'  =>  'LOCAL',
                                                'Military School'  =>  'MIL',
                                                'Municipal (City or County)'  =>  'MUNIC',
                                                'NASA'  =>  'NASA',
                                                'Navy'  =>  'NAVY',
                                                'Nursing Home'  =>  'NHOME',
                                                'Private Non Profit'  =>  'NONP',
                                                'Nursing Services'  =>  'NURSE',
                                                'Office of Secretary of Defense'  =>  'OSD',
                                                'Other/Quasi Govt/EPP'  =>  'OTHER',
                                                'Private School/Other'  =>  'PRIV',
                                                'Private for Profit'  =>  'PROF',
                                                'Public School District'  =>  'PUB',
                                                'UN, Red Cross, Export'  =>  'QUASI',
                                                'Rehab School'  =>  'REHAB',
                                                'Research'  =>  'RSCH',
                                                'Reseller'  =>  'RSLR',
                                                'Shared'  =>  'SHARE',
                                                'State Govt'  =>  'STATE',
                                                'Surgery Center'  =>  'SURG',
                                                'Health System'  =>  'SYS',
                                                'Air Force'  =>  'USAF',
                                                'Marines'  =>  'USMC',
                                                'Vocational training-certificate'  =>  'VOC'};
                                                    
                                                    public static Map<String,String> mapreasonId = new Map<String,String> {
                                                        'New Customer' => '01',
                                                            'Prospect' => '02',
                                                            'Reseller' => '03',
                                                            'Other Intermediary' => '04',
                                                            'Generic' => '05',
                                                            'Consolidation Account for multinational' => '83',
                                                            'Belongs to existing Account' => '104',
                                                            'Change Hierarchy' => '105',                                                      
                                                            'Information Change' => '13',  // this and the rest are for update Account suggestion  
                                                            'Reformatting Change' => '14',
                                                            'Typo Correction' => '15',
                                                            'Other Correction' => '16'};
                                                                
                                                                public static Map<String,String> mapregion=new Map<String,String> 
                                                            {'APJ' => 'ASIA-PACIFIC',
                                                                'EC-EMEA' => 'EUROPE',
                                                                'EMEA' => 'EUROPE',
                                                                'LATAM' => 'AMERICAS',
                                                                'LA' => 'AMERICAS',
                                                                'NA' => 'AMERICAS'};    
                                                                    
                                                                    //Method to process response in String format and assign to SuggestionResponse object
                                                                    public static SuggestionResponse parseResponseString(String responseString) {
                                                                        SuggestionResponse result = new SuggestionResponse();
                                                                        if(StringUtils.isNotBlank(responseString)){
                                                                            XmlStreamReader responseXMLreader = new XmlStreamReader(responseString);
                                                                            String strcurrentElement;
                                                                            while(responseXMLreader.hasNext() && responseString != '') {
                                                                                if (responseXMLreader.getEventType() == XmlTag.START_ELEMENT) {
                                                                                    strcurrentElement = responseXMLreader.getLocalName();
                                                                                }
                                                                                else if (responseXMLreader.getEventType() == XmlTag.CHARACTERS){
                                                                                    //assigns to different class variables
                                                                                    if (StringUtils.equalsIgnoreCase(strcurrentElement,'ID')){
                                                                                        result.strID = responseXMLreader.getText();
                                                                                    }
                                                                                    else if (StringUtils.equalsIgnoreCase(strcurrentElement,'ErrorDescription')){
                                                                                        result.strErrorDescription = responseXMLreader.getText();
                                                                                    }
                                                                                    else if (StringUtils.equalsIgnoreCase(strcurrentElement,'OracleError')){
                                                                                        result.strOracleError = responseXMLreader.getText();
                                                                                    }
                                                                                    else if (StringUtils.equalsIgnoreCase(strcurrentElement,'IsAccountDuplicate')){
                                                                                        result.bIsAccountDuplicate = BooleanUtils.strToBoolean(responseXMLreader.getText());
                                                                                    }
                                                                                }
                                                                                responseXMLreader.next();
                                                                            }//end of while loop
                                                                        }//end of If
                                                                        return result;
                                                                    }//end of method
    
    //Method to call sendAccountSuggestionToDST
    public static SuggestionResponse  submitAccountSuggestion(Lead leadRecord, Boolean bisDupCheckRequired) {
        String strresponse = sendAccountSuggestionToDST(leadRecord,'submit',bisDupCheckRequired);
        return parseResponseString(strresponse);
    }
    
    //Send AccountSuggestion to DST    
    public static String sendAccountSuggestionToDST(Lead leadRecord, String stroperationType, Boolean bisDupCheckRequired){
        String strresponse;
        if(leadRecord!=null){
            //create request body from the Account record
            String strrequestBody = createAccountsuggestionHTTPRequestBodyString(leadRecord, stroperationType, bisDupCheckRequired);
            //calls the method to send the request
            strresponse = sendHttpRequest(strrequestBody);
        }
        return strresponse;
    }
    
    //Method to create HTTP Request
    public static String createAccountsuggestionHTTPRequestBodyString(Lead leadRecord, String stroperationType, Boolean bisDupCheckRequired){
        if (currentUser == null){
            getCurrentUser();
        }
        XmlStreamWriter w = new XmlStreamWriter();
        Date dtodate = System.today();
        String strtoDateIn =String.valueOf(dtodate);
        //Added to merge the code at single place by Srini
        w=AccountSuggestion.Updatestatus(w);
        //Envelope
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('cmi', 'http://cmi.us.dell.com');
        
        //Header
        w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');
        
        //Body
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        
        //InsertSegmentationData
        w.writeStartElement('cmi', 'CreateAccountSuggestion', 'http://cmi.us.dell.com');
        //mandatory
        w = addElementAndValueString(w,'accountId','0');
        w = addElementAndValueString(w,'suggestionId',null);
        
        /* modified on 26-Oct-2009 */
        w = addElementAndValueString(w,'batchId',null);        
        
        //mandatory
        w = addElementAndValueString(w,'suggestionTypeId','100');
        //pass empty value
        w = addElementAndValueString(w,'linkToPartyId',null);
        w = addElementAndValue(w, 'orgGroupName', leadRecord, 'Company');
        w = addElementAndValue(w, 'orgGroupNickName', leadRecord, 'Other_Company_Name__c');
        w = addElementAndValue(w, 'orgGroupCountryCode', leadRecord, 'Organization_Country__r.Code__c');
        w = addElementAndValue(w, 'orgGroupWebsiteUrl', leadRecord, 'Website');
        //lookup
        w = addElementAndValue(w, 'currencyCode', leadRecord, 'Organization_Country__r.User_Currency_Iso_Code__c');
        w = addElementAndValue(w, 'physicalCompanyName', leadRecord, 'Physical_Company_Name__c');
        w = addElementAndValue(w, 'physicalStreetAddr1', leadRecord, 'Physical_Address_1__c');
        w = addElementAndValue(w, 'physicalStreetAddr2', leadRecord, 'Physical_Address_2__c');
        w = addElementAndValue(w, 'physicalCounty', leadRecord, 'Physical_County__c');
        w = addElementAndValue(w, 'physicalCity', leadRecord, 'Physical_City__c');
        w = addElementAndValue(w, 'physicalState', leadRecord, 'Physical_State__c');
        w = addElementAndValue(w, 'physicalPostalCode', leadRecord, 'Physical_PostalCode__c');
        w = addElementAndValue(w, 'physicalsuburb', leadRecord, 'Physical_suburb__c');
        //lookup
        w = addElementAndValue(w, 'physicalCountryCode', leadRecord, 'Physical_Country__r.Code__c');
        w = addElementAndValue(w, 'postalCompanyName', leadRecord, 'Postal_Company_Name__c');
        w = addElementAndValue(w, 'postalStreetAddr1', leadRecord, 'Postal_Address_1__c');
        w = addElementAndValue(w, 'postalStreetAddr2', leadRecord, 'Postal_Address_2__c');
        w = addElementAndValue(w, 'postalCounty', leadRecord, 'Postal_County__c');
        w = addElementAndValue(w, 'postalCity', leadRecord, 'Postal_City__c');
        w = addElementAndValue(w, 'postalsuburb', leadRecord, 'Postal_suburb__c');
        w = addElementAndValue(w, 'postalState', leadRecord, 'Postal_State__c');
        w = addElementAndValue(w, 'postalPostalCode', leadRecord, 'Postal_PostalCode__c');
        //lookup
        w = addElementAndValue(w, 'postalCountryCode', leadRecord, 'Postal_Country__r.Code__c');
        //mandatory
        w = addElementAndValueString(w,'sameAsPhysicalFlag','false');
        //mandatory
        w = addElementAndValueString(w,'orgPartyId','0');
        //may need conversion
        String strdmuValue = booleanUtils.toStringYN(leadRecord.DMU_Flag__c);
        w = addElementAndValueString(w,'dmuFlag',strdmuValue);
        String strsalesModelCode = mapSalesModelCode.get(leadRecord.Sales_Model_Code__c);
        w = addElementAndValueString(w,'salesModelCode',strsalesModelCode);
        String strmarketingClassCode = mapMarketingClassCode.get(leadRecord.Marketing_Class_Code__c);
        w = addElementAndValueString(w,'marketingClassCode',strmarketingClassCode);
        String strfuncCategoryCode = mapFunctionCategoryCode.get(leadRecord.Function_Category_Code__c);
        w = addElementAndValueString(w,'funcCategoryCode',strfuncCategoryCode);
        String strsubMarketCode = mapSubMarketCode.get(leadRecord.Sub_Market_Code__c);
        w = addElementAndValueString(w,'subMarketCode',strsubMarketCode);
        w = addElementAndValue(w, 'finGeo', leadRecord, 'FIN_GEO__c');
        String strretailFlag = booleanUtils.toStringYN(leadRecord.Retail_Flag__c);
        w = addElementAndValueString(w,'retailFlag',strretailFlag);
        String strndaFlag = booleanUtils.toStringYN(leadRecord.NDA_Flag__c);
        w = addElementAndValueString(w,'ndaFlag',strndaFlag);
        
        //mandatory
        String strndaExpDate = '0001-01-01T00:00:00';
        if(leadRecord.NDA_Expiry_Date__c!=null){
            strndaExpDate = datetimeString(leadRecord.NDA_Expiry_Date__c);
        }        
        w = addElementAndValueString(w,'ndaExpDate',strndaExpDate);        
        w = addElementAndValue(w, 'cfiProjectNumber', leadRecord, 'CFI_Project_Numbers__c');
        w = addElementAndValue(w, 'stdQuoteNumber', leadRecord, 'Std_Quote_Numbers__c');
        //mandatory
        String strlocations = '0';
        if(leadRecord.Location_Number__c!=null){
            strlocations = String.valueOf(leadRecord.Location_Number__c);
        }
        w = addElementAndValueString(w,'locationNum',''+strlocations);
        
        w = addElementAndValue(w, 'premierPageUrl', leadRecord, 'Premier_Page_URL__c');
        //mandatory
        String strcompanyFoundedDate = '0001-01-01T00:00:00';
        if(leadRecord.Date_Founded__c!=null){
            strcompanyFoundedDate = datetimeString(leadRecord.Date_Founded__c);
        }        
        w = addElementAndValueString(w,'companyFoundedDate',strcompanyFoundedDate);        
        //mandatory
        String straccountCreatedDate =datetimeString(null); 
        w = addElementAndValueString(w,'accountCreatedDate',straccountCreatedDate);        
        //mandatory
        String strfiscalYearEnd = '0001-01-01T00:00:00';
        if(leadRecord.Fiscal_Year_End__c!=null){
            strfiscalYearEnd = datetimeString(leadRecord.Fiscal_Year_End__c);
        }
        w = addElementAndValueString(w,'fiscalYearEnd',strfiscalYearEnd);      
        w = addElementAndValue(w, 'nationalId', leadRecord, 'National_ID__c');      
        //mandatory
        String streffectiveDate = datetimeString(null);
        w = addElementAndValueString(w,'effectiveDate',streffectiveDate);  
        
        /* updated as part of CR #1753 */     
        //w = addElementAndValueString(w,'createdBy','-1');         
        w = addElementAndValueString(w,'createdBy',currentUser.Badge_Number__c);     
        w = addElementAndValueString(w,'submittedBy','-1');     
        w = addElementAndValueString(w,'assignedTo',null);      
        w = addElementAndValueString(w,'lastUpdatedBy','-1');       
        //mandatory
        w = addElementAndValueString(w,'effectiveTypeId','1');            
        
        //mandatory
        String strreasonId =mapreasonId.get(leadRecord.Suggestion_Reason__c); 
        w = addElementAndValueString(w,'reasonId',strreasonId);
        
        w = addElementAndValue(w, 'comments', leadRecord, 'Questions_Comments__c');
        //mandatory
        w = addElementAndValueString(w,'suggestionStatusId','4');       
        w = addElementAndValueString(w,'relatedSuggestionIds','0');     
        //recheck this data for date format
        String strterritoryData = leadRecord.Territory_Assignment__r.Group_ID__c+'~'+leadRecord.Territory_Assignment__r.Name+'~'+dateString(null)+'~'+dateString(null)+'~~~D~$';
        //From Territorry Assignment
        w = addElementAndValueString(w,'territoryData',strterritoryData);      
        //pass empty
        String struserRole = StringUtils.substringAfter(leadRecord.Account_Owner__r.UserRole.name, '_');
        
        /* updated as part of CR #1753 to send account owner */ 
        /*String salesRepData = leadRecord.Account_Owner__r.Badge_Number__c+'~'+datetimeString(null)+'~'+datetimeString(null)+'~~~'+
leadRecord.Account_Owner__r.LastName+','+leadRecord.Account_Owner__r.FirstName+'~'+userRole+'~Y~'+leadRecord.Account_Owner__r.Title+'~Y~Y~$';*/
        
        /* modified on Dec 15th 2009 */
        if(leadRecord.Account_Owner__c != null){
            String strsalesRepData = leadRecord.Account_Owner__r.Badge_Number__c+'~'+dateString(null)+'~'+dateString(null)+'~~~'+
                leadRecord.Account_Owner__r.LastName+','+leadRecord.Account_Owner__r.FirstName+'~'+struserRole+'~Y~'+leadRecord.Account_Owner__r.Title+'~Y~Y~$';
            w = addElementAndValueString(w,'salesRepData',strsalesRepData);
        }
        else{
            w = addElementAndValueString(w,'salesRepData',null);
        }    
        
        w = addElementAndValueString(w,'externalEntity',null);
        //mandatory 
        w = addElementAndValueString(w,'CalculateMethod','0');      
        //pass empty
        w = addElementAndValueString(w,'sLOBData',null);
        //mandatory
        w = addElementAndValueString(w,'TotalFaculty','0');     
        //mandatory
        w = addElementAndValueString(w,'TotalHospitalBeds','0');        
        //mandatory
        w = addElementAndValueString(w,'TotalEmployeeNumber','0');      
        //mandatory
        w = addElementAndValueString(w,'TotalStudents','0');        
        //pass empty
        w = addElementAndValueString(w,'LatestRadTypeCode',null);
        //mandatory
        w = addElementAndValueString(w,'SICCode','0');      
        //pass empty
        w = addElementAndValueString(w,'VSEG',null);
        //String userDefinedAttributeData = '~I~86~'+leadRecord.Partner_Type__c+'~$~I~88~'+leadRecord.Partner_Class__c+'~$~I~89~'+leadRecord.Partner_Status__c+'~$~I~169~'+leadRecord.Account_Category__c+'$';
        String struserDefinedAttributeData = '~I~169~'+leadRecord.Account_Category__c+'~$~I~86~'+leadRecord.Partner_Type__c+'~$~I~88~'+leadRecord.Partner_Class__c+'~$~I~89~'+leadRecord.Partner_Status__c+'~$';
        //CR2574
        if (leadRecord.Secondary_Partner_Type_Optional__c != null) 
            struserDefinedAttributeData += '~I~87~'+leadRecord.Secondary_Partner_Type_Optional__c+'~$';
        w = addElementAndValueString(w,'userDefinedAttributeData',struserDefinedAttributeData);        
        w = addElementAndValueString(w,'accountType','A');      
        w = addElementAndValue(w, 'gsIcaIndicator', leadRecord, 'Program_Type__c');
        //pass empty
        w = addElementAndValueString(w,'technologyIntensive',null);
        w = addElementAndValueString(w,'consensusBuyPower',null);
        w = addElementAndValueString(w,'link_num_Data',null);
        w = addElementAndValueString(w,'LocalAccountName',null);
        //Value from Country
        String strregion = mapregion.get(leadRecord.Organization_Country__r.Region__c);
        w = addElementAndValueString(w,'Region',strregion);        
        w = addElementAndValue(w, 'postalPhone', leadRecord, 'Postal_Phone__c');
        w = addElementAndValue(w, 'physicalPhone', leadRecord, 'Physical_Phone__c');
        w = addElementAndValue(w, 'postalFax', leadRecord, 'Postal_Fax__c');
        w = addElementAndValue(w, 'physicalFax', leadRecord, 'Physical_Fax__c');
        w = addElementAndValueString(w,'IsDupCheckReq',''+bisDupCheckRequired);      
        w = addElementAndValueString(w,'createdByModule','SFDC');
        //Appending SFDC_ with leadID
        String strlegacyId = 'SFDC_'+leadRecord.id;
        w = addElementAndValueString(w,'legacyId',strlegacyId);
        //w = addElementAndValue(w, 'legacyId', leadRecord, 'id');
        //pass empty
        w = addElementAndValueString(w,'customerNoData',null);
        w = addElementAndValueString(w,'operationType',stroperationType);
        
        w.writeEndElement(); //end CreateAccountSuggestion data
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();                                                            
        return strxmlOutput;
    }
    
    //Method to add elemenet and value of type String to the XmlStreamWriter
    public static XmlStreamWriter addElementAndValueString(XmlStreamWriter w, String strtagName, String value){
        w.writeStartElement('cmi', strtagName, 'http://cmi.us.dell.com');
        if(value == null){
            w.writeCharacters('');  
        }
        else{
            w.writeCharacters(value);
        }
        w.writeEndElement();
        return w;
    }
    
    //Method to add elemenet and value of type String to the XmlStreamWriter
    public static XmlStreamWriter addElementFromMap(XmlStreamWriter w, String strtagName, Map<String, String> mapparameter){       
        w.writeStartElement('cmi', strtagName, 'http://cmi.us.dell.com');      
        w.writeCharacters(StringUtils.defaultString(mapparameter.get(strtagName)));         
        w.writeEndElement();
        return w;
    }
    
    //Method to add elemenet and value to the XmlStreamWriter
    public static XmlStreamWriter addElementAndValue(XmlStreamWriter w, string strtagName, sObject record, string strfieldName){
        String strvalueToBeAdded = '';     
        if(strfieldName.contains('Organization_Country__r.')){
            Lead leadRecord=(Lead) record;
            if(leadRecord.Organization_Country__c!=null){
                strfieldName = strfieldName.replace('Organization_Country__r.','');
                if(leadRecord.Organization_Country__r.get(strfieldName)!= null){
                    strvalueToBeAdded += leadRecord.Organization_Country__r.get(strfieldName);
                }
            }           
        }
        //Physical_Country__r.Name
        else if(strfieldName.contains('Physical_Country__r.')){
            Lead leadRecord=(Lead) record;
            if(leadRecord.Physical_Country__c!=null){
                strfieldName = strfieldName.replace('Physical_Country__r.','');
                if(leadRecord.Physical_Country__r.get(strfieldName)!= null){
                    strvalueToBeAdded += leadRecord.Physical_Country__r.get(strfieldName);
                }   
            }           
        }
        //Postal_Country__r.Name
        else if(strfieldName.contains('Postal_Country__r.')){
            Lead leadRecord=(Lead) record;
            if(leadRecord.Postal_Country__c!=null){
                strfieldName = strfieldName.replace('Postal_Country__r.','');
                if(leadRecord.Postal_Country__r.get(strfieldName)!= null){
                    strvalueToBeAdded += leadRecord.Postal_Country__r.get(strfieldName);
                }
            }           
        }
        else if(record.get(strfieldName)!=null){
            strvalueToBeAdded += record.get(strfieldName);
        }
        
        w.writeStartElement('cmi', strtagName, 'http://cmi.us.dell.com');
        if(strvalueToBeAdded != ''){
            w.writeCharacters(strvalueToBeAdded);
        }
        w.writeEndElement();
        return w;
    }
    //Method to create HTTPRequest Header
    public static HttpRequest createHttpRequestHeader(){
        
        if(UserInfo.getOrganizationId() == '00D300000006urqEAA') { 
            strUSERNAME='ServiceSOASFDC';  //for PRODUCTION env
            strPASSWORD='2R8tHu93PuKUcHe';  
            //Rev 4.0 - start
            strENDPOINT= System.Label.DST_DP_Prod_Server_URL;
            //Rev 4.0 - end 
            bAUTHENTICATIONREQUIRED = true;
        }
        //Set header parameters for Sandbox 
        else{
            
            strUSERNAME='ServiceSOASFDC';
            strPASSWORD='33Zyp+P+:Lx2X7$z';
            //ENDPOINT='https://soaibmdpasit06.us.dell.com:443/CustomerSegmentation/SegmentationService';            
            //Rev 4.0 - start
            strENDPOINT= System.Label.DST_DP_Sandbox_Server_URL;
            //Rev 4.0 - end
            bAUTHENTICATIONREQUIRED = true;
        }
        
        HttpRequest req = new HttpRequest();
        //Set endpoint URL      
        req.setEndpoint(strENDPOINT);
        //Set the method Type
        req.setMethod(METHOD);
        // Specify the required user name and password to access the endpoint
        // As well as the header and header information 
        if(bAUTHENTICATIONREQUIRED){ 
            Blob blbheaderValue = Blob.valueOf(strUSERNAME + ':' + strPASSWORD);
            String strauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbheaderValue);
            req.setHeader('Authorization', strauthorizationHeader);
        }
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req; 
    }   
    
    //Method to send HTTPRequest
    public static String sendHttpRequest(String strrequestBody){
        //method call to create HttpRequest
        HttpRequest req=createHttpRequestHeader();
        //sets the request body
        req.setBody(strrequestBody);
        Http http = new Http();
        //Sending the HTTP request
        HTTPResponse res = http.send(req);
        return res.getBody(); 
    }
    
    //Method to format DateTime
    public static String datetimeString(datetime dtDateTimeValue){
        
        //converts to yyyy-MM-ddTHH:mm:ss format.if null, takes current datetime
        string stringDTValue= '';
        if(dtDateTimeValue==null){
            dtDateTimeValue= Datetime.now();
        }
        stringDTValue = dtDateTimeValue.format('yyyy-MM-dd')+ 'T'+ dtDateTimeValue.format('HH:mm:ss');
        
        return stringDTValue; 
        
    }
    
    //Method to format Date
    public static String dateString(datetime dateValue){
        
        //converts to MM/dd/yyyy format.if null, takes current datetime
        
        string stringDTValue= '';
        if(dateValue==null){
            dateValue = DateTime.now();
        }
        stringDTValue = dateValue.format('MM/dd/yyyy');
        
        return stringDTValue;       
    }
    
    //Method to update Lead and Partner Request status
    public static void updateLeadAndPartnerStatus(List<Lead> listupdatedLead, Set<Id> setpartnerRequestId){
        List<Partner_Request__c> listrequestTobeUpdated = new List<Partner_Request__c>();          
        Map<Id, Partner_Request__c> mapassociatedRequest;
        Id partnerRequestId;
        
        if(setpartnerRequestId!=null){
            mapassociatedRequest = new Map<Id, Partner_Request__c>([SELECT Id, Name, Status__c 
                                                                    FROM Partner_Request__c 
                                                                    WHERE Id IN :setpartnerRequestId]);
        }
        
        
        for(Integer intcount=0;intcount<listupdatedLead.size();intcount++){
            
            partnerRequestId = listupdatedLead[intcount].Partner_Request__c;           
            if(partnerRequestId != null){
                if(mapassociatedRequest.get(partnerRequestId).Status__c == 'Approved'){
                    Partner_Request__c requestToUpdate = new Partner_Request__c(id = partnerRequestId , status__c = 'Lead Draft');
                    listrequestTobeUpdated.add(requestToUpdate);
                }
                else if(mapassociatedRequest.get(partnerRequestId).Status__c != 'Lead Draft'){                   
                    listupdatedLead[intcount].addError('Associated Partner Request is not in Approved status');
                }
            }                   
            listupdatedLead[intcount].Status = 'Draft';                        
        }
        if(listrequestTobeUpdated.size()>0){
            update listrequestTobeUpdated;
        }
    }
    
    /* ----METHODS RELATED TO UPDATE ACCOUNT SUGGESTION----- */
    /*      Added as per CR #1820 in R10.10     */
    
    //Method to create HTTP Request for Update Suggestion
    public static String updateAccountsuggestionHTTPRequestBodyString(Lead leadRecord){
        if (currentUser == null){
            getCurrentUser();
        }
        XmlStreamWriter w = new XmlStreamWriter();
        //Added to merge the code at single place by Srini
        w=AccountSuggestion.Updatestatus2(w);
        w=AccountSuggestion.Updatestatus(w);
        /*Envelope
w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
w.writeNamespace('cmi', 'http://cmi.us.dell.com');

//Header
w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');

//Body
w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');

//UpdateAccountSuggestion
w.writeStartElement('cmi', 'UpdateAccountSuggestion', 'http://cmi.us.dell.com');

w = addElementAndValueString(w,'suggestionId',null); 
w = addElementAndValueString(w,'batchId',null); 
w = addElementAndValueString(w,'suggestionTypeId','103');    // 103 for update Account*/
        
        // partyId. 
        w = addElementAndValueString(w,'partyId',leadRecord.Account__r.Account_ID__c); 
        w = addElementAndValue(w,'orgGroupName', leadRecord, 'Company'); 
        w = addElementAndValueString(w,'orgGroupNickName',null); 
        
        // org Country. 
        w = addElementAndValueString(w,'orgGroupCountryCode',null);
        
        /* updated as per Defect 53217 */
        w = addElementAndValueString(w,'orgGroupWebsiteUrl',null);         
        w = addElementAndValueString(w,'currencyCode',null);         
        w = addElementAndValueString(w,'physicalCompanyName',null); 
        
        /* updated as per Defect 53217 */
        w = addElementAndValueString(w,'physicalStreetAddr1',null); 
        w = addElementAndValueString(w,'physicalStreetAddr2',null); 
        w = addElementAndValueString(w,'physicalCounty',null);
        
        /* updated as per Defect 53217 */                         
        w = addElementAndValueString(w,'physicalCity', null); 
        w = addElementAndValueString(w,'physicalSuburb',null); 
        w = addElementAndValueString(w,'physicalState',null); 
        w = addElementAndValueString(w,'physicalPostalCode',null); 
        
        //lookup. 
        w = addElementAndValueString(w, 'physicalCountryCode',null);
        w = addElementAndValueString(w,'postalCompanyName',null); 
        w = addElementAndValueString(w,'postalStreetAddr1', null); 
        w = addElementAndValueString(w,'postalStreetAddr2', null);         
        w = addElementAndValueString(w,'postalCounty',null);
        
        /* updated as per Defect 53217 */
        w = addElementAndValueString(w,'postalCity', null); 
        w = addElementAndValueString(w,'postalSuburb', null); 
        w = addElementAndValueString(w,'postalState', null); 
        w = addElementAndValueString(w,'postalPostalCode', null);
        
        //country code
        w = addElementAndValueString(w, 'postalCountryCode', null); 
        
        w = addElementAndValueString(w,'sameAsPhysicalFlag','false');         
        
        /* updated based on DST team input */
        w = addElementAndValueString(w,'orgPartyId','0');
        
        // need conversion
        String strdmuValue = booleanUtils.toStringYN(leadRecord.DMU_Flag__c);
        w = addElementAndValueString(w,'dmuFlag',strdmuValue);
        
        // Removed from here
        
        /* updated based on DST team input */
        w = addElementAndValueString(w,'locationNum','0');
        w = addElementAndValueString(w,'premierPageUrl','0'); 
        w = addElementAndValueString(w,'companyFoundedDate','0001-01-01T00:00:00');
        w = addElementAndValueString(w,'accountCreatedDate','0001-01-01T00:00:00');
        
        /* updated as per Defect 53217 */
        w = addElementAndValueString(w,'fiscalYearEnd', '0001-01-01T00:00:00');
        w = addElementAndValue(w,'nationalId', leadRecord, 'National_ID__c');         
        
        //Effective date
        String streffectiveDate = datetimeString(null);
        w = addElementAndValueString(w,'effectiveDate',streffectiveDate);
        w = addElementAndValueString(w,'createdBy',currentUser.Badge_Number__c);
        w = addElementAndValueString(w,'submittedBy','-1'); 
        w = addElementAndValueString(w,'assignedTo','-1'); 
        w = addElementAndValueString(w,'lastUpdatedBy','-1'); 
        w = addElementAndValueString(w,'effectiveTypeId','1');
        
        String strreasonId = mapreasonId.get(leadRecord.Suggestion_Reason__c); 
        w = addElementAndValueString(w,'reasonId',strreasonId);
        w = addElementAndValue(w,'comments', leadRecord, 'Questions_Comments__c'); 
        w = addElementAndValueString(w,'suggestionStatusId','4'); 
        w = addElementAndValueString(w,'relatedSuggestionIds','0');         
        //UDA
        String struserDefinedAttributeData = '~I~169~'+leadRecord.Account_Category__c+'~$~I~86~'+leadRecord.Partner_Type__c+'~$~I~88~'+leadRecord.Partner_Class__c+'~$~I~89~'+leadRecord.Partner_Status__c+'~$';
        //CR2574
        if (leadRecord.Secondary_Partner_Type_Optional__c != null) struserDefinedAttributeData += '~I~87~'+leadRecord.Secondary_Partner_Type_Optional__c+'~$';
        w = addElementAndValueString(w,'userDefinedAttributeData',struserDefinedAttributeData); 
        w = addElementAndValue(w,'gsIcaIndicator', leadRecord, 'Program_Type__c'); 
        
        //Acccount name.
        w = addElementAndValue(w,'localAccountName', leadRecord, 'CompanyLocal');         
        
        /* Updated after testing */
        String strregion = mapregion.get(leadRecord.Organization_Country__r.Region__c);
        w = addElementAndValueString(w,'Region', strregion);  
        w = addElementAndValueString(w,'createdByModule','SFDC'); 
        w = addElementAndValueString(w,'postalPhone',null); 
        w = addElementAndValueString(w,'physicalPhone',null); 
        w = addElementAndValueString(w,'postalFax',null); 
        w = addElementAndValueString(w,'physicalFax',null); 
        w = addElementAndValueString(w,'legacyId',null);        
        
        Double dblemployeeSize = (leadRecord.Employee_Size__c == null)? 0: leadRecord.Employee_Size__c;         
        w = addElementAndValueString(w,'employeesize',  ''+dblemployeeSize);        
        
        /* Modified as of Oct 16 */
        w = addElementAndValueString(w,'siccode','0');
        w = addElementAndValueString(w,'OperationType','SUBMIT');
        if(!Test.IsrunningTest()){
            w.writeEndElement(); //end UpdateAccountSuggestion data
            w.writeEndElement(); //end Body
            w.writeEndElement(); //end envelope
        }
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    
    //Send Update AccountSuggestion to DST    
    public static String sendUpdateAccountSuggestionToDST(Lead leadRecord){
        String strresponse;
        if(leadRecord!=null){
            
            //create request body for update account suggestion
            String strrequestBody = updateAccountsuggestionHTTPRequestBodyString(leadRecord);
            //calls the method to send the request
            strresponse = sendHttpRequest(strrequestBody);
        }   
        return strresponse;
    }
    
    //Method to call sendUpdateAccountSuggestionToDST
    public static SuggestionResponse  submitUpdateAccountSuggestion(Lead leadRecord) {        
        String strresponseString = sendUpdateAccountSuggestionToDST(leadRecord);        
        return parseResponseString(strresponseString);
    }
    
    /* ----METHODS RELATED TO CR 2570 R11.5 - ACCOUNT UPDATE FROM SELFSERVICE PORTAL ----- */
    
    //Added as a part of CR#2570. [Ambily 03-May-2010]
    public static void updateAccountPartnerRequests(List<String> listpartnerRequestID) {
        
        List<Partner_Request__c> listpartnerRequest= new List<Partner_Request__c>();        
        
        for(Partner_Request__c partnerRequest : [SELECT id,Status__c 
                                                 FROM Partner_Request__c 
                                                 WHERE id IN : listpartnerRequestID
                                                 AND Status__c = 'Account Suggestion Submitted'
                                                 AND recordType.name = :PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER]){
                                                     
                                                     partnerRequest.Status__c='Account Suggestion Completed';
                                                     listpartnerRequest.add(partnerRequest);
                                                 }
        if(listpartnerRequest.size() > 0){
            update listpartnerRequest;
        }   
    } //end of method
    
    //Method to create HTTP Request for Update Suggestion
    public static String updateSelfServiceAccountHTTPRequestBodyString(Map<String, String> mapparameter){
        
        XmlStreamWriter w = new XmlStreamWriter();
        
        //Added to merge the code at single place by Srini
        w=AccountSuggestion.Updatestatus2(w);
        w=AccountSuggestion.Updatestatus(w);
        //copying value from orgGroupName to physicalCompanyName
        mapparameter.put('physicalCompanyName',mapparameter.get('orgGroupName'));
        
        String strcountryRegion = getCountryRegion(mapparameter.get('orgGroupCountryCode')); 
        mapparameter.put('Region', mapregion.get(strcountryRegion));
        
        /*Envelope
w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
w.writeNamespace('cmi', 'http://cmi.us.dell.com');

//Header
w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');

//Body
w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');

//UpdateAccountSuggestion
w.writeStartElement('cmi', 'UpdateAccountSuggestion', 'http://cmi.us.dell.com');

w = addElementAndValueString(w,'suggestionId',null); 
w = addElementAndValueString(w,'batchId',null); 
w = addElementAndValueString(w,'suggestionTypeId','103');    // 103 for update Account*/
        
        // partyId.
        w = addElementFromMap(w,'partyId',mapparameter);
        w = addElementFromMap(w,'orgGroupName',mapparameter);
        w = addElementFromMap(w,'orgGroupNickName',mapparameter);
        
        // org Country. 
        //not Required?
        w = addElementAndValueString(w,'orgGroupCountryCode',null);
        w = addElementAndValueString(w,'orgGroupWebsiteUrl',null);        
        w = addElementAndValueString(w,'currencyCode',null);         
        w = addElementFromMap(w,'physicalCompanyName',mapparameter);
        w = addElementFromMap(w,'physicalStreetAddr1',mapparameter);
        w = addElementFromMap(w,'physicalStreetAddr2',mapparameter);
        
        //**NOT required???
        w = addElementAndValueString(w,'physicalCounty',null); 
        w = addElementFromMap(w,'physicalCity',mapparameter);
        w = addElementAndValueString(w,'physicalSuburb',null); 
        w = addElementFromMap(w,'physicalState',mapparameter);
        w = addElementFromMap(w,'physicalPostalCode',mapparameter);
        
        //**NOT required???
        //CR3482
        w = addElementFromMap(w, 'physicalCountryCode',mapparameter);
        w = addElementAndValueString(w,'postalCompanyName',null);      
        w = addElementAndValueString(w,'postalStreetAddr1', null); 
        w = addElementAndValueString(w,'postalStreetAddr2', null);         
        w = addElementAndValueString(w,'postalCounty',null); 
        w = addElementAndValueString(w,'postalCity', null); 
        w = addElementAndValueString(w,'postalSuburb', null); 
        w = addElementAndValueString(w,'postalState', null); 
        w = addElementAndValueString(w,'postalPostalCode', null);
        w = addElementAndValueString(w, 'postalCountryCode', null);        
        w = addElementAndValueString(w,'sameAsPhysicalFlag','false');  
        w = addElementAndValueString(w,'orgPartyId','0'); 
        w = addElementAndValueString(w,'dmuFlag',null);
        
        // Removed from here
        
        w = addElementAndValueString(w,'locationNum','0');
        w = addElementAndValueString(w,'premierPageUrl','0'); 
        w = addElementAndValueString(w,'companyFoundedDate','0001-01-01T00:00:00'); 
        w = addElementAndValueString(w,'accountCreatedDate','0001-01-01T00:00:00');
        w = addElementAndValueString(w,'fiscalYearEnd', '0001-01-01T00:00:00');
        w = addElementAndValueString(w,'nationalId',null);
        
        //Effective date
        String streffectiveDate = datetimeString(null);
        w = addElementAndValueString(w,'effectiveDate',streffectiveDate); 
        w = addElementAndValueString(w,'createdBy','-1');
        w = addElementAndValueString(w,'submittedBy','-1'); 
        w = addElementAndValueString(w,'assignedTo','-1'); 
        w = addElementAndValueString(w,'lastUpdatedBy','-1'); 
        w = addElementAndValueString(w,'effectiveTypeId','1');
        
        String strreasonId = mapreasonId.get('Information Change'); 
        w = addElementAndValueString(w,'reasonId',strreasonId);   
        
        w = addElementAndValueString(w,'comments',null);
        
        w = addElementAndValueString(w,'suggestionStatusId','4'); 
        w = addElementAndValueString(w,'relatedSuggestionIds','0');         
        
        //** NOT REQUIRED???    UDA         
        w = addElementAndValueString(w,'userDefinedAttributeData',null);
        
        w = addElementAndValueString(w,'gsIcaIndicator',null);
        
        w = addElementAndValueString(w,'localAccountName',null);
        
        /* cannot be null */
        w = addElementFromMap(w,'Region',mapparameter);
        
        w = addElementAndValueString(w,'createdByModule','SFDC'); 
        w = addElementAndValueString(w,'postalPhone',null); 
        w = addElementAndValueString(w,'physicalPhone',null); 
        w = addElementAndValueString(w,'postalFax',null); 
        w = addElementAndValueString(w,'physicalFax',null); 
        
        w = addElementFromMap(w,'legacyId',mapparameter);         
        
        String stremployeeSize = (mapparameter.get('employeesize') == '')? '0': mapparameter.get('employeesize');         
        w = addElementAndValueString(w,'employeesize',  stremployeeSize);        
        
        w = addElementAndValueString(w,'siccode','0');
        
        w = addElementAndValueString(w,'OperationType','SUBMIT');
        
        w.writeEndElement(); //end UpdateAccountSuggestion data
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    public static String getCountryRegion(String strcountryCode){
        if(strcountryCode == null || strcountryCode == '')return '';
        {
            for(Country__c countryItem : [SELECT Name, Id, Dell_Online_Country_Code__c, Code__c, Region__c
                                          FROM Country__c
                                          WHERE Code__c =:strcountryCode]){            
                                              return StringUtils.defaultString(CountryItem.Region__c);
                                          }
        }
        return '';
    }
    /* Asynchronous method */
    @future(callout=true)
    public static void sendSelfServiceAccountUpdateSuggestion(String strpartnerRequestId,Map<String, String> mapparameter){
        Partner_Request__c partnereRequest;
        Boolean bupdateRequired = false;
        List<Partner_Request__c> listpartnerRequest = [SELECT Id, Account__c, Status__c, RecordType.Name, Description__c
                                                       FROM Partner_Request__c
                                                       WHERE Id = :strpartnerRequestId
                                                       AND Status__c = 'New'
                                                       AND RecordType.Name = 'Update Partner'];
        
        If(listpartnerRequest.size()>0)partnereRequest = listpartnerRequest[0];
        
        if(mapparameter!=null || mapparameter.size() > 0 ){
            bupdateRequired = true;
            try{
                
                //create request body for update account suggestion
                String strrequestBody = updateSelfServiceAccountHTTPRequestBodyString(mapparameter);
                //calls the method to send the request
                String strresponse = sendHttpRequest(strrequestBody); 
                SuggestionResponse result = parseResponseString(strresponse);
                
                if(result.strID == null || result.strID == ''){
                    partnereRequest = setRequestStatusAndDescription (partnereRequest,'Incomplete',
                                                                      'Invalid response[The response from the DST system could not be processed]');   
                }
                else if(result.strID == '0' || result.strID == '1008'|| result.strID == '1010'){      //validation error                         
                    partnereRequest = setRequestStatusAndDescription (partnereRequest,'Incomplete',
                                                                      'Validation Error! :'+StringUtils.defaultString(result.strErrorDescription) + '::'+ StringUtils.defaultString(result.strOracleError));
                }
                else {      //Success                           
                    partnereRequest = setRequestStatusAndDescription (partnereRequest,'Account Suggestion Submitted',
                                                                      'Successfully submitted! Suggestion Id = '+ result.strID);
                }   
            }catch(Exception e){ 
                partnereRequest = setRequestStatusAndDescription (partnereRequest,'Incomplete', 'Caught Apex Exception [' + e.getMessage()+']');                    
            }
        }//end of IF
        try{
            if(bupdateRequired)
            {
            }
            update partnereRequest;
        }catch(Exception e){
            System.debug('KP### Caught Apex Exception : ' + e.getMessage());
        }
    } 
    
    private static Partner_Request__c setRequestStatusAndDescription(Partner_Request__c partnereRequest,String strstatus, String strdescription){
        partnereRequest.Status__c = strstatus;
        partnereRequest.Description__c += '\nUpdate Suggestion result: ' + strdescription;
        return partnereRequest;
    }    
    //Added to merge the code at single place by Srini
    public static xmlStreamWriter Updatestatus(XmlStreamWriter  w){
        
        w=new XmlStreamWriter();
        w = addElementAndValueString(w,'salesModelCode',null);
        w = addElementAndValueString(w,'marketingClassCode',null);
        w = addElementAndValueString(w,'funcCategoryCode',null);
        w = addElementAndValueString(w,'subMarketCode',null);
        w = addElementAndValueString(w,'finGeo',null);
        w = addElementAndValueString(w,'retailFlag',null);
        w = addElementAndValueString(w,'ndaFlag',null);
        w = addElementAndValueString(w,'ndaExpDate','0001-01-01T00:00:00');
        w = addElementAndValueString(w,'cfiProjectNumber',null);
        w = addElementAndValueString(w,'stdQuoteNumber',null);
        return w;
    }
    //Added to merge the code at single place by Srini
    public static xmlStreamWriter Updatestatus2(XmlStreamWriter  w){
        
        w=new XmlStreamWriter();
        //Envelope
        w.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        w.writeNamespace('cmi', 'http://cmi.us.dell.com');
        
        //Header
        w.writeEmptyElement('soapenv','Header','http://schemas.xmlsoap.org/soap/envelope/');
        
        //Body
        w.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        
        //UpdateAccountSuggestion
        w.writeStartElement('cmi', 'UpdateAccountSuggestion', 'http://cmi.us.dell.com');
        
        w = addElementAndValueString(w,'suggestionId',null); 
        w = addElementAndValueString(w,'batchId',null); 
        w = addElementAndValueString(w,'suggestionTypeId','103');    // 103 for update Account
        return w;
    }
}