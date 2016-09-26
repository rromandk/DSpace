package org.dspace.app.xmlui.aspect.ELProcessor;

import java.util.List;

import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.Item;

public class SelectionManager extends Manager{

	private static HandleManager handleManager= new HandleManager();
	
	public static List<Item> selecItems(String value) throws Exception{
		
		//first I have to identify what are they selecting by
		String type=identifySelection(value, "item");
		
		if(type=="condition"){
			return conditionManager.getItemsFromCondition(value);
			//they are selecting by condition
			
		}else{
			//it is by handle
			return handleManager.getItemsFromHandle(value);
		}
		
	}
	
	public static List<Collection> selecCollections(String value) throws Exception{
		
		//first I have to identify what are they selecting by
		identifySelection(value, "collection");
		
		//if it reaches this far  is by handle
		return handleManager.getCollectionsFromHandle(value);
		
		
	}
	
	public static List<Community> selecCommunities(String value) throws Exception{
		
		//first I have to identify what are they selecting by		
		identifySelection(value, "community");
		
		//if it reaches this far  is by handle
		return handleManager.getCommunitiesFromHandle(value);
		
		
	}
	
	private static String identifySelection(String selection, String dsoType) throws Exception{
		
		String selectionType;
		if(selection.contains("=")){
			//they are selecting by condition
			selectionType="condition";
		}else{
			//it is by handle
			selectionType="handle";
		}
		
		//because collections and communities doesn't have metadata we can't find them by condition
		if(selectionType == "condition" && (dsoType == "collection" || dsoType == "community")){
			throw new Exception("You can only select "+dsoType+" by handle");
		}
		
		return selectionType;
	
	}
	
	
	
}
