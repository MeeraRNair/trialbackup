/**
 * @author: aidan@nebulaconsulting.co.uk
 * @date: 12/03/2018
 *
 * MIT License
 *
 * Copyright (c) 2018 Aidan Harding, Nebula Consulting
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public without sharing class TriggerObjectToEventsToHandlers {
    private Map<String, TriggerEventsToTriggerHandlers> mapTypeToEventHandlers;

    public TriggerObjectToEventsToHandlers() {
        mapTypeToEventHandlers = new Map<String, TriggerEventsToTriggerHandlers>();
    }

    public void putAll(List<Trigger_Handler__mdt> listTriggerHandlers) {
        for(Trigger_Handler__mdt thisTriggerHandler : listTriggerHandlers) {
            TriggerEventsToTriggerHandlers theseTriggerHandlers = mapTypeToEventHandlers.get(thisTriggerHandler.sObject__c);

            if(theseTriggerHandlers == null) {
                theseTriggerHandlers = new TriggerEventsToTriggerHandlers();

                mapTypeToEventHandlers.put(thisTriggerHandler.sObject__c, theseTriggerHandlers);
            }

            theseTriggerHandlers.put(thisTriggerHandler);
        }
    }

    public TriggerEventsToTriggerHandlers get(String strObjectName) {
        return mapTypeToEventHandlers.get(strObjectName);
    }
}