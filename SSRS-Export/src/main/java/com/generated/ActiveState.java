
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ActiveState complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ActiveState"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="DeliveryExtensionRemoved" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="SharedDataSourceRemoved" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="MissingParameterValue" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="InvalidParameterValue" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="UnknownReportParameter" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ActiveState", propOrder = {
    "deliveryExtensionRemoved",
    "sharedDataSourceRemoved",
    "missingParameterValue",
    "invalidParameterValue",
    "unknownReportParameter"
})
public class ActiveState {

    @XmlElement(name = "DeliveryExtensionRemoved")
    protected Boolean deliveryExtensionRemoved;
    @XmlElement(name = "SharedDataSourceRemoved")
    protected Boolean sharedDataSourceRemoved;
    @XmlElement(name = "MissingParameterValue")
    protected Boolean missingParameterValue;
    @XmlElement(name = "InvalidParameterValue")
    protected Boolean invalidParameterValue;
    @XmlElement(name = "UnknownReportParameter")
    protected Boolean unknownReportParameter;

    /**
     * Gets the value of the deliveryExtensionRemoved property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDeliveryExtensionRemoved() {
        return deliveryExtensionRemoved;
    }

    /**
     * Sets the value of the deliveryExtensionRemoved property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDeliveryExtensionRemoved(Boolean value) {
        this.deliveryExtensionRemoved = value;
    }

    /**
     * Gets the value of the sharedDataSourceRemoved property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSharedDataSourceRemoved() {
        return sharedDataSourceRemoved;
    }

    /**
     * Sets the value of the sharedDataSourceRemoved property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSharedDataSourceRemoved(Boolean value) {
        this.sharedDataSourceRemoved = value;
    }

    /**
     * Gets the value of the missingParameterValue property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isMissingParameterValue() {
        return missingParameterValue;
    }

    /**
     * Sets the value of the missingParameterValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setMissingParameterValue(Boolean value) {
        this.missingParameterValue = value;
    }

    /**
     * Gets the value of the invalidParameterValue property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isInvalidParameterValue() {
        return invalidParameterValue;
    }

    /**
     * Sets the value of the invalidParameterValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setInvalidParameterValue(Boolean value) {
        this.invalidParameterValue = value;
    }

    /**
     * Gets the value of the unknownReportParameter property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isUnknownReportParameter() {
        return unknownReportParameter;
    }

    /**
     * Sets the value of the unknownReportParameter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setUnknownReportParameter(Boolean value) {
        this.unknownReportParameter = value;
    }

}
