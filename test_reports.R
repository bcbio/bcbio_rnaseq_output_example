context("Reports")

library(rmarkdown)
library(bcbioRNASeq)

# R Markdown source templates from package
templates_dir <- system.file("rmarkdown/templates", package = "bcbioRNASeq")

# An old, unknown Ensembl release was used to save the example run.
# Using release 87, which is the oldest currently supported by AnnotationHub.
# A warning about 173 unannotated genes is expected.
bcb <- suppressWarnings(bcbioRNASeq(
    uploadDir = ".",
    interestingGroups = "group",
    organism = "Mus musculus",
    ensemblRelease = 87
))
stopifnot(is(bcb, "bcbioRNASeq"))
print(bcb)

unlink("report", recursive = TRUE)
dir.create("report")
setwd("report")

prepareRNASeqTemplate(overwrite = TRUE)

data_dir <- "data"
bcb_file <- saveData(bcb, dir = data_dir)
dds_file <- file.path(data_dir, "dds.rda")
res_file <- file.path(data_dir, "res.rda")

test_that("Quality Control", {
    file.copy(
        from = file.path(
            templates_dir,
            "quality_control",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "qc.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "qc.Rmd",
        params = list(
            bcb_file = bcb_file,
            data_dir = data_dir
        )
    )
    expect_identical(basename(x), "qc.html")
})

test_that("Differential Expression", {
    file.copy(
        from = file.path(
            templates_dir,
            "differential_expression",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "de.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "de.Rmd",
        params = list(
            bcb_file = bcb_file,
            design = formula("~group"),
            contrast = c("group", "ctrl", "ko"),
            data_dir = data_dir
        )
    )
    expect_identical(basename(x), "de.html")
})

test_that("Functional Analysis", {
    file.copy(
        from = file.path(
            templates_dir,
            "functional_analysis",
            "skeleton",
            "skeleton.Rmd"
        ),
        to = "fa.Rmd",
        overwrite = TRUE
    )
    x <- render(
        input = "fa.Rmd",
        params = list(
            dds_file = dds_file,
            res_file = res_file,
            organism = "Mus musculus",
            data_dir = data_dir
        )
    )
    expect_identical(basename(x), "fa.html")
})

setwd("..")
