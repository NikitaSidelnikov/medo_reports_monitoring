package com.Controller;

import com.AppProperties;
import javafx.concurrent.Task;
import javafx.fxml.FXML;
import javafx.scene.control.ProgressBar;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.Label;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.util.Optional;

public class ProgressController {
    private final Stage progressScene;
    private final Task<Void> task;

    @FXML
    public ProgressBar progressBar;
    public Label countLabel;
    public Label reportLabel;
    public Button btnCancel;
    public Button btnOpenFolder;

    public ProgressController(Stage progressScene, Task<Void> task) {
        this.progressScene = progressScene;
        this.task = task;
    }

    public void initialize(){
        progressScene.setOnCloseRequest(windowEvent -> {
            if(progressBar.getProgress() != 1.0) {
                windowEvent.consume();
                ExportCanceling();
            }
        });
        btnCancel.setOnAction(actionEvent -> {
            if(progressBar.getProgress() != 1.0) {
                ExportCanceling();
            }
            else
                progressScene.close();
        });
        btnOpenFolder.setOnAction(actionEvent -> {
            try {
                Desktop.getDesktop().open(new File(AppProperties.getSavePath()));
                progressScene.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
    }

    public void bind(Task<Void> task) {
        progressBar.progressProperty().bind(task.progressProperty());
        reportLabel.textProperty().bind(task.messageProperty());
        countLabel.textProperty().bind(task.titleProperty());
        task.progressProperty().addListener((observableValue, number, t1) -> {
            if(task.getProgress() == 1.0){
                btnOpenFolder.setVisible(true);
            }
        });
    }

    private void ExportCanceling() {
        final Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.initOwner(progressScene);
        alert.initModality(Modality.WINDOW_MODAL);
        alert.setTitle("Cancel export");
        alert.setHeaderText(null);
        alert.setContentText("Are you sure want to cancel export reports?");
        //alert.setContentText("C:/MyFile.txt");

        // option != null.
        final Optional<ButtonType> option = alert.showAndWait();

        if (option.get() == ButtonType.OK) {
            task.cancel(true);
            progressScene.close();
        }
    }
}
