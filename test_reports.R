context("Reports")
library(rmarkdown)
library(bcbioRNASeq)

test_that("qc_and_de", {
    unlink("report", recursive = TRUE)
    extraDir <- system.file("extra", package = "bcbioRNASeq")
    reportDir <- file.path("..", "..", "bcbioRNASeq",
        "inst", "rmarkdown",
        "templates", "quality_control",
        "skeleton")
    miscDir <- file.path("..",  "..", "bcbioRNASeq", "docs", "downloads")
    uploadDir <- tools::file_path_as_absolute(file.path("."))
    
    print(uploadDir)
    print(list.files(miscDir, full.names = TRUE))

    dir.create("report")
    setwd("report")
    outputDir <- tools::file_path_as_absolute(file.path("."))
    file.copy(list.files(miscDir, full.names = TRUE), ".",
              overwrite = FALSE, recursive = TRUE)
    file.copy(file.path(reportDir, "skeleton.Rmd"), "qc.Rmd", overwrite = TRUE)
    
    library(bcbioRNASeq)
    bcb <- loadRNASeqRun(
                        uploadDir,
                        interestingGroups = c("group")
                         )
    saveData(bcb, dir = "data")

    render("qc.Rmd", params = list(bcbFile = bcb,
                                   outputDir = outputDir))

    reportDir <- file.path("..",  "..", "bcbioRNASeq",
                           "inst", "rmarkdown",
                           "templates", "differential_expression",
                           "skeleton")

    file.copy(file.path(reportDir, "skeleton.Rmd"), "de.Rmd", overwrite = TRUE)
    render("de.Rmd", params = list(design = formula(~group),
                                   contrast = c("group", "ctrl", "ko"),
                                   outputDir = outputDir))
    
    load("data/bcb.rda")
    print(bcb)
    
    setwd("..")

})
