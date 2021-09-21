
package com.generated;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ReportParameter complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ReportParameter"&gt;
 *   &lt;complexContent&gt;
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType"&gt;
 *       &lt;sequence&gt;
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="Type" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ParameterTypeEnum" minOccurs="0"/&gt;
 *         &lt;element name="Nullable" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="AllowBlank" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="MultiValue" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="QueryParameter" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="Prompt" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *         &lt;element name="PromptUser" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="Dependencies" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfString1" minOccurs="0"/&gt;
 *         &lt;element name="ValidValuesQueryBased" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="ValidValues" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfValidValue" minOccurs="0"/&gt;
 *         &lt;element name="DefaultValuesQueryBased" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/&gt;
 *         &lt;element name="DefaultValues" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ArrayOfString2" minOccurs="0"/&gt;
 *         &lt;element name="State" type="{http://schemas.microsoft.com/sqlserver/2005/06/30/reporting/reportingservices}ParameterStateEnum" minOccurs="0"/&gt;
 *         &lt;element name="ErrorMessage" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/&gt;
 *       &lt;/sequence&gt;
 *     &lt;/restriction&gt;
 *   &lt;/complexContent&gt;
 * &lt;/complexType&gt;
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ReportParameter", propOrder = {
    "name",
    "type",
    "nullable",
    "allowBlank",
    "multiValue",
    "queryParameter",
    "prompt",
    "promptUser",
    "dependencies",
    "validValuesQueryBased",
    "validValues",
    "defaultValuesQueryBased",
    "defaultValues",
    "state",
    "errorMessage"
})
public class ReportParameter {

    @XmlElement(name = "Name")
    protected String name;
    @XmlElement(name = "Type")
    @XmlSchemaType(name = "string")
    protected ParameterTypeEnum type;
    @XmlElement(name = "Nullable")
    protected Boolean nullable;
    @XmlElement(name = "AllowBlank")
    protected Boolean allowBlank;
    @XmlElement(name = "MultiValue")
    protected Boolean multiValue;
    @XmlElement(name = "QueryParameter")
    protected Boolean queryParameter;
    @XmlElement(name = "Prompt")
    protected String prompt;
    @XmlElement(name = "PromptUser")
    protected Boolean promptUser;
    @XmlElement(name = "Dependencies")
    protected ArrayOfString1 dependencies;
    @XmlElement(name = "ValidValuesQueryBased")
    protected Boolean validValuesQueryBased;
    @XmlElement(name = "ValidValues")
    protected ArrayOfValidValue validValues;
    @XmlElement(name = "DefaultValuesQueryBased")
    protected Boolean defaultValuesQueryBased;
    @XmlElement(name = "DefaultValues")
    protected ArrayOfString2 defaultValues;
    @XmlElement(name = "State")
    @XmlSchemaType(name = "string")
    protected ParameterStateEnum state;
    @XmlElement(name = "ErrorMessage")
    protected String errorMessage;

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link ParameterTypeEnum }
     *     
     */
    public ParameterTypeEnum getType() {
        return type;
    }

    /**
     * Sets the value of the type property.
     * 
     * @param value
     *     allowed object is
     *     {@link ParameterTypeEnum }
     *     
     */
    public void setType(ParameterTypeEnum value) {
        this.type = value;
    }

    /**
     * Gets the value of the nullable property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isNullable() {
        return nullable;
    }

    /**
     * Sets the value of the nullable property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setNullable(Boolean value) {
        this.nullable = value;
    }

    /**
     * Gets the value of the allowBlank property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isAllowBlank() {
        return allowBlank;
    }

    /**
     * Sets the value of the allowBlank property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setAllowBlank(Boolean value) {
        this.allowBlank = value;
    }

    /**
     * Gets the value of the multiValue property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isMultiValue() {
        return multiValue;
    }

    /**
     * Sets the value of the multiValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setMultiValue(Boolean value) {
        this.multiValue = value;
    }

    /**
     * Gets the value of the queryParameter property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isQueryParameter() {
        return queryParameter;
    }

    /**
     * Sets the value of the queryParameter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setQueryParameter(Boolean value) {
        this.queryParameter = value;
    }

    /**
     * Gets the value of the prompt property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPrompt() {
        return prompt;
    }

    /**
     * Sets the value of the prompt property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPrompt(String value) {
        this.prompt = value;
    }

    /**
     * Gets the value of the promptUser property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isPromptUser() {
        return promptUser;
    }

    /**
     * Sets the value of the promptUser property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setPromptUser(Boolean value) {
        this.promptUser = value;
    }

    /**
     * Gets the value of the dependencies property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfString1 }
     *     
     */
    public ArrayOfString1 getDependencies() {
        return dependencies;
    }

    /**
     * Sets the value of the dependencies property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfString1 }
     *     
     */
    public void setDependencies(ArrayOfString1 value) {
        this.dependencies = value;
    }

    /**
     * Gets the value of the validValuesQueryBased property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isValidValuesQueryBased() {
        return validValuesQueryBased;
    }

    /**
     * Sets the value of the validValuesQueryBased property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setValidValuesQueryBased(Boolean value) {
        this.validValuesQueryBased = value;
    }

    /**
     * Gets the value of the validValues property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfValidValue }
     *     
     */
    public ArrayOfValidValue getValidValues() {
        return validValues;
    }

    /**
     * Sets the value of the validValues property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfValidValue }
     *     
     */
    public void setValidValues(ArrayOfValidValue value) {
        this.validValues = value;
    }

    /**
     * Gets the value of the defaultValuesQueryBased property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDefaultValuesQueryBased() {
        return defaultValuesQueryBased;
    }

    /**
     * Sets the value of the defaultValuesQueryBased property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDefaultValuesQueryBased(Boolean value) {
        this.defaultValuesQueryBased = value;
    }

    /**
     * Gets the value of the defaultValues property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfString2 }
     *     
     */
    public ArrayOfString2 getDefaultValues() {
        return defaultValues;
    }

    /**
     * Sets the value of the defaultValues property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfString2 }
     *     
     */
    public void setDefaultValues(ArrayOfString2 value) {
        this.defaultValues = value;
    }

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link ParameterStateEnum }
     *     
     */
    public ParameterStateEnum getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link ParameterStateEnum }
     *     
     */
    public void setState(ParameterStateEnum value) {
        this.state = value;
    }

    /**
     * Gets the value of the errorMessage property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getErrorMessage() {
        return errorMessage;
    }

    /**
     * Sets the value of the errorMessage property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setErrorMessage(String value) {
        this.errorMessage = value;
    }

}
