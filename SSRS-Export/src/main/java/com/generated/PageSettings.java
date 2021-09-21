
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for PageSettings complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="PageSettings"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="PaperSize" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ReportPaperSize" minOccurs="0"/&gt;
 *         &lt;element name="Margins" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ReportMargins" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "PageSettings", propOrder = {
    "paperSize",
    "margins"
})
public class PageSettings {

    @XmlElement(name = "PaperSize")
    protected ReportPaperSize paperSize;
    @XmlElement(name = "Margins")
    protected ReportMargins margins;

    /**
     * Gets the value of the paperSize property.
     * 
     * @return
     *     possible object is
     *     {@link ReportPaperSize }
     *     
     */
    public ReportPaperSize getPaperSize() {
        return paperSize;
    }

    /**
     * Sets the value of the paperSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link ReportPaperSize }
     *     
     */
    public void setPaperSize(ReportPaperSize value) {
        this.paperSize = value;
    }

    /**
     * Gets the value of the margins property.
     * 
     * @return
     *     possible object is
     *     {@link ReportMargins }
     *     
     */
    public ReportMargins getMargins() {
        return margins;
    }

    /**
     * Sets the value of the margins property.
     * 
     * @param value
     *     allowed object is
     *     {@link ReportMargins }
     *     
     */
    public void setMargins(ReportMargins value) {
        this.margins = value;
    }

}
