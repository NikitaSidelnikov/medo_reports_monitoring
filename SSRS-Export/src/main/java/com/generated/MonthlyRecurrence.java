
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for MonthlyRecurrence complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="MonthlyRecurrence"&gt;
 *   &lt;complexContent&gt;
 *     &lt;extension base="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}RecurrencePattern"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Days" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="MonthsOfYear" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}MonthsOfYearSelector" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/extension&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MonthlyRecurrence", propOrder = {
    "days",
    "monthsOfYear"
})
public class MonthlyRecurrence
    extends RecurrencePattern
{

    @XmlElement(name = "Days")
    protected String days;
    @XmlElement(name = "MonthsOfYear")
    protected MonthsOfYearSelector monthsOfYear;

    /**
     * Gets the value of the days property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDays() {
        return days;
    }

    /**
     * Sets the value of the days property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDays(String value) {
        this.days = value;
    }

    /**
     * Gets the value of the monthsOfYear property.
     * 
     * @return
     *     possible object is
     *     {@link MonthsOfYearSelector }
     *     
     */
    public MonthsOfYearSelector getMonthsOfYear() {
        return monthsOfYear;
    }

    /**
     * Sets the value of the monthsOfYear property.
     * 
     * @param value
     *     allowed object is
     *     {@link MonthsOfYearSelector }
     *     
     */
    public void setMonthsOfYear(MonthsOfYearSelector value) {
        this.monthsOfYear = value;
    }

}
