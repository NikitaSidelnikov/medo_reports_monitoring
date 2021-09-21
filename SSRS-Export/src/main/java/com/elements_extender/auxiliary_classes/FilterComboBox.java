package com.elements_extender.auxiliary_classes;

import javafx.beans.property.ObjectProperty;
import javafx.beans.property.SimpleObjectProperty;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.control.ComboBox;
import javafx.scene.control.skin.ComboBoxListViewSkin;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.util.StringConverter;

import java.util.ArrayList;
import java.util.List;

public class FilterComboBox<Object> extends ComboBox<Object> {

    private final ObjectProperty<Object> selectedValidValue = new SimpleObjectProperty<>();
    private final List<Object> objectList = new ArrayList<Object>();
    private boolean updatingFlag = false;
    private boolean clearingSelectionFlag = false;
    private int defaultVisibleRowCount = 10;
    private boolean strictCompare = false;

    public FilterComboBox() {
        this.setEditable(false);

    /*
        addEventFilter for catch typing of space, because list close after space pressed
    */
        ComboBoxListViewSkin<Object> comboBoxListViewSkin = new ComboBoxListViewSkin<>(this);
        comboBoxListViewSkin.getPopupContent().addEventFilter(KeyEvent.ANY, (event) -> {
            if (event.getCode() == KeyCode.SPACE) {
                event.consume();
            }
            if (event.getCode() == KeyCode.TAB) { //press tab for select first row list
                this.getSelectionModel().clearAndSelect(0);
                this.hide();
            }
        });
        this.setSkin(comboBoxListViewSkin);


    /*
        setOnHidden for updating listCell
    */
        this.setOnHidden(event -> {
            if(updatingFlag)
                return;
            if(this.getSelectionModel().getSelectedItem() != null){
                selectedValidValue.set(this.getSelectionModel().getSelectedItem());

                clearingSelectionFlag = true;
                this.getSelectionModel().clearSelection();
            }
            this.setEditable(false);        //disable editing of combobox after hiding list
            this.getEditor().setText("");   //clear text from editor after hiding list

            //set default list
            final ObservableList<Object> paramList_2 = FXCollections.observableArrayList();
            paramList_2.addAll(objectList);
            this.setItems(paramList_2);
            this.setValue(selectedValidValue.get());
            this.setVisibleRowCount(defaultVisibleRowCount);
        });

    /*
        setOnShowing for updating listCell
    */
        this.setOnShowing(event -> {
            if(updatingFlag){
                updatingFlag = false;
                return;
            }
            this.setValue(null);     //clear list's selected row for write user's filter value
            this.setEditable(true);  //enable editing of combobox after showing list
        });

    /*
        listening all changes in editor and filtering of list according to written text
    */
        this.getEditor().textProperty().addListener((observableValue, s, t1) -> {
            final ObservableList<Object> objectObservableList = FXCollections.observableArrayList();
            objectObservableList.addAll(objectList);

            if (this.getSelectionModel().getSelectedItem() != null || clearingSelectionFlag) {
                clearingSelectionFlag = false;
                return;
            }
            String filterValue = t1.toLowerCase();

            if (objectList.size() != 0)
                for (Object item : objectList)
                    if(!compare(item, filterValue))
                        objectObservableList.remove(item);

            updatingFlag = true;
            this.hide(); //before set new visibleRowCount value
            if (objectObservableList.size() > defaultVisibleRowCount)
                this.setVisibleRowCount(defaultVisibleRowCount);
            else
                this.setVisibleRowCount(objectObservableList.size());
            this.setItems(objectObservableList);
            this.show();
        });
    }

    private boolean compare(Object objectRow, String filterValue){
        StringConverter<Object> converter = this.getConverter();
        filterValue = filterValue.toLowerCase();
        if(this.getConverter() != null) {
            String objectValue = converter.toString(objectRow);
            objectValue = objectValue.toLowerCase();
            if(strictCompare)
                return objectValue.indexOf(filterValue) == 0;
            else
                return objectValue.contains(filterValue);
        }
        else if(objectRow instanceof String) {
            String objectValue = ((String) objectRow);
            objectValue = objectValue.toLowerCase();
            if(strictCompare)
                return objectValue.indexOf(filterValue) == 0;
            else
                return objectValue.contains(filterValue);
        }
        return false;
    }

    public void setDefaultVisibleRowCount(int defaultVisibleRowCount){
        this.defaultVisibleRowCount = defaultVisibleRowCount;
    }

    public void updateList(List<Object> objectList){
        this.objectList.clear();
        this.objectList.addAll(objectList);
        this.setItems(FXCollections.observableList(objectList));
    }

    public Object getSelectedValue(){
        return selectedValidValue.get();
    }
    public ObjectProperty<Object> selectedValueProperty(){
        return selectedValidValue;
    }

    public boolean isStrictCompare() {
        return strictCompare;
    }

    public void setStrictCompare(boolean strictCompare) {
        this.strictCompare = strictCompare;
    }
}
