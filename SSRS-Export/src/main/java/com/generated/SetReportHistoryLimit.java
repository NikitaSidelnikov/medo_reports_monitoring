
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
 *         &lt;element name="UseSystem" type="{http://www.w3.org/2001/XMLSchema}boolean"/&gt;
 *         &lt;element name="HistoryLimit" type="{http://www.w3.org/2001/XMLSchema}int"/&gt;
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
    "useSystem",
    "historyLimit"
})
@XmlRootElement(name = "SetReportHistoryLimit")
public class SetReportHistoryLimit {

    @XmlElement(name = "Report")
    protected String report;
    @XmlElement(name = "UseSystem")
    protected boolean useSystem;
    @XmlElement(name = "HistoryLimit")
    protected int historyLimit;

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
     * Gets the value of the useSystem property.
     * 
     */
    public boolean isUseSystem() {
        return useSystem;
    }

    /**
     * Sets the value of the useSystem property.
     * 
     */
    public void setUseSystem(boolean value) {
        this.useSystem = value;
    }

    /**
     * Gets the value of the historyLimit property.
     * 
     */
    public int getHistoryLimit() {
        return historyLimit;
    }

    /**
     * Sets the value of the historyLimit property.
     * 
     */
    public void setHistoryLimit(int value) {
        this.historyLimit = value;
    }

}
