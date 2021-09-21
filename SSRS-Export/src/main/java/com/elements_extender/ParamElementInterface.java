package com.elements_extender;

import com.generated.ReportParameter;

import java.util.List;

interface ParamElementInterface {
//    void setModified(Boolean modified);
//    Boolean getModified();

    void setParam(ReportParameter param);
//    ReportParameter getParam();

//    String getParamName();
//    String getParamPrompt();
//    List<String> getParamDependenciesList();
//    boolean haveDependencies();
//    boolean isMultiValue();

    void setDestinationValue(String paramValue);
    void setDestinationValue(List<String> paramValueList);

//    String getParamValue();
//    List<String> getParamValueList();
//
//    boolean getMandatory();
//    BooleanProperty focusProperty();
}
