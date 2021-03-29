library(jsonlite)

x <- read.csv("https://soosiana.github.io/issues/soosiana.csv")

tmp <- list(
    id = "$FILE",
    title = "$TITLE",
    author = structure(list(name = "$AUTHOR"), class = "data.frame", row.names = 1L),
    type = "article",
    year = "$YEAR",
    journal = list(
        name = "Soosiana",
        shortcode = "Soosiana",
        id = "soosiana",
        identifier = structure(list(
            id = "0133-7971", type = "ISSN"), class = "data.frame", row.names = 1L),
        volume = "$VOLUME",
        pages = "$START--$END"),
    link = structure(list(
        url = "https://soosiana.github.io/content/$VOLUME/$FILE"),
        class = "data.frame", row.names = 1L),
    identifier = structure(list(type = "DOI", id = "$DOI",
                                url = "https://doi.org/$DOI"),
                           class = "data.frame", row.names = 1L),
    license = structure(list(type = "CC BY 4.0",
                             url = "https://creativecommons.org/licenses/by/4.0/",
                             description = "Attribution 4.0 International",
                             jurisdiction = "universal"),
                        class = "data.frame", row.names = 1L))

z <- x[!duplicated(x$Volume), c("Journal", "Volume", "Year")]
rownames(z) <- NULL
colnames(z) <- c("journal", "volume", "year")
z$url <- paste0("https://soosiana.github.io/volume-", z$volume, "/")
#writeLines(toJSON(z, pretty = FALSE, auto_unbox = TRUE), "docs/index.json")

rm <- ""
for (i in nrow(z):1) {
    nv <- paste0("- [Soosiana Volume ", z$volume[i], ", ",
                 z$year[i], "](", z$url[i], ")\n")
    rm <- c(rm, nv)
}
#writeLines(rm, "docs/README.md")


vols <- unique(as.character(x$Volume))
names(vols) <- vols
vals <- as.integer(sapply(strsplit(vols, "-"), "[[", 1L))
vols <- vols[order(vals)]
#vols <- rev(vols)

for (vol in vols) {
    cat(vol, "\n")
    xx <- droplevels(as.data.frame(x[x$Volume==vol,]))
    out <- list()
    f <- file.path("docs", vol, paste0(xx$File, ".pdf"))
    OK <- file.exists(f)
#    if (!all(OK))
#        stop("Files not found:\n", paste(f[!OK], "\n"))

    toc <- ""
    for (i in 1:nrow(xx)) {
        p <- tmp
        p$year <- as.character(xx[i,"Year"])
        p$id <- as.character(xx[i,"File"])
        p$title <- as.character(xx[i,"Title"])

        p$journal$volume <- as.character(xx[i,"Volume"])
        p$journal$pages <- paste0(xx[i,"Start"], "--", xx[i,"End"])
        if (is.na(xx[i,"DOI"])) {
            p$identifier$id <- ""
            p$identifier$url <- ""
        }
        a <- xx[i,"Authors"]
        if (is.na(a) || a == "") {
            a <- ""
        } else {
            a <- strsplit(as.character(xx[i,"Authors"]), ";")[[1L]]
        }
        a0 <- a
        a <- data.frame(name=a)
        rownames(a) <- NULL
        p$author <- a
        p$link <- paste0("https://soosiana.github.io/volume-",
                         as.character(xx[i,"Volume"]), "/",
                         as.character(xx[i,"File"]), ".pdf")
        out[[i]] <- p

        n <- if (any(a0 == "")) {
            paste0(
                p$title,
                ". _", p$journal$name, "_, **",
                p$journal$volume, "**: ",
                p$journal$pages, ". [PDF](",
                p$link, ")\n\n"
            )
        } else {
            paste0(
                paste0(a0, collapse=", "),
                ", ", p$year, ". ",
                p$title,
                ". _", p$journal$name, "_, **",
                p$journal$volume, "**: ",
                p$journal$pages, ". [PDF](",
                p$link, ")\n\n"
            )

        }
        toc <- c(toc, n)
    }


    u <- c(paste0("---\ntitle: Soosiana Volume ", vol, "\n---\n\n"),
                toc, "\n")

    dir <- paste0("~/repos/soosiana.github.io/issues/", vol)
    if (!dir.exists(dir))
        dir.create(dir)
    writeLines(u, paste0(dir, "/index.md"))

#    writeLines(toJSON(out, pretty = FALSE, auto_unbox = TRUE),
#               paste0("docs/", vol, "/index.json"))
#    writeLines(u, paste0("docs/", vol, "/README.md"))
}

