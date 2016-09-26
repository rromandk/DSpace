package org.dspace.app.xmlui.aspect.ELProcessor;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.ArrayList;

import org.apache.cocoon.ProcessingException;
import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.util.HashUtil;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.Item;
import org.dspace.app.xmlui.wing.element.List;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.app.xmlui.wing.element.Text;
import org.dspace.app.xmlui.wing.element.TextArea;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.DSpaceObject;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.xml.sax.SAXException;

public class SelectionPage extends AbstractDSpaceTransformer implements CacheableProcessingComponent {
    
    /** language strings */
    private static final Message T_title =
        message("xmlui.ArtifactBrowser.Contact.title");
    
    private static final Message T_dspace_home =
        message("xmlui.general.dspace_home");
    
    private static final Message T_trail = 
        message("xmlui.ArtifactBrowser.Contact.trail");
    
    private static final Message T_head = 
        message("xmlui.ArtifactBrowser.Contact.head");
    
    private static final Message T_para1 =
        message("xmlui.ArtifactBrowser.Contact.para1");

    private static java.util.List<DSpaceObject> result;
	
    private static final ConfigurationService configurationService =DSpaceServicesFactory.getInstance().getConfigurationService();
    
    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    public Serializable getKey() 
    {
       return "1";
    }

    /**
     * Generate the cache validity object.
     */
    public SourceValidity getValidity() 
    {
        return NOPValidity.SHARED_INSTANCE;
    }
    
    
	@Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException, WingException, UIException, SQLException, IOException, AuthorizeException {
        pageMeta.addMetadata("title").addContent(T_title);
        
        pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
        pageMeta.addTrail().addContent(T_trail);
    }

    @Override
    public void addBody(Body body) throws SAXException, WingException, UIException, SQLException, IOException, AuthorizeException, ProcessingException {
    	Division contact = body.addDivision("contact","primary");
        
        contact.setHead(T_head);
        
        String name = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("dspace.name");
        contact.addPara(T_para1.parameterize(name));
        
        String[] options=(configurationService.getProperty("el.processor.options", null).split(","));
        
        List list = contact.addList("options");
        
        for(String option:options){
        	String description = configurationService.getProperty("el.processor.description."+option);
        	Item oneItem= list.addItem();
        	oneItem.addText("description").setValue(description);
        	oneItem.addText("identifier").setValue(option);
        }
        
        Division resultado=contact.addDivision("Resultado");
        List losResultados=resultado.addList("resultatos");
        if(result !=null){
	        for(DSpaceObject dso: result){
	        	Item unResultado=losResultados.addItem();
	        	unResultado.addText("valor").setValue(dso.getName());
	        }
        }
    }

	public java.util.List<DSpaceObject> getResult() {
		return result;
	}

	public static void setResult(java.util.List<DSpaceObject> list) {
		result = list;
	}
    
    

}