package org.dspace.app.xmlui.aspect.ELProcessor;

import java.sql.SQLException;
import java.util.List;

import org.apache.commons.collections.IteratorUtils;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.MetadataFieldService;

public class MetadataManager extends Manager{

	protected static final MetadataFieldService metadataService= ContentServiceFactory.getInstance().getMetadataFieldService();
	
	public void prepareMetadataField(String value) throws Exception{
		
		String[] arrayMetadataField=value.split("\\.");
		if(arrayMetadataField.length != 2 && arrayMetadataField.length != 3 ){  // chequeo que por lo menos tenga schema y element
			throw new Exception("The metadata has a wrong format");
		}
		schema = arrayMetadataField[0];
		element = arrayMetadataField[1];
		qualifier = null;
		if(arrayMetadataField.length == 3){
			qualifier = arrayMetadataField[2]; 
		}
	}
	
	public MetadataField getMetadataFieldFromString(String metadata) throws Exception{
		this.prepareMetadataField(metadata);
		return metadataService.findByElement(MainProcessor.getContext(), schema, element, qualifier);
	}
	
	public List<Item> getItemsFromMetadataAndValue(String metadata, String value) throws Exception{		
		this.prepareMetadataField(metadata);
		return IteratorUtils.toList(itemService.findByMetadataField(MainProcessor.getContext(), schema, element, qualifier, value));		
	}	
	
	
}
