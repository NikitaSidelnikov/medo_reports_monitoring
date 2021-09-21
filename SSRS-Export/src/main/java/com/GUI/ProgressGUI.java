package com.GUI;

import com.Controller.ProgressController;
import javafx.concurrent.Task;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Modality;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import java.io.IOException;

public class ProgressGUI {
    private ProgressController progressController;

    private final Stage mainStage;
    private final Task<Void> task;

    public ProgressGUI(Stage mainStage, Task<Void> task) {
        this.mainStage = mainStage;
        this.task = task;
    }

    public void start(){
        final Stage progressScene = new Stage();
        final FXMLLoader fxmlLoader = new FXMLLoader();
        fxmlLoader.setLocation(getClass().getResource("/fxml/progressScene.fxml"));

        progressController = new ProgressController(progressScene, task);
        fxmlLoader.setController(progressController);
        Parent root;
        try {
            root = fxmlLoader.load();
            progressScene.setScene(new Scene(root));
            progressScene.initOwner(mainStage);
            progressScene.initStyle(StageStyle.DECORATED);
            progressScene.initModality(Modality.WINDOW_MODAL);
            progressScene.setResizable(false);
            //progressScene.setAlwaysOnTop(true);
            progressScene.setTitle("Export progress");

            progressScene.show();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void bind(Task<Void> task) {
        progressController.bind(task);
    }
}
