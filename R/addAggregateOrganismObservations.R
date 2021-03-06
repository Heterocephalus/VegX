#' Add aggregate organism observation records
#'
#' Adds aggregate organism observation records to a VegX object from a data frame where rows are observation records.
#'
#' @param target The initial object of class \code{\linkS4class{VegX}} to be modified
#' @param x A data frame where each row corresponds to one aggregate organism observation. Columns can be varied.
#' @param mapping A named list whose elements are strings that correspond to column names in \code{x}. Names of the list should be:
#'  \itemize{
#'    \item{\code{plotName} - A string identifying the vegetation plot within the data set (required).}
#'    \item{\code{subPlotName} - A string identifying a subplot of the plot given by \code{plotName} (optional).}
#'    \item{\code{obsStartDate} - Plot observation start date (required; see \code{date.format}).}
#'    \item{\code{organismName} - The string of a name, defined by the dataset author, and which does not follow nomenclatural codes.}
#'    \item{\code{taxonName} - The string of a taxon name (not necessarily including authority). }
#'    \item{\code{stratumName} - A string used to identify a stratum (see \code{stratumDefinition}; optional).}
#'    \item{\code{heightMeasurement} - Optional height at which the aggregated observation was made, e.g. in meters. It applies to all aggregate measurements (optional).}
#'    \item{\code{...} - User defined names used to map aggregate organism measurements, such as percent cover (optional).}
#'  }
#' @param methods A list with measurement methods for \code{heightMeasurement} and all the user defined aggregate organism measurements (each method is an object of class \code{\linkS4class{VegXMethodDefinition}}).
#' Alternatively, methods can be specified using strings if predefined methods exist (see \code{\link{predefinedMeasurementMethod}}).
#' @param stratumDefinition An object of class \code{\linkS4class{VegXStrataDefinition}} indicating the definition of strata.
#' @param date.format A character string specifying the input format of dates (see \code{\link{as.Date}}).
#' @param missing.values A character vector of values that should be considered as missing observations/measurements.
#' @param verbose A boolean flag to indicate console output of the data integration process.
#'
#' @return The modified object of class \code{\linkS4class{VegX}}.
#'
#' @references Wiser SK, Spencer N, De Caceres M, Kleikamp M, Boyle B & Peet RK (2011). Veg-X - an exchange standard for plot-based vegetation data
#'
#' @family add functions
#'
#' @details The mapping should include either \code{organismName} or  \code{taxonName}, but can include both of them if the source data set contains both taxon names 
#' and others that are not taxa. Missing value policy:
#' \itemize{
#'   \item{Missing \code{plotName} and \code{obsStartDate} values are interpreted as if the previous non-missing value has to be used to define aggregate organism observation.}
#'   \item{Missing \code{subPlotName} values are interpreted in that observation refers to the parent plotName.}
#'   \item{When \code{stratumName} values are missing the aggregate organism observation is not assigned to any stratum.}
#'   \item{When both \code{organismName} and \code{taxonName} are missing (i.e. missing organism identity) the function generates an error.}
#'   \item{Missing aggregate organism measurements are not added to the Veg-X document.}
#' }
#'
#' @examples
#' # Load source data
#' data(mokihinui)
#'
#' # Define mapping
#' mapping = list(plotName = "Plot", obsStartDate = "PlotObsStartDate",
#'                taxonName = "NVSSpeciesName",
#'                stratumName = "Tier", cover = "Category")
#'
#' # Define abundance scale
#' coverscale = defineOrdinalScaleMethod(name = "Recce cover scale",
#'                    description = "Recce recording method by Hurst/Allen",
#'                    subject = "plant cover",
#'                    citation = "Hurst, JM and Allen, RB. (2007) 
#'                        The Recce method for describing New Zealand vegetation – 
#'                        Field protocols. Landcare Research, Lincoln.",
#'                    codes = c("P","1","2","3", "4", "5", "6"),
#'                    quantifiableCodes = c("1","2","3", "4", "5", "6"),
#'                    breaks = c(0, 1, 5, 25, 50, 75, 100),
#'                    midPoints = c(0.05, 0.5, 15, 37.5, 62.5, 87.5),
#'                    definitions = c("Presence", "<1%", "1-5%","6-25%", 
#'                                    "26-50%", "51-75%", "76-100%"))
#'
#' # Define strata
#' strataDef = defineMixedStrata(name = "Recce strata",
#'                  description = "Standard Recce stratum definition",
#'                  citation = "Hurst, JM and Allen, RB. (2007) 
#'                    The Recce method for describing New Zealand vegetation – Field protocols. 
#'                    Landcare Research, Lincoln.",
#'                  heightStrataBreaks = c(0, 0.3,2.0,5, 12, 25, 50),
#'                  heightStrataNames = paste0("Tier ",1:6),
#'                  categoryStrataNames = "Tier 7",
#'                  categoryStrataDefinition = "Epiphytes")
#'
#' # Create new Veg-X document with aggregate organism observations
#' x = addAggregateOrganismObservations(newVegX(), moki_tcv,
#'                  mapping = mapping,
#'                  methods = list(cover=coverscale),
#'                  stratumDefinition = strataDef)
#'
#' # Inspect the result
#' head(showElementTable(x, "aggregateOrganismObservation"))
#'
#'
#' # Example with individual counts
#' data(mtfyffe)
#' mapping = list(plotName = "Plot", subPlotName = "Subplot", obsStartDate = "PlotObsStartDate",
#'                taxonName = "NVSSpeciesName", stratumName = "Tier", counts = "Value")
#' strataDef = defineHeightStrata(name = "Standard seedling/sapling strata",
#'                description = "Seedling/sapling stratum definition",
#'                heightBreaks = c(0, 15, 45, 75, 105, 135, 200),
#'                strataNames = as.character(1:6),
#'                strataDefinitions = c("0-15 cm", "16-45 cm", "46-75 cm", 
#'                                      "76-105 cm", "106-135 cm", "> 135 cm"))
#' x = addAggregateOrganismObservations(newVegX(), mtfyffe_counts, mapping,
#'                methods = list(counts="Individual plant counts"),
#'                stratumDefinition = strataDef)
#' head(showElementTable(x, "aggregateOrganismObservation"))
#'
#' # Example with frequency in transects
#' data(takitimu)
#' mapping = list(plotName = "Plot", subPlotName = "Subplot", obsStartDate = "PlotObsStartDate",
#'                taxonName = "NVSSpeciesName", freq = "Value")
#' x = addAggregateOrganismObservations(newVegX(), taki_freq, mapping,
#'                methods = list(freq="Plant frequency/%"))
#' head(showElementTable(x, "aggregateOrganismObservation"))
#'
addAggregateOrganismObservations<-function(target, x,
                                     mapping,
                                     methods = list(),
                                     stratumDefinition = NULL,
                                     date.format = "%Y-%m-%d",
                                     missing.values = c(NA, "0", ""),
                                     verbose = TRUE) {

  if(class(target)!="VegX") stop("Wrong class for 'target'. Should be an object of class 'VegX'")
  x = as.data.frame(x)
  nrecords = nrow(x)
  nmissing = 0

  aggObservationMapping = c("plotName", "obsStartDate", "subPlotName", "stratumName", "organismName",
                            "taxonName")

  #Check columns exist
  for(i in 1:length(mapping)) {
    if(!(mapping[i] %in% names(x))) stop(paste0("Variable '", mapping[i],"' not found in column names. Revise mapping or data."))
  }
  plotNames = as.character(x[[mapping[["plotName"]]]])
  obsStartDates = as.Date(as.character(x[[mapping[["obsStartDate"]]]]), format =date.format)

  #Optional mappings
  stratumFlag = ("stratumName" %in% names(mapping))
  if(stratumFlag) {
    stratumNamesData = as.character(x[[mapping[["stratumName"]]]])
    if(is.null(stratumDefinition)) stop("Stratum definition must be supplied to map stratum observations.\n  Revise mapping or provide a stratum definition.")
  } else {
    if(!is.null(stratumDefinition)) stop("You need to include a mapping for 'stratumName' in order to map stratum observations.")
  }
  subPlotFlag = ("subPlotName" %in% names(mapping))
  if(subPlotFlag) {
    subPlotNames = as.character(x[[mapping[["subPlotName"]]]])
  }
  taxonNameFlag = ("taxonName" %in% names(mapping))
  if(taxonNameFlag) {
    taxonNames = as.character(x[[mapping[["taxonName"]]]])
  }
  organismNameFlag = ("organismName" %in% names(mapping))
  if(organismNameFlag) {
    organismNames = as.character(x[[mapping[["organismName"]]]])
  }

  #heightmeasurement
  aggMeasurementValues = list()
  heightMeasurementFlag = ("heightMeasurement" %in% names(mapping))
  if(heightMeasurementFlag) {
    if(!("heightMeasurement" %in% names(methods))) stop("Method definition must be provided for 'heightMeasurement'.")
    aggMeasurementValues[["heightMeasurement"]] = as.character(x[[mapping[["heightMeasurement"]]]])
  }

  aggmesmapping = mapping[!(names(mapping) %in% c(aggObservationMapping, "heightMeasurement"))]
  if(verbose && (length(aggmesmapping)>0)) cat(paste0(" ", length(aggmesmapping)," additional aggregate organism measurements found: ",paste(aggmesmapping, collapse = ", ") ,".\n"))
  if(length(aggmesmapping)>0) {
    for(i in 1:length(aggmesmapping)){
      if(!(names(aggmesmapping)[[i]] %in% names(methods))) stop("Method definition must be provided for '",names(aggmesmapping)[[i]],"'.")
      aggMeasurementValues[[names(aggmesmapping)[i]]] = as.character(x[[aggmesmapping[[i]]]])
    }
  }

  #Check duplicate records
  # aggObservationMapping = c("plotName", "obsStartDate", "subPlotName", "stratumName", "organismName",
  #                           "taxonName")

  mapcols = as.character(mapping[aggObservationMapping[c(T,T,subPlotFlag,stratumFlag,organismNameFlag,
                                                         taxonNameFlag)]])
  xstrings = apply(x[, mapcols],1, paste, collapse=" ")
  us = length(unique(xstrings))
  if(us<nrow(x)) warning(paste0(nrow(x)-us," duplicate records found!"))

  #add methods
  methodIDs = character(0)
  methodCodes = list()
  methodAttIDs = list()
  for(m in names(methods)) {
    method = methods[[m]]
    if(class(method)=="character") {
      method = predefinedMeasurementMethod(method)
      methods[[m]] = method
    }
    else if (class(method) != "VegXMethodDefinition") stop(paste("Wrong class for method: ",m ,"."))
    nmtid = .newMethodIDByName(target,method@name)
    methodID = nmtid$id
    methodIDs[[m]] = methodID
    methodCodes[[m]] = character(0)
    methodAttIDs[[m]] = character(0)
    if(nmtid$new) {
      target@methods[[methodID]] = list(name = method@name,
                                        description = method@description,
                                        subject = method@subject,
                                        attributeType = method@attributeType)
      if(verbose) cat(paste0(" Measurement method '", method@name,"' added for '",m,"'.\n"))
      # add literature citation if necessary
      if(method@citationString!="") {
        ncitid = .newLiteratureCitationIDByCitationString(target, method@citationString)
        if(ncitid$new) {
          target@literatureCitations[[ncitid$id]] = list(citationString =method@citationString)
          if(method@DOI!="")  target@literatureCitations[[ncitid$id]]$DOI = method@DOI
        }
        target@methods[[methodID]]$citationID = ncitid$id
      }
      # add attributes if necessary
      methodAttIDs[[m]] = character(length(method@attributes))
      methodCodes[[m]] = character(length(method@attributes))
      for(i in 1:length(method@attributes)) {
        attid = .nextAttributeID(target)
        target@attributes[[attid]] = method@attributes[[i]]
        target@attributes[[attid]]$methodID = methodID
        methodAttIDs[[m]][i] = attid
        if(method@attributes[[i]]$type != "quantitative") methodCodes[[m]][i] = method@attributes[[i]]$code
      }
    } else {
      methodCodes[[m]] = .getAttributeCodesByMethodID(target,methodID)
      methodAttIDs[[m]] = .getAttributeIDsByMethodID(target,methodID)
      if(verbose) cat(paste0(" Measurement method '", method@name,"' for '",m,"' already included.\n"))
    }
  }

  # stratum definition
  if(stratumFlag) {
    stratumDefMethod = stratumDefinition@method
    snmtid = .newMethodIDByName(target,stratumDefMethod@name)
    strmethodID = snmtid$id
    if(snmtid$new) {
      target@methods[[strmethodID]] = list(name = stratumDefMethod@name,
                                           description = stratumDefMethod@description,
                                           subject = stratumDefMethod@subject,
                                           attributeType = stratumDefMethod@attributeType)
      if(verbose) cat(paste0(" Stratum definition method '", stratumDefMethod@name,"' added.\n"))
      # add literature citation if necessary
      if(stratumDefMethod@citationString!="") {
        ncitid = .newLiteratureCitationIDByCitationString(target, stratumDefMethod@citationString)
        if(ncitid$new) {
          target@literatureCitations[[ncitid$id]] = list(citationString =stratumDefMethod@citationString)
          if(stratumDefMethod@DOI!="")  target@literatureCitations[[ncitid$id]]$DOI = stratumDefMethod@DOI
        }
        target@methods[[strmethodID]]$citationID = ncitid$id
      }
      # add attributes if necessary
      if(length(stratumDefMethod@attributes)>0) {
        for(i in 1:length(stratumDefMethod@attributes)) {
          attid = .nextAttributeID(target)
          target@attributes[[attid]] = stratumDefMethod@attributes[[i]]
          target@attributes[[attid]]$methodID = strmethodID
        }
      }
      # add strata (beware of new strata)
      orinstrata = length(target@strata)
      nstr = length(stratumDefinition@strata)
      stratumIDs = character(0)
      stratumNames = character(0)
      for(i in 1:nstr) {
        strid = .nextStratumID(target)
        stratumIDs[i] = strid
        stratumNames[i] = stratumDefinition@strata[[i]]$stratumName
        target@strata[[strid]] = stratumDefinition@strata[[i]]
        target@strata[[strid]]$methodID = strmethodID
      }
      finnstrata = length(target@strata)
      if(verbose) {
        cat(paste0(" ", finnstrata-orinstrata, " new stratum definitions added.\n"))
      }
    }
    else { #Read stratum IDs and stratum names from selected method
      if(verbose) cat(paste0(" Stratum definition '", stratumDefMethod@name,"' already included.\n"))
      stratumIDs = .getStratumIDsByMethodID(target,strmethodID)
      stratumNames = .getStratumNamesByMethodID(target,strmethodID)
    }
  }

  orinplots = length(target@plots)
  orinplotobs = length(target@plotObservations)
  orinstrobs = length(target@stratumObservations)
  orinons = length(target@organismNames)
  orinois = length(target@organismIdentities)
  orinaggobs = length(target@aggregateObservations)
  parsedPlots = character(0)
  parsedPlotIDs = character(0)
  parsedPlotObs = character(0)
  parsedPlotObsIDs = character(0)
  parsedONs = character(0)
  parsedONIDs = character(0)
  parsedTCs = character(0)
  parsedTCIDs = character(0)
  parsedOIs = character(0)
  parsedOIIDs = character(0)
  parsedStrObs = character(0)
  parsedStrObsIDs = character(0)
  aggObsCounter = orinaggobs+1 #counter
  #Record parsing loop
  for(i in 1:nrecords) {
    #plot
    if(!(plotNames[i] %in% missing.values)) {# If plotName is missing take the previous one
      plotName = plotNames[i]
    }
    if(!(plotName %in% parsedPlots)) {
      npid = .newPlotIDByName(target, plotName) # Get the new plot ID (internal code)
      plotID = npid$id
      if(npid$new) target@plots[[plotID]] = list("plotName" = plotName)
      parsedPlots = c(parsedPlots, plotName)
      parsedPlotIDs = c(parsedPlotIDs, plotID)
    } else { #this access should be faster
      plotID = parsedPlotIDs[which(parsedPlots==plotName)]
    }
    #subplot (if defined)
    if(subPlotFlag){
      if(!(subPlotNames[i] %in% missing.values)) {# If subPlotName is missing use parent plot ID
        subPlotCompleteName = paste0(plotNames[i],"_", subPlotNames[i])
        if(!(subPlotCompleteName %in% parsedPlots)) {
          parentPlotID = plotID
          npid = .newPlotIDByName(target, subPlotCompleteName) # Get the new subplot ID (internal code)
          plotID = npid$id
          if(npid$new) target@plots[[plotID]] = list("plotName" = subPlotCompleteName,
                                                     "parentPlotID" = parentPlotID)
          parsedPlots = c(parsedPlots, subPlotCompleteName)
          parsedPlotIDs = c(parsedPlotIDs, plotID)
        } else { #this access should be faster
          plotID = parsedPlotIDs[which(parsedPlots==subPlotCompleteName)]
        }
      }
    }
    #plot observation
    if(!(obsStartDates[i] %in% missing.values)) {# If observation date is missing take the previous one
      obsStartDate = obsStartDates[i]
    }
    pObsString = paste(plotID, as.character(obsStartDate)) # plotID+Date
    if(!(pObsString %in% parsedPlotObs)) {
      npoid = .newPlotObsIDByDate(target, plotID, obsStartDate) # Get the new plot observation ID (internal code)
      plotObsID = npoid$id
      if(npoid$new) {
        target@plotObservations[[plotObsID]] = list("plotID" = plotID,
                                                    "obsStartDate" = obsStartDate)
      }
      parsedPlotObs = c(parsedPlotObs, pObsString)
      parsedPlotObsIDs = c(parsedPlotObsIDs, plotObsID)
    } else {
      plotObsID = parsedPlotObsIDs[which(parsedPlotObs==pObsString)]
    }

    # Process organism name/taxon concept/identity
    organismName = NA
    oiID = NA
    tcID = NA
    isTaxon = FALSE
    taxonConceptString = ""
    citationString = ""
    if(taxonNameFlag) {
      organismName = taxonNames[i]
      isTaxon = TRUE
    }
    if(!isTaxon && organismNameFlag) {
      organismName = organismNames[i]
    }
    if(!(organismName %in% missing.values)) { #Process organism name and identity if the name is not missing
      if(!(organismName %in% parsedONs)) {
        nonid = .newOrganismNameIDByName(target, organismName, isTaxon) # Get the new organism name usage ID (internal code)
        onID = nonid$id
        if(nonid$new) target@organismNames[[onID]] = list("name" = organismName,
                                                          "taxon" = isTaxon)
        parsedONs = c(parsedONs, organismName)
        parsedONIDs = c(parsedONIDs, onID)
      } else {
        onID = parsedONIDs[which(parsedONs==organismName)]
      }
      # taxon concept
      # if(!is.null(citationStringAll)) {
      #   citationString = citationStringAll
      # }
      # if(citationStringFlag){
      #   if(!(citationStringData[i] %in% missing.values)) { #If there is citation data in a column, this overrides the string for all data set
      #     citationString = citationStringData[i]
      #   }
      # }
      taxonConceptString = paste(organismName, citationString)
      # if(citationString!="") { # Parse taxon concept only if citation string is not missing
      #   if(!(taxonConceptString %in% parsedTCs)) {
      #     ntcid = .newTaxonConceptIDByNameCitation(target, organismName, taxonConceptString) # Get the new taxon concept ID (internal code)
      #     tcID = ntcid$id
      #     if(ntcid$new) {
      #       ncitid = .newLiteratureCitationIDByCitationString(target, citationString)
      #       if(ncitid$new) {
      #         target@literatureCitations[[ncitid$id]] = list(citationString = citationString)
      #       }
      #       target@taxonConcepts[[tcID]] = list("organismNameID" = onID,
      #                                           "citationID" = ncitid$id)
      #     }
      #     parsedTCs = c(parsedTCs, taxonConceptString)
      #     parsedTCIDs = c(parsedTCIDs, tcID)
      #   } else {
      #     tcID = parsedTCIDs[which(parsedTCs==taxonConceptString)]
      #   }
      # }

      # organism identity
      if(!(taxonConceptString %in% parsedOIs)) {
        noiid = .newOrganismIdentityIDByTaxonConcept(target, organismName, citationString) # Get the new taxon name usage ID (internal code)
        oiID = noiid$id
        if(noiid$new) target@organismIdentities[[oiID]] = list("originalOrganismNameID" = onID)
        parsedOIs = c(parsedOIs, taxonConceptString)
        parsedOIIDs = c(parsedOIIDs, oiID)
      } else {
        oiID = parsedOIIDs[which(parsedOIs==taxonConceptString)]
      }
      if(!is.na(tcID)) target@organismIdentities[[oiID]]$originalConceptIdentification = list(taxonConceptID = tcID)
    }
    # stratum observations
    strObsID = ""
    if(stratumFlag) {
      if(!(stratumNamesData[i] %in% missing.values)) { # If stratum name is missing do not add stratum information
        stratumName = stratumNamesData[i]
        if(!(stratumName %in% stratumNames)) stop(paste0(stratumName," not found within stratum names. Revise stratum definition or data."))
        strID = stratumIDs[which(stratumNames==stratumName)]
        strObsString = paste(plotObsID, strID) # plotObsID+stratumID
        if(!(strObsString %in% parsedStrObs)) {
          nstroid = .newStratumObsIDByIDs(target, plotObsID, strID) # Get the new stratum observation ID (internal code)
          strObsID = nstroid$id
          if(nstroid$new) target@stratumObservations[[strObsID]] = list("plotObservationID" = plotObsID,
                                                                        "stratumID" = strID)
          parsedStrObs = c(parsedStrObs, strObsString)
          parsedStrObsIDs = c(parsedStrObsIDs, strObsID)
        } else {
          strObsID = parsedStrObsIDs[which(parsedStrObs==strObsString)]
        }
      }
    }

    if(is.na(oiID)) stop(paste0("Missing identity for record #", i,". Please fix source data table."))

    # agg org observations
    naoID = .newAggregateOrganismObservationIDByOrganismIdentityID(target, plotObsID, strObsID, oiID)
    aggObsID = naoID$id
    if(naoID$new) {
      aggObs = list("plotObservationID" = plotObsID,
                    "organismIdentityID" = oiID,
                    "stratumObservationID" = "")
      if(stratumFlag) aggObs$stratumObservationID = strObsID
    }
    else {
      aggObs = target@aggregateObservations[[aggObsID]]
    }

    # height limit measurements
    for(m in c("heightMeasurement")) {
      if(m %in% names(mapping)) {
        method = methods[[m]]
        attIDs = methodAttIDs[[m]]
        codes = methodCodes[[m]]
        value = as.character(aggMeasurementValues[[m]][i])
        if(!(value %in% as.character(missing.values))) {
          if(method@attributeType== "quantitative") {
            value = as.numeric(value)
            if(value> method@attributes[[1]]$upperLimit) {
              stop(paste0("Height '", value,"' larger than upper limit of measurement definition. Please revise scale or data."))
            }
            else if(value < method@attributes[[1]]$lowerLimit) {
              stop(paste0("Height '", value,"' smaller than lower limit of measurement definition. Please revise scale or data."))
            }
            aggObs[[m]] = list("attributeID" = attIDs[1], "value" = value)
          } else {
            ind = which(codes==as.character(value))
            if(length(ind)==1) {
              aggObs[[m]] = list("attributeID" = attIDs[ind], "value" = value)
            }
            else stop(paste0("Value '", value,"' not found in height measurement definition. Please revise height classes or data."))
          }
        } else {
          nmissing = nmissing + 1
        }
      }
    }
    # stratum measurements
    for(m in names(aggmesmapping)) {
      method = methods[[m]]
      attIDs = methodAttIDs[[m]]
      codes = methodCodes[[m]]
      value = as.character(aggMeasurementValues[[m]][i])
      if(!(value %in% as.character(missing.values))) {
        if(!("aggregateOrganismMeasurements" %in% names(aggObs))) aggObs$aggregateOrganismMeasurements = list()
        mesID = as.character(length(aggObs$aggregateOrganismMeasurements)+1)
        if(method@attributeType== "quantitative") {
          value = as.numeric(value)
          if(value> method@attributes[[1]]$upperLimit) {
            stop(paste0("Value '", value,"' larger than upper limit of measurement definition for '",m,"'. Please revise scale or data."))
          }
          else if(value < method@attributes[[1]]$lowerLimit) {
            stop(paste0("Value '", value,"' smaller than lower limit of measurement definition for '",m,"'. Please revise scale or data."))
          }
          aggObs$aggregateOrganismMeasurements[[mesID]] = list("attributeID" = attIDs[1], "value" = value)
        } else {
          ind = which(codes==value)
          if(length(ind)==1) {
            aggObs$aggregateOrganismMeasurements[[mesID]] = list("attributeID" = attIDs[ind], "value" = value)
          }
          else stop(paste0("Value '", value,"' not found in measurement definition for '",m,"'. Please revise height classes or data."))
        }
      }
      else {
        nmissing = nmissing + 1
      }
    }
    #Store value in target
    target@aggregateObservations[[aggObsID]] = aggObs
  }
  finnplots = length(target@plots)
  finnplotobs = length(target@plotObservations)
  finnstrobs = length(target@stratumObservations)
  finnons = length(target@organismNames)
  finnois = length(target@organismIdentities)
  finnaggobs = length(target@aggregateObservations)
  if(verbose) {
    cat(paste0(" " , length(parsedPlots)," plot(s) parsed, ", finnplots-orinplots, " new added.\n"))
    cat(paste0(" " , length(parsedPlotObs)," plot observation(s) parsed, ", finnplotobs-orinplotobs, " new added.\n"))
    cat(paste0(" " , length(parsedONs)," organism names(s) parsed, ", finnons-orinons, " new added.\n"))
    cat(paste0(" " , length(parsedOIs)," organism identitie(s) parsed, ", finnois-orinois, " new added.\n"))
    if(stratumFlag) cat(paste0(" " , length(parsedStrObs)," stratum observation(s) parsed, ", finnstrobs-orinstrobs, " new added.\n"))
    cat(paste0(" ", nrecords," record(s) parsed, ", finnaggobs-orinaggobs, " new aggregate organism observation(s) added.\n"))
    if(nmissing>0) cat(paste0(" ", nmissing, " aggregate organism observation(s) with missing abundance value(s) not added.\n"))
  }


  return(target)
}
