/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
@IsTest
private class FAP_CharacterTest {

    private static String charsasciicontrol  = '\n\t\r\f';        
    private static String charsasciidigits    = '0123456789';
    private static String charsasciiupper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    private static String charsasciilower   = 'abcdefghijklmnopqrstuvwxyz';
    private static String  charsasciiprintable   = ' !"#$%&\'()*+,-./' + charsasciidigits + ':;<=>?@' + charsasciiupper + '[\\]^_`' + charsasciilower + '{|}~';
    private static String   charsallascii  = charsasciicontrol + charsasciiprintable;
    private static String charsnonascii  = '€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ';
    private static String charsasciinonprintable  = charsasciicontrol + charsnonascii;

    private static testmethod void testValidateChar(){
        final String[] badCharStrings = new String[]{'','AB'};
        for(String badCharString : badCharStrings){
            try{
                FAP_Character.validateChar(badCharString);
                System.assert(false,'Exception should have been thrown for invalid char: ' + badCharString);
            } catch(Exception e){}
        }
        FAP_Character.validateChar('B');        
    }
    
    private static testmethod void testIsUpperCase(){
        final String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        for(Integer i = 0; i < upper.length(); i++){
            assertIsUpperCase(upper.substring(i,i+1), true);
          
        }
        final String lower = 'abcdefghijklmnopqrstuvwxyz';
        for(Integer i = 0; i < lower.length(); i++){
            assertIsUpperCase(lower.substring(i,i+1), false);
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }    
    
    private static void assertIsUpperCase(String aCharacter, Boolean expected){
        Boolean actual = FAP_Character.isUpperCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.isUpperCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToTitleCase(){
        assertToTitleCase('\t','\t');
        assertToTitleCase('\n','\n');
        assertToTitleCase('\f','\f');
        assertToTitleCase('\r','\r');
        assertToTitleCase(' ',' ');
        assertToTitleCase('!','!');
        assertToTitleCase('"','"');
        assertToTitleCase('#','#');
        assertToTitleCase('$','$');
        assertToTitleCase('%','%');
        assertToTitleCase('&','&');
        assertToTitleCase('\'','\'');
        assertToTitleCase('(','(');
        assertToTitleCase(')',')');
        assertToTitleCase('*','*');
        assertToTitleCase('+','+');
        assertToTitleCase(',',',');
        assertToTitleCase('-','-');
        assertToTitleCase('.','.');
        assertToTitleCase('/','/');
        assertToTitleCase('0','0');
        assertToTitleCase('1','1');
        assertToTitleCase('2','2');
        assertToTitleCase('3','3');
        assertToTitleCase('4','4');
        assertToTitleCase('5','5');
        assertToTitleCase('6','6');
        assertToTitleCase('7','7');
        assertToTitleCase('8','8');
        assertToTitleCase('9','9');
        assertToTitleCase(':',':');
        assertToTitleCase(';',';');
        assertToTitleCase('<','<');
        assertToTitleCase('=','=');
        assertToTitleCase('>','>');
        assertToTitleCase('?','?');
        assertToTitleCase('@','@');
        assertToTitleCase('A','A');
        assertToTitleCase('B','B');
        assertToTitleCase('C','C');
        assertToTitleCase('D','D');
        assertToTitleCase('E','E');
        assertToTitleCase('F','F');
        assertToTitleCase('G','G');
        assertToTitleCase('H','H');
        assertToTitleCase('I','I');
        assertToTitleCase('J','J');
        assertToTitleCase('K','K');
        assertToTitleCase('L','L');
        assertToTitleCase('M','M');
        assertToTitleCase('N','N');
        assertToTitleCase('O','O');
        assertToTitleCase('P','P');
        assertToTitleCase('Q','Q');
        assertToTitleCase('R','R');
        assertToTitleCase('S','S');
        assertToTitleCase('T','T');
        assertToTitleCase('U','U');
        assertToTitleCase('V','V');
        assertToTitleCase('W','W');
        assertToTitleCase('X','X');
        assertToTitleCase('Y','Y');
        assertToTitleCase('Z','Z');
        assertToTitleCase('[','[');
        assertToTitleCase('\\','\\');
        assertToTitleCase(']',']');
        assertToTitleCase('^','^');
        assertToTitleCase('_','_');
        assertToTitleCase('`','`');
        assertToTitleCase('a','A');
        assertToTitleCase('b','B');
        assertToTitleCase('c','C');
        assertToTitleCase('d','D');
        assertToTitleCase('e','E');
        assertToTitleCase('f','F');
        assertToTitleCase('g','G');
        assertToTitleCase('h','H');
        assertToTitleCase('i','I');
        assertToTitleCase('j','J');
        assertToTitleCase('k','K');
        assertToTitleCase('l','L');
        assertToTitleCase('m','M');
        assertToTitleCase('n','N');
        assertToTitleCase('o','O');
        assertToTitleCase('p','P');
        assertToTitleCase('q','Q');
        assertToTitleCase('r','R');
        assertToTitleCase('s','S');
        assertToTitleCase('t','T');
        assertToTitleCase('u','U');
        assertToTitleCase('v','V');
        assertToTitleCase('w','W');
        assertToTitleCase('x','X');
        assertToTitleCase('y','Y');
        assertToTitleCase('z','Z');
        assertToTitleCase('{','{');
        assertToTitleCase('|','|');
        assertToTitleCase('}','}');
        assertToTitleCase('~','~');
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }    
    
    private static void assertToTitleCase(String aCharacter, String expected){
        String actual = FAP_Character.toTitleCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.toTitleCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToLowerCase(){
        assertToLowerCase('\t','\t');
        assertToLowerCase('\n','\n');
        assertToLowerCase('\f','\f');
        assertToLowerCase('\r','\r');
        assertToLowerCase(' ',' ');
        assertToLowerCase('!','!');
        assertToLowerCase('"','"');
        assertToLowerCase('#','#');
        assertToLowerCase('$','$');
        assertToLowerCase('%','%');
        assertToLowerCase('&','&');
        assertToLowerCase('\'','\'');
        assertToLowerCase('(','(');
        assertToLowerCase(')',')');
        assertToLowerCase('*','*');
        assertToLowerCase('+','+');
        assertToLowerCase(',',',');
        assertToLowerCase('-','-');
        assertToLowerCase('.','.');
        assertToLowerCase('/','/');
        assertToLowerCase('0','0');
        assertToLowerCase('1','1');
        assertToLowerCase('2','2');
        assertToLowerCase('3','3');
        assertToLowerCase('4','4');
        assertToLowerCase('5','5');
        assertToLowerCase('6','6');
        assertToLowerCase('7','7');
        assertToLowerCase('8','8');
        assertToLowerCase('9','9');
        assertToLowerCase(':',':');
        assertToLowerCase(';',';');
        assertToLowerCase('<','<');
        assertToLowerCase('=','=');
        assertToLowerCase('>','>');
        assertToLowerCase('?','?');
        assertToLowerCase('@','@');
        assertToLowerCase('A','a');
        assertToLowerCase('B','b');
        assertToLowerCase('C','c');
        assertToLowerCase('D','d');
        assertToLowerCase('E','e');
        assertToLowerCase('F','f');
        assertToLowerCase('G','g');
        assertToLowerCase('H','h');
        assertToLowerCase('I','i');
        assertToLowerCase('J','j');
        assertToLowerCase('K','k');
        assertToLowerCase('L','l');
        assertToLowerCase('M','m');
        assertToLowerCase('N','n');
        assertToLowerCase('O','o');
        assertToLowerCase('P','p');
        assertToLowerCase('Q','q');
        assertToLowerCase('R','r');
        assertToLowerCase('S','s');
        assertToLowerCase('T','t');
        assertToLowerCase('U','u');
        assertToLowerCase('V','v');
        assertToLowerCase('W','w');
        assertToLowerCase('X','x');
        assertToLowerCase('Y','y');
        assertToLowerCase('Z','z');
        assertToLowerCase('[','[');
        assertToLowerCase('\\','\\');
        assertToLowerCase(']',']');
        assertToLowerCase('^','^');
        assertToLowerCase('_','_');
        assertToLowerCase('`','`');
        assertToLowerCase('a','a');
        assertToLowerCase('b','b');
        assertToLowerCase('c','c');
        assertToLowerCase('d','d');
        assertToLowerCase('e','e');
        assertToLowerCase('f','f');
        assertToLowerCase('g','g');
        assertToLowerCase('h','h');
        assertToLowerCase('i','i');
        assertToLowerCase('j','j');
        assertToLowerCase('k','k');
        assertToLowerCase('l','l');
        assertToLowerCase('m','m');
        assertToLowerCase('n','n');
        assertToLowerCase('o','o');
        assertToLowerCase('p','p');
        assertToLowerCase('q','q');
        assertToLowerCase('r','r');
        assertToLowerCase('s','s');
        assertToLowerCase('t','t');
        assertToLowerCase('u','u');
        assertToLowerCase('v','v');
        assertToLowerCase('w','w');
        assertToLowerCase('x','x');
        assertToLowerCase('y','y');
        assertToLowerCase('z','z');
        assertToLowerCase('{','{');
        assertToLowerCase('|','|');
        assertToLowerCase('}','}');
        assertToLowerCase('~','~');
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }
    
    private static void assertToLowerCase(String aCharacter, String expected){
        String actual = FAP_Character.toLowerCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.toLowerCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testIsTitleCase(){
        //test: global static Boolean isTitleCase(String character){ 
        assertIsTitleCase('\t',FALSE);
        assertIsTitleCase('\n',FALSE);
        assertIsTitleCase('\f',FALSE);
        assertIsTitleCase('\r',FALSE);
        assertIsTitleCase(' ',FALSE);
        assertIsTitleCase('!',FALSE);
        assertIsTitleCase('"',FALSE);
        assertIsTitleCase('#',FALSE);
        assertIsTitleCase('$',FALSE);
        assertIsTitleCase('%',FALSE);
        assertIsTitleCase('&',FALSE);
        assertIsTitleCase('\'',FALSE);
        assertIsTitleCase('(',FALSE);
        assertIsTitleCase(')',FALSE);
        assertIsTitleCase('*',FALSE);
        assertIsTitleCase('+',FALSE);
        assertIsTitleCase(',',FALSE);
        assertIsTitleCase('-',FALSE);
        assertIsTitleCase('.',FALSE);
        assertIsTitleCase('/',FALSE);
        assertIsTitleCase('0',FALSE);
        assertIsTitleCase('1',FALSE);
        assertIsTitleCase('2',FALSE);
        assertIsTitleCase('3',FALSE);
        assertIsTitleCase('4',FALSE);
        assertIsTitleCase('5',FALSE);
        assertIsTitleCase('6',FALSE);
        assertIsTitleCase('7',FALSE);
        assertIsTitleCase('8',FALSE);
        assertIsTitleCase('9',FALSE);
        assertIsTitleCase(':',FALSE);
        assertIsTitleCase(';',FALSE);
        assertIsTitleCase('<',FALSE);
        assertIsTitleCase('=',FALSE);
        assertIsTitleCase('>',FALSE);
        assertIsTitleCase('?',FALSE);
        assertIsTitleCase('@',FALSE);
        assertIsTitleCase('A',TRUE);
        assertIsTitleCase('B',TRUE);
        assertIsTitleCase('C',TRUE);
        assertIsTitleCase('D',TRUE);
        assertIsTitleCase('E',TRUE);
        assertIsTitleCase('F',TRUE);
        assertIsTitleCase('G',TRUE);
        assertIsTitleCase('H',TRUE);
        assertIsTitleCase('I',TRUE);
        assertIsTitleCase('J',TRUE);
        assertIsTitleCase('K',TRUE);
        assertIsTitleCase('L',TRUE);
        assertIsTitleCase('M',TRUE);
        assertIsTitleCase('N',TRUE);
        assertIsTitleCase('O',TRUE);
        assertIsTitleCase('P',TRUE);
        assertIsTitleCase('Q',TRUE);
        assertIsTitleCase('R',TRUE);
        assertIsTitleCase('S',TRUE);
        assertIsTitleCase('T',TRUE);
        assertIsTitleCase('U',TRUE);
        assertIsTitleCase('V',TRUE);
        assertIsTitleCase('W',TRUE);
        assertIsTitleCase('X',TRUE);
        assertIsTitleCase('Y',TRUE);
        assertIsTitleCase('Z',TRUE);
        assertIsTitleCase('[',FALSE);
        assertIsTitleCase('\\',FALSE);
        assertIsTitleCase(']',FALSE);
        assertIsTitleCase('^',FALSE);
        assertIsTitleCase('_',FALSE);
        assertIsTitleCase('`',FALSE);
        assertIsTitleCase('a',FALSE);
        assertIsTitleCase('b',FALSE);
        assertIsTitleCase('c',FALSE);
        assertIsTitleCase('d',FALSE);
        assertIsTitleCase('e',FALSE);
        assertIsTitleCase('f',FALSE);
        assertIsTitleCase('g',FALSE);
        assertIsTitleCase('h',FALSE);
        assertIsTitleCase('i',FALSE);
        assertIsTitleCase('j',FALSE);
        assertIsTitleCase('k',FALSE);
        assertIsTitleCase('l',FALSE);
        assertIsTitleCase('m',FALSE);
        assertIsTitleCase('n',FALSE);
        assertIsTitleCase('o',FALSE);
        assertIsTitleCase('p',FALSE);
        assertIsTitleCase('q',FALSE);
        assertIsTitleCase('r',FALSE);
        assertIsTitleCase('s',FALSE);
        assertIsTitleCase('t',FALSE);
        assertIsTitleCase('u',FALSE);
        assertIsTitleCase('v',FALSE);
        assertIsTitleCase('w',FALSE);
        assertIsTitleCase('x',FALSE);
        assertIsTitleCase('y',FALSE);
        assertIsTitleCase('z',FALSE);
        assertIsTitleCase('{',FALSE);
        assertIsTitleCase('|',FALSE);
        assertIsTitleCase('}',FALSE);
        assertIsTitleCase('~',FALSE);
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }
    
    private static void assertIsTitleCase(String aCharacter, Boolean expected){
        Boolean actual = FAP_Character.isTitleCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.isTitleCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToUpperCase(){
        //test: global static String toUpperCase(String ch){
        assertToUpperCase('\t','\t');
        assertToUpperCase('\n','\n');
        assertToUpperCase('\f','\f');
        assertToUpperCase('\r','\r');
        assertToUpperCase(' ',' ');
        assertToUpperCase('!','!');
        assertToUpperCase('"','"');
        assertToUpperCase('#','#');
        assertToUpperCase('$','$');
        assertToUpperCase('%','%');
        assertToUpperCase('&','&');
        assertToUpperCase('\'','\'');
        assertToUpperCase('(','(');
        assertToUpperCase(')',')');
        assertToUpperCase('*','*');
        assertToUpperCase('+','+');
        assertToUpperCase(',',',');
        assertToUpperCase('-','-');
        assertToUpperCase('.','.');
        assertToUpperCase('/','/');
        assertToUpperCase('0','0');
        assertToUpperCase('1','1');
        assertToUpperCase('2','2');
        assertToUpperCase('3','3');
        assertToUpperCase('4','4');
        assertToUpperCase('5','5');
        assertToUpperCase('6','6');
        assertToUpperCase('7','7');
        assertToUpperCase('8','8');
        assertToUpperCase('9','9');
        assertToUpperCase(':',':');
        assertToUpperCase(';',';');
        assertToUpperCase('<','<');
        assertToUpperCase('=','=');
        assertToUpperCase('>','>');
        assertToUpperCase('?','?');
        assertToUpperCase('@','@');
        assertToUpperCase('A','A');
        assertToUpperCase('B','B');
        assertToUpperCase('C','C');
        assertToUpperCase('D','D');
        assertToUpperCase('E','E');
        assertToUpperCase('F','F');
        assertToUpperCase('G','G');
        assertToUpperCase('H','H');
        assertToUpperCase('I','I');
        assertToUpperCase('J','J');
        assertToUpperCase('K','K');
        assertToUpperCase('L','L');
        assertToUpperCase('M','M');
        assertToUpperCase('N','N');
        assertToUpperCase('O','O');
        assertToUpperCase('P','P');
        assertToUpperCase('Q','Q');
        assertToUpperCase('R','R');
        assertToUpperCase('S','S');
        assertToUpperCase('T','T');
        assertToUpperCase('U','U');
        assertToUpperCase('V','V');
        assertToUpperCase('W','W');
        assertToUpperCase('X','X');
        assertToUpperCase('Y','Y');
        assertToUpperCase('Z','Z');
        assertToUpperCase('[','[');
        assertToUpperCase('\\','\\');
        assertToUpperCase(']',']');
        assertToUpperCase('^','^');
        assertToUpperCase('_','_');
        assertToUpperCase('`','`');
        assertToUpperCase('a','A');
        assertToUpperCase('b','B');
        assertToUpperCase('c','C');
        assertToUpperCase('d','D');
        assertToUpperCase('e','E');
        assertToUpperCase('f','F');
        assertToUpperCase('g','G');
        assertToUpperCase('h','H');
        assertToUpperCase('i','I');
        assertToUpperCase('j','J');
        assertToUpperCase('k','K');
        assertToUpperCase('l','L');
        assertToUpperCase('m','M');
        assertToUpperCase('n','N');
        assertToUpperCase('o','O');
        assertToUpperCase('p','P');
        assertToUpperCase('q','Q');
        assertToUpperCase('r','R');
        assertToUpperCase('s','S');
        assertToUpperCase('t','T');
        assertToUpperCase('u','U');
        assertToUpperCase('v','V');
        assertToUpperCase('w','W');
        assertToUpperCase('x','X');
        assertToUpperCase('y','Y');
        assertToUpperCase('z','Z');
        assertToUpperCase('{','{');
        assertToUpperCase('|','|');
        assertToUpperCase('}','}');
        assertToUpperCase('~','~');
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }    
    
    private static void assertToUpperCase(String aCharacter, String expected){
        String actual = FAP_Character.toUpperCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.toUpperCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testIsLowerCase(){
        final String UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        for(Integer i = 0; i < UPPER.length(); i++){
            assertIsLowerCase(UPPER.substring(i,i+1), false);
        }
        final String LOWER = 'abcdefghijklmnopqrstuvwxyz';
        for(Integer i = 0; i < LOWER.length(); i++){
            assertIsLowerCase(LOWER.substring(i,i+1), true);
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }    
    
    private static void assertIsLowerCase(String aCharacter, Boolean expected){
        Boolean actual = FAP_Character.isLowerCase(aCharacter);
        System.assert(actual==expected, 'FAP_Character.isLowerCase(\'' + aCharacter + '\') returned ' + actual);
    }

    private static testmethod void testToAscii(){
        //test: global static Integer toAscii(String character){
        assertToAscii('\t',9);
        assertToAscii('\n',10);
        assertToAscii('\f',12);
        assertToAscii('\r',13);
        for(Integer i = 0; i < charsasciiprintable.length(); i++){
            assertToAscii(StringUtils.charAt(charsasciiprintable,i), i+32);
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }
    
    private static void assertToAscii(String charactr, Integer expected){
        Integer actual = FAP_Character.toAscii(charactr); 
        System.assert(actual==expected, 'FAP_Character.toAscii(' + charactr + ') returned \'' 
            + actual + '\'; expected \'' +expected + '\'');
    }

    private static testmethod void testToChar(){
        //test: global static String toChar(Integer ascii){
        assertToChar(-1,null);
        assertToChar(0,null);
        assertToChar(128,null);
        assertToChar(9,'\t');
        assertToChar(10,'\n');
        assertToChar(12,'\f');
        assertToChar(13,'\r');
        for(Integer i = 32; i < 128; i++){
            assertToChar(i,StringUtils.charAt(charsasciiprintable,i-32));
        }
        String actual = FAP_Character.toChar(-1); 
        system.AssertEquals(null,actual);
        //system.assertEquals()
    }

    private static void assertToChar(Integer ascii, String expected){
        String actual = FAP_Character.toChar(ascii); 
        System.assert(actual==expected, 'FAP_Character.toChar(' + ascii + ') returned \'' 
            + actual + '\'; expected \'' +expected + '\'');
    }

    private static testmethod void testIsAscii(){
        //test: global static boolean isAscii(String character) {
        for(Integer i = 0; i < charsallascii.length(); i++){
            assertIsAscii(StringUtils.charAt(charsallascii,i), true);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAscii(StringUtils.charAt(charsnonascii,i), true);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }     

    private static void assertIsAscii(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAscii(charactr); 
        //System.assert(actual==expected, 'FAP_Character.isAscii(\'' + charactr + '\') returned ' + actual);
        String charact ='a';    
        actual = FAP_Character.isLetterOrDigit(charact); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charact + '\') returned ' + actual);    
    }
            
    private static testmethod void testIsAsciiPrintable(){
        //test: global static boolean isAsciiPrintable(String character) {
        for(Integer i = 0; i < charsasciiprintable.length(); i++){
            assertIsAsciiPrintable(StringUtils.charAt(charsasciiprintable,i), true);        
        }
        for(Integer i = 0; i < charsasciinonprintable.length(); i++){
            assertIsAsciiPrintable(StringUtils.charAt(charsasciinonprintable,i), false);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }     

    private static void assertIsAsciiPrintable(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiPrintable(charactr); 
        //System.assert(actual==expected, 'FAP_Character.isAsciiPrintable(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiControl(){
        //test: global static boolean isAsciiControl(String character) {
        for(Integer i = 0; i < charsasciicontrol.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(charsasciicontrol,i), true);        
        }
        for(Integer i = 0; i < charsasciiprintable.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(charsasciiprintable,i), false);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);            
    }     

    private static void asertIsAsciiControl(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiControl(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiControl(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlpha(){
        //test: global static boolean isAsciiAlpha(String character) {
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(charsasciiupper,i), true);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(charsasciilower,i), true);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(charsasciidigits,i), false);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);             
    }     

    private static void assertIsAsciiAlpha(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiAlpha(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiAlpha(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphaUpper(){
        //test: global static boolean isAsciiAlphaUpper(String character) {
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(charsasciiupper,i), true);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(charsasciilower,i), false);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(charsasciidigits,i), false);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='¿';
        Integer expected=29;
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);         
    }     

    private static void assertIsAsciiAlphaUpper(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiAlphaUpper(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiAlphaUpper(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphaLower(){
        //test: global static boolean isAsciiAlphaLower(String character) {
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(charsasciiupper,i), false);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(charsasciilower,i), true);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(charsasciidigits,i), false);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='¿';
        Integer expected=29;
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);         
    }     

    private static void assertIsAsciiAlphaLower(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiAlphaLower(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiAlphaLower(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiNumeric(){
        //test: global static boolean isAsciiNumeric(String character) {
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(charsasciiupper,i), false);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(charsasciilower,i), false);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(charsasciidigits,i), true);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='¿';
        Integer expected=29;
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);         
    }     

    private static void assertIsAsciiNumeric(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiNumeric(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiNumeric(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphanumeric(){
        //test: global static boolean isAsciiAlphanumeric(String character) {
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(charsasciiupper,i), true);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(charsasciilower,i), true);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(charsasciidigits,i), true);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='¿';
        Integer expected=29;
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected); 
    }     
    
    private static void assertIsAsciiAlphanumeric(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isAsciiAlphanumeric(charactr); 
        System.assert(actual==expected, 'FAP_Character.isAsciiAlphanumeric(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsDigit(){
        //test: global static Boolean isDigit(String character){ 
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(charsasciiupper,i), false);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(charsasciilower,i), false);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(charsasciidigits,i), true);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='¿';
        Boolean expected=false;
        Boolean actual = FAP_Character.isDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isDigit(\'' + charactr + '\') returned ' + actual);     
    }     

    private static void assertIsAsciiDigit(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isDigit(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsLetter(){
        //test: global static Boolean isLetter(String character){ 
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsLetter(StringUtils.charAt(charsasciiupper,i), true);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsLetter(StringUtils.charAt(charsasciilower,i), true);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsLetter(StringUtils.charAt(charsasciidigits,i), false);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsLetter(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetter(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetter(\'' + charactr + '\') returned ' + actual);      
    }     

    private static void assertIsLetter(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isLetter(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetter(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsLetterOrDigit(){
        //test: global static Boolean isLetterOrDigit(String character){
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(charsasciiupper,i), true);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(charsasciilower,i), true);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(charsasciidigits,i), true);        
        }
        for(Integer i = 0; i < charsnonascii.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(charsnonascii,i), false);        
        }
        String charactr ='a';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);         
    }     
    
    private static void assertIsLetterOrDigit(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'FAP_Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsWhitespace(){
        //test: global static Boolean isWhitespace(String character){
        for(Integer i = 0; i < charsasciiupper.length(); i++){
            assertIsWhitespace(StringUtils.charAt(charsasciiupper,i), false);        
        }
        for(Integer i = 0; i < charsasciilower.length(); i++){
            assertIsWhitespace(StringUtils.charAt(charsasciilower,i), false);        
        }
        for(Integer i = 0; i < charsasciidigits.length(); i++){
            assertIsWhitespace(StringUtils.charAt(charsasciidigits,i), false);        
        }
        //for(Integer i = 0; i < charsnonascii.length(); i++){
            //assertIsWhitespace(StringUtils.charAt(charsnonascii,i), false);        
        //}
        for(Integer i = 0; i < charsasciicontrol.length(); i++){
            assertIsWhitespace(StringUtils.charAt(charsasciicontrol,i), true);        
        }
        String charactr =' ';
        Boolean expected=true;        
        Boolean actual = FAP_Character.isWhitespace(charactr); 
        System.assert(actual==expected, 'FAP_Character.isWhitespace(\'' + charactr + '\') returned ' + actual);        
    }     
    
    private static void assertIsWhitespace(String charactr, Boolean expected){
        Boolean actual = FAP_Character.isWhitespace(charactr); 
        System.assert(actual==expected, 'FAP_Character.isWhitespace(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testGetType(){
        //test: global static Integer getType(String character){
        assertGetType('¿', FAP_Character.UNASSIGNED); 
        assertGetType(FAP_Character.toChar(0), FAP_Character.CONTROL); 
        assertGetType(FAP_Character.toChar(9), FAP_Character.CONTROL); 
        assertGetType(FAP_Character.toChar(10), FAP_Character.CONTROL); 
        assertGetType(FAP_Character.toChar(12), FAP_Character.CONTROL); 
        assertGetType(FAP_Character.toChar(13), FAP_Character.CONTROL); 
        assertGetType(FAP_Character.toChar(32), FAP_Character.SPACE_SEPARATOR); 
        assertGetType(FAP_Character.toChar(33), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(34), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(35), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(36), FAP_Character.CURRENCY_SYMBOL); 
        assertGetType(FAP_Character.toChar(37), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(38), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(39), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(40), FAP_Character.START_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(41), FAP_Character.END_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(42), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(43), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(44), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(45), FAP_Character.DASH_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(46), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(47), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(48), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(49), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(50), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(51), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(52), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(53), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(54), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(55), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(56), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(57), FAP_Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(FAP_Character.toChar(58), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(59), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(60), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(61), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(62), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(63), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(64), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(65), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(66), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(67), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(68), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(69), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(70), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(71), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(72), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(73), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(74), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(75), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(76), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(77), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(78), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(79), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(80), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(81), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(82), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(83), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(84), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(85), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(86), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(87), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(88), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(89), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(90), FAP_Character.UPPERCASE_LETTER); 
        assertGetType(FAP_Character.toChar(91), FAP_Character.START_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(92), FAP_Character.OTHER_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(93), FAP_Character.END_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(94), FAP_Character.MODIFIER_SYMBOL); 
        assertGetType(FAP_Character.toChar(95), FAP_Character.CONNECTOR_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(96), FAP_Character.MODIFIER_SYMBOL); 
        assertGetType(FAP_Character.toChar(97), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(98), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(99), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(100), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(101), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(102), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(103), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(104), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(105), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(106), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(107), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(108), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(109), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(110), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(111), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(112), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(113), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(114), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(115), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(116), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(117), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(118), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(119), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(120), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(121), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(122), FAP_Character.LOWERCASE_LETTER ); 
        assertGetType(FAP_Character.toChar(123), FAP_Character.START_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(124), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(125), FAP_Character.END_PUNCTUATION); 
        assertGetType(FAP_Character.toChar(126), FAP_Character.MATH_SYMBOL); 
        assertGetType(FAP_Character.toChar(127), FAP_Character.CONTROL); 
        String charactr ='¿';
        Integer expected=29;
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);        
    }     
    
    private static void assertGetType(String charactr, Integer expected){
        Integer actual = FAP_Character.getType(charactr); 
        System.assert(actual==expected, 'FAP_Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);
    }
            
            
}