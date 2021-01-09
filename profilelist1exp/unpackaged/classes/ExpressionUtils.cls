/******************************************************************************** 
Name        : ExpressionUtils
Description : Data structure for Stack and auxillary functions used.
            This class also defines the function to convert infix expression to postfix.
             
-----------------------------------------------------------------------------------------* 
  Revision  Name            Date        CR#     Description
* 1.0       Meghana Gupta   11.06.2012  CR      Data Structure and functions defined
 

************************************************************************************/

global with sharing class ExpressionUtils {
    global final String sTRUE = '1';
    global final String sFALSE = '0';
    
    public Class Stack{
        List<String> itemList = new List<String>();
        integer lastIndex;
    
        public Stack(){
            //Stack(null);
            itemList = null;
            initialize();
        }       
        public Stack(List<String> strList){
            itemList  = strList;
            initialize();
        }       
        public void initialize(){      
            if(itemList==null)
                itemList  = new List<String>();
            lastIndex = itemList.size()-1;      
        }
        public void setLastIndex(){
            lastIndex = itemList.size()-1;
        }    
        public String pop(){
            String lastElement;
            if(lastIndex>=0){
                lastElement = itemList[lastIndex];
                itemList.remove(lastIndex);
                setLastIndex();
            }   
            return lastElement;
        }
        public String push(String item){
            itemList.add(item);
            setLastIndex();
            return item;
        }
        public Boolean hasElement(){
            return (itemList != null && itemList.size() > 0);
        }    
        public String getLastElement(){         
            String lastElement;
            if(lastIndex>=0){
                lastElement = itemList[lastIndex];          
            }   
            return lastElement;
        }       
    }       
    
    global class ExpressionConversionException extends Exception{
        
    }
    
    global class StringExpression{
        String expression;
        
        public String getExpression(){
            return expression;
        }
        public StringExpression(){
            expression ='';
        }
        public void addItem(String item){
            item = StringUtils.defaultString(item).trim();
            if(expression == '' || expression == null){
                expression = item;
            }
            else{
                expression += ' ' + item;
            }
        }
    }

    global String convertInFixToPostFixNotation(String infixExpression){
        if (infixExpression == null){
            throw new ExpressionConversionException('Evaluation Expression is invalid or empty');
        }
        
        //trims first
        infixExpression = infixExpression.trim();
        //Replace unnecessary spaces        
        infixExpression = infixExpression.replaceAll('\\s+', ' ');
        //   \s =  A whitespace character: [ \t\n\x0B\f\r] and    + =  One or more occurance of the previous character
        
        List<String> infixExpStrList = infixExpression.split(' ');   //split by space
        if(infixExpStrList.isEmpty()){
            throw new ExpressionConversionException('Evaluation Expression is invalid');
        }
        
        Stack operatorStack = new Stack();
        StringExpression resultExpression = new StringExpression();
        for(String item : infixExpStrList){
            if(isOperator(item) || item == ';'){
                if(isORoperator(item)){ // if it is "OR"
                    while(operatorStack.hasElement() && isANDoperator(operatorStack.getLastElement())){
                        resultExpression.addItem(operatorStack.pop());              
                    }           
                }
                operatorStack.push(item);
            }
            else if(item == '('){
                operatorStack.push(item);       
            }
            else if(item == ')' ){
                String tempOperator;
                while(operatorStack.hasElement()){
                    tempOperator = operatorStack.pop();
                    if(tempOperator == '(')
                        break; //immediately break. but it is not added to resultExpression                  
                    
                    resultExpression.addItem(tempOperator);             
                }
                
                if(tempOperator != '('){                 
                    throw new ExpressionConversionException('No matching left parenthesis found');
                }   
            }
            else{ // it must be ID/external ID
                resultExpression.addItem(item);
            }   
        }// end of for loop
    
        //poping out all operators from operatorStack and adds that to resultExpression
        while(operatorStack.hasElement()){
            String tempOperator = operatorStack.pop();
            if(tempOperator=='(')
                throw new ExpressionConversionException('No matching right parenthesis found');
            resultExpression.addItem(tempOperator);
        }//end of while loop
        return resultExpression.getExpression();
    }
    
    
    global Boolean isEvaluated(String item){
        return (isTrue(item) || isFalse(item));
    }
    global Boolean isTrue(String item){
        return (item==sTRUE);
    }
    global Boolean isFalse(String item){
        return (item == sFALSE);
    }
    global Boolean isOperator(String item){
        return (isANDoperator(item) || isORoperator(item));
    }
    global Boolean isANDoperator(String item){
        return (item=='AND');
    }
    global Boolean isORoperator(String item){
        return (item=='OR');
    }
    global String evaluateSimpleCondition(String operand1, String operand2, String operator){
        //converting each operand to boolean and calls the same (overloaded) method.
        return evaluateSimpleCondition(StrToBool(operand1), StrToBool(operand2), operator );
    }
    global String evaluateSimpleCondition(Boolean operand1, Boolean operand2, String operator){
        Boolean result;
        if(isORoperator(operator)){
            result = (operand1 || operand2) ;
        }
        else{
            result = (operand1 && operand2);
        }
        return BoolToStr(result);   
    }

    global String  BoolToStr(Boolean value){
        return value==true ? sTRUE : sFALSE;
    }
    global Boolean StrToBool(String value){
        return (value==sTrue);
    }
}