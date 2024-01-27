# # Install required packages if not already installed
# if (!requireNamespace("rmarkdown", quietly = TRUE)) {
#   install.packages("rmarkdown")
# }
# 
# if (!requireNamespace("pagedown", quietly = TRUE)) {
#   install.packages("pagedown")
# }
# 
# # Load the required libraries
# library(rmarkdown)
# library(pagedown)
# 
# # Set the RMD file name
# rmd_file <- "monthly_stockVsorders_master.rmd"
# 
# # Render R Markdown to HTML
# rmarkdown::render(rmd_file, output_format = "html_document")
# 
# # Convert HTML to PDF using chrome_print
# pagedown::chrome_print(paste0(tools::file_path_sans_ext(rmd_file), ".html"), 
#                        output = paste0(tools::file_path_sans_ext(rmd_file), ".pdf"))


# Install required packages if not already installed
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown")
}

if (!requireNamespace("pagedown", quietly = TRUE)) {
  install.packages("pagedown")
}

# Load the required libraries
library(rmarkdown)
library(pagedown)

# Data frame with shop names and image names
shop_data <- data.frame(
  shop_name = c("Shop1", "Shop2", "Shop3"),
  image_name = c("ZUE.png", "XYZ.png", "ABC.png")
)

# Loop through each row in the data frame
for (i in seq_len(nrow(shop_data))) {
  # Set the RMD file name
  rmd_file <- "monthly_stockVsorders_master.rmd"
  
  # Shop name and image name from the data frame
  shop_name <- shop_data$shop_name[i]
  image_name <- shop_data$image_name[i]
  
  # Read the RMD file content
  rmd_content <- readLines(rmd_file, warn = FALSE)
  
  # Replace the word "Partner" with the shop name in the RMD content
  rmd_content <- gsub("Partner", shop_name, rmd_content)
  
  # Insert the image dynamically without assuming a specific pattern
  rmd_content <- gsub("<!--IMAGE_PLACEHOLDER-->", paste0("![](`r file.path(getwd(), '", image_name, "')`)"), rmd_content)
  
  # Write the modified RMD content to a temporary file
  temp_rmd_file <- tempfile(fileext = ".rmd")
  writeLines(rmd_content, temp_rmd_file)
  
  # Render R Markdown to HTML
  rmarkdown::render(temp_rmd_file, output_format = "html_document")
  
  # Convert HTML to PDF using chrome_print
  output_pdf <- paste0(tools::file_path_sans_ext(temp_rmd_file), "_", shop_name, ".pdf")
  pagedown::chrome_print(paste0(tools::file_path_sans_ext(temp_rmd_file), ".html"), output = output_pdf)
  
  # Clean up temporary RMD file
  unlink(temp_rmd_file)
  
  # Print the path to the generated PDF
  cat("PDF generated at:", normalizePath(output_pdf), "\n")
}
