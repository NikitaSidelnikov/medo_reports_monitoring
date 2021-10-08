package com.elements_extender;

import com.generated.ReportParameter;
import javafx.scene.control.DatePicker;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

public class DateElement extends ParamElement {
    private final DatePicker paramDate = new DatePicker();

    public DateElement(ReportParameter param) {
        setParam(param);

        paramDate.getStylesheets().add("fxml/style.css");

        paramDate.focusedProperty().addListener((observableValue, s, t1) -> {
            SimpleDateFormat dtf = new SimpleDateFormat("MM/dd/yyyy");
            //DateTimeFormatter dtf = DateTimeFormatter.ofPattern("dd.MM.yyyy");
            Date date = null;
            LocalDate dt;
            try {
                final SimpleDateFormat parser = new SimpleDateFormat("MM/dd/yyyy");
                date = parser.parse(paramDate.getEditor().getText());
                dt = date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
                //dt = LocalDate.parse(paramDate.getEditor().getText(), dtf);
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

            try {
                //dtf = DateTimeFormatter.ofPattern("MM/dd/yyyy");
                final SimpleDateFormat parser = new SimpleDateFormat("MM/dd/yyyy");
                if(date==null) {
                    date = parser.parse(paramDate.getEditor().getText());
                    dt = date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
                    //dt = LocalDate.parse(paramDate.getEditor().getText(), dtf);
                    paramDate.setValue(dt);
                    if (!paramDate.getValue().toString().equals(this.paramValue)) {
                        setValue(paramDate.getValue());
                    }
                    paramDate.setStyle("");
                }
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
            LocalDate dt = null;
            Date date = null;
            try {
                final SimpleDateFormat parser = new SimpleDateFormat("MM/dd/yyyy");
                date = parser.parse(defaultDate);
            }
            catch (Exception e) { e.printStackTrace(); }
            try {
                final SimpleDateFormat parser = new SimpleDateFormat("dd.MM.yyyy");
                if(date==null)
                    date = parser.parse(defaultDate);
            }
            catch (Exception e) { e.printStackTrace(); }

            if(date!=null) {
                dt = date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
                paramDate.setValue(dt);
                setValue(paramDate.getValue());
            }
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

