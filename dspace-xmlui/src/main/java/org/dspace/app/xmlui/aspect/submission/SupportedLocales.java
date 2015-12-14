/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.submission;


import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;

import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.xml.sax.SAXException;


/**
 * Adds supported locales to the pageMeta
 * 
 * @author Nestor Oviedo
 */
public class SupportedLocales extends AbstractDSpaceTransformer implements CacheableProcessingComponent
{
	
    /**
     * Generate the cache validity object.
     */
    public SourceValidity getValidity() 
    {
        return NOPValidity.SHARED_INSTANCE;
    }
    
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException
    {
        // Adds supported locales from webui.supported.locales config property
        String supportedLocalesString = ConfigurationManager.getProperty("webui.supported.locales");
        for (String locale : supportedLocalesString.split(",")) {
        	pageMeta.addMetadata("supported_locale").addContent(locale.trim());
		}
    }

	@Override
	public Serializable getKey() {
	    return "1";
	}
}

