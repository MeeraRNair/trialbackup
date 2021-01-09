public class AccountSuggestionIntegrationCIL {
    /*
* Author   : Niveda
* Purpose  : This is the controller to send request for duplicate account check in affinity and proceed to create new account/associate with an existing account(11867).
*
* Revision CR Number   Release No     Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
* 1.0      12387       16.12          01-Dec-2015     Niveda           Created New method to send webservice request to activate account in Affinity
* 2.0                  CSM0104        25-Dec-2015     Anu
* 3.0     CR 13627     FY17-DCS-0103  18-Oct-2016     Gan             to activate account in affinity for account that meets the criteria.
* 3.1     CR 13627     FY17-DCS-0103  24-Nov-2016     Gan             fixing the existing issue where some of the acc is assigned to Global Data Admin even though we provided the account owner
* 3.2     CR 13806     FY18-DCS-0202  23-Dec-2016     Gan             To enable creation of SubAccount
* 3.3     CR 13806     FY18-DCS-0202  28-Dec-2016     Gan             OEM Account & SubAccount
* 4.0     CR 14728     FY18-DCS-1001  02-Aug-2017     Uday            New fields addition as per Story 3676977 
* 4.1     CR 14688     FY18-DCS-1001  04-Aug-2017     Azwanti         story 3645355: created new method createGDMRequest()
* 4.2     CR 14730     FY18-DCS-1001  07-Aug-2017     Uday            update Account suggestion XML Updated  as per Story 3681954
* 4.3     CR-14779     FY18-DCS-1001  07-Aug-2017     Ashok           Create Account Web Service and strENDPOINT Change
* 4.4     CR-14781     FY18-DCS-1001  07-Aug-2017     Ashok           Retire Update Account Web Service
* 4.5     CR 14741     FY18-DCS-1001  16-Aug-2017     Azwanti         LM2_MDM_6-New Attribute in Create Account Web Service      
* 5.0     CR 15322     FY19-DCS-0203  18-Dec-2017     Sajith          Affinity interlock - RTM value change
* 5.1     CR 15399     FY19-DCS-0203  12-Jan-2018     Azwanti         Fix Affinity integration issue - missing Local Account Name and Local Address
* 6.0     CR 15435     FY19-DCS-0401  02-March-2018   Azwanti         Affinity Interlock: Making Legal English or Legal Local Address mandatory for China and Japan countries
* 7.0     CR 15697     FY19-DCS-0602  27-April-2018   Pallavi         Removed CreateGDMRequest() method as part of Story 4168524  
* 8.0     CR 16248     FY19-DCS-0902  01-Aug-2018     Shue            Story 5199685: Lead 2.0 - Update the Territory assignment end date to blank during Account XML generation
* 9.0     CR 16427     FY20-DCS-0402  07-JAN-2019     Prasanthi M     Story 5606815:New Request Creation for Create Account Web Service(Previously it was in XML, Now Changed to JSON)
*/
    public final static String SANDBOX = 'Sandbox';
    public final static string START_TAG = 'dell';
    public final static string START_URL = 'http://schemas.xmlsoap.org/soap/envelope/';
    public final static string ENV_URL = 'http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Request';
    public final static string NAMESPACE_URL = 'https://soagw-dmznonprod.ins.dell.com';
    public final static string RESPONSE_NAMESPACE_URL = 'http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response';
    public static final Integer TIMEOUT = 120000;
    public static final String METHOD = 'POST';
    public static boolean bAUTHENTICATIONREQUIRED = false;
    public static String strUSERNAME;
    public static String strPASSWORD;
    public static String strENDPOINT;
    public static String strIdenitityKey;	
	public static String strRestrictionAPIKey;
    public static User currentUser;
    public static string strregionName;
    public static string strcountryName;
    public static boolean bisOnBoarding = false; //v2.0
    public static boolean bisHavingPhysiscalAdd = false;
    public static Boolean bisHavingPostalAddress = false;
    public static Boolean bisPostalAddressSameAsPhysical = false;
    
    public static Boolean  bisHavingLegalLocal = false;
    public static Boolean  bisHavingSalesLocal = false;
    
    
    public static Map < String, String > mapSalesModelCode = new Map < String, String > {
        'Relationship' => 'REL',
            'Transactional' => 'TRANS',
            'Public Transaction Group' => 'PTG',
            'Large' => 'LG',
            'Medium' => 'MED',
            'Small' => 'SM',
            'Other' => 'O'
            };
                public static Map < String, String > mapsuggestionReason = new Map < String, String > {
                    'New Customer' => 'NewCustomer',
                        'Prospect' => 'Prospect',
                        'Reseller' => 'Reseller',
                        'Other Intermediary' => 'OtherIntermediary',
                        'Generic' => 'Generic',
                        'Consolidation Account for multinational' => 'ConsolidationAccountForMultinational',
                        'Belongs to existing Account' => 'BelongsToExistingAccount',
                        'Change Hierarchy' => 'ChangeHierarchy',
                        'Information Change' => 'InformationChange', // this and the rest are for update Account suggestion  
                        'Reformatting Change' => 'ReformattingChange',
                        'Typo Correction' => 'TypoCorrection',
                        'Other Correction' => 'OtherCorrection'
                        };
                            public static Map < String, String > mapSubMarketCode = new Map < String, String > {
                                '4 Year Undergraduate' => '4YR',
                                    'Administrative Agency' => 'ADMIN',
                                    'Army' => 'ARMY',
                                    'Association' => 'ASSOC',
                                    'Assisted Living' => 'ASST',
                                    'Municipal Authority' => 'AUTHO',
                                    'BOCES, Coop, Board of Ed, Regional Educ Service Ctr' => 'BOC',
                                    'Cabinet/Department' => 'CAB',
                                    'Community College/2 year' => 'CCOL',
                                    'Church Owned' => 'CHUR',
                                    'City Government' => 'CITY',
                                    'Clinic' => 'CLIN',
                                    'County Government' => 'COUNT',
                                    'US Courts' => 'COURT',
                                    'eHealth' => 'EHLTH',
                                    'Employee Purchase' => 'EPP',
                                    'Faculty/Student/Staff Purchase' => 'FSS',
                                    'Generic' => 'GENER',
                                    'Govt Owned' => 'GOVT',
                                    'Group Purchasing Organization' => 'GPO',
                                    'Graduate/Research' => 'GRAD',
                                    'Health Management' => 'HMGMT',
                                    'HMO' => 'HMO',
                                    'Home Health' => 'HOMEH',
                                    'Hospital' => 'HOSP',
                                    'Independent Delivery Network' => 'IDN',
                                    'Intelligence' => 'INTEL',
                                    'Industry Solutions Vendor' => 'ISV',
                                    'Judicial' => 'JUDIC',
                                    'Laboratory' => 'LAB',
                                    'Legislature' => 'LEGIS',
                                    'Library' => 'LIBRA',
                                    'City & County Govt' => 'LOCAL',
                                    'Military School' => 'MIL',
                                    'Municipal (City or County)' => 'MUNIC',
                                    'NASA' => 'NASA',
                                    'Navy' => 'NAVY',
                                    'Nursing Home' => 'NHOME',
                                    'Private Non Profit' => 'NONP',
                                    'Nursing Services' => 'NURSE',
                                    'Office of Secretary of Defense' => 'OSD',
                                    'Other/Quasi Govt/EPP' => 'OTHER',
                                    'Private School/Other' => 'PRIV',
                                    'Private for Profit' => 'PROF',
                                    'Public School District' => 'PUB',
                                    'UN, Red Cross, Export' => 'QUASI',
                                    'Rehab School' => 'REHAB',
                                    'Research' => 'RSCH',
                                    'Reseller' => 'RSLR',
                                    'Shared' => 'SHARE',
                                    'State Govt' => 'STATE',
                                    'Surgery Center' => 'SURG',
                                    'Health System' => 'SYS',
                                    'Air Force' => 'USAF',
                                    'Marines' => 'USMC',
                                    'Vocational training-certificate' => 'VOC'
                                    };
                                        public static Map < String, String > mapregion = new Map < String, String > {
                                            'APJ' => 'ASIA_PACIFIC',
                                                'EC-EMEA' => 'EUROPE',
                                                'EMEA' => 'EUROPE',
                                                'LATAM' => 'AMERICAS',
                                                'LA' => 'AMERICAS',
                                                'NA' => 'AMERICAS'
                                                };
                                                    public static Map < String, String > mapFunctionCategoryCode = new Map < String, String > {
                                                        'Army & Air Force Exchange Service' => 'AAFES',
                                                            'Army Corp Of Engineers' => 'ACOE',
                                                            'Adult Education' => 'ADED',
                                                            'Admin & Finance' => 'ADFIN',
                                                            'Administrative Agency' => 'ADMIN',
                                                            'Air Force Air Station' => 'AFAIR',
                                                            'Air Force Base' => 'AFBAS',
                                                            'Air Force Europe' => 'AFEUR',
                                                            'Air Force Headquarters' => 'AFHQ',
                                                            'Air Force Middle East' => 'AFMID',
                                                            'Air Force National Guard' => 'AFNG',
                                                            'Air Force Other' => 'AFOTH',
                                                            'Air Force Pacific' => 'AFPAC',
                                                            'Air Force Programs' => 'AFPRG',
                                                            'Air Force Reserve' => 'AFR',
                                                            'Army Arsenals & Weapons Test' => 'AGUNS',
                                                            'Airports' => 'AIRPT',
                                                            'Army National Guard' => 'ANG',
                                                            'Army Reserve' => 'AR',
                                                            'Army Air Base' => 'ARAIR',
                                                            'Army Base' => 'ARBAS',
                                                            'American Red Cross' => 'ARC',
                                                            'Army Command' => 'ARCOM',
                                                            'Army Europe' => 'AREUR',
                                                            'Army Headquarters' => 'ARHQ',
                                                            'Army Research & Testing' => 'ARLAB',
                                                            'Army Medical' => 'ARMED',
                                                            'Army Other' => 'AROTH',
                                                            'Army Pacific' => 'ARPAC',
                                                            'Arts Humanities Museums' => 'ARTS',
                                                            'Association & PTA' => 'ASSN',
                                                            'Assisted Living' => 'ASST',
                                                            'Banking & Monetary Policy' => 'BANK',
                                                            'Specialty OBGYN' => 'BIRTH',
                                                            'BOCES' => 'BOC',
                                                            'Specialty Cancer' => 'CANC',
                                                            'Private Catholic' => 'CATH',
                                                            'DocResearch Univ Extensive' => 'CC215',
                                                            'DocResearch Univ Intensive' => 'CC216',
                                                            'Masters College and University I' => 'CC221',
                                                            'Masters College and University II' => 'CC222',
                                                            'Baccalaureate College Liberal Arts' => 'CC231',
                                                            'Baccalaureate College General' => 'CC232',
                                                            'Baccalaureate & Associate College' => 'CC233',
                                                            'Associate Colleges' => 'CC240',
                                                            'Specialized Inst Seminary' => 'CC251',
                                                            'Specialized Inst Medical Sch & Ctr' => 'CC252',
                                                            'Specialized Inst Other Health Prof' => 'CC253',
                                                            'Specialized Inst Engineering & Tech' => 'CC254',
                                                            'Specialized Inst Business & Mgmt' => 'CC255',
                                                            'Specialized Inst Art Music & Design' => 'CC256',
                                                            'Specialized Inst Law' => 'CC257',
                                                            'Specialized Inst Teachers College' => 'CC258',
                                                            'Specialized Inst Other' => 'CC259',
                                                            'Tribal College & University' => 'CC260',
                                                            'Central Intelligence Agency' => 'CIA',
                                                            'Cooperative or Consortium' => 'COOP',
                                                            'US Courts' => 'COURT',
                                                            'Defense Contract Audit Agency' => 'DCAA',
                                                            'Dell Education Alliance Reseller' => 'DEA',
                                                            'Defense Finance & Accounting Services' => 'DFAS',
                                                            'Health & Human Services' => 'DHHS',
                                                            'Defense Intelligence Agency' => 'DIA',
                                                            'Defense Information Systems Agency' => 'DISA',
                                                            'Defense Logistics Agency' => 'DLA',
                                                            'Commerce' => 'DOC',
                                                            'OSD Dept Of Defense Education Activity' => 'DODEA',
                                                            'Energy' => 'DOE',
                                                            'Interior' => 'DOI',
                                                            'Justice' => 'DOJ',
                                                            'Labor' => 'DOL',
                                                            'Transportation' => 'DOT',
                                                            'Education' => 'EDUC',
                                                            'Electric Power' => 'ELECT',
                                                            'Elementary Only' => 'ELEM',
                                                            'Emergency District' => 'EMERG',
                                                            'Executive Office of the President' => 'EOP',
                                                            'Employee Purchase' => 'EPP',
                                                            'Exec Office' => 'EXEC',
                                                            'Executive & Governor' => 'EXGOV',
                                                            'Federal' => 'FED',
                                                            'Federal Reserve' => 'FEDRS',
                                                            'Firefighters' => 'FIRE',
                                                            'Fire Other' => 'FIREO',
                                                            'GAS Supply' => 'GAS',
                                                            'General Services Administration' => 'GSA',
                                                            'National Guard' => 'GUARD',
                                                            'Water Supply' => 'H2OSP',
                                                            'Water Transport & Terminals' => 'H2OTR',
                                                            'Specialty Heart Lung' => 'HEART',
                                                            'Health' => 'HLTH',
                                                            'HMO/PPO' => 'HMO',
                                                            'Hospital' => 'HOSP',
                                                            'Housing & Comm Dev' => 'HOUSE',
                                                            'Health System' => 'HSYS',
                                                            'Housing' => 'HUD',
                                                            'Human Services' => 'HUMAN',
                                                            'Independent Delivery Network' => 'IDN',
                                                            'Indian School' => 'IND',
                                                            'Intelligence Other' => 'INOTH',
                                                            'Intelligence Reseller' => 'INVAR',
                                                            'Industry Software Vendor' => 'ISV',
                                                            'Judicial & Courts' => 'JUDIC',
                                                            'Laboratory' => 'LAB',
                                                            'Labor & Econ Dev' => 'LABOR',
                                                            'Legislature & Congress' => 'LEGIS',
                                                            'Coop Library' => 'LIBCO',
                                                            'State Library' => 'LIBGS',
                                                            'Main Library' => 'LIBMA',
                                                            'Library Systems' => 'LIBSY',
                                                            'Marine Air Base' => 'MCAIR',
                                                            'Marine Base' => 'MCBAS',
                                                            'Marine Headquarters' => 'MCHQ',
                                                            'Marines Other' => 'MCOTH',
                                                            'Doctors Office' => 'MD',
                                                            'MSA County' => 'MSAGC',
                                                            'MSA City' => 'MSAGL',
                                                            'Naval Air Station' => 'NAS',
                                                            'Aeronautics & Space' => 'NASA',
                                                            'Natural Resources' => 'NATRS',
                                                            'Navy Computer Facility' => 'NCOMP',
                                                            'Navy Arsenal & Weapons Test' => 'NGUNS',
                                                            'National Imagery & Mapping Agency' => 'NIMA',
                                                            'Navy Marine Corps Intranet' => 'NMCI',
                                                            'National Reconnaissance Office' => 'NRO',
                                                            'National Security Agency' => 'NSA',
                                                            'Navy Shipyard' => 'NSHIP',
                                                            'Navy Spawar' => 'NSPAW',
                                                            'Nursing Home' => 'NURSE',
                                                            'Navy Air Base' => 'NVAIR',
                                                            'Navy Base' => 'NVBAS',
                                                            'Navy Command' => 'NVCOM',
                                                            'Navy Facilities' => 'NVFAC',
                                                            'Navy Headquarters' => 'NVHQ',
                                                            'Navy Research & Testing' => 'NVLAB',
                                                            'Navy Medical' => 'NVMED',
                                                            'Navy Other' => 'NVOTH',
                                                            'Navy Security' => 'NVSEC',
                                                            'Navy Submarine Facility' => 'NVSUB',
                                                            'Navy Supply Center' => 'NVSUP',
                                                            'OSD Other' => 'OSDO',
                                                            'Other County' => 'OTHGC',
                                                            'Other City' => 'OTHGL',
                                                            'Other SLG' => 'OTHSL',
                                                            'Outpatient Other' => 'OUTP',
                                                            'Parks & Recreation' => 'PARKS',
                                                            'Pentagon' => 'PENT',
                                                            'Postal Service' => 'POST',
                                                            'Preschool & Daycare' => 'PREK',
                                                            'Prisoners' => 'PRIS',
                                                            'Private Other' => 'PRVOT',
                                                            'Public School District' => 'PUB',
                                                            'Public Works' => 'PUBWK',
                                                            'County or Regional Center' => 'REG',
                                                            'Regulatory' => 'REGUL',
                                                            'Rehabilitation Facility' => 'REHAB',
                                                            'Religious Other' => 'RELIG',
                                                            'Reserves' => 'RESRV',
                                                            'Retirement' => 'RETIR',
                                                            'Research' => 'RSCH',
                                                            'Reseller' => 'RSLR',
                                                            'Law & Public Safety' => 'SAFTY',
                                                            'Science & Technology' => 'SCIEN',
                                                            'OSD Headquarters' => 'SDHQ',
                                                            'OSD Medical' => 'SDMED',
                                                            'OSD Other' => 'SDOTH',
                                                            'Selective Service' => 'SERV',
                                                            'Sewerage' => 'SEWER',
                                                            'State Library' => 'SLIBR',
                                                            'Solid Waste' => 'SOLID',
                                                            'Social Security' => 'SSA',
                                                            'State Department' => 'ST',
                                                            'State Dept Aid' => 'STAID',
                                                            'State' => 'STATE',
                                                            'State Dept Embassies & Consulates' => 'STEMB',
                                                            'Streets & Highways' => 'STHWY',
                                                            'State Dept Other' => 'STOTH',
                                                            'Specialty Surgical' => 'SURG',
                                                            'Transportation' => 'TPORT',
                                                            'DOD Training/ Schools' => 'TRAIN',
                                                            'Treasury' => 'TREAS',
                                                            'Transit' => 'TRSIT',
                                                            'United Nations' => 'UN',
                                                            'Agriculture' => 'USDA',
                                                            'Utility District' => 'UTIL',
                                                            'Veterans Affairs' => 'VA',
                                                            'Vocational & Technical' => 'VTECH',
                                                            'Welfare' => 'WELF',
                                                            'Public Works' => 'WORKS'
                                                            };
                                                                public static Map < String, String > mapMarketingClassCode = new Map < String, String > {
                                                                    'Defense Air Force' => 'AF',
                                                                        'Defense Army' => 'AR',
                                                                        'Civilian Admin Agency' => 'CA',
                                                                        'Civilian Cabinet' => 'CB',
                                                                        'CIV EPP' => 'CE',
                                                                        'Civilian Justice' => 'CJ',
                                                                        'Civilian Legislature' => 'CL',
                                                                        'Civilian Other' => 'CO',
                                                                        'Civilian Quasi' => 'CQ',
                                                                        'Civilian Space' => 'CS',
                                                                        'Civilian Reseller' => 'CV',
                                                                        'Defense EPP' => 'DE',
                                                                        'Defense Reseller' => 'DV',
                                                                        'HED Microcenter' => 'EM',
                                                                        'HED Reseller' => 'EV',
                                                                        'HED FSS' => 'FS',
                                                                        'Federal Reseller' => 'FV',
                                                                        'SLG Library' => 'GB',
                                                                        'SLG County' => 'GC',
                                                                        'SLG City' => 'GL',
                                                                        'SLG Other' => 'GO',
                                                                        'SLG State' => 'GS',
                                                                        'SLG Reseller' => 'GV',
                                                                        'BROADLANE PURCHASERS' => 'HB',
                                                                        'Clinic & Doctor Office' => 'HC',
                                                                        'Ehealth' => 'HE',
                                                                        'Hospital' => 'HH',
                                                                        'ISV Consultant' => 'HI',
                                                                        'Nursing Home' => 'HN',
                                                                        'Health Other' => 'HO',
                                                                        'HPG Member' => 'HP',
                                                                        'HCD Reseller' => 'HR',
                                                                        'Health System IDN' => 'HS',
                                                                        'Defense & Intelligence' => 'IN',
                                                                        'K12 Boces Educ Svc Ctr Coop' => 'KB',
                                                                        'K12 Private Catholic School' => 'KC',
                                                                        'K12 DEA Reseller' => 'KD',
                                                                        'K12 FSS' => 'KE',
                                                                        'K12 Private Other' => 'KO',
                                                                        'K12 Public School District' => 'KP',
                                                                        'K12 Reseller' => 'KV',
                                                                        'Defense Navy' => 'NV',
                                                                        'HED Private Non-Profit' => 'PN',
                                                                        'HED Private For-Profit' => 'PP',
                                                                        'HED Public Institution' => 'PU',
                                                                        'Internal ACCT_ID' => 'QX',
                                                                        'Secretary of Defense' => 'SD'
                                                                        };
                                                                            
                                                                            public static AccountSuggestionResponse sendAccountSuggestion(Lead leadRecord, Boolean bisDupCheckRequired) {
                                                                                AccountSuggestionResponse response = new AccountSuggestionResponse();
                                                                                string strinitialResponse;
                                                                                if (leadRecord != null) {
                                                                                    //create request body from the Account record
                                                                                    String strrequestBody = createAccountsuggestionHTTPRequestBodyString(leadRecord, bisDupCheckRequired);
                                                                                    strinitialResponse = sendHttpRequest(strrequestBody, 'CreateAccount');
                                                                                    response = AccountSuggestionResponse.parseResponseString(strinitialResponse);
                                                                                }
                                                                                return response;
                                                                            }
    
    //Send request to affinity to create a new account.
    public static String sendAccountSuggestionToAffinty(Lead leadRecord, Boolean bisDupCheckRequired) {
        string strinitialResponse;
        system.debug('****Start');
        if (leadRecord != null) {
            //create request body from PR/Lead
            GAMASuggestionReq suggReq = new GAMASuggestionReq(); 
            String strrequestBody =  suggReq.generateReq(leadRecord, bisDupCheckRequired);
            system.debug('Request Body : '+strrequestBody);
            strinitialResponse = sendHttpRequestForDST(strrequestBody, 'CreateAccount');
            
            system.debug('****Initial Response: '+strinitialResponse);
            
        }
        return strinitialResponse;
    }
    
    //Send request to affinity to activate a account which is at Under Review status
    public static AccountSuggestionResponse sendAccountActivationRequest(Account accountRecord) {
        AccountSuggestionResponse response = new AccountSuggestionResponse();
        string strinitialResponse;
        if (accountRecord != null) {
            //create request body from the Account record
            String strrequestBody = createActivateAccountHTTPRequestBodyString(accountRecord);
            strinitialResponse = sendHttpRequest(strrequestBody, 'UpdateAccount');
            response = AccountSuggestionResponse.parseResponseString(strinitialResponse);
        }
        return response;
    }
    
    //Method to send HTTPRequest (DST Suggestion)
    public static String sendHttpRequestForDST(String strrequestBody, String straction) {
        //method call to create HttpRequest
        HttpRequest req = createHttpRequestHeaderToDST(straction);
        //sets the request body
        req.setBody(strrequestBody);
        Http http = new Http();
        //Sending the HTTP request
        HTTPResponse res = http.send(req);
        system.debug('***Status' +res.getStatusCode());  
        
        string strresult;    
        if(res.getStatusCode() == 200){
            strresult = res.getBody();
        }else if(res.getStatusCode() != 200){
            WebServiceExceptionHandling.insertException(strrequestBody,res.getBody(),res.getStatusCode(),'SendDST','Partner_Request' ); 
            strresult = 'Internal Server Error';
        }
        return strresult;
    }
    
    
    public static String sendHttpRequest(String strrequestBody, String straction) {
        //method call to create HttpRequest
        HttpRequest req = createHttpRequestHeader(straction);
        //sets the request body
        req.setBody(strrequestBody);
        
        Http http = new Http();
        //Sending the HTTP request
        HTTPResponse res = http.send(req);
        return res.getBody();
        
    }   
    
    //Method to create HTTPRequest Header (DST Suggestion)
    public static HttpRequest createHttpRequestHeaderToDST(string straction) {
        if (StaticFactory.getEnvironment() == SANDBOX) {
            strUSERNAME = System.Label.Affinity_DST_SandBox_UserName;
            strPASSWORD = System.Label.Affinity_DST_SandBox_Pwd;
            strENDPOINT = System.Label.Affinity_DST_SandBox_Endpoint;
            strIdenitityKey = System.Label.Affinity_DST_Dell_Identity_Key_SB;	
    		strRestrictionAPIKey = System.Label.Affinity_DST_Dell_Identity_restriction_api_key_SB;
            bAUTHENTICATIONREQUIRED = true;
        }
        //Set header parameters for Sandbox 
        else {
            strUSERNAME = System.Label.Affinity_DST_Prod_UserName; //for PRODUCTION env
            strPASSWORD = System.Label.Affinity_DST_Prod_Pwd;
            //Rev 4.0 - start
            strENDPOINT = System.Label.Affinity_DST_Prod_Endpoint;
            //Rev 4.0 - end 
            strIdenitityKey = System.Label.Affinity_DST_Dell_Identity_Key_Prod;	
			strRestrictionAPIKey = System.Label.Affinity_DST_Dell_Identity_restriction_api_key_Prod;
            bAUTHENTICATIONREQUIRED = true;
            system.debug('&&&***');
        }
        HttpRequest req = new HttpRequest();
        //Set ENDPOINT URL      
        req.setEndpoint(strENDPOINT);
        req.setHeader('apikey',System.Label.Affinity_DST_APIKey);
        req.setHeader('content-type', 'application/json;charset=UTF-8');
        req.setHeader('x-dell-identity-key',strIdenitityKey);	
		req.setHeader('x-dell-identity-restriction-api-key',strRestrictionAPIKey);
        String stractionMethod = 'CIL/IExploreAffinity/' + straction;
        req.setMethod(METHOD);
        
        // Specify the required user name and strPASSWORD to access the strENDPOINT
        // As well as the header and header information 
        if (bAUTHENTICATIONREQUIRED) {
            Blob blbheaderValue = Blob.valueOf(strUSERNAME + ':' + strPASSWORD);
            String strauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbheaderValue);
            req.setHeader('Authorization', strauthorizationHeader);
        }
        
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req;
    }
    
    //Method to create HTTPRequest Header
    public static HttpRequest createHttpRequestHeader(string straction) {
        if (StaticFactory.getEnvironment() == SANDBOX) {
            /* USERNAME='AffinitySearch';
strPASSWORD='MDM@d3ll';
strENDPOINT='https://soagw-dmznonprod.ins.dell.com:443/CIL/AffinityService.svc/ws'; */
            strUSERNAME = System.Label.Affinity_SandBox_UserName;
            strPASSWORD = System.Label.Affinity_SandBox_Pwd;
            strENDPOINT = System.Label.Affinity_SandBox_Endpoint;
            bAUTHENTICATIONREQUIRED = true;
        }
        //Set header parameters for Sandbox 
        else {
            strUSERNAME = System.Label.Affinity_Prod_UserName; //for PRODUCTION env
            strPASSWORD = System.Label.Affinity_Prod_Pwd;
            //Rev 4.0 - start
            strENDPOINT = System.Label.Affinity_Prod_Endpoint;
            //Rev 4.0 - end 
            bAUTHENTICATIONREQUIRED = true;
        }
        HttpRequest req = new HttpRequest();
        //Set strENDPOINT URL      
        req.setEndpoint(strENDPOINT);
        
        req.setHeader('content-type', 'text/xml;charset=UTF-8');
        String stractionMethod = 'CIL/IExploreAffinity/' + straction;
        req.setHeader('SOAPAction', stractionMethod);
        
        //Set the method Type
        req.setMethod(METHOD);
        
        // Specify the required user name and strPASSWORD to access the strENDPOINT
        // As well as the header and header information 
        if (bAUTHENTICATIONREQUIRED) {
            Blob blbheaderValue = Blob.valueOf(strUSERNAME + ':' + strPASSWORD);
            String strauthorizationHeader = 'Basic ' + EncodingUtil.base64Encode(blbheaderValue);
            req.setHeader('Authorization', strauthorizationHeader);
        }
        
        //Set the timeout value for the Request
        req.setTimeout(TIMEOUT);
        return req;
    }   
    
    //v2.0
    public static Boolean addressCheck(Lead leadRecord) {
        if (leadRecord.Physical_Company_Name__c != null || leadRecord.Physical_Address_1__c != null || leadRecord.Physical_Address_2__c != null  || leadRecord.Physical_City__c != null || leadRecord.Physical_State__c != null || leadRecord.Physical_PostalCode__c != null || leadRecord.Physical_suburb__c != null || leadRecord.Physical_Country__r.Code__c != null) {
            bisHavingPhysiscalAdd = True;
        }
        if (leadRecord.Postal_Company_Name__c != null || leadRecord.Postal_Address_1__c != null || leadRecord.Postal_Address_2__c != null ||  leadRecord.Physical_City__c != null || leadRecord.Postal_suburb__c != null || leadRecord.Postal_State__c != null || leadRecord.Postal_PostalCode__c != null || leadRecord.Postal_Country__r.Code__c != null) {
            bisHavingPostalAddress = True;
        }
        
        
        if(!test.isRunningTest()){
            bisHavingLegalLocal  = true;
            bisHavingSalesLocal = true;
            
        }else{
            bisHavingLegalLocal  = false;
            bisHavingSalesLocal = false;
            
        }
        
        if (leadRecord.Physical_Company_Name__c == leadRecord.Postal_Company_Name__c && leadRecord.Physical_Address_1__c == leadRecord.Postal_Address_1__c &&
            leadRecord.Physical_Address_2__c == leadRecord.Postal_Address_2__c && leadRecord.Physical_City__c == leadRecord.Postal_City__c && leadRecord.Physical_State__c == leadRecord.Postal_State__c && leadRecord.Physical_suburb__c == leadRecord.Postal_suburb__c && leadRecord.Physical_PostalCode__c == leadRecord.Postal_PostalCode__c && leadRecord.Physical_Country__r.Code__c == leadRecord.Postal_Country__r.Code__c) {
                return True;
            } else {
                return False;
            }
        
    }
    //v2.0
    public static String convertDateTimeToString(DateTime dt) {
        if (dt == null) {
            return DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        } else {
            return dt.format('yyyy-MM-dd\'T\'hh:mm:ss');
        }
        
    }
    
    //Build xml request body - To create account
    public static String createAccountsuggestionHTTPRequestBodyString(Lead leadRecord, Boolean bisDupCheckRequired) {
        currentUser = [SELECT Id, Badge_Number__c, FirstName, LastName, Email,HR_Location_Country_Desc__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1][0];
        String strtoDateIn = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        User leadOwner;
        string strlegacyId = 'SFDC_' + leadRecord.id;
        Country__c leadCountry;
        if (leadRecord.Physical_Country__c != null){
            leadCountry = [Select name, code__c, region__c from country__c where id = : leadRecord.Physical_Country__c limit 1];
        }
        XmlStreamWriter w = new XmlStreamWriter();
        w=AccountSuggestionIntegrationCIL.updatestatus2(w);
        /*w.writeStartElement('soapenv', 'Envelope', START_URL);
w.writeNamespace('soapenv', START_URL);
w.writeNamespace('cil', 'CIL');
w.writeNamespace(START_TAG, ENV_URL);

//Header
w.writeEmptyElement('soapenv', 'Header', START_URL);
//Body
w.writeStartElement('soapenv', 'Body', START_URL);
w.writeStartElement('cil', 'CreateAccount', NAMESPACE_URL);
w.writeStartElement('cil', 'request', NAMESPACE_URL);*/
        /*------------------------------------------- AddressInformation -----------------------------------------------*/
        if (!bisOnBoarding) {
            leadOwner = StaticFactory.getUserDetails(leadRecord.ownerid);
            
            w = IntegrationUtilities.startElement(w, 'AddressInformation', START_TAG, NAMESPACE_URL);
            if(leadRecord.Street != null && leadRecord.City != null && leadRecord.Country != null){ // v6.0
                w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                if(currentUser.HR_Location_Country_Desc__c!=null && currentUser.HR_Location_Country_Desc__c.toUppercase()=='CHINA'){
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Street_CN__c', START_TAG, NAMESPACE_URL);
                }else{
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Street', START_TAG, NAMESPACE_URL);
                }
                w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Legal', START_TAG, NAMESPACE_URL);//Story 3676977 //Updated by Ashok - Story 3645255 - 4.3
                if(currentUser.HR_Location_Country_Desc__c!=null && currentUser.HR_Location_Country_Desc__c.toUppercase()=='CHINA'){
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'City_CN__c', START_TAG, NAMESPACE_URL);
                }else{
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'City', START_TAG, NAMESPACE_URL);
                }
                //v6.0 only populate Company Name and Country Code if Addressline1, City and Country != null
                if(leadRecord.Street != null && leadRecord.City != null && leadCountry.code__c != null){
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadCountry.code__c, START_TAG, NAMESPACE_URL); 
                }        
                w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Country', START_TAG, NAMESPACE_URL);
                
                if(currentUser.HR_Location_Country_Desc__c!=null && currentUser.HR_Location_Country_Desc__c.toUppercase()=='CHINA'){
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Zip_Postal_Code_CN__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'State_Province_CN__c', START_TAG, NAMESPACE_URL);
                }else{
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'PostalCode', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'State', START_TAG, NAMESPACE_URL);
                }
                w.writeEndElement();
            }
            //start - v5.1
            //LegalLocal address section for End User Account
            
            /********************new nodes for address**************************/    
            
            if (leadRecord.Legal_Local_Country__c != null && leadRecord.Legal_Local_Country__c!=''
                && leadRecord.Legal_Local_Address_1__c != null && leadRecord.Legal_Local_Address_1__c != ''
                && leadRecord.Legal_Local_City__c!= null && leadRecord.Legal_Local_City__c!= '')
            {  
                w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Legal_Local_Address_1__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Legal_Local_Address_2__c', START_TAG, NAMESPACE_URL);
                
                w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'LegalLocal', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Legal_Local_City__c', START_TAG, NAMESPACE_URL);
                if(leadRecord.Legal_Local_Company_Name__c == null){ //v6.0 populate Company to Company Local if only submit Local address
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
                }
                else{
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Legal_Local_Company_Name__c', START_TAG, NAMESPACE_URL);
                }
                w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode',  leadCountry.code__c, START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'Country', leadRecord.Legal_Local_Country__c, START_TAG, NAMESPACE_URL);
                
                w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Legal_Local_Postal_Code__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Legal_Local_Postal_State__c', START_TAG, NAMESPACE_URL);
                w.writeEndElement(); //end AccountAddressInfo
                
            }//end - v5.1  
            w.writeEndElement(); //end AddressInformation         
            
        } else {
            //checking id Physical/postal address is populated
            bisPostalAddressSameAsPhysical = addressCheck(leadRecord);
            
            //if any of the address details present
            if (bisHavingPhysiscalAdd || bisHavingPostalAddress) {
                w = IntegrationUtilities.startElement(w, 'AddressInformation', START_TAG, NAMESPACE_URL);
                if (bisHavingPhysiscalAdd) {
                    w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Physical_Address_1__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Physical_Address_2__c', START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Sales', START_TAG, NAMESPACE_URL);//Story 3676977 
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Physical_City__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Physical_Company_Name__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Physical_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'Country', leadRecord.Physical_Country__r.Name, START_TAG, NAMESPACE_URL);
                    
                    List<string> listFaxpsplit = new List<string>();
                    if(leadRecord.Physical_Fax__c != null && leadRecord.Physical_Fax__c != ''){       
                        listFaxpsplit = leadRecord.Physical_Fax__c.split('-');
                        
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxArea', listFaxpsplit[1], START_TAG, NAMESPACE_URL);
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxCountry', listFaxpsplit[0], START_TAG, NAMESPACE_URL);
                        if(listFaxpsplit.size()>3){
                            w = IntegrationUtilities.addElementAndValueString(w, 'FaxExtn', listFaxpsplit[3], START_TAG, NAMESPACE_URL); 
                        }
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxNum', listFaxpsplit[2], START_TAG, NAMESPACE_URL);
                    }
                    List<string> listphonepsplit = new List<string>();
                    if(leadRecord.Physical_Phone__c != null && leadRecord.Physical_Phone__c != ''){
                        listphonepsplit = leadRecord.Physical_Phone__c.split('-');
                        if(listphonepsplit.size() > 2) {  
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneArea',listphonepsplit[1], START_TAG, NAMESPACE_URL);
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneCountry', listphonepsplit[0], START_TAG, NAMESPACE_URL); 
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneNum',listphonepsplit[2], START_TAG, NAMESPACE_URL);
                            if(listphonepsplit.size()>3) {
                                w = IntegrationUtilities.addElementAndValueString(w, 'PhoneExtn',listphonepsplit[3], START_TAG, NAMESPACE_URL);
                            }
                        }
                        else if(listphonepsplit.size() == 2){
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneCountry', listphonepsplit[0], START_TAG, NAMESPACE_URL); 
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneNum',listphonepsplit[1], START_TAG, NAMESPACE_URL);
                        }      
                    }  
                    
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Physical_PostalCode__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Physical_State__c', START_TAG, NAMESPACE_URL);
                    w.writeEndElement(); //end AccountAddressInfo
                }
                
                if (bisHavingPostalAddress) { //Story 3676977 
                    w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Postal_Address_1__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Postal_Address_2__c', START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Legal', START_TAG, NAMESPACE_URL);//Story 3676977 
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Postal_City__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Postal_Company_Name__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Postal_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'Country', leadRecord.Postal_Country__r.Name, START_TAG, NAMESPACE_URL);
                    
                    List<string> listFaxsplit = new List<string>();
                    if(leadRecord.Postal_Fax__c!= null && leadRecord.Postal_Fax__c!= ''){       
                        listFaxsplit = leadRecord.Postal_Fax__c.split('-');
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxArea', listFaxsplit[1], START_TAG, NAMESPACE_URL);
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxCountry', listFaxsplit[0], START_TAG, NAMESPACE_URL);
                        if(listFaxsplit.size()>3){
                            w = IntegrationUtilities.addElementAndValueString(w, 'FaxExtn', listFaxsplit[3], START_TAG, NAMESPACE_URL); 
                        }
                        w = IntegrationUtilities.addElementAndValueString(w, 'FaxNum', listFaxsplit[2], START_TAG, NAMESPACE_URL);
                    }
                    List<string> listphonesplit = new List<string>();
                    if(leadRecord.Postal_Phone__c != null && leadRecord.Postal_Phone__c != ''){
                        listphonesplit = leadRecord.Postal_Phone__c.split('-');
                        
                        if(listphonesplit.size() > 2){  
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneArea',listphonesplit[1], START_TAG, NAMESPACE_URL);
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneCountry',listphonesplit[0], START_TAG, NAMESPACE_URL); 
                            if(listphonesplit.size()>3){
                                w = IntegrationUtilities.addElementAndValueString(w, 'PhoneExtn',listphonesplit[3], START_TAG, NAMESPACE_URL);
                            }
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneNum',listphonesplit[2], START_TAG, NAMESPACE_URL);
                        }else if(listphonesplit.size() == 2){
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneCountry',listphonesplit[0], START_TAG, NAMESPACE_URL); 
                            w = IntegrationUtilities.addElementAndValueString(w, 'PhoneNum',listphonesplit[1], START_TAG, NAMESPACE_URL);
                        }
                    } 
                    
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Postal_PostalCode__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Postal_State__c', START_TAG, NAMESPACE_URL);
                    w.writeEndElement(); //end AccountAddressInfo
                }
                
                //LegalLocal address section
                
                /********************new nodes for address**************************/
                
                if (bisHavingLegalLocal && leadRecord.Legal_Local_Country__c !=null && leadRecord.Legal_Local_Country__c!='') { //Story 3676977 
                    w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Legal_Local_Address_1__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Legal_Local_Address_2__c', START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'LegalLocal', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Legal_Local_City__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Legal_Local_Company_Name__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Postal_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'Country', leadRecord.Legal_Local_Country__c, START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Legal_Local_Postal_Code__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Legal_Local_Postal_State__c', START_TAG, NAMESPACE_URL);
                    w.writeEndElement(); //end AccountAddressInfo
                }
                
                if (bisHavingSalesLocal && leadRecord.Sales_Relationship_Local_Country__c !=null && leadRecord.Sales_Relationship_Local_Country__c !='') { //Story 3676977 
                    w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Sales_Relationship_Local_Address_1__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Sales_Relationship_Local_Address_2__c', START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'SalesLocal', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Sales_Relationship_Local_City__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Sales_Relationship_Local_Company_Name__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Physical_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'Country', leadRecord.Sales_Relationship_Local_Country__c, START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Sales_Relationship_Local_Code__c', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Sales_Relationship_Local_State__c', START_TAG, NAMESPACE_URL);
                    w.writeEndElement(); //end AccountAddressInfo
                }       
                
                /********************* end of new address****************************/
                
                //end of LegalLocal address section
                w.writeEndElement(); //end AddressInformation 
            }
            
        }
        /*------------------------------------------- BasicInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'BasicInformation', START_TAG, NAMESPACE_URL);
        if (bisOnBoarding){
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountCategory', 'Partner', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountCategory', 'EndUser', START_TAG, NAMESPACE_URL);
        }
            w = IntegrationUtilities.addElementAndValue(w, 'AccountName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
        
        if (bisOnBoarding){
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountStatus', 'Active', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountStatus', 'Active', START_TAG, NAMESPACE_URL);
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'Account', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'CFIProjectNumber', leadRecord, 'CFI_Project_Numbers__c', START_TAG, NAMESPACE_URL);
        if (bisOnBoarding) {
            w = IntegrationUtilities.addElementAndValueString(w, 'ChannelCompEligibleFlg', 'No', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'CompanyFoundedDate', convertDateTimeToString(leadRecord.Date_Founded__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Organization_Country__r.Code__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Currency', leadRecord.Organization_Country__r.User_Currency_Iso_Code__c, START_TAG, NAMESPACE_URL);
            
            if (leadRecord.DMU_Flag__c)
                w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'Yes', START_TAG, NAMESPACE_URL);
            else
                w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'No', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'FinGeo', leadRecord, 'FIN_GEO__c', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'FiscalYearEnd', convertDateTimeToString(leadRecord.Fiscal_Year_End__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'FuctionalCategoryCode', mapFunctionCategoryCode.get(leadRecord.Function_Category_Code__c), START_TAG, NAMESPACE_URL);
            if (leadRecord.NDA_Flag__c){
                w = IntegrationUtilities.addElementAndValueString(w, 'GCPFlag', 'Yes', START_TAG, NAMESPACE_URL);
            }
            else{
                w = IntegrationUtilities.addElementAndValueString(w, 'GCPFlag', 'No', START_TAG, NAMESPACE_URL);
            }
        } else {
            w = IntegrationUtilities.addElementAndValueString(w, 'ChannelCompEligibleFlg', 'No', START_TAG, NAMESPACE_URL);//v4.5
            w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadCountry.code__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'Yes', START_TAG, NAMESPACE_URL);
            
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'HierarchyType', 'SALES', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'LegacyID', strlegacyId, START_TAG, NAMESPACE_URL);
        if (bisOnBoarding) {
            w = IntegrationUtilities.addElementAndValue(w, 'LocalAccountName', leadRecord, 'CompanyLocal', START_TAG, NAMESPACE_URL);
            if (leadRecord.Location_Number__c != null){
                w = IntegrationUtilities.addElementAndValue(w, 'LocationNumber', leadRecord, 'Location_Number__c', START_TAG, NAMESPACE_URL);
            }
            else{
                w = IntegrationUtilities.addElementAndValueString(w, 'LocationNumber', '0', START_TAG, NAMESPACE_URL);
            }
            w = IntegrationUtilities.addElementAndValueString(w, 'MarkettingClassCode', mapMarketingClassCode.get(leadRecord.Marketing_Class_Code__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'NDAAgreemenet', booleanUtils.toStringYesNo(leadRecord.NDA_Flag__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'NDAExpiryDate', convertDateTimeToString(leadRecord.NDA_Expiry_Date__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'NationalID', leadRecord.National_ID__c, START_TAG, NAMESPACE_URL);
            if (leadRecord.NumberOfEmployees != null) {
                w = IntegrationUtilities.addElementAndValue(w, 'NoOfEmployee', leadRecord, 'NumberOfEmployees', START_TAG, NAMESPACE_URL);
            } else {
                w = IntegrationUtilities.addElementAndValueString(w, 'NoOfEmployee', '0', START_TAG, NAMESPACE_URL);
            }
            w = IntegrationUtilities.addElementAndValueString(w, 'PremierPageUrl', leadRecord.Premier_Page_URL__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'ProgramType', leadRecord.Program_Type__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'RTM', leadRecord.RTM__c, START_TAG, NAMESPACE_URL);//Story 3676977
            w = IntegrationUtilities.addElementAndValueString(w, 'SICCode', '0', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'STDQuoteNumbers', leadRecord.Std_Quote_Numbers__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SalesModelCode', mapSalesModelCode.get(leadRecord.Sales_Model_Code__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SubMarketCode', mapSubMarketCode.get(leadRecord.Sub_Market_Code__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'WebSiteUrl', leadRecord.Website, START_TAG, NAMESPACE_URL);
        } else {
            w = IntegrationUtilities.addElementAndValue(w, 'LocalAccountName', leadRecord, 'Legal_Local_Company_Name__c', START_TAG, NAMESPACE_URL); //v5.1
            w = IntegrationUtilities.addElementAndValueString(w, 'RTM', 'DIRECT', START_TAG, NAMESPACE_URL);//v4.5
            w = IntegrationUtilities.addElementAndValue(w, 'SalesModelCode', leadRecord, 'Sales_Model_Code__c', START_TAG, NAMESPACE_URL);
            
        }
        
        w.writeEndElement(); //end BasicInformation
        /*------------------------------------------- Duplicate Check -----------------------------------------------*/
        if (bisDupCheckRequired){
            w = IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation', 'Yes', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation', 'No', START_TAG, NAMESPACE_URL);
    	}
    /*------------------------------------------- SalesRepInformation -----------------------------------------------*/
        if (!bisOnBoarding) {
            w = IntegrationUtilities.startElement(w, 'SalesRepInformation', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.startElement(w, 'AccountSalesRepInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentType', 'Direct', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', leadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
            //3.1
            w = IntegrationUtilities.addElementAndValueString(w, 'OwnerForAccount', 'Yes', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'PrimaryAssignee', 'Yes', START_TAG, NAMESPACE_URL);
            //8.0 Leave this as blank -- w = IntegrationUtilities.addElementAndValueString(w, 'ResourceRoleEndDate', '9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'ResourceRoleStartDate', strtoDateIn, START_TAG, NAMESPACE_URL);
            
            w.writeEndElement(); //end AccountSalesRepInfo
            w.writeEndElement(); //end SalesRepInformation
        }
        if (bisOnBoarding && leadRecord.Account_Owner__c != null) {
            w = IntegrationUtilities.startElement(w, 'SalesRepInformation', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.startElement(w, 'AccountSalesRepInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'straction', 'Add', START_TAG, NAMESPACE_URL);
            w= IntegrationUtilities.addElementAndValueString(w,'AssignmentType', 'Direct', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', leadRecord.Account_Owner__r.Badge_Number__c, START_TAG, NAMESPACE_URL);
            //3.1
            w = IntegrationUtilities.addElementAndValueString(w, 'OwnerForAccount', 'Yes', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'ResourceRoleStartDate', strtoDateIn, START_TAG, NAMESPACE_URL);   
            String struserRole = StringUtils.substringAfter(leadRecord.Account_Owner__r.UserRole.name, '_');
            w = IntegrationUtilities.addElementAndValueString(w, 'SalesRepName', leadRecord.Account_Owner__r.FirstName + ' ' + leadRecord.Account_Owner__r.LastName, START_TAG, NAMESPACE_URL);
            
            w.writeEndElement(); //end AccountSalesRepInfo
            w.writeEndElement(); //end SalesRepInformation
        }
        /*------------------------------------------- SuggestionInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'SuggestionInformation', START_TAG, NAMESPACE_URL);
        String strregion = mapregion.get(leadRecord.Organization_Country__r.Region__c);
        
        if (bisOnBoarding) {
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'Account', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', currentUser.Badge_Number__c, START_TAG, NAMESPACE_URL);// CR 14728    
            w = IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule', 'SFDC', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate', strtoDateIn, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveTypeId', '1', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Region', strregion, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments', leadRecord.Questions_Comments__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason', mapsuggestionReason.get(leadRecord.Suggestion_Reason__c), START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus', 'Approved', START_TAG, NAMESPACE_URL);
            
            
        } else {
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'Account', START_TAG, NAMESPACE_URL);//Story 3645255 Added by Ashok G - 4.3
            w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', leadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule', 'SFDC_LM', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate', strtoDateIn, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveTypeId', '1', START_TAG, NAMESPACE_URL);
            
            w = IntegrationUtilities.addElementAndValueString(w, 'Region', mapregion.get(leadCountry.region__c), START_TAG, NAMESPACE_URL);
            
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments', '', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason', 'Generic', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus', 'Approved', START_TAG, NAMESPACE_URL);
            
        }
        w.writeEndElement(); //end SuggestionInformation
        /*------------------------------------------- TerritoryInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'TerritoryInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.startElement(w, 'AccountTerritoryInfo', START_TAG, NAMESPACE_URL);
        String strterritoryGroupId;
        String strterritoryGroupName;
        //3.3
        string strRegionDesc;
        
        if (leadRecord.Territory_Assignment__r.Group_ID__c == null) {
            //3.3
            Sales_Channel_Group__c salesChannelObj = [select name, Group_ID__c, region_desc__c from Sales_Channel_Group__c 
                                                      where id = : leadRecord.Territory_Assignment__c];
            strterritoryGroupId = salesChannelObj.Group_ID__c;
            strterritoryGroupName = salesChannelObj.Name;
            //3.3
            strRegionDesc = salesChannelObj.region_desc__c; 
        } else {
            strterritoryGroupId = leadRecord.Territory_Assignment__r.Group_ID__c;
            strterritoryGroupName = leadRecord.Territory_Assignment__r.Name;
            //3.3 excluding !bisOnBoarding as need channel lead changes and this is only required for direct lead at the moment.
            if (!bisOnBoarding) {
                strRegionDesc = leadRecord.Territory_Assignment__r.Region_Desc__c;
            }
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'straction', 'Assign', START_TAG, NAMESPACE_URL);
        //8.0 Leave this as blank -- w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentEndDate', '9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentStartDate', strtoDateIn, START_TAG, NAMESPACE_URL);
        if (strterritoryGroupId != null && strterritoryGroupName != null) {
            w = IntegrationUtilities.addElementAndValueString(w, 'GroupID', strterritoryGroupId, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'GroupName', strterritoryGroupName, START_TAG, NAMESPACE_URL);
        }
        w.writeEndElement(); //end AccountTerritoryInfo
        w.writeEndElement(); //end TerritoryInformation
        /*------------------------------------------- UDA-----------------------------------------------*/
        if (bisOnBoarding) {
            w = IntegrationUtilities.startElement(w, 'UDAInformation', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '169', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Account_Category__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '86', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Type__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '88', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Class__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '89', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Status__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            if (leadRecord.Secondary_Partner_Type_Optional__c != null) {
                w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '87', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Secondary_Partner_Type_Optional__c, START_TAG, NAMESPACE_URL);
                w.writeEndElement(); //end AccountUDAInfo
            }
            w.writeEndElement(); //end UDAInformation
        }
        //3.3
        else {
            if (strterritoryGroupId != null && 
                ((strterritoryGroupName != null && strterritoryGroupName.containsIgnoreCase('oem')) || (strRegionDesc != null && strRegionDesc.containsIgnoreCase('oem')))) {
                    w = IntegrationUtilities.startElement(w, 'UDAInformation', START_TAG, NAMESPACE_URL);
                    
                    w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL); 
                    w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '200', START_TAG, NAMESPACE_URL);
                    w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', 'OEM', START_TAG, NAMESPACE_URL);
                    w.writeEndElement();
                    
                    w.writeEndElement(); //end UDAInformation
                }
        }  
        w.writeEndElement(); // end cilRequest
        w.writeEndElement(); // end createAccount
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    
    //Build xml request body - To activate account 
    public static String createActivateAccountHTTPRequestBodyString(Account accountRecord) {
        currentUser = StaticFactory.getCurrentUserDetails();
        String strtoDateIn = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        string strlegacyId = 'SFDC_' + accountRecord.id;
        User accountOwner = StaticFactory.getUserDetails(accountRecord.ownerid);
        Country__c accountCountry = [Select name, code__c, region__c from country__c where code__c = : accountRecord.Account_Country_Code__c limit 1];
        string strregion = mapregion.get(accountCountry.region__c);
        strregionName = accountCountry.region__c;
        strcountryName = accountCountry.name;
        
        XmlStreamWriter w = new XmlStreamWriter();
        w=AccountSuggestionIntegrationCIL.updatestatus(w);
        /*w.writeStartElement('soapenv', 'Envelope', START_URL);
w.writeNamespace('soapenv', START_URL);
w.writeNamespace('cil', 'CIL');
w.writeNamespace(START_TAG, ENV_URL);

//Header
w.writeEmptyElement('soapenv', 'Header', START_URL);

//Body
w.writeStartElement('soapenv', 'Body', START_URL);
w.writeStartElement('cil', 'UpdateAccount', NAMESPACE_URL);
w.writeStartElement('cil', 'request', NAMESPACE_URL);*/
        
        w = IntegrationUtilities.startElement(w, 'BasicInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountCategory', 'EndUser', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountId', accountRecord.Account_ID__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountName', accountRecord.name, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'Account', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'CFIProjectNumber', '', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', accountCountry.code__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'Yes', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate', strtoDateIn, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'HierarchyType', 'SALES', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'LegacyID', strlegacyId, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SalesModelCode', '', START_TAG, NAMESPACE_URL);
        w.writeEndElement(); //end BasicInformation
        w = IntegrationUtilities.startElement(w, 'SuggestionInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', accountOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule', 'SFDC_LM', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveTypeId', '1', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Region', strregion, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'RelatedSuggestionIds', '0', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments', '', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason', 'TypoCorrection', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus', 'Pending', START_TAG, NAMESPACE_URL);
        w.writeEndElement(); //end SuggestionInformation
        
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionUpdateAction', 'Activate', START_TAG, NAMESPACE_URL);
        
        w.writeEndElement(); // end cilRequest
        w.writeEndElement(); // end updateAccount
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    
    /***************** Update Account *****************************/
    //Send request to affinity to update a new account.
    public static AccountSuggestionResponse sendAccountSuggestionToUpdateAccount(Lead leadRecord) {
        AccountSuggestionResponse response = new AccountSuggestionResponse();
        string strinitialResponse;
        if (leadRecord != null) {
            //create request body from the Account record
            String strrequestBody = UpdateAccountsuggestionHTTPRequestBodyString(leadRecord);
            strinitialResponse = sendHttpRequest(strrequestBody, 'UpdateAccount');
            response = AccountSuggestionResponse.parseResponseString(strinitialResponse);
        }
        return response;
    }
    //Build xml request body - To Update account
    public static String updateAccountsuggestionHTTPRequestBodyString(Lead leadRecord) {
        currentUser = [SELECT Id, Badge_Number__c, FirstName, LastName, Email FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1][0];
        String strtoDateIn = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        string strlegacyId = 'SFDC_' + leadRecord.id;
        
        XmlStreamWriter w = new XmlStreamWriter();
        w=AccountSuggestionIntegrationCIL.updatestatus(w);
        /*w.writeStartElement('soapenv', 'Envelope', START_URL);
w.writeNamespace('soapenv', START_URL);
w.writeNamespace('cil', 'CIL');
w.writeNamespace(START_TAG, ENV_URL);

//Header
w.writeEmptyElement('soapenv', 'Header', START_URL);

//Body
w.writeStartElement('soapenv', 'Body', START_URL);
w.writeStartElement('cil', 'UpdateAccount', NAMESPACE_URL);
w.writeStartElement('cil', 'request', NAMESPACE_URL);*/
        
        /*------------------------------------------- AddressInformation -----------------------------------------------*/
        //checking if Physical/postal address is populated
        bisPostalAddressSameAsPhysical = addressCheck(leadRecord);
        
        //if any of the address details present
        if (bisHavingPhysiscalAdd || bisHavingPostalAddress) {
            w = IntegrationUtilities.startElement(w, 'AddressInformation', START_TAG, NAMESPACE_URL);
            if (bisHavingPhysiscalAdd) {
                w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Physical_Address_1__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Physical_Address_2__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Sales', START_TAG, NAMESPACE_URL);//as per Story 3681954 
                w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Physical_City__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Physical_Company_Name__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Physical_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'Country', leadRecord, 'Physical_County__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Physical_Fax__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Physical_Phone__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Physical_PostalCode__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Physical_State__c', START_TAG, NAMESPACE_URL);
                w.writeEndElement(); //end AccountAddressInfo
            }
            //  if (bisHavingPostalAddress && !bisPostalAddressSameAsPhysical) {// commented as per Story 3681954:Modifications in Web-service to Affinity - Update Account
            if (bisHavingPostalAddress ) {
                w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', leadRecord, 'Postal_Address_1__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'AddressLine2', leadRecord, 'Postal_Address_2__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Legal', START_TAG, NAMESPACE_URL);//as per Story 3676977 
                w = IntegrationUtilities.addElementAndValue(w, 'City', leadRecord, 'Postal_City__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', leadRecord, 'Postal_Company_Name__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', leadRecord.Postal_Country__r.Code__c, START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Postal_County__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'County', leadRecord, 'Postal_Fax__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', leadRecord, 'Postal_PostalCode__c', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValue(w, 'State', leadRecord, 'Postal_State__c', START_TAG, NAMESPACE_URL);
                w.writeEndElement(); //end AccountAddressInfo
            }
            w.writeEndElement(); //end AddressInformation 
        }
        /*------------------------------------------- BasicInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'BasicInformation', START_TAG, NAMESPACE_URL);
        if(leadRecord.Account_Category__c == 'Partner'){
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountCategory', 'Partner', START_TAG, NAMESPACE_URL);
        }
        else{  
            w = IntegrationUtilities.addElementAndValueString(w, 'AccountCategory', 'EndUser', START_TAG, NAMESPACE_URL);
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountId', leadRecord.Account__r.Account_ID__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'AccountName', leadRecord, 'Company', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'CFIProjectNumber', leadRecord, 'CFI_Project_Numbers__c', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'CompanyFoundedDate', convertDateTimeToString(leadRecord.Date_Founded__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Currency', leadRecord.Organization_Country__r.User_Currency_Iso_Code__c, START_TAG, NAMESPACE_URL);
        if (leadRecord.DMU_Flag__c)
            w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'Yes', START_TAG, NAMESPACE_URL);
        else
            w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'No', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate', strtoDateIn, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'FinGeo', leadRecord, 'FIN_GEO__c', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'FiscalYearEnd', convertDateTimeToString(leadRecord.Fiscal_Year_End__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'FuctionalCategoryCode', mapFunctionCategoryCode.get(leadRecord.Function_Category_Code__c), START_TAG, NAMESPACE_URL);
        if (leadRecord.NDA_Flag__c){
            w = IntegrationUtilities.addElementAndValueString(w, 'GCPFlag', 'Yes', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'GCPFlag', 'No', START_TAG, NAMESPACE_URL);
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'HierarchyType', 'SALES', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'LegacyID', strlegacyId, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'LocalAccountName', leadRecord, 'CompanyLocal', START_TAG, NAMESPACE_URL);
        if (leadRecord.Location_Number__c != null){
            w = IntegrationUtilities.addElementAndValue(w, 'LocationNumber', leadRecord, 'Location_Number__c', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'LocationNumber', '0', START_TAG, NAMESPACE_URL);
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'MarkettingClassCode', mapMarketingClassCode.get(leadRecord.Marketing_Class_Code__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'NDAAgreemenet', booleanUtils.toStringYesNo(leadRecord.NDA_Flag__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'NDAExpiryDate', convertDateTimeToString(leadRecord.NDA_Expiry_Date__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'NationalID', leadRecord.National_ID__c, START_TAG, NAMESPACE_URL);
        if (leadRecord.NumberOfEmployees != null){
            w = IntegrationUtilities.addElementAndValue(w, 'NoOfEmployee', leadRecord, 'NumberOfEmployees', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'NoOfEmployee', '0', START_TAG, NAMESPACE_URL);
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'PremierPageUrl', leadRecord.Premier_Page_URL__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'ProgramType', leadRecord.Program_Type__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SICCode', '0', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'STDQuoteNumbers', leadRecord.Std_Quote_Numbers__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SalesModelCode', mapSalesModelCode.get(leadRecord.Sales_Model_Code__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SubMarketCode', mapSubMarketCode.get(leadRecord.Sub_Market_Code__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'WebSiteUrl', leadRecord.Website, START_TAG, NAMESPACE_URL);
        
        w.writeEndElement(); //end BasicInformation
        /*------------------------------------------- SuggestionInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'SuggestionInformation', START_TAG, NAMESPACE_URL);
        w= IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber',currentUser.Badge_Number__c, START_TAG, NAMESPACE_URL); 
        w = IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule', 'SFDC', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Region', mapregion.get(leadRecord.Organization_Country__r.Region__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments', leadRecord.Questions_Comments__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason', mapsuggestionReason.get(leadRecord.Suggestion_Reason__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus', 'Approved', START_TAG, NAMESPACE_URL);
        w.writeEndElement(); //end SuggestionInformation
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionUpdateAction', 'Update', START_TAG, NAMESPACE_URL);
        /*------------------------------------------- UDA-----------------------------------------------*/
        // if(bisOnBoarding){
        w = IntegrationUtilities.startElement(w, 'UDAInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '169', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Account_Category__c, START_TAG, NAMESPACE_URL);
        w.writeEndElement(); //end AccountUDAInfo
        if(leadRecord.Account_Category__c == 'Partner'){
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '86', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Type__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '88', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Class__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '89', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Partner_Status__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
        }
        if (leadRecord.Secondary_Partner_Type_Optional__c != null) {
            w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '87', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', leadRecord.Secondary_Partner_Type_Optional__c, START_TAG, NAMESPACE_URL);
            w.writeEndElement(); //end AccountUDAInfo
        }
        w.writeEndElement(); //end UDAInformation
        // }
        w.writeEndElement(); // end cilRequest
        w.writeEndElement(); // end createAccount
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    
    // 3.2 
    public static AccountSuggestionResponse sendSubAccountSuggestion(Lead objLeadRecord, Boolean bIsDupCheckRequired, string strParentId) {
        AccountSuggestionResponse response = new AccountSuggestionResponse();
        string strInitialResponse;
        if (objLeadRecord != null) {
            //create request body from the Account record
            String strRequestBody = createSubAccountsuggestionHTTPRequestBodyString(objLeadRecord, bIsDupCheckRequired, strParentId);
            strInitialResponse = sendHttpRequest(strRequestBody, 'CreateAccount');
            response = AccountSuggestionResponse.parseResponseString(strInitialResponse);
        }
        return response;
    }
    
    // 3.2  
    //Build xml request body - To create Sub account
    public static String createSubAccountsuggestionHTTPRequestBodyString(Lead objLeadRecord, Boolean bIsDupCheckRequired, string strParentId) {
        currentUser = [SELECT Id, Badge_Number__c, FirstName, LastName, Email FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1][0];
        String strToDateInString = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss');
        User objLeadOwner;
        string strLegacyId = 'SFDC_' + objLeadRecord.id;
        
        Country__c objLeadCountry;
        //v6.0 - start
        if (objLeadRecord.Physical_Country__c != null && objLeadRecord.Legal_Local_Country__c == null){
            objLeadCountry = [Select name, code__c, region__c from country__c where id = : objLeadRecord.Physical_Country__c limit 1];
        }
        if (objLeadRecord.Physical_Country__c == null && objLeadRecord.Legal_Local_Country__c != null){
            objLeadCountry = [Select name, code__c, region__c from country__c where id = : objLeadRecord.Legal_Local_Country__c limit 1];
        }
        if (objLeadRecord.Physical_Country__c != null && objLeadRecord.Legal_Local_Country__c != null){
            objLeadCountry = [Select name, code__c, region__c from country__c where id = : objLeadRecord.Physical_Country__c limit 1];
        }
            //v6.0 - end
        
        XmlStreamWriter w = new XmlStreamWriter();
        w=AccountSuggestionIntegrationCIL.updatestatus2(w);
        /*w.writeStartElement('soapenv', 'Envelope', START_URL);
w.writeNamespace('soapenv', START_URL);
w.writeNamespace('cil', 'CIL');
w.writeNamespace(START_TAG, ENV_URL);

//Header
w.writeEmptyElement('soapenv', 'Header', START_URL);
//Body
w.writeStartElement('soapenv', 'Body', START_URL);
w.writeStartElement('cil', 'CreateAccount', NAMESPACE_URL);
w.writeStartElement('cil', 'request', NAMESPACE_URL);*/
        /*------------------------------------------- AddressInformation -----------------------------------------------*/
        
        objLeadOwner = StaticFactory.getUserDetails(objLeadRecord.ownerid);
        
        if (objLeadRecord.city != null || objLeadRecord.Street != null || objLeadRecord.Country != null || objLeadRecord.State != null) {
            w = IntegrationUtilities.startElement(w, 'AddressInformation', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.startElement(w, 'AccountAddressInfo', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'AddressLine1', objLeadRecord, 'Street', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'AddressType', 'Legal', START_TAG, NAMESPACE_URL);//Story 3645255 - 4.3
            w = IntegrationUtilities.addElementAndValue(w, 'City', objLeadRecord, 'City', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'CompanyName', objLeadRecord, 'Company', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', objLeadCountry.code__c, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'County', objLeadRecord, 'Country', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'PostalCode', objLeadRecord, 'PostalCode', START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValue(w, 'State', objLeadRecord, 'State', START_TAG, NAMESPACE_URL);
            w.writeEndElement();
            w.writeEndElement(); //end AddressInformation 
        }
        
        /*------------------------------------------- BasicInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'BasicInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValue(w, 'AccountName', objLeadRecord, 'Company', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountStatus', 'Active', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'SubAccount', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'ChannelCompEligibleFlg', 'No', START_TAG, NAMESPACE_URL);//v4.5
        
        w = IntegrationUtilities.addElementAndValueString(w, 'CountryCode', objLeadCountry.code__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'DmuFlag', 'Yes', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'LegacyID', strLegacyId, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'ParentAccountID', strParentId, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'RTM', 'DIRECT', START_TAG, NAMESPACE_URL);//v4.5
        
        w.writeEndElement(); //end BasicInformation
        /*------------------------------------------- Duplicate Check -----------------------------------------------*/
        if (bIsDupCheckRequired){
            w = IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation', 'Yes', START_TAG, NAMESPACE_URL);
        }
        else{
            w = IntegrationUtilities.addElementAndValueString(w, 'RequireMatchedAccountInformation', 'No', START_TAG, NAMESPACE_URL);
        }
            /*------------------------------------------- SalesRepInformation -----------------------------------------------*/
        
        w = IntegrationUtilities.startElement(w, 'SalesRepInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.startElement(w, 'AccountSalesRepInfo', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Add', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentType', 'Direct', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', objLeadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
        
        //3.1
        w = IntegrationUtilities.addElementAndValueString(w, 'OwnerForAccount', 'Yes', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'PrimaryAssignee', 'Yes', START_TAG, NAMESPACE_URL);
        //8.0 Leave this as blank -- w = IntegrationUtilities.addElementAndValueString(w, 'ResourceRoleEndDate', '9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'ResourceRoleStartDate', strToDateInString, START_TAG, NAMESPACE_URL);
        
        w.writeEndElement(); //end AccountSalesRepInfo
        w.writeEndElement(); //end SalesRepInformation
        
        /*------------------------------------------- SuggestionInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'SuggestionInformation', START_TAG, NAMESPACE_URL);
        String strRegion = mapregion.get(objLeadRecord.Organization_Country__r.Region__c);
        w = IntegrationUtilities.addElementAndValueString(w, 'AccountType', 'Account', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'BadgeNumber', objLeadOwner.Badge_Number__c, START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'CreatedByModule', 'SFDC_LM', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveDate', strToDateInString, START_TAG, NAMESPACE_URL);//4.5
        w = IntegrationUtilities.addElementAndValueString(w, 'EffectiveTypeId', '1', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'Region', mapregion.get(objLeadCountry.region__c), START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionComments', '', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionReason', 'Generic', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'SuggestionStatus', 'Approved', START_TAG, NAMESPACE_URL);
        
        
        w.writeEndElement(); //end SuggestionInformation
        /*------------------------------------------- TerritoryInformation -----------------------------------------------*/
        w = IntegrationUtilities.startElement(w, 'TerritoryInformation', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.startElement(w, 'AccountTerritoryInfo', START_TAG, NAMESPACE_URL);
        String strTerritoryGroupId;
        String strTerritoryGroupName;
        //3.3
        string strRegionDesc;
        
        if (objLeadRecord.Territory_Assignment__r.Group_ID__c == null) {
            Sales_Channel_Group__c objSalesChannel = [select name, Group_ID__c, Region_Desc__c from Sales_Channel_Group__c where id = : objLeadRecord.Territory_Assignment__c];
            strTerritoryGroupId = objSalesChannel.Group_ID__c;
            strTerritoryGroupName = objSalesChannel.Name;
            //3.3
            strRegionDesc = objSalesChannel.Region_Desc__c;
        } else {
            strTerritoryGroupId = objLeadRecord.Territory_Assignment__r.Group_ID__c;
            strTerritoryGroupName = objLeadRecord.Territory_Assignment__r.Name;
            //3.3
            strRegionDesc = objLeadRecord.Territory_Assignment__r.Region_Desc__c;
        }
        w = IntegrationUtilities.addElementAndValueString(w, 'Action', 'Assign', START_TAG, NAMESPACE_URL);
        //8.0 Leave this as blank -- w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentEndDate', '9999-07-21T13:38:00', START_TAG, NAMESPACE_URL);
        w = IntegrationUtilities.addElementAndValueString(w, 'AssignmentStartDate', strToDateInString, START_TAG, NAMESPACE_URL);
        if (strTerritoryGroupId != null && strTerritoryGroupName != null) {
            w = IntegrationUtilities.addElementAndValueString(w, 'GroupID', strTerritoryGroupId, START_TAG, NAMESPACE_URL);
            w = IntegrationUtilities.addElementAndValueString(w, 'GroupName', strTerritoryGroupName, START_TAG, NAMESPACE_URL);
        }
        w.writeEndElement(); //end AccountTerritoryInfo
        w.writeEndElement(); //end TerritoryInformation
        /*------------------------------------------- UDA-----------------------------------------------*/
        //3.3
        if (strTerritoryGroupId != null && 
            ((strTerritoryGroupName != null && strTerritoryGroupName.containsIgnoreCase('oem')) || (strRegionDesc != null && strRegionDesc.containsIgnoreCase('oem')))) {
                w = IntegrationUtilities.startElement(w, 'UDAInformation', START_TAG, NAMESPACE_URL);
                
                w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL); 
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '200', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', 'OEM', START_TAG, NAMESPACE_URL);
                w.writeEndElement();
                
                w = IntegrationUtilities.startElement(w, 'AccountUDAInfo', START_TAG, NAMESPACE_URL); 
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAID', '201', START_TAG, NAMESPACE_URL);
                w = IntegrationUtilities.addElementAndValueString(w, 'UDAValue', 'Yes', START_TAG, NAMESPACE_URL);
                w.writeEndElement();
                
                w.writeEndElement(); //end UDAInformation
            }
        w.writeEndElement(); // end cilRequest
        w.writeEndElement(); // end createAccount
        w.writeEndElement(); //end Body
        w.writeEndElement(); //end envelope
        String strxmlOutput = w.getXmlString();
        w.close();
        return strxmlOutput;
    }
    
    Public static XmlStreamWriter updatestatus(XmlStreamWriter  w){
        w=new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', START_URL);
        w.writeNamespace('soapenv', START_URL);
        w.writeNamespace('cil', 'CIL');
        w.writeNamespace(START_TAG, ENV_URL);
        
        //Header
        w.writeEmptyElement('soapenv', 'Header', START_URL);
        
        //Body
        w.writeStartElement('soapenv', 'Body', START_URL);
        w.writeStartElement('cil', 'UpdateAccount', NAMESPACE_URL);
        w.writeStartElement('cil', 'request', NAMESPACE_URL);
        return w;
    }
    Public static XmlStreamWriter updatestatus2(XmlStreamWriter  w){
        w=new XmlStreamWriter();
        w.writeStartElement('soapenv', 'Envelope', START_URL);
        w.writeNamespace('soapenv', START_URL);
        w.writeNamespace('cil', 'CIL');
        w.writeNamespace(START_TAG, ENV_URL);
        
        //Header
        w.writeEmptyElement('soapenv', 'Header', START_URL);
        //Body
        w.writeStartElement('soapenv', 'Body', START_URL);
        w.writeStartElement('cil', 'CreateAccount', NAMESPACE_URL);
        w.writeStartElement('cil', 'request', NAMESPACE_URL);
        return w;
    }
    
}