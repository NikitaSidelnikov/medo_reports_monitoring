
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *         &lt;element name="SecurityScope" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}SecurityScopeEnum"/&gt;
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
    "securityScope"
})
@XmlRootElement(name = "ListRoles")
public class ListRoles {

    @XmlElement(name = "SecurityScope", required = true)
    @XmlSchemaType(name = "string")
    protected SecurityScopeEnum securityScope;

    /**
     * Gets the value of the securityScope property.
     * 
     * @return
     *     possible object is
     *     {@link SecurityScopeEnum }
     *     
     */
    public SecurityScopeEnum getSecurityScope() {
        return securityScope;
    }

    /**
     * Sets the value of the securityScope property.
     * 
     * @param value
     *     allowed object is
     *     {@link SecurityScopeEnum }
     *     
     */
    public void setSecurityScope(SecurityScopeEnum value) {
        this.securityScope = value;
    }

}
