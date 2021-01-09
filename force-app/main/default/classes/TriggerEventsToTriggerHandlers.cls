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

public without sharing class TriggerEventsToTriggerHandlers {
    private Map<String, List<Trigger_Handler__mdt>> mapTriggerEventsToTriggerHandlers;

    public TriggerEventsToTriggerHandlers() {
        mapTriggerEventsToTriggerHandlers = new Map<String, List<Trigger_Handler__mdt>>();
    }

    public void put(Trigger_Handler__mdt thisTriggerHandler) {
        List<Trigger_Handler__mdt> listTriggerHandlers = mapTriggerEventsToTriggerHandlers.get(thisTriggerHandler.Event__c);

        if(listTriggerHandlers == null) {
            listTriggerHandlers = new List<Trigger_Handler__mdt>();

            mapTriggerEventsToTriggerHandlers.put(thisTriggerHandler.Event__c, listTriggerHandlers);
        }

        listTriggerHandlers.add(thisTriggerHandler);
    }

    public List<Trigger_Handler__mdt> getTriggerHandlers(String strEvent) {
        return mapTriggerEventsToTriggerHandlers.get(strEvent);
    }
}