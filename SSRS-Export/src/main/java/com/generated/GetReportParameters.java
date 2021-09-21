
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Report" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="HistoryID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ForRendering" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="Values" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfParameterValue" minOccurs="0"/&gt;
 *         &lt;element name="Credentials" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfDataSourceCredentials" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "report",
    "historyID",
    "forRendering",
    "values",
    "credentials"
})
@XmlRootElement(name = "GetReportParameters")
public class GetReportParameters {

    @XmlElement(name = "Report")
    protected String report;
    @XmlElement(name = "HistoryID")
    protected String historyID;
    @XmlElement(name = "ForRendering")
    protected boolean forRendering;
    @XmlElement(name = "Values")
    protected ArrayOfParameterValue values;
    @XmlElement(name = "Credentials")
    protected ArrayOfDataSourceCredentials credentials;

    /**
     * Gets the value of the report property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReport() {
        return report;
    }

    /**
     * Sets the value of the report property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReport(String value) {
        this.report = value;
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
     * Gets the value of the forRendering property.
     * 
     */
    public boolean isForRendering() {
        return forRendering;
    }

    /**
     * Sets the value of the forRendering property.
     * 
     */
    public void setForRendering(boolean value) {
        this.forRendering = value;
    }

    /**
     * Gets the value of the values property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfParameterValue }
     *     
     */
    public ArrayOfParameterValue getValues() {
        return values;
    }

    /**
     * Sets the value of the values property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfParameterValue }
     *     
     */
    public void setValues(ArrayOfParameterValue value) {
        this.values = value;
    }

    /**
     * Gets the value of the credentials property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfDataSourceCredentials }
     *     
     */
    public ArrayOfDataSourceCredentials getCredentials() {
        return credentials;
    }

    /**
     * Sets the value of the credentials property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfDataSourceCredentials }
     *     
     */
    public void setCredentials(ArrayOfDataSourceCredentials value) {
        this.credentials = value;
    }

}
