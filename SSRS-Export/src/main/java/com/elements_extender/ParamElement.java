package com.elements_extender;

import com.generated.ReportParameter;
import javafx.beans.property.BooleanProperty;
import javafx.beans.property.SimpleBooleanProperty;
import javafx.geometry.Pos;
import javafx.scene.Group;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.HBox;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import javafx.scene.text.Text;

import java.util.List;


public class ParamElement extends AnchorPane implements ParamElementInterface {
    private final HBox hBox = new HBox();
    private final Label mandatoryLabel = new Label("*");
    private final Label paramLabel = new Label();

    protected ReportParameter param;
    protected String paramValue;
    protected List<String> paramValueList;
    protected Boolean modified = false;

    private BooleanProperty nodeFocusFlag;
    private Boolean mandatory = true;

    protected void initialize(){
        paramLabel.setAlignment(Pos.BASELINE_LEFT);
        paramLabel.setFont(new Font("Tahoma", 12));
        paramLabel.setText(param.getPrompt());
        setLabelSize(getLabelSize());

        //System.out.println("Param: " + param.getName() + "\n isNullable - " + param.isNullable()+ "\n isMultiValue - " + param.isMultiValue()+ "\n isQueryParameter - " + param.isQueryParameter() + "\n isDefaultValuesQueryBased - " + param.isDefaultValuesQueryBased()+ "\n isValidValuesQueryBased - " + param.isValidValuesQueryBased());

        mandatoryLabel.setTextFill(Color.RED);
        mandatoryLabel.setFont(new Font(15));
        if(param.isNullable() || param.isDefaultValuesQueryBased()) {
            mandatoryLabel.setVisible(false);
            mandatory = false;
        }

        hBox.getChildren().addAll(mandatoryLabel, paramLabel);
        this.getChildren().add(hBox);
    }

    protected void addElement(Node node){
        hBox.getChildren().add(node);
        if(param.getDependencies()!=null && param.isValidValuesQueryBased()) {
            nodeFocusFlag = new SimpleBooleanProperty();
            nodeFocusFlag.set(false);
            node.focusedProperty().addListener((observableValue, aBoolean, t1) -> {
                if(node.isFocused())
                    nodeFocusFlag.set(!nodeFocusFlag.get()); //pick flag
            });
        }
    }

    @Override
    public void setParam(ReportParameter param) { this.param = param; }
    @Override
    public void setDestinationValue(String paramValue) { this.paramValue = paramValue; }
    @Override
    public void setDestinationValue(List<String> paramValueList) { this.paramValueList = paramValueList; }

    public void setLabelSize(double width){
        paramLabel.setPrefWidth(width);
    }

    public double getLabelSize(){
        final Text text = new Text(paramLabel.getText());
        new Scene(new Group(text));
        text.applyCss();
        final double width = text.getLayoutBounds().getWidth();
        return width + 10;
    }


    public void setModified(Boolean modified) {
        this.modified = modified;
    }
    public Boolean getModified() {
        return modified;
    }

    public ReportParameter getParam() { return param; }
    public String getParamName() {
        return param.getName();
    }
    public String getParamPrompt() {
        return param.getPrompt();
    }
    public List<String> getParamDependenciesList() {
        return param.getDependencies().getDependency();
    }
    public boolean isMultiValue() {
        return param.isMultiValue();
    }
    public boolean haveDependencies() {
        return (param.getDependencies()!=null && param.isValidValuesQueryBased());
    }

    public String getParamValue() {
        return paramValue;
    }
    public List<String> getParamValueList() {
        return paramValueList;
    }

    public boolean getMandatory() {
        return mandatory;
    }

    public BooleanProperty focusProperty() {
        return nodeFocusFlag;
    }
}
