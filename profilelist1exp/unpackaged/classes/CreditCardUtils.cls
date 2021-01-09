/***********************************************************
* Revision   Name        Date           Description
* 1.0        Nooryati    06-03-2011     CR 5886 Validate a string of credit card number from being keyed into Notes body text field.    
*                                       This class is to check whether a string of digits is a valid credit card number according to the Luhn algorithm.
  2.0        Devika      09-01-2015     Regex update for Credit card validation. 
     
************************************************************/

public class CreditCardUtils {  
    
    public static boolean getCreditCardValidation(String bodyNotes) {

        //Instantiate a new Pattern object 'ccPattern' 
        Pattern ccPattern = Pattern.compile('[\\ -]*(?:(4[\\ -]*(?:\\d[\\ -]*){11}(?:(?:\\d[\\ -]*){3})?\\d)|(5[\\ -]*[1-5](?:[\\ -]*[0-9]){14})|(6[\\ -]*(?:0[\\ -]*1[\\ -]*1|5[\\ -]*\\d[\\ -]*\\d)(?:[\\ -]*[0-9]){12})|(3[\\ -]*[47](?:[\\ -]*[0-9]){13})|(3[\\ -]*(?:0[\\ -]*[0-5]|[68][\\ -]*[0-9])(?:[\\ -]*[0-9]){11})|((?:2[\\ -]*1[\\ -]*3[\\ -]*1|1[\\ -]*8[\\ -]*0[\\ -]*0|(3[\\ -]*5|3[\\ -]*0)(?:[\\ -]*[0-9]){3})(?:[\\ -]*[0-9]){11}))[\\ -]*');                            

        System.debug('###DEBUG ### n.Body Input = ' + bodyNotes);               
        
        //Instantiate a new Matcher object 'ccMatcher'
        Matcher ccMatcher = ccPattern.matcher(bodyNotes);
        System.debug('###DEBUG ### ccMatcher = ' + ccMatcher);                                                  
        
        // Loop through and passing the CC number to 'isValidCreditNum' class to perform Luhn Algorithm
        while(ccMatcher.find()) {
            
            string ccNo = ccMatcher.group(0);
            System.debug('###DEBUG ccNo### - ' + ccNo); 
            
            if (ccNo != null) {                 
                boolean isValidCC = CreditCardUtils.isValidCreditNum(ccNo);
                if (isValidCC) {                                    
                    return true;
                }   
            }                                                   
        }
        return false;   
    }
     
     /** v2.0 Maintainance Starts***/        
     public static boolean getCreditCardValid(String bodyNotes) {

        //Pattern ccPattern = Pattern.compile('((\\b4\\d{12}\\b)|(\\b(36|38)\\d{12}\\b)|(\\b30([0-5]\\d{11})\\b)|(\\b3[47]\\d{13}\\b)|(\\b(2014|2149)\\d{11}\\b)|(\\b(6011|2131|1800)\\d{12}\\b)|(\\b5[1-5]\\d{14}\\b)|(\\b(3|4)\\d{15}\\b)|(\\b4\\d{3}([^a-zA-Z\\d]\\d{4}){2}[^a-zA-Z\\d]\\d\\b)|(\\b((38|36)\\d{2}|30[0-5]\\d)([^A-Za-z\\d]\\d{4}){2}[^A-Za-z\\d]\\d{2}\\b)|(\\b(36\\d{2}|30[0-5]\\d)[^A-Za-z\\d]\\d{6}[^A-Za-z\\d]\\d{4})|(\\b(3[47]\\d{2}|(2014|2149))([^a-zA-Z\\d]\\d{4}){2}[^a-zA-Z\\d]\\d{3}\\b)|(\\b(6011|2131|1800|(5[1-5]\\d{2})|((3|4)\\d{3}))([^a-zA-Z\\d]\\d{4}){3}\\b))?');
        Pattern ccPattern = Pattern.compile('((\\b4\\d{12}\\b)|(\\b(36|38)\\d{12}\\b)|(\\b30([0-5]\\d{11})\\b)|(\\b3[47]\\d{13}\\b)|(\\b(2014|2149)\\d{11}\\b)|(\\b(6011|2131|1800)\\d{12}\\b)|(\\b5[1-5]\\d{14}\\b)|(\\b(3|4)\\d{15}\\b)|(\\b4\\d{3}([^a-zA-Z\\d]\\d{4}){2}[^a-zA-Z\\d]\\d\\b)|(\\b((38|36)\\d{2}|30[0-5]\\d)([^A-Za-z\\d]\\d{4}){2}[^A-Za-z\\d]\\d{2}\\b)|(\\b(36\\d{2}|30[0-5]\\d)[^A-Za-z\\d]\\d{6}[^A-Za-z\\d]\\d{4})|(\\b(3[47]\\d{2}|(2014|2149))((([^a-zA-Z\\d]\\d{4}){2}[^a-zA-Z\\d]\\d{3})|([^a-zA-Z\\d]\\d{6})[^a-zA-Z\\d]\\d{5})\\b)|(\\b(6011|2131|1800|(5[1-5]\\d{2})|((3|4)\\d{3}))([^a-zA-Z\\d]\\d{4}){3}\\b))?');
        
        System.debug('###DEBUG ### n.Body Input = ' + bodyNotes);               
        
        Matcher ccMatcher = ccPattern.matcher(bodyNotes);
        System.debug('###DEBUG ### ccMatcher = ' + ccMatcher);                                                  
        
        while(ccMatcher.find()) {
            
            string ccNo = ccMatcher.group(0);
            System.debug('###DEBUG ccNo### - ' + ccNo); 
            
            if (ccNo != null && ccNo != '') {                 
                boolean isValidCC = CreditCardUtils.isValidCreditNum(ccNo);
                if (isValidCC) {                                    
                    return true;
                }   
            }                                                   
        }
        return false;   
    }
    /** v2.0 Maintainance Ends***/       
    
    public static boolean isValidCreditNum(String CCnum) {
    long sum = 0;
    System.debug('###DEBUG CCnum### - ' + CCnum);          
    boolean alternate = false; 
    string CCnumExtract = CCnum.replaceAll('[^0-9０-９]',''); 
    System.debug('###DEBUG CCnumExtract### - ' + CCnumExtract);             
        
        for (integer i = CCnumExtract.length() - 1; i >= 0; i--) {
            System.debug('###DEBUG CCnum.length()### - ' + CCnumExtract.length());         
            integer num = integer.valueOf(CCnumExtract.substring(i, i + 1));
            if (alternate) {
                num *= 2;
                if (num > 9) {
                    num = (math.mod(num, 10)) + 1;
                }
            }
            sum += num;
            alternate = !alternate;
        } 
        return (math.mod( sum, 10) == 0);
    } 
}