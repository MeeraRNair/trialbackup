public class AposConstants {

	//===========================================================================
	// APOS ERROR CODE
	//===========================================================================
	public static final String ERROR_CONTACT_CREATION 					  	= '101001';
	public static final String ERROR_CONTACT_UPDATE   					  	= '101002';
	public static final String ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME		= '101003';
	public static final String ERROR_OPPTY_CREATION   				      	= '102001';
	public static final String ERROR_SERVICETAG_CONTRACTS_CREATION  	  	= '103001';
	public static final String ERROR_CONTACT_ROLE_CREATION				  	= '104001';
	public static final String ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID	  	= '104002';
	public static final String ERROR_APOS_INSIDE_REP_NOT_EXIST			  	= '105001';
	
	public static final String ERROR_CONTACT_CREATION_DESC 				  	= 'Unable to create contact';
	public static final String ERROR_CONTACT_UPDATE_DESC   				  	= 'Unable to update contact';
	public static final String ERROR_CONTACT_UPDATE_NO_FIRSTLAST_NAME_DESC	= 'Unable to update contact due to firstname or lastname not found';
	public static final String ERROR_OPPTY_CREATION_DESC   				  	= 'Unable to create opportunity';
	public static final String ERROR_SERVICETAG_CONTRACTS_CREATION_DESC   	= 'Unable to create Service tag contract';
	public static final String ERROR_CONTACT_ROLE_CREATION_DESC			  	= 'Unable to create contact role';
	public static final String ERROR_CONTACT_ROLE_NO_OPPTY_CONTACT_ID_DESC	= 'Unable to create contact role due to no opportunity or contact id found';
	public static final String ERROR_APOS_INSIDE_REP_NOT_EXIST_DESC		  	= 'Apos Inside Sales Rep Not Exist';
	public static final String ERROR_CONTACT_CREATION_NO_EMAIL_PHONE_DESC 	= 'Unable to create contact due to email or phone empty';
}