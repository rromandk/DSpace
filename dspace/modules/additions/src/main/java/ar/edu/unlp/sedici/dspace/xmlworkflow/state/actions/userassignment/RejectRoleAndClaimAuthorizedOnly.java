package ar.edu.unlp.sedici.dspace.xmlworkflow.state.actions.userassignment;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.factory.AuthorizeServiceFactoryImpl;
import org.dspace.core.Context;
import org.dspace.xmlworkflow.WorkflowConfigurationException;
import org.dspace.xmlworkflow.storedcomponents.XmlWorkflowItem;

public class RejectRoleAndClaimAuthorizedOnly extends RejectRole {

	//TODO In the future, add properties class, initialized by Spring Bean Files, to configure what Authorization is required to be authorized.
	
	@Override
	public boolean isAuthorized(Context context, HttpServletRequest request, XmlWorkflowItem wfi)
			throws SQLException, AuthorizeException, IOException, WorkflowConfigurationException {
		return super.isAuthorized(context, request, wfi) &&
				//Check if current user has ADMIN privileges over the workflowitem's collection.
				AuthorizeServiceFactoryImpl.getInstance().getAuthorizeService().isAdmin(context, wfi.getCollection());
	}
}
