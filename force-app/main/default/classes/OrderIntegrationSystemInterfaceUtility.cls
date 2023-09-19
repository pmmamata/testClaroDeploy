public class OrderIntegrationSystemInterfaceUtility {
    public static Map<String, Map<String,String>> getOMEricsonMappings(){
        Map<String, Map<String,String>> sourceAndTargetAttrByClassName = new Map<String, Map<String,String>>();
        for(OMEricsonMapping__mdt key : OMEricsonMapping__mdt.getAll().values()){
            if(!sourceAndTargetAttrByClassName.containsKey(key.ClassName__c)){
                sourceAndTargetAttrByClassName.put(key.ClassName__c, new Map<String, String>() );
            }
            sourceAndTargetAttrByClassName.get(key.ClassName__c).put(key.SourceAttribute__c, key.TargetAttribute__c); 
        }
        return sourceAndTargetAttrByClassName;
    }
}