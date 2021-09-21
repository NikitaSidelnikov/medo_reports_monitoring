
package com.generated;

import java.net.MalformedURLException;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebEndpoint;
import javax.xml.ws.WebServiceClient;
import javax.xml.ws.WebServiceException;
import javax.xml.ws.WebServiceFeature;


/**
 * The Reporting Services Execution Service enables report execution
 * 
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.3.2
 * Generated source version: 2.2
 * 
 */
@WebServiceClient(name = "ReportExecutionService", targetNamespace = "http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices", wsdlLocation = "file:/C:/Users/n.sidelnikov/IdeaProjects/WSDL/src/main/resources/wsdl/ReportExecution2005.wsdl")
public class ReportExecutionService
    extends Service
{

    private final static URL REPORTEXECUTIONSERVICE_WSDL_LOCATION;
    private final static WebServiceException REPORTEXECUTIONSERVICE_EXCEPTION;
    private final static QName REPORTEXECUTIONSERVICE_QNAME = new QName("http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices", "ReportExecutionService");

    static {
        URL url = null;
        WebServiceException e = null;
        try {
            url = new URL("file:/C:/Users/n.sidelnikov/IdeaProjects/WSDL/src/main/resources/wsdl/ReportExecution2005.wsdl");
        } catch (MalformedURLException ex) {
            e = new WebServiceException(ex);
        }
        REPORTEXECUTIONSERVICE_WSDL_LOCATION = url;
        REPORTEXECUTIONSERVICE_EXCEPTION = e;
    }

    public ReportExecutionService() {
        super(__getWsdlLocation(), REPORTEXECUTIONSERVICE_QNAME);
    }

    public ReportExecutionService(WebServiceFeature... features) {
        super(__getWsdlLocation(), REPORTEXECUTIONSERVICE_QNAME, features);
    }

    public ReportExecutionService(URL wsdlLocation) {
        super(wsdlLocation, REPORTEXECUTIONSERVICE_QNAME);
    }

    public ReportExecutionService(URL wsdlLocation, WebServiceFeature... features) {
        super(wsdlLocation, REPORTEXECUTIONSERVICE_QNAME, features);
    }

    public ReportExecutionService(URL wsdlLocation, QName serviceName) {
        super(wsdlLocation, serviceName);
    }

    public ReportExecutionService(URL wsdlLocation, QName serviceName, WebServiceFeature... features) {
        super(wsdlLocation, serviceName, features);
    }

    /**
     * 
     * @return
     *     returns ReportExecutionServiceSoap
     */
    @WebEndpoint(name = "ReportExecutionServiceSoap")
    public ReportExecutionServiceSoap getReportExecutionServiceSoap() {
        return super.getPort(new QName("http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices", "ReportExecutionServiceSoap"), ReportExecutionServiceSoap.class);
    }

    /**
     * 
     * @param features
     *     A list of {@link javax.xml.ws.WebServiceFeature} to configure on the proxy.  Supported features not in the <code>features</code> parameter will have their default values.
     * @return
     *     returns ReportExecutionServiceSoap
     */
    @WebEndpoint(name = "ReportExecutionServiceSoap")
    public ReportExecutionServiceSoap getReportExecutionServiceSoap(WebServiceFeature... features) {
        return super.getPort(new QName("http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices", "ReportExecutionServiceSoap"), ReportExecutionServiceSoap.class, features);
    }

    private static URL __getWsdlLocation() {
        if (REPORTEXECUTIONSERVICE_EXCEPTION!= null) {
            throw REPORTEXECUTIONSERVICE_EXCEPTION;
        }
        return REPORTEXECUTIONSERVICE_WSDL_LOCATION;
    }

}
