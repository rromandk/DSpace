package org.dspace.app.xmlui.aspect.ELProcessor;

import java.util.List;

import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;

public class ConditionManager extends Manager{

	private String metadata;
	private String value;
	
	
	public List<Item> getItemsFromCondition(String condition) throws Exception{
		
		this.separeteCondition(condition);
		return metadataManager.getItemsFromMetadataAndValue(metadata, value);
	}
	
	private void separeteCondition(String condition) throws Exception{
		String[] arrayCondition=condition.split("\\=");
		
		if(arrayCondition.length!=2){
			throw new Exception("The condition must have the format metadata=value");
		}		
		metadata=arrayCondition[0];
		value=arrayCondition[1];
	}
	
}
