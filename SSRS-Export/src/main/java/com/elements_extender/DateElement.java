package com.elements_extender;

import com.generated.ReportParameter;
import javafx.scene.control.DatePicker;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class DateElement extends ParamElement {
    private final DatePicker paramDate = new DatePicker();

    public DateElement(ReportParameter param) {
        setParam(param);

        paramDate.getStylesheets().add("fxml/style.css");

        paramDate.focusedProperty().addListener((observableValue, s, t1) -> {
            final DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd.MM.yyyy");
            final LocalDate dt;
            try {
                dt = LocalDate.parse(paramDate.getEditor().getText(), dtf);
                paramDate.setValue(dt);
                if(!paramDate.getValue().toString().equals(this.paramValue)) {
                    setValue(paramDate.getValue());
                }
                paramDate.setStyle("");
            }
            catch (Exception e){
                paramDate.setStyle("-fx-border-color: red; -fx-text-inner-color: red;");
                setValue(null);
            }
        });

        this.initialize();
        this.addElement(paramDate);
    }

    @Override
    public void setParam(ReportParameter param) {
        this.param = param;

        if(param.isDefaultValuesQueryBased()) {
            String defaultDate = param.getDefaultValues().getValue().get(0);
            defaultDate = defaultDate.substring(0 , 10);
            final DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd.MM.yyyy");
            final LocalDate dt = LocalDate.parse(defaultDate, dtf);

            paramDate.setValue(dt);
            setValue(paramDate.getValue());
        }
    }

    @Override
    public void setDestinationValue(String paramValue) {
        this.paramValue = paramValue;
        final DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        final LocalDate dt = LocalDate.parse(paramValue, dtf);

        paramDate.setValue(dt);
    }

    private void setValue(LocalDate value){
        modified = true;
        if (value != null)
            this.paramValue = value.toString();
        else
            this.paramValue = null;
    }
}

