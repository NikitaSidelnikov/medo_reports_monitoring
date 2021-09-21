
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
 *         &lt;element name="ExecutionSetting" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ExecutionSettingEnum"/&gt;
 *         &lt;choice&gt;
 *           &lt;element name="NoSchedule" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}NoSchedule" minOccurs="0"/&gt;
 *           &lt;element name="ScheduleReference" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleReference" minOccurs="0"/&gt;
 *           &lt;element name="ScheduleDefinition" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ScheduleDefinition" minOccurs="0"/&gt;
 *         &lt;/choice&gt;
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
    "executionSetting",
    "noSchedule",
    "scheduleReference",
    "scheduleDefinition"
})
@XmlRootElement(name = "GetExecutionOptionsResponse")
public class GetExecutionOptionsResponse {

    @XmlElement(name = "ExecutionSetting", required = true)
    @XmlSchemaType(name = "string")
    protected ExecutionSettingEnum executionSetting;
    @XmlElement(name = "NoSchedule")
    protected NoSchedule noSchedule;
    @XmlElement(name = "ScheduleReference")
    protected ScheduleReference scheduleReference;
    @XmlElement(name = "ScheduleDefinition")
    protected ScheduleDefinition scheduleDefinition;

    /**
     * Gets the value of the executionSetting property.
     * 
     * @return
     *     possible object is
     *     {@link ExecutionSettingEnum }
     *     
     */
    public ExecutionSettingEnum getExecutionSetting() {
        return executionSetting;
    }

    /**
     * Sets the value of the executionSetting property.
     * 
     * @param value
     *     allowed object is
     *     {@link ExecutionSettingEnum }
     *     
     */
    public void setExecutionSetting(ExecutionSettingEnum value) {
        this.executionSetting = value;
    }

    /**
     * Gets the value of the noSchedule property.
     * 
     * @return
     *     possible object is
     *     {@link NoSchedule }
     *     
     */
    public NoSchedule getNoSchedule() {
        return noSchedule;
    }

    /**
     * Sets the value of the noSchedule property.
     * 
     * @param value
     *     allowed object is
     *     {@link NoSchedule }
     *     
     */
    public void setNoSchedule(NoSchedule value) {
        this.noSchedule = value;
    }

    /**
     * Gets the value of the scheduleReference property.
     * 
     * @return
     *     possible object is
     *     {@link ScheduleReference }
     *     
     */
    public ScheduleReference getScheduleReference() {
        return scheduleReference;
    }

    /**
     * Sets the value of the scheduleReference property.
     * 
     * @param value
     *     allowed object is
     *     {@link ScheduleReference }
     *     
     */
    public void setScheduleReference(ScheduleReference value) {
        this.scheduleReference = value;
    }

    /**
     * Gets the value of the scheduleDefinition property.
     * 
     * @return
     *     possible object is
     *     {@link ScheduleDefinition }
     *     
     */
    public ScheduleDefinition getScheduleDefinition() {
        return scheduleDefinition;
    }

    /**
     * Sets the value of the scheduleDefinition property.
     * 
     * @param value
     *     allowed object is
     *     {@link ScheduleDefinition }
     *     
     */
    public void setScheduleDefinition(ScheduleDefinition value) {
        this.scheduleDefinition = value;
    }

}
