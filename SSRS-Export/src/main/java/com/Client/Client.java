//Client.java
package com.Client;

import com.AppProperties;
import com.GUI.Alert.ErrorAlert;
import com.generated.*;
import org.apache.cxf.Bus;
import org.apache.cxf.bus.CXFBusFactory;
import org.apache.cxf.configuration.security.AuthorizationPolicy;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.jaxws.endpoint.dynamic.JaxWsDynamicClientFactory;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.transport.http.HTTPConduitConfigurer;
import org.apache.cxf.transports.http.configuration.HTTPClientPolicy;

import javax.xml.namespace.QName;
import javax.xml.ws.Holder;
import javax.xml.ws.Service;

import java.awt.Desktop;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.MalformedURLException;

import java.net.URL;
import java.util.List;

public class Client {
    private final QName SERVICE_NAME =
            new QName("http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices",
                    "ReportingService2005");
    private final QName EXECUTION_NAME =
            new QName("http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices",
                    "ReportExecutionService");
    private String WSDL = "http://127.0.0.1:8080/ReportServer/ReportService2005.asmx?WSDL";
    private String WSDL_EXECUTION = "http://127.0.0.1:8080/ReportServer/ReportExecution2005.asmx?WSDL";

    private static ReportingService2005Soap RS_Service;
    private static ReportExecutionServiceSoap RS_Execution;
    private ExecutionInfo executionInfo;
    private String PATH_SAVE = "C:\\Users\\Public\\Documents";
    private String FORMAT = "EXCEL";
    private Boolean OPEN_FILE = false;

    public Client() {
        getProperties();
    }

    public boolean clientAuthorization(String login, String psw) {
        /*  Initializing the client for authorization  */
        final Bus bus = CXFBusFactory.getThreadDefaultBus(true);

        final MyHTTPConduitConfigurer conf = new MyHTTPConduitConfigurer(login, psw);

        //final MyHTTPConduitConfigurer conf = new MyHTTPConduitConfigurer("n.sidelnikov", "BaRHan4ik2020");

        bus.setExtension(conf, HTTPConduitConfigurer.class); //important: do not use your implementation class, but the interface
        final JaxWsDynamicClientFactory dcf = JaxWsDynamicClientFactory.newInstance(bus);
        org.apache.cxf.endpoint.Client client;
        try {
            client = dcf.createClient(WSDL); //or WSDL_EXECUTION
            createServices();
            client.close();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
        /*  ----------------------------------------  */
        createServices();
        return true;
    }


    private void createServices() {

        /*  Creating a services for managing generated classes  */
        //  ReportingService2005.wsdl
        URL wsdlURL = null;
        try {
            wsdlURL = new URL(WSDL);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        final Service service = ReportingService2005.create(wsdlURL, SERVICE_NAME);
        RS_Service = service.getPort(ReportingService2005Soap.class);

        //  ReportExecutionService.wsdl
        try {
            wsdlURL = new URL(WSDL_EXECUTION);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        final Service service_execution = ReportExecutionService.create(wsdlURL, EXECUTION_NAME);
        RS_Execution = service_execution.getPort(ReportExecutionServiceSoap.class);
        /*  -----------------------------------------------  */

        /*  Set timeout  */
        final org.apache.cxf.endpoint.Client cxfClient = ClientProxy.getClient(RS_Execution);
        final HTTPConduit httpConduit = (HTTPConduit) cxfClient.getConduit();

        final HTTPClientPolicy httpClientPolicy = new HTTPClientPolicy();
        httpClientPolicy.setConnectionTimeout(5 * 60 * 1000);
        httpClientPolicy.setReceiveTimeout(5 * 60 * 1000);
        httpConduit.setClient(httpClientPolicy);
    }

    public void loadReportDefinition(String path) {
        final File file = new File(path);
        FileInputStream fis = null;
        byte[] fileContent = new byte[(int) file.length()];
        try {
            fis = new FileInputStream(file);
            fis.read(fileContent);
        } catch (FileNotFoundException e) {
            ErrorAlert.show(e);
        } catch (IOException ioe) {
            ErrorAlert.show(ioe);
        } finally {
            // close the streams using close method
            try {
                if (fis != null) {
                    fis.close();
                }
            } catch (IOException ioe) {
                ErrorAlert.show(ioe);
            }
        }
        try {
            executionInfo = RS_Execution.loadReportDefinition(fileContent, null, null, null, null, null);
        } catch (Exception e){
            ErrorAlert.show(e);
        }
    }

    public void setExecutionParameters(List<ParameterValue> params) {
        final ArrayOfParameterValue arrayOfParameterValue = new ArrayOfParameterValue();

        final ExecutionHeader executionHeader = new ExecutionHeader();
        executionHeader.setExecutionID(executionInfo.getExecutionID()); // set ExecutionID in SOAP Header

        for (ParameterValue param : params) {
            arrayOfParameterValue.addParameterValue(param);
        }
        executionInfo = RS_Execution.setExecutionParameters(arrayOfParameterValue, "nl-nl", executionHeader, null, null);

    }

    /* Rendering report on SSRS side and getting result */
    public byte[] Render() {
        final ExecutionHeader executionHeader = new ExecutionHeader();
        executionHeader.setExecutionID(executionInfo.getExecutionID()); // set ExecutionID in SOAP Header

        byte[] renderResult;
        final String format = FORMAT;
        final String deviceInfo = "<DeviceInfo><SimplePageHeaders>False</SimplePageHeaders></DeviceInfo>";
        final Holder<byte[]> result = new Holder<>();
        final Holder<String> extension = new Holder<>("");
        final Holder<String> mimeType = new Holder<>("");
        final Holder<String> encoding = new Holder<>("");
        final Holder<ArrayOfWarning> warnings = new Holder<>();
        System.out.println("Rendering");
        //Calling the rendering method from the SSRS side

        renderResult = RS_Execution.render(
                format
                , deviceInfo
                , result
                , extension
                , mimeType
                , encoding
                , warnings
                , null
                , executionHeader
                , null
                , null
        );

        return renderResult;
    }

    /* Save result of rendering in file */
    public void SaveReport(byte[] result, String reportName) {
        String fileFormat;
        switch (FORMAT) {
            case ("EXCEL"):
                fileFormat = ".xls";
                break;
            case ("WORD"):
                fileFormat = ".doc";
                break;
            case ("PDF"):
                fileFormat = ".pdf";
                break;
            default:
                fileFormat = ".xls";
                break;
        }


        //Writing the result to a file
        File file = new File(PATH_SAVE + "\\" + reportName + fileFormat);
        int count = 1;
        while(file.exists()){
            file = new File(PATH_SAVE + "\\" + reportName + "#" + count + fileFormat);
            count++;
        }
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            fos.write(result);
        } catch (FileNotFoundException e) {
            ErrorAlert.show(e);
        } catch (IOException ioe) {
            ErrorAlert.show(ioe);
        } finally {
            // close the streams using close method
            try {
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException ioe) {
                ErrorAlert.show(ioe);
            }
        }
        try {
            if (OPEN_FILE)
                Desktop.getDesktop().open(file);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void setURL(String url) {

        WSDL_EXECUTION = url + "/ReportExecution2005.asmx?WSDL";
        WSDL = url + "/ReportService2005.asmx?WSDL";
    }

    public ExecutionInfo getExecutionInfo(){
        return executionInfo;
    }

    public void getProperties() {
        WSDL_EXECUTION = AppProperties.getUrl() + "/ReportExecution2005.asmx?WSDL";
        WSDL = AppProperties.getUrl() + "/ReportService2005.asmx?WSDL";
        PATH_SAVE = AppProperties.getSavePath();
        FORMAT = AppProperties.getFormat();
        OPEN_FILE = AppProperties.getFileOpening();
    }
}

record MyHTTPConduitConfigurer(String username, String password) implements HTTPConduitConfigurer {

    @Override
    public void configure(String name, String address, HTTPConduit c) {
        AuthorizationPolicy ap = new AuthorizationPolicy();
        ap.setUserName(username);
        ap.setPassword(password);
        c.setAuthorization(ap);
    }
}
