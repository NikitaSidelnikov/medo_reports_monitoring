package com.Controller;


import com.AppProperties;
import com.GUI.Alert.ErrorAlert;
import com.GUI.Alert.WarningAlert;
import com.GUI.AuthGUI;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.stage.DirectoryChooser;
import javafx.stage.Stage;
import org.apache.commons.validator.routines.UrlValidator;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;


public class SettingsController {
    private final Stage stage;
    private String urlWebService_last;

    @FXML
    public TextField urlWebService;
    public ChoiceBox<String> choiceFormat;
    public ChoiceBox<String> btnToSaving;
    public TextField pathToSaving;
    public CheckBox openingFile;
    public Button btnSave;
    public Button btnCancel;

    public SettingsController(Stage stage) {
        this.stage = stage;
    }

    public void initialize(){
        urlWebService.setText(AppProperties.getUrl());
        choiceFormat.setValue(AppProperties.getFormat());
        pathToSaving.setText(AppProperties.getSavePath());
        openingFile.setSelected(AppProperties.getFileOpening());

        urlWebService_last = AppProperties.getUrl();

        stage.addEventHandler(KeyEvent.KEY_RELEASED, (KeyEvent event) -> {
            if (KeyCode.ESCAPE == event.getCode()) {
                stage.close();
            }
        });

        urlWebService.setOnKeyPressed(keyEvent -> {
            if (keyEvent.getCode() == KeyCode.ENTER) {
                if(AppProperties.getPropStatus("UrlSSRS") == 3 || !urlWebService_last.equals(urlWebService.getText())) {
                    if (checkUrl()) {
                        AppProperties.setPropStatus("UrlSSRS", 2);
                        urlWebService.setStyle("");
                    } else {
                        AppProperties.setPropStatus("UrlSSRS", 3);
                        urlWebService.setStyle("-fx-border-color: red; -fx-text-inner-color: red;");
                    }
                }
                pathToSaving.requestFocus();
            }
        });

        btnToSaving.setOnMouseClicked(mouseEvent -> openFolder());
        pathToSaving.focusedProperty().addListener((observableValue, aBoolean, t1) -> {
            if(!pathToSaving.isFocused()) {
                if (checkPath()) {
                    AppProperties.setPropStatus("PATH_SAVE", 2);
                    pathToSaving.setStyle("");
                } else {
                    //System.out.println("Укажите корректный путь к папке");
                    AppProperties.setPropStatus("PATH_SAVE", 3);
                    pathToSaving.setStyle("-fx-border-color: red; -fx-text-inner-color: red;");
                }
            }
        });
        pathToSaving.setOnKeyPressed(keyEvent -> {
            if (keyEvent.getCode() == KeyCode.ENTER) {
                if(checkPath()) {
                    AppProperties.setPropStatus("PATH_SAVE", 2);
                    pathToSaving.setStyle("");
                }
                else{
                    //System.out.println("Укажите корректный путь к папке");
                    AppProperties.setPropStatus("PATH_SAVE", 3);
                    pathToSaving.setStyle("-fx-border-color: red; -fx-text-inner-color: red;");
                }
                urlWebService.requestFocus();
            }
        });
        btnSave.setOnAction(actionEvent -> saveProperties());
        btnCancel.setOnAction(actionEvent -> stage.close());

        final ArrayList<String> format = new ArrayList<>(Arrays.asList("EXCEL", "PDF", "WORD"));
        choiceFormat.getItems().addAll(format);
    }


    private boolean checkUrl(){
        if(urlWebService != null) { // Check textField on nullPointer and empty
            if(!urlWebService.getText().isEmpty()) {
                UrlValidator urlValidator = new UrlValidator();

                String urlWS = urlWebService.getText() + "/ReportExecution2005.asmx?WSDL";
                if(urlValidator.isValid(urlWS)) { // Check url on valid
                    URL url;
                    try {
                        url = new URL(urlWS);
                        HttpURLConnection http = (HttpURLConnection) url.openConnection(); // Check url on success connection

                        switch(http.getResponseCode()){
                            case(HttpURLConnection.HTTP_NOT_FOUND):
                                ErrorAlert.show("404 страница не найдена");
                                //System.out.println("404 страница не найдена");
                                break;
                            case(HttpURLConnection.HTTP_UNAUTHORIZED):
                                if(setConnection(urlWebService.getText())) {
                                    //System.out.println("Успех");
                                    return true;
                                }
                                //else
                                    //System.out.println("Не успех");
                                break;
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                else
                    ErrorAlert.show("URL не валидный");
            }
            //else
                //System.out.println("ТЕКСТОВОЕ ПОЛЕ НЕ ЗАПОЛНЕНО");
        }
        return false;
    }

    private boolean setConnection(String urlWS){
        try {
            System.out.println("aaaaaff");
            final AuthGUI authGUI = new AuthGUI(stage, urlWS);
            return authGUI.authorization();
        } catch (IOException e) {
            ErrorAlert.show(e);
            //System.err.println(e);
            return false;
        }
    }

    private void openFolder() {
        final DirectoryChooser directoryChooser = new DirectoryChooser();//Класс работы с диалогом выборки и сохранения
        directoryChooser.setTitle("Папка сохранения");//Заголовок диалога

        File defaultDirectory;
        if(pathToSaving.getText()!=null && AppProperties.getPropStatus("PATH_SAVE") != 3)
            defaultDirectory = new File(pathToSaving.getText());
        else
            defaultDirectory = new File("C:\\Users");
        directoryChooser.setInitialDirectory(defaultDirectory);

        final File directory = directoryChooser.showDialog(stage);//Указываем текущую сцену CodeNote.mainStage
        if (directory != null) {
            pathToSaving.setText(directory.getPath());
        }
        pathToSaving.setStyle("");
        AppProperties.setPropStatus("PATH_SAVE", 2);
    }

    private boolean checkPath() {
        if(pathToSaving != null) { // Check textField on nullPointer and empty
            if (!pathToSaving.getText().isEmpty()) {
                final File directory = new File(pathToSaving.getText());

                return directory.isDirectory();
            }
        }
        return false;
    }

    private void saveProperties(){
        final String field = AppProperties.getPropCheckerErr();
        if(field!=null)
            ErrorAlert.show(field + " заполнено не корректно");
        else {
            AppProperties.setUrl(urlWebService.getText());
            AppProperties.setFormat(choiceFormat.getValue());
            AppProperties.setSavePath(pathToSaving.getText());
            AppProperties.setFileOpening(openingFile.isSelected());
            AppProperties.saveProperties();
            stage.close();
        }
    }
}
