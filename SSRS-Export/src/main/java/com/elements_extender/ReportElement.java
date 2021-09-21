package com.elements_extender;

import com.generated.ExecutionInfo;
import com.generated.ReportParameter;

import javafx.scene.control.Label;
import javafx.scene.layout.AnchorPane;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;

import org.apache.commons.io.FilenameUtils;

import java.io.File;
import java.util.List;

public class ReportElement extends AnchorPane {

    private final File file;
    private List<ReportParameter> paramList;
    private double maxParamsNodeSize = 0.0;

    public ReportElement(ExecutionInfo executionInfo, File file) {
        this.file = file;
        paramList = executionInfo.getParameters().getReportParameter();

        final Label labelReport = new Label(FilenameUtils.removeExtension(file.getName()));
        labelReport.setFont(Font.font("System", FontWeight.BOLD, 13));

        this.getChildren().addAll(labelReport);
    }

    public void updateExecutionInfo(ExecutionInfo executionInfo) {
        paramList = executionInfo.getParameters().getReportParameter();
    }

    public List<ReportParameter> getParamList() {
        return paramList;
    }

    public File getFile() {
        return file;
    }
    public String getFileName() { return FilenameUtils.removeExtension(file.getName()); }
    public String getPath() { return file.getPath(); }

    public void setMaxParamsNodeSize(double maxParamsNodeSize) {
        this.maxParamsNodeSize = maxParamsNodeSize;
    }
    public double getMaxParamsNodeSize() {
        return maxParamsNodeSize;
    }
}
