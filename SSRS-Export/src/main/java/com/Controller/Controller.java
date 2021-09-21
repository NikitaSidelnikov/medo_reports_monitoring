package com.Controller;

import com.Client.Client;


import com.GUI.*;
import com.GUI.Alert.WarningAlert;
import com.elements_extender.*;
import com.generated.ParameterValue;
import com.generated.ReportParameter;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.scene.control.*;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.MenuItem;
import javafx.scene.input.KeyCode;
import javafx.scene.layout.AnchorPane;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import javafx.stage.Stage;
import javafx.stage.FileChooser;

import java.awt.Desktop;
import java.awt.SystemTray;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.AWTException;
import java.awt.TrayIcon;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Controller{

    @FXML
    public TreeView<AnchorPane>  exportList;
    public Button btn_export;
    public Button btn_sett;
    public Button btn_add;
    public Button btn_delete;
    public Button btn_paramsDefault;
    public Button btn_show;
    public Button btn_hide;



    private final Client client = new Client();
    private final GUI gui;
    //private Image btnSettIcon;
    private final Stage stage;
    private TreeItem<AnchorPane> mainTreeElement;
    private MultipleSelectionModel<TreeItem<AnchorPane>> selectionModel;

    private String lastPath = null;

    public Controller(GUI gui, Stage stage) {
        this.gui = gui;
        this.stage = stage;
    }

    public void initialize(){
        Label mainTreeLabel = new Label("Reports");
        mainTreeLabel.setFont(Font.font("System", FontWeight.BOLD, 13.0));

        mainTreeElement = new TreeItem<>(new AnchorPane(mainTreeLabel));
        exportList.setRoot(mainTreeElement);
        exportList.setShowRoot(false);

        // получаем модель выбора
        selectionModel = exportList.getSelectionModel();
        // устанавливаем множественный выбор (если он необходим)
        selectionModel.setSelectionMode(SelectionMode.MULTIPLE);

        btn_sett.setOnAction(actionEvent -> gui.createSettWindow());
        btn_delete.setOnAction(actionEvent -> deleteReportItem());
        btn_paramsDefault.setDisable(true);
        
        selectionModel.selectedItemProperty().addListener((observableValue, anchorPaneTreeItem, t1) -> {
            if(selectionModel.getSelectedItems().size()==0) {
                btn_paramsDefault.setDisable(true);
                return;
            }

            List<String> paramNameList = new ArrayList<>();
            for(TreeItem<AnchorPane> treeItem : selectionModel.getSelectedItems()) {
                if (treeItem.getValue() instanceof ReportElement) {
                    btn_paramsDefault.setDisable(true);
                    return;
                }
                String paramName = ((ParamElement)(treeItem.getValue())).getParamName();
                paramNameList.add(paramName);
                if (paramNameList.indexOf(paramName) != paramNameList.lastIndexOf(paramName)) {
                    btn_paramsDefault.setDisable(true);
                    return;
                }
            }
            btn_paramsDefault.setDisable(false);
        });
        exportList.setOnKeyReleased(keyEvent -> {
            if(exportList.isFocused()) {
                if (keyEvent.getCode() == KeyCode.DELETE) {
                    deleteReportItem();
                    selectionModel.clearSelection();
                }
                else if (keyEvent.getCode() == KeyCode.ESCAPE)
                    selectionModel.clearSelection();
            }
        });
    }

    public void loadController(){
        btn_export.setOnAction(actionEvent -> {
            client.getProperties();
            if (mainTreeElement.getChildren().size() != 0) {
                for (TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()) {
                    if (!checkParams(reportItem))
                        return;
                }
                startExportTask();
            }

        });
        btn_add.setOnAction(actionEvent -> {
            client.getProperties();
            List<File> filesReport = selectFiles();
            if (filesReport != null) {
                for(File file : filesReport)
                    addReportItem(file);
            }
        });
        btn_show.setOnAction(actionEvent -> {
            if(mainTreeElement.getChildren().size()!=0){
                for(TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()){
                    reportItem.setExpanded(true);
                }
            }
        });
        btn_hide.setOnAction(actionEvent -> {
            if(mainTreeElement.getChildren().size()!=0){
                for(TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()){
                    reportItem.setExpanded(false);
                }
            }
        });
        btn_paramsDefault.setOnAction(actionEvent -> {
            for(TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()){
                for (TreeItem<AnchorPane> selectedParamItem : selectionModel.getSelectedItems()) {
                    setParamsDefaultValues(reportItem, selectedParamItem);
                }
            }
        });
    }

    private void setParamsDefaultValues(TreeItem<AnchorPane> reportItem, TreeItem<AnchorPane> originalParamItem) {
        for (TreeItem<AnchorPane> paramItem : reportItem.getChildren()) {
            ParamElement paramNode = (ParamElement) paramItem.getValue();
            String paramName = paramNode.getParamName();


            if (paramItem == originalParamItem)
                return;

            ParamElement selectedParamNode = (ParamElement) originalParamItem.getValue();
            String selectedParamName = selectedParamNode.getParamName();

            if (paramName.equals(selectedParamName)) {

                if(paramNode.haveDependencies()) {

                    int count = 0;
                    for (TreeItem<AnchorPane> buffParamItem : selectionModel.getSelectedItems()) {
                        ParamElement buffParamNode = (ParamElement) buffParamItem.getValue();
                        if(paramNode.getParamDependenciesList().contains(buffParamNode.getParamName()))
                            count++;
                    }
                    if(count!=paramNode.getParamDependenciesList().size()) {
                        (new WarningAlert()).show("Параметр \"" + paramNode.getParamPrompt() + "\" должен быть передан по умолчанию в составе родительских параметров: " + paramNode.getParamDependenciesList());
                        return;

                    }
                }

                setParamDefaultValue(reportItem, paramItem, selectedParamNode);
            }

        }

    }

    private void setParamDefaultValue(TreeItem<AnchorPane> reportItem, TreeItem<AnchorPane> paramItem, ParamElement originalParamNode) {
        ParamElement paramElement = createParamNode(originalParamNode.getParam(), reportItem);
        paramItem.setValue(paramElement);
        if (!originalParamNode.isMultiValue())
            paramElement.setDestinationValue(originalParamNode.getParamValue());
        else
            paramElement.setDestinationValue(originalParamNode.getParamValueList());
        resizeParamNodes(reportItem, paramElement);
    }



    public void loadControllerWithoutClient() {
        btn_export.setOnAction(actionEvent -> auth());
        btn_add.setOnAction(actionEvent -> auth());
    }

    public void auth(){
        AuthGUI authGUI = new AuthGUI(stage);
        try {
            if(authGUI.authorization())
                loadController(); //if authorization is completed successfully
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void deleteReportItem(){
        // перебираем выбанные элементы
        List<TreeItem<AnchorPane>> deleteList = new ArrayList<>(selectionModel.getSelectedItems());
        for(TreeItem<AnchorPane> item : deleteList){
            mainTreeElement.getChildren().remove(item);
        }
    }

    private void addReportItem(File file) {
        client.loadReportDefinition(file.getPath());

        ReportElement reportElement = new ReportElement(client.getExecutionInfo(), file);

        TreeItem<AnchorPane> reportItem = new TreeItem<>(reportElement);

        //context menu by right click
        final ContextMenu contextMenu = createContextMenu(reportElement, reportItem);
        reportElement.setOnContextMenuRequested(contextMenuEvent -> contextMenu.show(reportElement, contextMenuEvent.getScreenX(), contextMenuEvent.getScreenY()));

        addParamsItem(reportItem);
    }

    private void addParamsItem(TreeItem<AnchorPane> reportItem){
        List<ReportParameter> params = ((ReportElement) reportItem.getValue()).getParamList();

        for (ReportParameter param : params) {
            ParamElement paramNode = createParamNode(param, reportItem);

            TreeItem<AnchorPane> paramItem = new TreeItem<>(paramNode);

            resizeParamNodes(reportItem, paramNode);
            reportItem.getChildren().add(paramItem);
        }

        mainTreeElement.getChildren().add(reportItem);
        reportItem.setExpanded(true);
    }

    private void resizeParamNodes(TreeItem<AnchorPane> reportItem, ParamElement paramNode) {
        ReportElement reportNode = (ReportElement) reportItem.getValue();

        if(paramNode.getLabelSize() <= reportNode.getMaxParamsNodeSize())
            paramNode.setLabelSize(reportNode.getMaxParamsNodeSize());
        else {
            reportNode.setMaxParamsNodeSize(paramNode.getLabelSize());
            for(TreeItem<AnchorPane> paramItem : reportItem.getChildren())
                ((ParamElement) paramItem.getValue()).setLabelSize(paramNode.getLabelSize());
        }

    }

    private boolean checkDependenciesParams(TreeItem<AnchorPane> reportItem, List<String> paramDependenciesList) {
        boolean paramsModified = false;
        for(TreeItem<AnchorPane> paramItem : reportItem.getChildren()){
            ParamElement paramNode = (ParamElement) paramItem.getValue();
            if(paramDependenciesList.contains(paramNode.getParamName())) {
                if (paramNode.getParamValue() == null) {
                    System.out.println("Параметр \"" + paramNode.getParamPrompt() + " должен быть заполнен");
                    return false;
                }
                else if (paramNode.getParamValue().length() == 0){
                    System.out.println("Параметр \"" + paramNode.getParamPrompt() + " должен быть заполнен");
                    return false;
                }
                if(paramNode.getModified()) {
                    paramNode.setModified(false);
                    paramsModified = true;
                }
            }
        }
        return paramsModified;

    }

    public void updateReport(TreeItem<AnchorPane> reportItem, String paramItemName){
        ReportElement reportNode = (ReportElement)reportItem.getValue();

        ParamElement paramDepItem = null;

        List<ParameterValue> userParams = new ArrayList<>();
        for(TreeItem<AnchorPane> paramItem : reportItem.getChildren()){
            ParamElement param = (ParamElement) paramItem.getValue();
            if(!param.isMultiValue()) {
                String paramValue = param.getParamValue();
                String paramName = param.getParamName();
                userParams.add(addUserParams(paramName, paramValue));
            }
            else {
                List<String> paramValuesList = param.getParamValueList();
                String paramName = param.getParamName();
                for(String paramValue_1: paramValuesList)
                    userParams.add(addUserParams(paramName, paramValue_1));
            }
            if(param.getParamName().equals(paramItemName))
                paramDepItem = (ParamElement) paramItem.getValue();
        }

        String reportPath = ((ReportElement) reportItem.getValue()).getPath();
        client.loadReportDefinition(reportPath);
        client.setExecutionParameters(userParams);

        reportNode.updateExecutionInfo(client.getExecutionInfo());
        List<ReportParameter> paramsList = client.getExecutionInfo().getParameters().getReportParameter();
        for(ReportParameter param : paramsList) {
            if (param.getName().equals(paramItemName)) {
                if (paramDepItem != null) {
                    paramDepItem.setParam(param);
                }
            }
        }
    }


    private ContextMenu createContextMenu(AnchorPane reportItemAP, TreeItem<AnchorPane> reportItem) {
        //context menu by right click
        final ContextMenu contextMenu = new ContextMenu();
        final MenuItem itemExport = new MenuItem("Export");
        final MenuItem itemOpenFile = new MenuItem("Open file");
        final MenuItem itemOpenFolder = new MenuItem("Open folder");
        final MenuItem itemDuplicate = new MenuItem("Duplicate");
        final MenuItem itemDelete = new MenuItem("Delete");

        itemExport.setOnAction(actionEvent -> startExportTask(reportItem));
        itemOpenFile.setOnAction(actionEvent -> {
            try {
                Desktop.getDesktop().open(new File(((ReportElement)reportItemAP).getPath()));
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        itemOpenFolder.setOnAction(actionEvent -> {
            String fullPath = ((ReportElement)reportItemAP).getPath();
            String path = fullPath.substring(0, fullPath.lastIndexOf('\\'));
            try {
                Desktop.getDesktop().open(new File(path));
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        itemDuplicate.setOnAction(actionEvent -> {
            for(TreeItem<AnchorPane> selectedReportItem : selectionModel.getSelectedItems()) {
                duplicateReportItem(selectedReportItem);
            }
        });

        itemDelete.setOnAction(actionEvent -> deleteReportItem());

        contextMenu.getItems().addAll(itemExport, itemOpenFile, itemOpenFolder, itemDuplicate, itemDelete);
        return contextMenu;
    }

    public void duplicateReportItem(TreeItem<AnchorPane> originalReportItem){
        if(originalReportItem.getValue() instanceof ReportElement) {
            addReportItem(((ReportElement) originalReportItem.getValue()).getFile());
            TreeItem<AnchorPane> duplicatedReportItem = mainTreeElement.getChildren().get(mainTreeElement.getChildren().size() - 1);

            for(int i = 0; i < duplicatedReportItem.getChildren().size(); i++) {
                TreeItem<AnchorPane> originalParamItem = originalReportItem.getChildren().get(i);
                ParamElement originalParam = (ParamElement) originalParamItem.getValue();

                TreeItem<AnchorPane> duplicatedParamItem = duplicatedReportItem.getChildren().get(i);

                setParamDefaultValue(duplicatedReportItem, duplicatedParamItem, originalParam);
            }

        }
    }

    private boolean checkParams(TreeItem<AnchorPane> reportItem) {
        ReportElement report = ((ReportElement) reportItem.getValue());
        for(TreeItem<AnchorPane> paramItem : reportItem.getChildren()) {
            ParamElement param = ((ParamElement) paramItem.getValue());
            if(param.getMandatory() && (param.getParamValueList() == null && param.getParamValue() == null)){
                (new WarningAlert()).show("Обязательный параметр \"" + param.getParamPrompt() + "\" отчета " + report.getFileName() + " не заполнен");
                return false;
            }
        }
        return true;
    }

    // Export Task for several reports
    private void startExportTask(){
        Task<Void>  task = new Task<>() {
            @Override
            protected Void call() {
                int steps = mainTreeElement.getChildren().size();
                int step = 0;
                for (TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()) {
                    if (this.isCancelled())
                        return null;
                    updateProgress(step, steps);
                    updateMessage(((Label) reportItem.getValue().getChildren().get(0)).getText());
                    updateTitle(step + "/" + mainTreeElement.getChildren().size());

                    export(reportItem, this);
                    step++;
                }
                updateProgress(step, steps);
                updateMessage("Success");
                updateTitle(step + "/" + mainTreeElement.getChildren().size());
                showTrayMessage();
                return null;
            }
        };

        new Thread(task).start();

        ProgressGUI progressGUI = new ProgressGUI(stage, task);
        progressGUI.start();
        progressGUI.bind(task);

        //progressGUI.finish();
    }

    private void showTrayMessage() {
        if (SystemTray.isSupported()) {
            SystemTray tray = SystemTray.getSystemTray();

            Image image = Toolkit.getDefaultToolkit().createImage(getClass().getResource("/icon.png"));
            TrayIcon trayIcon = new TrayIcon(image, "ssrs-export tray");
            //trayIcon.setImageAutoSize(true);
            //trayIcon.setToolTip("ssrs-export tray");
            try {
                tray.add(trayIcon);
            } catch (AWTException e) {
                e.printStackTrace();
            }

            trayIcon.displayMessage("ssrs-export", "Export has been completed", TrayIcon.MessageType.INFO);
            tray.remove(trayIcon);
        }
    }


    // Export Task for one report
    private void startExportTask(TreeItem<AnchorPane> reportItem){
        Task<Void>  task = new Task<>() {
            @Override
            protected Void call() {
                int steps = 1;
                int step = 0;

                updateProgress(step, steps);
                updateMessage(((Label) reportItem.getValue().getChildren().get(0)).getText());
                updateTitle(step + "/" + 1);


                export(reportItem, this);
                step++;

                updateProgress(step, steps);
                updateMessage("Success");
                updateTitle(step + "/" + 1);
                showTrayMessage();
                return null;
            }
        };

        new Thread(task).start();

        ProgressGUI exportProgressBar = new ProgressGUI(stage, task);
        exportProgressBar.start();
        exportProgressBar.bind(task);

        //exportProgressBar.finish();
    }

    private void export(TreeItem<AnchorPane> reportItem, Task<Void> task) {
/*        ExportProgressBar exportProgressBar = new ExportProgressBar();
        exportProgressBar.start();

        for(TreeItem<AnchorPane> reportItem : mainTreeElement.getChildren()){*/
        List<ParameterValue> userParams = new ArrayList<>();
        for(TreeItem<AnchorPane> paramItem : reportItem.getChildren()){
            ParamElement param = (ParamElement) paramItem.getValue();
            if(!param.isMultiValue()) {
                String paramValue = param.getParamValue();
                String paramName = param.getParamName();
                if(paramValue!=null)
                    userParams.add(addUserParams(paramName, paramValue));
            }
            else {
                List<String> paramValuesList = param.getParamValueList();
                String paramName = param.getParamName();
                for(String paramValue_1: paramValuesList) {
                    if(paramValue_1!=null)
                        userParams.add(addUserParams(paramName, paramValue_1));
                }
            }

        }

        String reportPath = ((ReportElement) reportItem.getValue()).getPath();

        client.loadReportDefinition(reportPath);
        client.setExecutionParameters(userParams);
        byte[] renderResult = client.Render();
        if (!task.isCancelled())
            client.SaveReport(renderResult, ((ReportElement) reportItem.getValue()).getFileName());
    }

    public ParameterValue addUserParams(String paramName, String paramValue){
        ParameterValue rp = new ParameterValue();
        rp.setName(paramName);
        rp.setValue(paramValue);
        return rp;
    }

    public ParamElement createParamNode(ReportParameter param, TreeItem<AnchorPane> reportItem){
        ParamElement paramElement;

        switch (param.getType().toString()) {
            case ("DATE_TIME"):
                paramElement = new DateElement(param); //param;
                break;
/*            case ("INTEGER"):
                node = new FieldElement(param);
                break;
            case ("STRING"):
                if(!param.isMultiValue())
                    node = new ChoiceElement(param);
                else
                    node = new MultiChoiceElement(param);
                break;*/
            default:
                if(!param.isMultiValue())
                    paramElement = new ChoiceElement(param);
                else
                    paramElement = new MultiChoiceElement(param);
                break;
        }
        //Add listener for paramNode
        if(paramElement.haveDependencies()) {
            paramElement.focusProperty().addListener(observable -> {
                if(checkDependenciesParams(reportItem, paramElement.getParamDependenciesList()))
                    updateReport(reportItem, paramElement.getParamName());
            });
        }

        return  paramElement;
    }


    private List<File> selectFiles() {
        FileChooser fileChooser = new FileChooser();//Класс работы с диалогом выборки и сохранения
        fileChooser.setTitle("Выбор отчета");//Заголовок диалога
        fileChooser.getExtensionFilters().addAll(//
                new FileChooser.ExtensionFilter("RDL", "*.rdl")
        );

        File defaultDirectory = lastPath != null ? new File(lastPath) : new File(System.getProperty("user.home"));
        fileChooser.setInitialDirectory(defaultDirectory);
        List<File> selectedFiles = fileChooser.showOpenMultipleDialog(stage);//Указываем текущую сцену CodeNote.mainStage
        if (selectedFiles != null) {
            lastPath = selectedFiles.get(0).getPath().substring(0, selectedFiles.get(0).getPath().lastIndexOf('\\'));
            return selectedFiles;
        }
        return null;
    }

}
