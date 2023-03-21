#' @title Download species image
#'
#' @description Download an image or series of images for a species, from the Reef Life Survey website.
#'
#' @param species_name Character string of species name.
#' @param image_number Single integer value or a vector of integers with the image number.
#'
#' @return A magick image file.
#'
#' @import httr
#' @import magick
#' @import stringr
#' @import rvest
#'
#' @examples
#' \dontrun{
#' # get a single image for the species
#' get_species_image("Pseudocheilinus hexataenia")
#' get_species_image("Pseudocheilinus hexataenia", 1)
#'
#' # ...or a different single image
#' get_species_image("Pseudocheilinus hexataenia", 2)
#'
#' # or get a series of images for the species (will ignore when not enough images are available)
#' get_species_image("Pseudocheilinus hexataenia", 1:30)
#'
#' # NULL returns when no image available
#' get_species_image("Nonexistent species", 1)
#'
#' # including the image in a ggplot
#' my_img <- get_species_image("Pseudocheilinus hexataenia", 1)
#'
#' ggplot() +
#'   aes(x = 1:10,
#'       y = 1:10) +
#'   geom_point() +
#'   {if(!is.null(my_img))  annotation_raster(my_img,
#'                                            xmin = 1,
#'                                            xmax = 3,
#'                                            ymin = 8,
#'                                            ymax = 10) }
#' }
#'
#' @export
get_species_image <- function(species_name, image_number = 1){

  url <-
    "https://reeflifesurvey.com//species/" |>
    paste0(species_name |>
             tolower() |>
             stringr::str_replace_all(" ", "-"))

    if(!httr::http_error(url)){

    url_vector <-
      url |>
      rvest::read_html() |>
      rvest::html_elements("img") |>
      rvest::html_attr("src")

    n_spp_images <- sum(stringr::str_detect(url_vector, "species_"))

    n_images <- image_number[image_number<=n_spp_images]

    if(n_spp_images){
      url_vector[url_vector |> str_detect("species_")][n_images] |>
        magick::image_read()
    } else {
      NULL
    }

  } else {
    NULL
  }

}
