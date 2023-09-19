/**
* This class exposes extends the Default System Interface class used by Order Management to
* make a synchronous callout to an Integration Procedure (rather than a direct REST API call).
*
* The general flow is as follows:
* 
*  -----------    ------------------    ------------    -----------------------
* | Orch Item |  | System Interface |  | this Class |  | Integration Procedure |
*  -----------    ------------------    ------------    -----------------------
*       |                 |                   |                    |
*       |     execute     |                   |                    |
*       |---------------->|    startBatch()   |                    |
*       |                 |------------------>|                    |
*       |                 |                   |                    |
*       |                 |   executeItem()   |                    |
*       |                 |------------------>|      call IP       |
*       |                 |                   |------------------->|
*       |                 |                   |                    |<----------> Do integration stuff
*       |                 |                   |      response      |
*       |                 | processResponse() |<-------------------|
*       |                 |<------------------|                    |
*       |                 |                   |                    |
*       |                 |    endBatch()     |                    |
*       |     complete    |------------------>|                    |
*       |<----------------|                   |                    |
*       |                 |                   |                    |
*       
*
*/
global class OrderIntegrationSystemInterface extends vlocity_cmt.DefaultSystemInterface{
    /**
* Default Constructor
*/
    global OrderIntegrationSystemInterface() {
        
        super();
    }
    
    /**
* This method is a part of the ISystemInterface. It is invoked at the start of the batch
* 
* @param url   base URL the batch is started for
* @param path  path this batch is started for
*/
    global override void startBatch(String url, String path) {}
    
    /**
* Executes a Callout OrchestrationItem
* 
* @param url   base URL to send the request to (in this class it is ignored as we'll be calling an Integration Procedure)
* @param path  path to send the request to (in this class it is interpreted as the Integration Procedure API Key)
* @param item  OrchestrationItem that needs to be executed
*/
    global override void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        Map<String, Map<String,String>> sourceAndTargetAttrByClassName = OrderIntegrationSystemInterfaceUtility.getOMEricsonMappings();
        
        System.debug(' - Orchestration Item -> ' + JSON.serialize(item.getPopulatedFieldsAsMap()));
        
        // Get the Order SObject - the technique will differ depending on if this orchestration item is related to an Order Item or a Fulfillment Request Line
        Id orderId = null;
        Id accountId = null;
        Id orchestrationPlanId = null;
        
        if (item.vlocity_cmt__OrderItemId__c != null) 
            
            orderId = item.vlocity_cmt__OrderItemId__r.OrderId;
        
        else {
            
            vlocity_cmt__OrchestrationItem__c orchItem = [SELECT vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id, 
                                                          vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId,
                                                          vlocity_cmt__OrchestrationPlanId__c
                                                          FROM vlocity_cmt__OrchestrationItem__c WHERE Id = :item.Id];
            orderId = orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Id;
            accountId = orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.AccountId;
            orchestrationPlanId = orchItem.vlocity_cmt__OrchestrationPlanId__c;
        }
        Map<String, Object> ipInput   = (Map<String, Object>)JSON.deserializeUntyped('{"OrderId" : "'+orderId+'","AccountId":"'+accountId+'","OrchestrationPlanId":"'+orchestrationPlanId+'"}');        
        Map<String, Object> ipOptions = new Map<String, Object>();
		
        Map<String, Object> inputParamsDR = (Map<String, Object>)JSON.deserializeUntyped('{"OrchestrationPlanId":"'+orchestrationPlanId+'"}');   
        List<Map <String, Object>> getDRResult = IntegrationSystemInterfaceHelper.callDrExtract(inputParamsDR, 'OM_DR_Extract_RequestLineItemByOrchPlanId');
        
		
		
		Map<String, Map<String, Object>> attrCodeValueMap = new Map<String, Map<String, Object>>();
        Map<String,Set<String>> sourceKeyClassMap = new Map<String,Set<String>>();
		for(String key1 : sourceAndTargetAttrByClassName.keyset()){
			attrCodeValueMap.put(key1, new Map<String,Object>());
			for(String key2 : sourceAndTargetAttrByClassName.get(key1).keyset()){
				if(!sourceKeyClassMap.containskey(key2)) sourceKeyClassMap.put(key2, new Set<String>());
				sourceKeyClassMap.get(key2).add(key1);
			}
		}
        
		String attrCatCode = IntegrationSystemInterfaceHelper.getTechAttributeCategoryCode();
        List<Object> allAttrList = new List<Object>();
        
        for(Map <String, Object> outputDRMap : getDRResult){
            System.debug('====key====='+outputDRMap);
            Map<String, Object> tempMap = new Map<String, Object>();
            String fulfilmentId = '';
            String action = '';
            for(String key1 : outputDRMap.keySet()){
				if(key1.equalsIgnoreCase('Action')){
					action = (String)outputDRMap.get(key1);
				}else if(key1.equalsIgnoreCase('fulfilmentId')){
					fulfilmentId = (String)outputDRMap.get(key1);
				}else if(!key1.equals(OrderIntegrationSystemInterfaceConstants.FULFILMENTID)){
                    Map<String, Object> deserialisedMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(outputDRMap.get(key1))) ;
                    allAttrList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(deserialisedMap.get(attrCatCode))); 
                    for(Object key2: allAttrList){
                        tempMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(key2));
                        System.debug('===key2=Code  ====='+tempMap.get('Code'));
                        System.debug('===key2=SegmentValue ===='+tempMap.get('SegmentValue'));
                        if(sourceKeyClassMap.containskey((String)tempMap.get('Code'))){
							for(String classKey: sourceKeyClassMap.get((String)tempMap.get('Code'))){
								attrCodeValueMap.get(classKey).put(sourceKeyClassMap.get((String)tempMap.get('Code')) , (String)tempMap.get('SegmentValue'));
							}
						}
                    }
                    
                }
            }
            tempMap.put('action',action);
        }
        System.debug('====sourceKeyClassMap======'+sourceKeyClassMap);
		System.debug('====attrCodeValueMap======'+attrCodeValueMap);
        EricsonRequestJSON instEricsonReq = new EricsonRequestJSON();
        instEricsonReq.orderItems = new List<EricsonRequestJSON.cls_orderItems>();
        Map<String, String> actionAndFulfilmentId = new Map<String, String>();

        Integer itemCounter = 0;
        String techItem = 'TechItem';
        String techATR = 'TechATR';
        String techPC = 'TechPC';
        String techSC = 'TechSC';
        String techRC = 'TechRC';
        String techAttr = 'TechAttr';
        
        for(String sfulfillmentId : attrCodeValueMap.keyset()){
            EricsonRequestJSON.cls_item jsonItem = new EricsonRequestJSON.cls_item();
            
            for(String key : sourceAndTargetAttrByClassName.keySet()){
                if(key.equalsIgnoreCase('cls_item')){
                    
                }
            }
            jsonItem.id = String.valueOf(itemCounter);
            jsonItem.orderType = (String)attrCodeValueMap.get(sfulfillmentId).get(techItem+'OrderType');
            jsonItem.orderSpecification = (String)attrCodeValueMap.get(sfulfillmentId).get(techItem+'OrderSpecification');
            jsonItem.action = actionAndFulfilmentId.get(OrderIntegrationSystemInterfaceConstants.ACTION);
            jsonItem.productOffering = new EricsonRequestJSON.cls_productOffering();
            
            jsonItem.product = new EricsonRequestJSON.cls_product();
            jsonItem.product.productCharacteristics = new List<EricsonRequestJSON.cls_productCharacteristics>();
            for(String sKey : ''.split(',')){
                
            }
            
            jsonItem.product.productId = '';
            jsonItem.product.productPrice = new List<EricsonRequestJSON.cls_productPrice>();
            jsonItem.product.isBundled = true;
            
            jsonItem.resources = new List<EricsonRequestJSON.cls_resources>();
            
            jsonItem.services = new List<EricsonRequestJSON.cls_services>();
            
            jsonItem.relatedOrderItems = new List<EricsonRequestJSON.cls_relatedOrderItems>();
            
            jsonItem.relatedEntities = new List<EricsonRequestJSON.cls_OIrelatedEntities>();
        }
        
        System.debug('=====attrCodeValueMap====='+attrCodeValueMap);
        // Add any extra information to the payload that might be useful and otherwise not available via the DataRaptors configured in the Callout
        ipInput.put('orchestration_item_id',   item.Id);
        ipInput.put('orchestration_item_name', item.Name);       
        
        // Call the Integration Procedure
        System.debug(' - Attempting to call Integration Procedure "' + path + '"');
        System.debug(' - IP Input -> ' + JSON.serialize(ipInput));
        
        
        //Map<String, Object> ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(path, ipInput, ipOptions);       
        
        //system.debug(ipOutput);
        
        // process any response
        //processResponse(item, ipInput, ipOutput);
        
    }
    
    /**
* This method is called from executeItem to handle the response from the Integration Procedure.
* By default it does nothing (but some logging), but it could be customized to do something more.
*
* @param item      The Orchestration Item
* @param ipInput   The request sent to the Integration Procedure
* @param ipOutput  The response from the Integration Procedure
*/
    global virtual void processResponse(vlocity_cmt__OrchestrationItem__c item, Map<String, Object> ipInput, Map<String, Object> ipOutput) {
        
        // Do nothing by default
        System.debug(' - M:IP Output -> ' + JSON.serialize(ipOutput));
        
        System.debug(' - IP Request -> ' + JSON.serialize(ipOutput.get('request')));
        System.debug(' - IP Response -> ' + JSON.serialize(ipOutput.get('response')));
        
        if(Test.isRunningTest()){
            
            String inputString = '{"responseStatus": {"status": "ERROR"}}';
            
            Object inputObject = JSON.deserializeUntyped(inputString);  
            
            ipOutput.put('response', inputObject);
            ipOutput.put('manualQueueId', 'a2m78000000XgekAAC');
            
            system.debug('Es un test');
        }
        
        System.debug(' - IpOutput -> ' + JSON.serialize(ipOutput.get('response')));
        
        Map<String, Object> mapResponse = (Map<String, Object>)ipOutput.get('response');       
        Map<String, Object> mapResponseStatus = (Map<String, Object>)mapResponse.get('responseStatus');
        
        System.debug(' - IpOutput -> ' + JSON.serialize(mapResponseStatus));
        
        // For debugging, store the Request in the Orchestration Item SObject
        item.vlocity_cmt__Request__c = JSON.serialize(ipOutput.get('request'));
        item.vlocity_cmt__Response__c = JSON.serialize(ipOutput.get('response'));
        if((String)ipOutput.get('manualQueueId') != ''){
            item.vlocity_cmt__ErrorQueueId__c = (String)ipOutput.get('manualQueueId');    
        }
        
        if(!Test.isRunningTest()){            
            update item;                   
        }
        
        try
        {
            system.debug('mapResponseStatus: '+mapResponseStatus.get('status'));
            
            if((String)mapResponseStatus.get('status') == 'ERROR'){
                
                throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Response: ' + ipOutput.get('response'));    
                
            }
        }
        catch (CalloutException e)
        {
            throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException ('Callout exception '
                                                                                                  + e + ': trying to retry');
        }
        
        
    }
    
    /**
* This method is called at the end of the batch
* 
* @param url   base URL for the batch
* @param path  path for the batch
*/
    global override void endBatch(String url, String path) {} 
}
