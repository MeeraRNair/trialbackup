/*
History:
    0.0 - 21-Feb-2010: Richard	:Creatioed as per CR 2406, R 11.1
    1.0 - 02-Jun-2010: Krishna	:Updated the DELL_PRODUCTION_ORG_ID value to 18 char Id(CR 2770, R11.5)
    							 Made related change in isProduction. Updated the EnvironmentTest class    							 
    
*/


global class Environment {

    global static final String DELL_PRODUCTION_ORG_ID = '00D1b000000Dh0WEAA';
    													    
    global static Boolean isProduction(){    	
        return DELL_PRODUCTION_ORG_ID.equals(UserInfo.getOrganizationId());
    }

    global static Boolean isSandbox(){
        return !isProduction(); 
    }
    
    global static String getShortOrgId(){
        return StringUtils.substring(UserInfo.getOrganizationId(),0,15);
    }     
}