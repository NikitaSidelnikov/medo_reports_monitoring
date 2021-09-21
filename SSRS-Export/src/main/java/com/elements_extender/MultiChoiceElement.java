package com.elements_extender;

import com.elements_extender.auxiliary_classes.ComboBoxItemWrap;
import com.generated.ReportParameter;
import com.generated.ValidValue;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.control.*;
import javafx.scene.input.MouseEvent;
import javafx.util.Callback;

import java.util.ArrayList;
import java.util.List;

public class MultiChoiceElement extends ParamElement {

    private final ComboBox<ComboBoxItemWrap> paramChoice = new ComboBox<>();
    private final List<String> listValues = new ArrayList<>();

    public MultiChoiceElement(ReportParameter param) {
        setParam(param);

        paramChoice.getStylesheets().add("fxml/style.css");
        //paramChoice.setEditable(true);
        paramChoice.setMaxWidth(200);
        paramChoice.setPlaceholder(new Label("Nothing"));
        createCellFactory();

        this.initialize();
        this.addElement(paramChoice);
    }

    @Override
    public void setParam(ReportParameter param) {
        this.param = param;
        paramChoice.getItems().clear();

        final ObservableList<ComboBoxItemWrap> paramList = FXCollections.observableArrayList();
        if(param.getValidValues() != null) {
            final List<ValidValue> validValues = param.getValidValues().getValidValue();
            if (validValues.size() != 0)
                for (ValidValue item : validValues)
                    paramList.add(new ComboBoxItemWrap(item));
        }
       /* paramChoice.getEditor().textProperty().addListener((observableValue, s, t1) -> {
            String paramNameEditor = t1.toLowerCase();

            final ObservableList<ComboBoxItemWrap> paramList_2 = FXCollections.observableArrayList();

            if(param.getValidValues() != null) {
                final List<ValidValue> validValues = param.getValidValues().getValidValue();
                if (validValues.size() != 0)
                    for (ValidValue item : validValues) {
                        ComboBoxItemWrap comboBoxItemWrap = new ComboBoxItemWrap(item);
                        if (comboBoxItemWrap.getLabel().toLowerCase().contains(paramNameEditor))
                            paramList_2.add(comboBoxItemWrap);
                    }
            }
            paramChoice.setItems(paramList_2);
            paramChoice.show();
        });*/
        paramChoice.setItems(paramList);
    }

    @Override
    public void setDestinationValue(List<String> paramValueList) {
        this.paramValueList = paramValueList;
        final StringBuilder sb = new StringBuilder();

        for (ComboBoxItemWrap boxItem : paramChoice.getItems()) {
            boxItem.setCheckProperty(false);
            for(String value : paramValueList) {
                if (boxItem.getValue().equals(value)) {
                    boxItem.setCheckProperty(true);
                    sb.append("; ").append(boxItem.getLabel());
                }
            }
        }

        final String buttonCellText = sb.toString();
        paramChoice.getButtonCell().setText(buttonCellText.substring(Integer.min(2, buttonCellText.length())));
    }

    private void setValue(){
        modified = true;
        paramValueList = listValues;
    }

    private void createCellFactory(){
        paramChoice.setButtonCell(new ListCell<>());

        paramChoice.setCellFactory(new Callback<>() {
            @Override
            public ListCell<ComboBoxItemWrap> call(ListView<ComboBoxItemWrap> stringListView) {
                final ListCell<ComboBoxItemWrap> cell = new ListCell<>() {
                    @Override
                    protected void updateItem(ComboBoxItemWrap item, boolean empty) {
                        super.updateItem(item, empty);
                        if (!empty) {
                            final CheckBox cb = new CheckBox(item.getLabel());
                            cb.getStylesheets().add("fxml/style.css");
                            cb.selectedProperty().bind(item.getCheckProperty());

                            setGraphic(cb);
                        }
                        if (paramChoice.getSelectionModel().getSelectedIndex() != -1)
                            paramChoice.getSelectionModel().clearSelection();
                    }
                };


                cell.addEventFilter(MouseEvent.MOUSE_RELEASED, event -> {
                    cell.getItem().getCheckProperty().set(!cell.getItem().getCheckProperty().get());
                    final StringBuilder sb = new StringBuilder();
                    listValues.clear();
                    paramChoice.getItems().filtered( f-> f!=null).filtered( f-> f.getCheck()).forEach( p -> {
                        sb.append("; ").append(p.getLabel());
                        listValues.add(p.getValue());
                    });
                    final String buttonText = sb.toString();

                    paramChoice.getButtonCell().setText(buttonText.substring(Integer.min(2, buttonText.length())));
                    paramChoice.show();
                    setValue();
                });

                return cell;
            }
        });
    }
}

