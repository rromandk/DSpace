package org.dspace.app.xmlui.aspect.ELProcessor;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.el.ELProcessor;

import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.core.Context;

public class MainProcessor {
	
	private static InstanciadorEL instanciador;
	private static ELProcessor processor;
	private static Context context;
	
	public void process(String query, String handle, Context context) throws SQLException {
		setContext(context);
		if(query==null){
			return;
		}
		if(processor==null){
			processor=getInstanciador().instanciar(context);
		}
		//List<DSpaceObject> list=(List<DSpaceObject>) processor.eval(query+".collect(Collectors.toList())");
		Item item = (Item) processor.eval(query);
		List<DSpaceObject> list= new ArrayList();
		list.add(item);
		SelectionPage.setResult(list);
		
	}

	public static InstanciadorEL getInstanciador() {
		if(instanciador==null){
			instanciador = new InstanciadorEL();
		}
		return instanciador;
	}

	public static void setInstanciador(InstanciadorEL instanciador) {
		MainProcessor.instanciador = instanciador;
	}

	public static Context getContext() {
		return context;
	}

	public static void setContext(Context context) {
		MainProcessor.context = context;
	}
	public static void setContext(String hola) {
		
	}
	
	
	
}
