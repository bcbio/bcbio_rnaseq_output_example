context("Reports")
library(rmarkdown)
library(bcbioRNASeq)

test_that("qc_and_de", {
    unlink("report", recursive = TRUE)
    extraDir <- system.file("extra", package = "bcbioRNASeq")
    reportDir <- file.path("..", "..", "bcbioRnaseq",
        "inst", "rmarkdown",
        "templates", "quality_control",
        "skeleton")
    miscDir <- file.path("..",  "..", "bcbioRnaseq", "docs", "downloads")
    uploadDir <- tools::file_path_as_absolute(file.path("."))
    
    print(uploadDir)

    dir.create("report")
    setwd("report")
    outputDir <- tools::file_path_as_absolute(file.path("."))
    print(list.files(miscDir, full.names = TRUE))
    file.copy(list.files(miscDir, full.names = TRUE), ".",
              overwrite = FALSE, recursive = TRUE)
    print(file.path(reportDir, "skeleton.Rmd"))
    file.copy(file.path(reportDir, "skeleton.Rmd"), "qc.Rmd", overwrite = TRUE)

    render("qc.Rmd", params = list(uploadDir = uploadDir,
                                   interestingGroups = "group",
                                   outputDir = outputDir))

    reportDir <- file.path("..",  "..", "bcbioRnaseq",
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
