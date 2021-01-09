/* ============================================================
 * Find a Partner Utility Class
 */
global class FAP_Character {

    global static final FAP_IntegerRange UPPERCASE_ASCII_RANGE = new FAP_IntegerRange(65,90);
    global static final FAP_IntegerRange LOWERCASE_ASCII_RANGE = new FAP_IntegerRange(97,122);
    global static final FAP_IntegerRange DIGIT_ASCII_RANGE = new FAP_IntegerRange(48,57);
    
    global static final Integer CONNECTOR_PUNCTUATION = 2;
    global static final Integer CONTROL = 3;
    global static final Integer CURRENCY_SYMBOL = 4;
    global static final Integer DASH_PUNCTUATION = 5;
    global static final Integer DECIMAL_DIGIT_NUMBER = 6;
    global static final Integer END_PUNCTUATION = 8;
    global static final Integer LOWERCASE_LETTER = 14;
    global static final Integer MATH_SYMBOL = 15;
    global static final Integer MODIFIER_SYMBOL = 17;
    global static final Integer OTHER_PUNCTUATION = 21;
    global static final Integer SPACE_SEPARATOR = 25;
    global static final Integer START_PUNCTUATION = 26;
    global static final Integer UNASSIGNED = 29;
    global static final Integer UPPERCASE_LETTER = 30;

    private static final Map<String,Integer> CHARTOASCII = new Map<String,Integer>();
    private static final Map<Integer,String> ASCIITOCHAR = new Map<Integer,String>();
    private static final Map<Integer,Integer> ASCIITOTYPE = new Map<Integer,Integer>();
    
    
    global static Integer getType(String character){
        validateChar(character);
        Integer ascii = toAscii(character);
        if(ASCIITOTYPE.containsKey(ascii)){
            return ASCIITOTYPE.get(ascii);
        }
        return UNASSIGNED; 
    }
    
    global static Integer toAscii(String character){
        validateChar(character);
        if(CHARTOASCII.containsKey(character)){
            return CHARTOASCII.get(character);
        }
        return -1; 
    }
    
    global static String toChar(Integer ascii){
        if(ascii <= 0 || ascii > 127){
            return null;    
        }
        if(ASCIITOCHAR.containsKey(ascii)){
            return ASCIITOCHAR.get(ascii);
        }
        return null; 
    }
    
    global static String toTitleCase(String ch){
        if(inAsciiRange(ch,LOWERCASE_ASCII_RANGE)){
            return toChar(toAscii(ch)-32);
        }
        return ch; 
    }
    
    global static String toUpperCase(String ch){
        return toTitleCase(ch); 
    }
    
    global static String toLowerCase(String ch){
        if(inAsciiRange(ch,UPPERCASE_ASCII_RANGE)){
            return toChar(toAscii(ch)+32);
        }
        return ch; 
    }
    
    global static Boolean isUpperCase(String character){ 
        return inAsciiRange(character,UPPERCASE_ASCII_RANGE); 
    }
    
    global static Boolean isTitleCase(String character){ 
        return inAsciiRange(character,UPPERCASE_ASCII_RANGE); 
    }
    
    global static Boolean isLowerCase(String character){ 
        return inAsciiRange(character,LOWERCASE_ASCII_RANGE); 
    }
    
    global static Boolean isDigit(String character){ 
        return inAsciiRange(character,DIGIT_ASCII_RANGE); 
    }

    global static Boolean isLetter(String character){ 
        return isLowerCase(character) || isUpperCase(character);
    }
    
    global static Boolean isLetterOrDigit(String character){
        return isLetter(character) || isDigit(character);
    }
    
    global static Boolean isWhitespace(String character){
        validateChar(character);
        return 
            ' '.equals(character)
            || '\n'.equals(character)
            || '\t'.equals(character)
            || '\f'.equals(character)
            || '\r'.equals(character)
            ;        
    }
    
    global static boolean isAscii(String character) {
        Integer ascii = toAscii(character);
        return ascii >= 0 && ascii < 128;
    }
    
    global static boolean isAsciiPrintable(String character) {
        Integer ascii = toAscii(character);
        return ascii >= 32 && ascii < 127;
    }
    
    global static boolean isAsciiControl(String character) {
        Integer ascii = toAscii(character);
        return (ascii >= 0 && ascii < 32) || ascii == 127;
    }
    
    global static boolean isAsciiAlpha(String character) {
        return inAsciiRange(character,UPPERCASE_ASCII_RANGE) || inAsciiRange(character,LOWERCASE_ASCII_RANGE);
    }
    
    global static boolean isAsciiAlphaUpper(String character) {
        return inAsciiRange(character,UPPERCASE_ASCII_RANGE);
    }
    
    global static boolean isAsciiAlphaLower(String character) {
        return inAsciiRange(character,LOWERCASE_ASCII_RANGE);
    }
    
    global static boolean isAsciiNumeric(String character) {
        return inAsciiRange(character,DIGIT_ASCII_RANGE);
    }
    
    global static boolean isAsciiAlphanumeric(String character) {
        return inAsciiRange(character,UPPERCASE_ASCII_RANGE) 
            || inAsciiRange(character,LOWERCASE_ASCII_RANGE)
            || inAsciiRange(character,DIGIT_ASCII_RANGE);
    }
        
    global static void validateChar(String character){
        if(character != null && character.length() != 1){
            throw new FAP_InvalidCharacterStringException('Invalid charcter string: ' + character);
        }
    }

    private static Boolean inAsciiRange(String character, FAP_IntegerRange range){
        return range == null ? false : range.contains(toAscii(character));
    }
    
    static{
        CHARTOASCII.put(null, 0);
        CHARTOASCII.put('\t', 9);
        CHARTOASCII.put('\n', 10);
        CHARTOASCII.put('\f', 12);
        CHARTOASCII.put('\r', 13);
        CHARTOASCII.put(' ', 32);
        CHARTOASCII.put('!', 33);
        CHARTOASCII.put('"', 34);
        CHARTOASCII.put('#', 35);
        CHARTOASCII.put('$', 36);
        CHARTOASCII.put('%', 37);
        CHARTOASCII.put('&', 38);
        CHARTOASCII.put('\'', 39);
        CHARTOASCII.put('(', 40);
        CHARTOASCII.put(')', 41);
        CHARTOASCII.put('*', 42);
        CHARTOASCII.put('+', 43);
        CHARTOASCII.put(',', 44);
        CHARTOASCII.put('-', 45);
        CHARTOASCII.put('.', 46);
        CHARTOASCII.put('/', 47);
        CHARTOASCII.put('0', 48);
        CHARTOASCII.put('1', 49);
        CHARTOASCII.put('2', 50);
        CHARTOASCII.put('3', 51);
        CHARTOASCII.put('4', 52);
        CHARTOASCII.put('5', 53);
        CHARTOASCII.put('6', 54);
        CHARTOASCII.put('7', 55);
        CHARTOASCII.put('8', 56);
        CHARTOASCII.put('9', 57);
        CHARTOASCII.put(':', 58);
        CHARTOASCII.put(';', 59);
        CHARTOASCII.put('<', 60);
        CHARTOASCII.put('=', 61);
        CHARTOASCII.put('>', 62);
        CHARTOASCII.put('?', 63);
        CHARTOASCII.put('@', 64);
        CHARTOASCII.put('A', 65);
        CHARTOASCII.put('B', 66);
        CHARTOASCII.put('C', 67);
        CHARTOASCII.put('D', 68);
        CHARTOASCII.put('E', 69);
        CHARTOASCII.put('F', 70);
        CHARTOASCII.put('G', 71);
        CHARTOASCII.put('H', 72);
        CHARTOASCII.put('I', 73);
        CHARTOASCII.put('J', 74);
        CHARTOASCII.put('K', 75);
        CHARTOASCII.put('L', 76);
        CHARTOASCII.put('M', 77);
        CHARTOASCII.put('N', 78);
        CHARTOASCII.put('O', 79);
        CHARTOASCII.put('P', 80);
        CHARTOASCII.put('Q', 81);
        CHARTOASCII.put('R', 82);
        CHARTOASCII.put('S', 83);
        CHARTOASCII.put('T', 84);
        CHARTOASCII.put('U', 85);
        CHARTOASCII.put('V', 86);
        CHARTOASCII.put('W', 87);
        CHARTOASCII.put('X', 88);
        CHARTOASCII.put('Y', 89);
        CHARTOASCII.put('Z', 90);
        CHARTOASCII.put('[', 91);
        CHARTOASCII.put('\\', 92);
        CHARTOASCII.put(']', 93);
        CHARTOASCII.put('^', 94);
        CHARTOASCII.put('_', 95);
        CHARTOASCII.put('`', 96);
        CHARTOASCII.put('a', 97);
        CHARTOASCII.put('b', 98);
        CHARTOASCII.put('c', 99);
        CHARTOASCII.put('d', 100);
        CHARTOASCII.put('e', 101);
        CHARTOASCII.put('f', 102);
        CHARTOASCII.put('g', 103);
        CHARTOASCII.put('h', 104);
        CHARTOASCII.put('i', 105);
        CHARTOASCII.put('j', 106);
        CHARTOASCII.put('k', 107);
        CHARTOASCII.put('l', 108);
        CHARTOASCII.put('m', 109);
        CHARTOASCII.put('n', 110);
        CHARTOASCII.put('o', 111);
        CHARTOASCII.put('p', 112);
        CHARTOASCII.put('q', 113);
        CHARTOASCII.put('r', 114);
        CHARTOASCII.put('s', 115);
        CHARTOASCII.put('t', 116);
        CHARTOASCII.put('u', 117);
        CHARTOASCII.put('v', 118);
        CHARTOASCII.put('w', 119);
        CHARTOASCII.put('x', 120);
        CHARTOASCII.put('y', 121);
        CHARTOASCII.put('z', 122);
        CHARTOASCII.put('{', 123);
        CHARTOASCII.put('|', 124);
        CHARTOASCII.put('}', 125);
        CHARTOASCII.put('~', 126);
        for(String key : CHARTOASCII.keySet()){
            ASCIITOCHAR.put(CHARTOASCII.get(key), key);    
        }

        ASCIITOTYPE.put(0, CONTROL);
        ASCIITOTYPE.put(9, CONTROL);
        ASCIITOTYPE.put(10, CONTROL);
        ASCIITOTYPE.put(12, CONTROL);
        ASCIITOTYPE.put(13, CONTROL);
        ASCIITOTYPE.put(32, SPACE_SEPARATOR);
        ASCIITOTYPE.put(33, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(34, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(35, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(36, CURRENCY_SYMBOL);
        ASCIITOTYPE.put(37, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(38, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(39, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(40, START_PUNCTUATION);
        ASCIITOTYPE.put(41, END_PUNCTUATION);
        ASCIITOTYPE.put(42, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(43, MATH_SYMBOL);
        ASCIITOTYPE.put(44, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(45, DASH_PUNCTUATION);
        ASCIITOTYPE.put(46, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(47, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(48, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(49, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(50, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(51, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(52, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(53, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(54, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(55, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(56, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(57, DECIMAL_DIGIT_NUMBER);
        ASCIITOTYPE.put(58, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(59, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(60, MATH_SYMBOL);
        ASCIITOTYPE.put(61, MATH_SYMBOL);
        ASCIITOTYPE.put(62, MATH_SYMBOL);
        ASCIITOTYPE.put(63, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(64, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(65, UPPERCASE_LETTER);
        ASCIITOTYPE.put(66, UPPERCASE_LETTER);
        ASCIITOTYPE.put(67, UPPERCASE_LETTER);
        ASCIITOTYPE.put(68, UPPERCASE_LETTER);
        ASCIITOTYPE.put(69, UPPERCASE_LETTER);
        ASCIITOTYPE.put(70, UPPERCASE_LETTER);
        ASCIITOTYPE.put(71, UPPERCASE_LETTER);
        ASCIITOTYPE.put(72, UPPERCASE_LETTER);
        ASCIITOTYPE.put(73, UPPERCASE_LETTER);
        ASCIITOTYPE.put(74, UPPERCASE_LETTER);
        ASCIITOTYPE.put(75, UPPERCASE_LETTER);
        ASCIITOTYPE.put(76, UPPERCASE_LETTER);
        ASCIITOTYPE.put(77, UPPERCASE_LETTER);
        ASCIITOTYPE.put(78, UPPERCASE_LETTER);
        ASCIITOTYPE.put(79, UPPERCASE_LETTER);
        ASCIITOTYPE.put(80, UPPERCASE_LETTER);
        ASCIITOTYPE.put(81, UPPERCASE_LETTER);
        ASCIITOTYPE.put(82, UPPERCASE_LETTER);
        ASCIITOTYPE.put(83, UPPERCASE_LETTER);
        ASCIITOTYPE.put(84, UPPERCASE_LETTER);
        ASCIITOTYPE.put(85, UPPERCASE_LETTER);
        ASCIITOTYPE.put(86, UPPERCASE_LETTER);
        ASCIITOTYPE.put(87, UPPERCASE_LETTER);
        ASCIITOTYPE.put(88, UPPERCASE_LETTER);
        ASCIITOTYPE.put(89, UPPERCASE_LETTER);
        ASCIITOTYPE.put(90, UPPERCASE_LETTER);
        ASCIITOTYPE.put(91, START_PUNCTUATION);
        ASCIITOTYPE.put(92, OTHER_PUNCTUATION);
        ASCIITOTYPE.put(93, END_PUNCTUATION);
        ASCIITOTYPE.put(94, MODIFIER_SYMBOL);
        ASCIITOTYPE.put(95, CONNECTOR_PUNCTUATION);
        ASCIITOTYPE.put(96, MODIFIER_SYMBOL);
        ASCIITOTYPE.put(97, LOWERCASE_LETTER );
        ASCIITOTYPE.put(98, LOWERCASE_LETTER );
        ASCIITOTYPE.put(99, LOWERCASE_LETTER );
        ASCIITOTYPE.put(100, LOWERCASE_LETTER );
        ASCIITOTYPE.put(101, LOWERCASE_LETTER );
        ASCIITOTYPE.put(102, LOWERCASE_LETTER );
        ASCIITOTYPE.put(103, LOWERCASE_LETTER );
        ASCIITOTYPE.put(104, LOWERCASE_LETTER );
        ASCIITOTYPE.put(105, LOWERCASE_LETTER );
        ASCIITOTYPE.put(106, LOWERCASE_LETTER );
        ASCIITOTYPE.put(107, LOWERCASE_LETTER );
        ASCIITOTYPE.put(108, LOWERCASE_LETTER );
        ASCIITOTYPE.put(109, LOWERCASE_LETTER );
        ASCIITOTYPE.put(110, LOWERCASE_LETTER );
        ASCIITOTYPE.put(111, LOWERCASE_LETTER );
        ASCIITOTYPE.put(112, LOWERCASE_LETTER );
        ASCIITOTYPE.put(113, LOWERCASE_LETTER );
        ASCIITOTYPE.put(114, LOWERCASE_LETTER );
        ASCIITOTYPE.put(115, LOWERCASE_LETTER );
        ASCIITOTYPE.put(116, LOWERCASE_LETTER );
        ASCIITOTYPE.put(117, LOWERCASE_LETTER );
        ASCIITOTYPE.put(118, LOWERCASE_LETTER );
        ASCIITOTYPE.put(119, LOWERCASE_LETTER );
        ASCIITOTYPE.put(120, LOWERCASE_LETTER );
        ASCIITOTYPE.put(121, LOWERCASE_LETTER );
        ASCIITOTYPE.put(122, LOWERCASE_LETTER );
        ASCIITOTYPE.put(123, START_PUNCTUATION);
        ASCIITOTYPE.put(124, MATH_SYMBOL);
        ASCIITOTYPE.put(125, END_PUNCTUATION);
        ASCIITOTYPE.put(126, MATH_SYMBOL);
        ASCIITOTYPE.put(127, CONTROL);
    }    
    
}