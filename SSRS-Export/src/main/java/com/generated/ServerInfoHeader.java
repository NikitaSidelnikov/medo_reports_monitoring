
package com.generated;

import java.util.HashMap;
import java.util.Map;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;
import javax.xml.namespace.QName;


/**
 * <p>Java class for ServerInfoHeader complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ServerInfoHeader"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="ReportServerVersionNumber" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ReportServerEdition" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ReportServerVersion" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ReportServerDateTime" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *       &lt;anyAttribute/&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ServerInfoHeader", propOrder = {
    "reportServerVersionNumber",
    "reportServerEdition",
    "reportServerVersion",
    "reportServerDateTime"
})
public class ServerInfoHeader {

    @XmlElement(name = "ReportServerVersionNumber")
    protected String reportServerVersionNumber;
    @XmlElement(name = "ReportServerEdition")
    protected String reportServerEdition;
    @XmlElement(name = "ReportServerVersion")
    protected String reportServerVersion;
    @XmlElement(name = "ReportServerDateTime")
    protected String reportServerDateTime;
    @XmlAnyAttribute
    private Map<QName, String> otherAttributes = new HashMap<QName, String>();

    /**
     * Gets the value of the reportServerVersionNumber property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportServerVersionNumber() {
        return reportServerVersionNumber;
    }

    /**
     * Sets the value of the reportServerVersionNumber property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportServerVersionNumber(String value) {
        this.reportServerVersionNumber = value;
    }

    /**
     * Gets the value of the reportServerEdition property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportServerEdition() {
        return reportServerEdition;
    }

    /**
     * Sets the value of the reportServerEdition property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportServerEdition(String value) {
        this.reportServerEdition = value;
    }

    /**
     * Gets the value of the reportServerVersion property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportServerVersion() {
        return reportServerVersion;
    }

    /**
     * Sets the value of the reportServerVersion property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportServerVersion(String value) {
        this.reportServerVersion = value;
    }

    /**
     * Gets the value of the reportServerDateTime property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReportServerDateTime() {
        return reportServerDateTime;
    }

    /**
     * Sets the value of the reportServerDateTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReportServerDateTime(String value) {
        this.reportServerDateTime = value;
    }

    /**
     * Gets a map that contains attributes that aren't bound to any typed property on this class.
     * 
     * <p>
     * the map is keyed by the name of the attribute and 
     * the value is the string value of the attribute.
     * 
     * the map returned by this method is live, and you can add new attribute
     * by updating the map directly. Because of this design, there's no setter.
     * 
     * 
     * @return
     *     always non-null
     */
    public Map<QName, String> getOtherAttributes() {
        return otherAttributes;
    }

}
