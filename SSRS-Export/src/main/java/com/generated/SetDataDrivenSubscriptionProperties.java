
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
 *         &lt;element name="DataDrivenSubscriptionID" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="ExtensionSettings" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ExtensionSettings" minOccurs="0"/&gt;
 *         &lt;element name="DataRetrievalPlan" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}DataRetrievalPlan" minOccurs="0"/&gt;
 *         &lt;element name="Description" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="EventType" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="MatchData" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Parameters" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfParameterValueOrFieldReference" minOccurs="0"/&gt;
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
    "dataDrivenSubscriptionID",
    "extensionSettings",
    "dataRetrievalPlan",
    "description",
    "eventType",
    "matchData",
    "parameters"
})
@XmlRootElement(name = "SetDataDrivenSubscriptionProperties")
public class SetDataDrivenSubscriptionProperties {

    @XmlElement(name = "DataDrivenSubscriptionID")
    protected String dataDrivenSubscriptionID;
    @XmlElement(name = "ExtensionSettings")
    protected ExtensionSettings extensionSettings;
    @XmlElement(name = "DataRetrievalPlan")
    protected DataRetrievalPlan dataRetrievalPlan;
    @XmlElement(name = "Description")
    protected String description;
    @XmlElement(name = "EventType")
    protected String eventType;
    @XmlElement(name = "MatchData")
    protected String matchData;
    @XmlElement(name = "Parameters")
    protected ArrayOfParameterValueOrFieldReference parameters;

    /**
     * Gets the value of the dataDrivenSubscriptionID property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDataDrivenSubscriptionID() {
        return dataDrivenSubscriptionID;
    }

    /**
     * Sets the value of the dataDrivenSubscriptionID property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDataDrivenSubscriptionID(String value) {
        this.dataDrivenSubscriptionID = value;
    }

    /**
     * Gets the value of the extensionSettings property.
     * 
     * @return
     *     possible object is
     *     {@link ExtensionSettings }
     *     
     */
    public ExtensionSettings getExtensionSettings() {
        return extensionSettings;
    }

    /**
     * Sets the value of the extensionSettings property.
     * 
     * @param value
     *     allowed object is
     *     {@link ExtensionSettings }
     *     
     */
    public void setExtensionSettings(ExtensionSettings value) {
        this.extensionSettings = value;
    }

    /**
     * Gets the value of the dataRetrievalPlan property.
     * 
     * @return
     *     possible object is
     *     {@link DataRetrievalPlan }
     *     
     */
    public DataRetrievalPlan getDataRetrievalPlan() {
        return dataRetrievalPlan;
    }

    /**
     * Sets the value of the dataRetrievalPlan property.
     * 
     * @param value
     *     allowed object is
     *     {@link DataRetrievalPlan }
     *     
     */
    public void setDataRetrievalPlan(DataRetrievalPlan value) {
        this.dataRetrievalPlan = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDescription(String value) {
        this.description = value;
    }

    /**
     * Gets the value of the eventType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEventType() {
        return eventType;
    }

    /**
     * Sets the value of the eventType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEventType(String value) {
        this.eventType = value;
    }

    /**
     * Gets the value of the matchData property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMatchData() {
        return matchData;
    }

    /**
     * Sets the value of the matchData property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMatchData(String value) {
        this.matchData = value;
    }

    /**
     * Gets the value of the parameters property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfParameterValueOrFieldReference }
     *     
     */
    public ArrayOfParameterValueOrFieldReference getParameters() {
        return parameters;
    }

    /**
     * Sets the value of the parameters property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfParameterValueOrFieldReference }
     *     
     */
    public void setParameters(ArrayOfParameterValueOrFieldReference value) {
        this.parameters = value;
    }

}
