package org.dspace.app.xmlui.aspect.ELProcessor;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.collections.IteratorUtils;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;

public class HandleManager extends Manager{

	protected static final HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
	
	
	public List<Item> getItemsFromHandle(String handle) throws Exception{
		
		this.handleResolver(handle);
		
		if(dso instanceof Item){
			result.add((Item) dso);
		}else if (dso instanceof Collection){
			getItemsFromCollection((Collection) dso, result);
		}else if (dso instanceof Community){
			getItemsFromCommunity((Community)dso,result);
		}
		
		return (List<Item>)(List<?>) result;
	}
	
	public List<Collection> getCollectionsFromHandle(String handle) throws Exception{
		
		this.handleResolver(handle);
		
		if(dso instanceof Item){
			throw new Exception("The handle is from an Item");
		}else if(dso instanceof Collection){
			result.add(dso);
		}else if(dso instanceof Community){
			getCollectionsFromCommunity( (Community)dso, result);
		}
		
		return (List<Collection>)(List<?>)result;
	}
	
	public  List<Community> getCommunitiesFromHandle(String handle) throws Exception{
		
		this.handleResolver(handle);
		
		if(dso instanceof Item){
			throw new Exception("The handle is from an Item");
		}else if(dso instanceof Collection){
			throw new Exception("The handle is from a Collection");
		}else if(dso instanceof Community){
			result.add((Community)dso);
			result.addAll( ((Community)dso).getSubcommunities() );
		}
		
		return (List<Community>)(List<?>)result;
	}
	
	private void getCollectionsFromCommunity(Community com, List<DSpaceObject> result){
		for(Community community: com.getSubcommunities()){
			getCollectionsFromCommunity(community,result);
		}
		result.addAll(com.getCollections());
	}
	
	private void getItemsFromCommunity(Community com, List<DSpaceObject> result) throws SQLException{
		for(Community community: com.getSubcommunities()){
			getItemsFromCommunity(community,result);
		}
		for(Collection col: com.getCollections()){
			getItemsFromCollection(col,result);
		}		
	}
	
	private void getItemsFromCollection(Collection col, List<DSpaceObject> result) throws SQLException{
		result.addAll(IteratorUtils.toList(itemService.findAllByCollection(MainProcessor.getContext(), col)));
	}
	
	/**
	 * Find the corresponding DSO for the handle, and sets the dso variable 
	 * 
	 * @param handle
	 * @throws Exception
	 */
	public void handleResolver(String handle) throws Exception{
		try{
			dso=handleService.resolveToObject(MainProcessor.getContext(), handle);
		}
		catch(Exception e){
			throw new Exception("The're is no DSO with the handle:" +handle);
		}
	}
}
