
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * <p>Java class for ExecutionInfo complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ExecutionInfo"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="HasSnapshot" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="NeedsProcessing" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="AllowQueryExecution" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="CredentialsRequired" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="ParametersRequired" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="ExpirationDateTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/&gt;
 *         &lt;element name="ExecutionDateTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/&gt;
 *         &lt;element name="NumPages" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *         &lt;element name="Parameters" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfReportParameter" minOccurs="0"/&gt;
 *         &lt;element name="DataSourcePrompts" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfDataSourcePrompt" minOccurs="0"/&gt;
 *         &lt;element name="HasDocumentMap" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="ExecutionID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ReportPath" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="HistoryID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ReportPageSettings" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}PageSettings" minOccurs="0"/&gt;
 *         &lt;element name="AutoRefreshInterval" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ExecutionInfo", propOrder = {
    "hasSnapshot",
    "needsProcessing",
    "allowQueryExecution",
    "credentialsRequired",
    "parametersRequired",
    "expirationDateTime",
    "executionDateTime",
    "numPages",
    "parameters",
    "dataSourcePrompts",
    "hasDocumentMap",
    "executionID",
    "reportPath",
    "historyID",
    "reportPageSettings",
    "autoRefreshInterval"
})
@XmlSeeAlso({
    ExecutionInfo2 .class
})
public class ExecutionInfo {

    @XmlElement(name = "HasSnapshot")
    protected boolean hasSnapshot;
    @XmlElement(name = "NeedsProcessing")
    protected boolean needsProcessing;
    @XmlElement(name = "AllowQueryExecution")
    protected boolean allowQueryExecution;
    @XmlElement(name = "CredentialsRequired")
    protected boolean credentialsRequired;
    @XmlElement(name = "ParametersRequired")
    protected boolean parametersRequired;
    @XmlElement(name = "ExpirationDateTime", required = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar expirationDateTime;
    @XmlElement(name = "ExecutionDateTime", required = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar executionDateTime;
    @XmlElement(name = "NumPages")
    protected int numPages;
    @XmlElement(name = "Parameters")
    protected ArrayOfReportParameter parameters;
    @XmlElement(name = "DataSourcePrompts")
    protected ArrayOfDataSourcePrompt dataSourcePrompts;
    @XmlElement(name = "HasDocumentMap")
    protected boolean hasDocumentMap;
    @XmlElement(name = "ExecutionID")
    protected String executionID;
    @XmlElement(name = "ReportPath")
    protected String reportPath;
    @XmlElement(name = "HistoryID")
    protected String historyID;
    @XmlElement(name = "ReportPageSettings")
    protected PageSettings reportPageSettings;
    @XmlElement(name = "AutoRefreshInterval")
    protected int autoRefreshInterval;

    /**
     * Gets the value of the hasSnapshot property.
     * 
     */
    public boolean isHasSnapshot() {
        return hasSnapshot;
    }

    /**
     * Sets the value of the hasSnapshot property.
     * 
     */
    public void setHasSnapshot(boolean value) {
        this.hasSnapshot = value;
    }

    /**
     * Gets the value of the needsProcessing property.
     * 
     */
    public boolean isNeedsProcessing() {
        return needsProcessing;
    }

    /**
     * Sets the value of the needsProcessing property.
     * 
     */
    public void setNeedsProcessing(boolean value) {
        this.needsProcessing = value;
    }

    /**
     * Gets the value of the allowQueryExecution property.
     * 
     */
    public boolean isAllowQueryExecution() {
        return allowQueryExecution;
    }

    /**
     * Sets the value of the allowQueryExecution property.
     * 
     */
    public void setAllowQueryExecution(boolean value) {
        this.allowQueryExecution = value;
    }

    /**
     * Gets the value of the credentialsRequired property.
     * 
     */
    public boolean isCredentialsRequired() {
        return credentialsRequired;
    }

    /**
     * Sets the value of the credentialsRequired property.
     * 
     */
    public void setCredentialsRequired(boolean value) {
        this.credentialsRequired = value;
    }

    /**
     * Gets the value of the parametersRequired property.
     * 
     */
    public boolean isParametersRequired() {
        return parametersRequired;
    }

    /**
     * Sets the value of the parametersRequired property.
     * 
     */
    public void setParametersRequired(boolean value) {
        this.parametersRequired = value;
    }

    /**
     * Gets the value of the expirationDateTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getExpirationDateTime() {
        return expirationDateTime;
    }

    /**
     * Sets the value of the expirationDateTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setExpirationDateTime(XMLGregorianCalendar value) {
        this.expirationDateTime = value;
    }

    /**
     * Gets the value of the executionDateTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getExecutionDateTime() {
        return executionDateTime;
    }

    /**
     * Sets the value of the executionDateTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setExecutionDateTime(XMLGregorianCalendar value) {
        this.executionDateTime = value;
    }

    /**
     * Gets the value of the numPages property.
     * 
     */
    public int getNumPages() {
        return numPages;
    }

    /**
     * Sets the value of the numPages property.
     * 
     */
    public void setNumPages(int value) {
        this.numPages = value;
    }

    /**
     * Gets the value of the parameters property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfReportParameter }
     *     
     */
    public ArrayOfReportParameter getParameters() {
        return parameters;
    }

    /**
     * Sets the value of the parameters property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfReportParameter }
     *     
     */
    public void setParameters(ArrayOfReportParameter value) {
        this.parameters = value;
    }

    /**
     * Gets the value of the dataSourcePrompts property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfDataSourcePrompt }
     *     
     */
    public ArrayOfDataSourcePrompt getDataSourcePrompts() {
        return dataSourcePrompts;
    }

    /**
     * Sets the value of the dataSourcePrompts property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfDataSourcePrompt }
     *     
     */
    public void setDataSourcePrompts(ArrayOfDataSourcePrompt value) {
        this.dataSourcePrompts = value;
    }

    /**
     * Gets the value of the hasDocumentMap property.
     * 
     */
    public boolean isHasDocumentMap() {
        return hasDocumentMap;
    }

    /**
     * Sets the value of the hasDocumentMap property.
     * 
     */
    public void setHasDocumentMap(boolean value) {
        this.hasDocumentMap = value;
    }

    /**
     * Gets the value of the executionID property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecutionID() {
        return executionID;
    }

    /**
     * Sets the value of the executionID property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecutionID(String value) {
        this.executionID = value;
    }

    /**
     * Gets the value of the reportPath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportPath() {
        return reportPath;
    }

    /**
     * Sets the value of the reportPath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportPath(String value) {
        this.reportPath = value;
    }

    /**
     * Gets the value of the historyID property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHistoryID() {
        return historyID;
    }

    /**
     * Sets the value of the historyID property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHistoryID(String value) {
        this.historyID = value;
    }

    /**
     * Gets the value of the reportPageSettings property.
     * 
     * @return
     *     possible object is
     *     {@link PageSettings }
     *     
     */
    public PageSettings getReportPageSettings() {
        return reportPageSettings;
    }

    /**
     * Sets the value of the reportPageSettings property.
     * 
     * @param value
     *     allowed object is
     *     {@link PageSettings }
     *     
     */
    public void setReportPageSettings(PageSettings value) {
        this.reportPageSettings = value;
    }

    /**
     * Gets the value of the autoRefreshInterval property.
     * 
     */
    public int getAutoRefreshInterval() {
        return autoRefreshInterval;
    }

    /**
     * Sets the value of the autoRefreshInterval property.
     * 
     */
    public void setAutoRefreshInterval(int value) {
        this.autoRefreshInterval = value;
    }

}
