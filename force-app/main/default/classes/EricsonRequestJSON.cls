public class EricsonRequestJSON{
	public String orderType;	//ProductOfferingOrder
	public String createdDate;	//2023-03-07T14:40:48.894Z
	public String description;	//ORDMD282406
	public cls_relatedParties[] relatedParties;
	public String correlationID;	//1678200050
	public boolean run;
	public cls_relatedEntities[] relatedEntities;
	public Integer version;	//0
	public cls_orderItems[] orderItems;
	public String requestedCompletionDate;	//2023-03-11T14:40:48.894Z
	public cls_orderSpec orderSpec;
	public cls_attributes[] attrs;
    
	public class cls_relatedParties {
		public String reference;	//93000000000181
		public String role;	//Customer
		public cls_party party;
	}
	public class cls_party {
		public cls_CustomerInformation CustomerInformation;
	}
	public class cls_CustomerInformation {
		public cls_attributes[] attributes;
	}
	public class cls_attributes {
		public String name;	//MARKET
		public String value;	//GSM
	}
	public class cls_OIrelatedEntities {
		public String type;	//Contract
		public String name;	//ContractId
		public String reference;	//CONTR0000
		public cls_OIentity entity;
	}
    
    public class cls_relatedEntities {
		public String type;	//Contract
		public String id;	//ContractId
		public String reference;	//CONTR0000
		public cls_entity entity;
	}
    
	public class cls_OIentity {
		public cls_contractCreationInformation contractCreationInformation;
	}
    
    public class cls_entity {
		public cls_locationInformation contractCreationInformation;
	}
    
	public class cls_locationInformation {
		public cls_attributes[] attributes;
	}
	public class cls_orderItems {
		public cls_item item;
	}
	public class cls_item {
		public String id;	//0
		public String orderType;	//ProductOfferingOrder
		public String orderSpecification;	//e
		public String action;	//Add
		public cls_productOffering productOffering;
		public cls_product product;
		public cls_resources[] resources;
		public cls_services[] services;
		public cls_relatedOrderItems[] relatedOrderItems;
		public cls_OIrelatedEntities[] relatedEntities;
		public cls_attributes[] attrs;
	}
	public class cls_productOffering {
		public String id;	//PO_MovPosBasico
	}
	public class cls_product {
		public cls_productCharacteristics[] productCharacteristics;
		public String productId;	//12360943224
		public cls_productPrice[] productPrice;
		public boolean isBundled;
	}
	public class cls_productCharacteristics {
		public String name;	//RPName
		public String value;	//Servicio Movil Postpago
		public boolean isConfigurable;
	}
	public class cls_productPrice {
		public Integer amount;	//380
		public cls_taxCode taxCode;
		public String frequency;	//O
		public String v_currency;	//COP
		public String chargeTypeCode;	//CT_SimCarTaxIVA
		public String popId;	//Tax_IVA
		public String priceType;
		public cls_characteristics[] characteristics;
		public String name;	//IVA SimCard
		public cls_externalIDs externalIDs;
		public cls_unitOfMeasure unitOfMeasure;
		public String description;	//
		public cls_overrideAmount overrideAmount;
	}
	public class cls_taxCode {
	}
	
	public class cls_characteristics {
		public String name;	//loadInstalledBaseStrategy
		public String value;	//NOSR
	}
	public class cls_externalIDs {
	}
	public class cls_unitOfMeasure {
	}
	public class cls_overrideAmount {
	}
	public class cls_resources {
		public cls_resourceCharacteristics[] resourceCharacteristics;
		public String resourceId;	//1917667068
		public String resourceSpecification;	//PRS_SimCard
		public cls_resourceCandidate resourceCandidate;
		public boolean isLogical;
		public boolean isCompound;
		public cls_parentId parentId;
		public cls_physicalResourceId physicalResourceId;
		public String resourceType;	//Accessory
		public cls_resourceNumber resourceNumber;
		public String serialNumber;	//8957101100000100353
	}
	public class cls_resourceCharacteristics {
		public String name;	//CodigoMaterial
		public cls_value value;
		public boolean isConfigurable;
	}
	public class cls_value {
	}
	public class cls_resourceCandidate {
	}
	public class cls_parentId {
	}
	public class cls_physicalResourceId {
	}
	public class cls_resourceNumber {
	}
	public class cls_services {
		public cls_serviceCharacteristics[] serviceCharacteristics;
		public cls_serviceCandidate serviceCandidate;
		public String serviceId;	//1917667069
		public String cfsSpecification;	//CFSS_MovPosBasico
		public String serviceType;	//CustomerFacingServiceSpec
	}
	public class cls_serviceCharacteristics {
        public String name;	//CodigoMaterial
		public cls_value value;
		public boolean isConfigurable;
	}
	public class cls_serviceCandidate {
	}
	public class cls_relatedOrderItems {
        public String role;
        public String reference;
	}
	public class cls_contractCreationInformation {
		public cls_attributes[] attributes;
	}
	/*public class cls_attrs {
		public String name;	//SkipPricing
		public String value;	//true
	}*/
	public class cls_orderSpec {
		public String name;	//ProductOrder
		public cls_characteristics[] characteristics;
	}
	public static EricsonRequestJSON parse(String json){
		return (EricsonRequestJSON) System.JSON.deserialize(json, EricsonRequestJSON.class);
	}

}