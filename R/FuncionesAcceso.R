# ==============================================================================
# Librería para Carga de Datos del Portal de Hacienda
# Buscar, descargar y proyectar rápidamente series..
# FERGD 12-2017
# 08-18: Actualización de series. Incremento del timeout default para evitar problemas recurrentes
# 05-20: Preparado para CRAN. Se eliminó base offline y caracteres non-ASCII
# ==============================================================================

# Importar el operador de pipe
#' @importFrom magrittr "%>%"
magrittr::`%>%`
#' @importFrom utils "download.file"
utils::globalVariables(c("serie_descripcion", "serie_id"))   # Evitar notes del check

# Mensaje de Bienvenida
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "=============================================================================" %+% "\n" %+%
    "Acceso API Portal Datos Hacienda - v 0.1.0 - 05-2020 por F.Garc" %+%
    "\U00ED" %+% "a D" %+% "\U00ED" %+% "az" %+% "\n" )
}

# Definición Funciones internas helpers
# Concatenar
"%+%" <- function(x, y) paste(x, y, sep = "")
# Detectar periocididad para lags
freq <- function(x) {
                      switch(xts::periodicity(x)$scale,
                      daily = 365,
                      weekly = 52,
                      monthly = 12,
                      quarterly = 4,
                      yearly = 1)
  }

# ==========================================================================
#' Acceder a la API del Portal de Datos
#'
#' \code{Get} devuelve la serie seleccionada en series = ID. Para un detalle sobre las opciones
#' disponibles en parametros consultar:
#' \url{https://series-tiempo-ar-api.readthedocs.io/es/latest/}
#'
#' @param series ID de la serie a obtener
#' @param start_date Fecha de inicio
#' @param end_date Fecha de final
#' @param representation_mode Indica el modo de representacion de las series
#' @param collapse Modifica la frecuencia de muestreo de los datos de la serie
#' @param collapse_aggregation Indica la función de agregacion temporal que debe usarse para homogeneizar la frecuencia temporal de todas las series solicitadas
#' @param limit Limite de datos a obtener (para evitar descargas fallidas siempre verificar el cumplimiento de los maximos permitidos por la API)
#' @param timeout Timeout para la conección a la API de datos
#' @param detail Agregar detalles a las series (requiere descarga de base de metadatos)
#'
#' @return Un objeto XTS con la serie seleccionada en ID
#' @export
#' @examples
#' # Cargar serie mensual de TCN
#' TCN     <- Get("174.1_T_DE_CATES_0_0_32")
#' # Cargar serie mensual de TCN, transformada en anual y en variaciones
#' TCN <- Get("174.1_T_DE_CATES_0_0_32", start_date = 1999, collapse = "year",
#' collapse_aggregation = "avg", representation_mode = "percent_change")
Get <- function(series, start_date = NULL, end_date = NULL, representation_mode = NULL,
                collapse = NULL, collapse_aggregation = NULL, limit = 1000, timeout = 5,
                detail = FALSE) {
  cat("Descagando series...\n")
  url_base <- "http://apis.datos.gob.ar/series/api/series?"                                      # Cambiar URL base si cambia en la WEB
  GETSAFE <- purrr::safely(httr::GET)   # enmarco en purrr para manejo de errores
  suppressMessages(serie <- GETSAFE(url = url_base, query = list(ids = series,
                                                                      start_date = start_date,
                                                                      end_date = end_date,
                                                                      representation_mode = representation_mode,
                                                                      collapse = collapse,
                                                                      collapse_aggregation = collapse_aggregation,
                                                                      format = "csv",
                                                                      limit = limit),
                                                                      httr::timeout(timeout)))
  if (is.null(serie$result)) {
    stop("Error general o timeout, por favor verificar conexi\u00F3n.")
    }
  suppressMessages(serie <- httr::content(serie$result , encoding = "UTF-8"))
  if ("errors" %in% names(serie)) stop("Error en la carga > " %+% serie$errors[[1]][[1]])
  if(detail == TRUE){
    Listado <- Search_online()
    Nombres <-  Listado %>% dplyr::filter(grepl(gsub("\\,", "\\|", series), serie_id)) %>%
    dplyr::select(serie_id, serie_descripcion)                                                   # obtener descripciones
    serie <- xts::xts(serie[, -1], order.by = lubridate::ymd(serie$indice_tiempo), unique = TRUE, desc = Nombres[2])  # Pasar a XTS
    attr(serie, "frequency") <- freq(serie)                                                        # Fijar frecuencia de la serie en el XTS
    print("Cargada/s las series: " %+% Nombres[1] %+% ". Descripci\u00F3n: " %+% Nombres[2])
    print("Cargados " %+% length(serie) %+% " datos, desde " %+% min(zoo::index(serie)) %+%
          " hasta " %+% max(zoo::index(serie)) %+% " Periodicidad estimada: " %+% xts::periodicity(serie)$scale)
  } else
  {
    serie <- xts::xts(serie[, -1], order.by = lubridate::ymd(serie$indice_tiempo), unique = TRUE)  # Pasar a XTS
    attr(serie, "frequency") <- freq(serie)                                                        # Fijar frecuencia de la serie en el XTS
    print("Cargada/s las series...")
    print("Cargados " %+% length(serie) %+% " datos, desde " %+% min(zoo::index(serie)) %+%
            " hasta " %+% max(zoo::index(serie)) %+% " Periodicidad estimada: " %+% xts::periodicity(serie)$scale)
  }
  return(serie)
}

# ==========================================================================
#' Extender series con proyecciones de auto.arima (paquete Forecast)
#'
#' Recomendado sólo para estimaciones rápidas.\code{Forecast} sólo acepta XTS con una única serie de tiempo. Para múltiples series usar \code{vForecast}
#'
#' @param SERIE XTS a extender
#'
#' @param N Cantidad de períodos a extender (detecta automáticamente la frecuencia de la serie)
#'
#' @param confidence Vector de intervalos de confianza a agregar en la salida (i.e. c(95)) o FALSE sin intervalos
#'
#' @param ... otros parámetros para \code{auto.arima}
#'
#' @return XTS con la serie expandida e intervalos de confianza al % seleccionado en level
#'
#' @export
#'
#' @importFrom zoo "as.Date"
#'
#' @examples
#' # Forecast de 12 meses del tipo de cambio
#' TCN <- Forecast(Get("174.1_T_DE_CATES_0_0_32"), N = 12 , confidence = c(80))
Forecast <- function(SERIE, N = 6, confidence = c(80), ...) {
  if (confidence == FALSE)
    level <- c(95)
  else
    level <- confidence
  attr(SERIE, "frequency") <- freq(SERIE)                                                    # Fijar su frecuencia en base a estimacion de periocididad
  SERIE.model <- forecast::auto.arima(SERIE, seasonal = TRUE, allowdrift = TRUE, ...)        # Estimar modelo (clave fijar frecuencia antes!)
  SERIE.fit <- forecast::forecast(SERIE.model, h = N, level = level)                         # Extraer forecasts
  # Construir el objeto XTS a partir del PIB.fit (porque sino devuelve fechas mal e inusable)
  if (confidence == FALSE) {
    SERIE.final <- cbind(y = SERIE)                                                           # sin intervalos de confianza
    SERIE.final <- rbind(SERIE.final,                                                         # pega el forecast, al que a su vez le pego fechas corregidas
                         xts::xts(cbind(y = SERIE.fit$mean),
                          timetk::tk_make_future_timeseries(zoo::as.Date(timetk::tk_index(SERIE, timetk_idx = TRUE)),
                                                                    n_future = N,
                                                                    inspect_weekdays = TRUE,
                                                                    inspect_months = TRUE)))
    }
    else {
    SERIE.final <- cbind(y = SERIE, y.lo = NA, y.hi = NA)                                     # agregar columnas dymmy
    SERIE.final <- rbind(SERIE.final,                                                         # pega el forecast, al que a su vez le pego fechas corregidas
                         xts::xts(cbind(y = SERIE.fit$mean, y.lo = SERIE.fit$lower, y.hi = SERIE.fit$upper),
                           timetk::tk_make_future_timeseries(zoo::as.Date(timetk::tk_index(SERIE, timetk_idx = TRUE)),
                                                                    n_future = N,
                                                                    inspect_weekdays = TRUE,
                                                                    inspect_months = TRUE)))
    }
  colnames(SERIE.final)[1] <- "y"
  print("Serie extendida " %+% N %+% " per\U00EDodos, usando el modelo auto detectado: " %+% SERIE.model)
  return(SERIE.final )
}

# ==========================================================================
#' Extender series con proyecciones de auto.arima (paquete Forecast)
#'
#' Recomendado sólo para estimaciones rápidas. A diferencia de \code{Forecast}, no devuelve intervalos de confianza, pero acepta
#' como input un XTS con múltiples series de tiempo.
#'
#' @param SERIE XTS a extender
#'
#' @param N Cantidad de períodos a extender (detecta automáticamente la frecuencia de la serie)
#'
#' @param ... Otros parámetros para \code{auto.arima}
#'
#' @return XTS con la series expandidas, acepta xts con muchas series
#'
#' @export
#'
#' @importFrom zoo "as.Date"
#'
#' @examples
#' \donttest{
#' #' # Forecast de 12 meses del tipo de cambio
#' TCN <- vForecast(Get("120.1_PCE_1993_0_24,120.1_ED1_1993_0_26"),12)
#' }
vForecast <- function(SERIE, N = 6, ...) {
  attr(SERIE, "frequency") <- freq(SERIE)                                                    # Fijar su frecuencia en base a estimacion de periocididad
  SERIE.fit <- lapply(SERIE, function(x) forecast::forecast(forecast::auto.arima(x,
                                   seasonal = TRUE, allowdrift = TRUE, ...), h = N)$mean)
  SERIE.fit <- data.frame(do.call(cbind, SERIE.fit))
  # Construir el objeto XTS a partir del PIB.fit (porque sino devuelve fechas mal e inusable)
  SERIE.final <- cbind(y = SERIE)                                                           # sin intervalos de confianza
  SERIE.final <- rbind(SERIE.final,                                                         # pega el forecast, al que a su vez le pego fechas corregidas
                       xts::xts(SERIE.fit,
                                timetk::tk_make_future_timeseries(zoo::as.Date(timetk::tk_index(SERIE, timetk_idx = TRUE)),
                                        n_future = N,
                                        inspect_weekdays = TRUE,
                                        inspect_months = TRUE)))
  print("Serie extendida " %+% N %+% " per\U00ED" %+% "odos, usando modelo auto detectado")
  return(SERIE.final)
}


#' Buscar series
#'
#' Buscar en el archivo de meta-datos online del Portal de Hacienda.
#' Utilizar \code{Search_online("*")} para descargar todos los metadatos y hacer búsquedas posteriores
#' sin descargar toda la base nuevamente.
#'
#' @param PATTERN Pattern de búsqueda en la descripción de la serie
#'
#' @return Tibble con las series disponibles que con descripción coincidente
#' @export
#'
#' @examples
#' \donttest{
#' Listado <- Search_online("Tipo de Cambio")
#' Todaslasseries <- Search_online("*")
#' }
Search_online <- function(PATTERN = "*") {
  cat("Descagando base de metadatos...\n")
  download.file("http://infra.datos.gob.ar/catalog/modernizacion/dataset/1/distribution/1.2/download/series-tiempo-metadatos.csv",
                file.path(tempdir(), "series-tiempo-metadatos.csv"))  # Fixed as per CRAN suggestion
  Temp  <- suppressMessages(suppressWarnings(readr::read_csv(file.path(tempdir(), "series-tiempo-metadatos.csv"))))
  unlink(file.path(tempdir(), "series-tiempo-metadatos.csv"))
  return(Temp %>% dplyr::filter(grepl(PATTERN, serie_descripcion, ignore.case = TRUE)) %>%
           tibble::as_tibble())
}


#' PortalHacienda: Interface R a la API de datos del Ministerio de Hacienda
#'
#' Un paquete R para acceder a la API del portal de datos del Ministerio de Hacienda de la República Argentina.
#' Se proveen funciones para buscar, descargar y proyectar las series de tiempo de la base.
#' An R client for the Ministry of Economy of Argentina time-series database API.
#' This package provides functions for searching, downloading and forecasting available time-series.
#'
#'
#'
#' @section PortalHacienda functions:
#' \code{Search_online} busca las series descargando la última versión del paquete de meta-datos (10mb aprox)
#'
#' \code{Get} obtiene las series desde la API
#'
#' \code{Forecast} extiende las series obtenidas con un modelo auto-detectado por el paquete **forecast** - Hyndman RJ, Khandakar Y (2008).
#'
#' \code{vForecast} extiende múltiples series obtenidas con un modelo auto-detectado por el paquete **forecast** - Hyndman RJ, Khandakar Y (2008).
#'
#' @docType package
#' @name PortalHacienda
NULL
