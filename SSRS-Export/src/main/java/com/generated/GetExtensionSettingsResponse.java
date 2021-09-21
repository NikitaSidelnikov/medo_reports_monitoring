
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
 *         &lt;element name="ExtensionParameters" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfExtensionParameter" minOccurs="0"/&gt;
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
    "extensionParameters"
})
@XmlRootElement(name = "GetExtensionSettingsResponse")
public class GetExtensionSettingsResponse {

    @XmlElement(name = "ExtensionParameters")
    protected ArrayOfExtensionParameter extensionParameters;

    /**
     * Gets the value of the extensionParameters property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfExtensionParameter }
     *     
     */
    public ArrayOfExtensionParameter getExtensionParameters() {
        return extensionParameters;
    }

    /**
     * Sets the value of the extensionParameters property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfExtensionParameter }
     *     
     */
    public void setExtensionParameters(ArrayOfExtensionParameter value) {
        this.extensionParameters = value;
    }

}
