context("Reports")
library(rmarkdown)
library(bcbioRNASeq)

test_that("qc_and_de", {
    unlink("report", recursive = TRUE)
    dir.create("report")
    setwd("report")

    install.packages("DT")
    install.packages("tidyverse")

    extraDir <- system.file("extra", package = "bcbioRNASeq")
    reportDir <- file.path("..", "..", "bcbioRNASeq",
        "inst", "rmarkdown",
        "templates", "quality_control",
        "skeleton")
    miscDir <- file.path("..",  "..", "bcbioRNASeq",
                         "inst", "rmarkdown", "shared")
    uploadDir <- tools::file_path_as_absolute(file.path("."))

    print(uploadDir)
    print(list.files(miscDir, full.names = TRUE))

    outputDir <- tools::file_path_as_absolute(file.path("."))
    file.copy(list.files(miscDir, full.names = TRUE), ".",
              overwrite = TRUE, recursive = TRUE)
    file.copy(file.path(reportDir, "skeleton.Rmd"), "qc.Rmd", overwrite = TRUE)

    library(bcbioRNASeq)
    bcb <- loadRNASeqRun(
                        uploadDir,
                        interestingGroups = c("group")
                         )
    saveData(bcb, dir = "data")

    render("qc.Rmd", params = list(bcbFile = "data/bcb.rda",
                                   outputDir = outputDir))

    reportDir <- file.path("..",  "..", "bcbioRNASeq",
                           "inst", "rmarkdown",
                           "templates", "differential_expression",
                           "skeleton")

    file.copy(file.path(reportDir, "skeleton.Rmd"), "de.Rmd", overwrite = TRUE)
    render("de.Rmd", params = list(bcbFile = "data/bcb.rda",
                                   design = formula(~group),
                                   contrast = c("group", "ctrl", "ko"),
                                   outputDir = outputDir))

    reportDir <- file.path("..",  "..", "bcbioRNASeq",
                           "inst", "rmarkdown",
                           "templates", "functional_analysis",
                           "skeleton")

    file.copy(file.path(reportDir, "skeleton.Rmd"), "fa.Rmd", overwrite = TRUE)
    render("fa.Rmd", params = list(bcbFile = "data/bcb.rda",
                                   outputDir = outputDir))

    load("data/bcb.rda")
    print(bcb)

    setwd("..")

})
