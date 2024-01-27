
# Load required libraries
library(jsonlite)
library(dplyr)

# Function to fetch data from API
fetch_data <- function(url) {
  return(fromJSON(url))
}

# API URLs

# User data
user_list_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetAllUserList"
orders_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetAllOrdersList"
cart_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetCartList"
shipment_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetShipmentListdata"

# Store data
store_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetStoreListdata"
product_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetProductsList"
areas_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetAreaListdata"
categories_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetCategoriesListdata"
map_cat_prod_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetMapProCategoriesAll"

# Brand data
brands_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetListOfBrands"
map_brand_url <- "https://api4r.petsmarket.com/api/apps/v1/api.svc/GetMapProEntityAll"

# Fetch data from APIs

Data_UserList <- fetch_data(user_list_url) # Fetch user data
Data_Orders <- fetch_data(orders_url) # Fetch orders data
Data_Cart <- fetch_data(cart_url) # Fetch cart data
Data_Shipment <- fetch_data(shipment_url) # Fetch shipment data

Data_Store <- tbl_df(fetch_data(store_url)) # Fetch store data
Data_Product <- fetch_data(product_url) # Fetch product data
Data_Areas <- fetch_data(areas_url) # Fetch areas data
Data_Categories <- fetch_data(categories_url) # Fetch categories data
Data_MapCatProd <- fetch_data(map_cat_prod_url) # Fetch category-product mapping data

Data_Brands <- fetch_data(brands_url) # Fetch brands data
Data_Map_Brand <- fetch_data(map_brand_url) # Fetch brand mapping data


#---------------------------------Registered Users------------------------------
#-------------------------------------------------------------------------------

# Customers Table ---- 

# Extracting user data from the fetched JSON
dfUsersList <- tbl_df(Data_UserList$ListOfUsers)

# Creating a new column 'FullName' by concatenating 'Name' and 'LastName'
dfUsersList$FullName <- paste(dfUsersList$Name, dfUsersList$LastName)

# Creating a tibble with selected columns and renaming them
dfUsersList <- tibble::as_tibble(dfUsersList %>% select(id, FullName, Email, CreatedDate, Phone))
names(dfUsersList)[names(dfUsersList) == "id"] <- "UserID"
names(dfUsersList)[names(dfUsersList) == "CreatedDate"] <- "RegDateTime"
names(dfUsersList)[names(dfUsersList) == "Phone"] <- "Mobile"

# Removing the first row (assuming it's a header row)
dfUsersList <- dfUsersList[-1, ] 

# Converting the registration datetime to 24 hours format
dfUsersList$RegDateTime <- strptime(dfUsersList$RegDateTime, "%m/%d/%Y %I:%M:%S %p") 

# Converting the datetime to date 
dfUsersList$RegDate <- as.Date(dfUsersList$RegDateTime)

# Converting the datetime to time
dfUsersList$RegTime <-  format(as.POSIXct(dfUsersList$RegDateTime), format = "%H:%M:%S")
dfUsersList$Mobile <- as.factor(dfUsersList$Mobile)

# Removing unwanted columns
dfUsersList <- dfUsersList[ ,-4] 

# Extracting hour from registration time
dfUsersList$RegHour <- format(as.POSIXct(dfUsersList$RegTime,format="%H:%M:%S"),"%H")
dfUsersList$RegHour <- as.integer(dfUsersList$RegHour)

# Extracting day, month, year, weekday, and month name from registration date
dfUsersList$RegDay <- day(as.POSIXlt(dfUsersList$RegDate, format="%m/%d/%y"))
dfUsersList$RegMonth <- month(as.POSIXlt(dfUsersList$RegDate, format="%m/%d/%y"))
dfUsersList$RegYear <- year(as.POSIXlt(dfUsersList$RegDate, format="%m/%d/%Y"))
dfUsersList$RegWeekDay <- weekdays(as.POSIXlt(dfUsersList$RegDate, format="%m/%d/%y"))
dfUsersList$RegMonth_Name <- months(as.POSIXlt(dfUsersList$RegDate, format="%m/%d/%y"))

#***************************************************************************
#BREAKER
#***************************************************************************

# Orders Table ----

# Creating a tibble from the fetched JSON data
dfOrders <- tbl_df(Data_Orders$ListOfOrders)

# Renaming columns for consistency
names(dfOrders)[names(dfOrders) == "Orderdate"] <- "OrderDate"
names(dfOrders)[names(dfOrders) == "result_date"] <- "ResultDate"

# Converting OrderDate to POSIXct format
dfOrders$OrderDate <- strptime(dfOrders$OrderDate, "%m/%d/%Y %I:%M:%S %p") 

# Extracting OrderTime in 24-hour format
dfOrders$OrderTime <- format(as.POSIXct(dfOrders$OrderDate), format = "%H:%M:%S")

# Converting OrderDate to Date format
dfOrders$OrderDate <- as.Date(dfOrders$OrderDate)

# Converting ResultDateTime to POSIXct format
dfOrders$ResultDateTime <- strptime(dfOrders$ResultDate, "%m/%d/%Y %I:%M:%S %p") 

# Extracting ResultTime in 24-hour format
dfOrders$ResultTime <- format(as.POSIXct(dfOrders$ResultDateTime), format = "%H:%M:%S")

# Converting ResultDate to Date format
dfOrders$ResultDate <- as.Date(dfOrders$ResultDateTime)

# Selecting specific columns for the Orders table
dfOrders <- dfOrders %>% select(UserId, OrderNumber, Browser, ResultDateTime, ResultDate, ResultTime, 
                                order_suptotal, shippingCost, order_discount, coupon_code, grand_total, 
                                OrderStatus, PaymentType, PaymentStatus, cStep, note, OrderDate, OrderTime)

# Renaming selected columns for consistency
names(dfOrders)[names(dfOrders) == "Browser"] <- "Source"
names(dfOrders)[names(dfOrders) == "OrderNumber"] <- "OrderID"
names(dfOrders)[names(dfOrders) == "UserId"] <- "UserID"
names(dfOrders)[names(dfOrders) == "shippingCost"] <- "DeliveryCharges"
names(dfOrders)[names(dfOrders) == "order_discount"] <- "Discount"
names(dfOrders)[names(dfOrders) == "coupon_code"] <- "Coupon"
names(dfOrders)[names(dfOrders) == "order_suptotal"] <- "SubTotal"
names(dfOrders)[names(dfOrders) == "grand_total"] <- "GrandTotal"
names(dfOrders)[names(dfOrders) == "note"] <- "Note"
names(dfOrders)[names(dfOrders) == "cStep"] <- "OrderStep"
names(dfOrders)[names(dfOrders) == "CreatedMethod"] <- "OrderMethod"

# Converting data types for selected columns
dfOrders$UserID <- as.integer(dfOrders$UserID)
dfOrders$SubTotal <- as.double(dfOrders$SubTotal)
dfOrders$GrandTotal <- as.double(dfOrders$GrandTotal)
dfOrders$Discount <- as.double(dfOrders$Discount)
dfOrders$DeliveryCharges <- as.double(dfOrders$DeliveryCharges)
dfOrders$OrderStatus <- as.integer(dfOrders$OrderStatus)
dfOrders$PaymentType <- as.integer(dfOrders$PaymentType)
dfOrders$PaymentStatus <- as.integer(dfOrders$PaymentStatus)

# Extracting additional date and time information
dfOrders$Hour <- format(as.POSIXct(dfOrders$ResultTime, format="%H:%M:%S"),"%H")
dfOrders$Hour <- as.integer(dfOrders$Hour)
dfOrders$Day <- day(as.POSIXlt(dfOrders$ResultDate, format="%m/%d/%y"))
dfOrders$Month <- month(as.POSIXlt(dfOrders$ResultDate, format="%m/%d/%y"))
dfOrders$Year <- year(as.POSIXlt(dfOrders$ResultDate, format="%m/%d/%Y"))
dfOrders$WeekDay <- weekdays(as.POSIXlt(dfOrders$ResultDate, format="%m/%d/%y"))
dfOrders$Month_Name <- months(as.POSIXlt(dfOrders$ResultDate, format="%m/%d/%y"))
dfOrders$OrderDTH <- format(as.POSIXct(dfOrders$OrderTime, format="%H:%M:%S"),"%H")
dfOrders$OrderDTH <- as.integer(dfOrders$OrderDTH)
dfOrders$Daily <- as.Date(dfOrders$ResultDate)

#***************************************************************************
#BREAKER
#***************************************************************************

# Cart Table ----

# Creating a tibble from the fetched JSON data
dfCart <- tbl_df(Data_Cart$ListOfCart)

# Calculating TotalPrice by multiplying Quantity and Price
dfCart$TotalPrice <- dfCart$Qty * dfCart$Price

# Selecting specific columns for the Cart table
dfCart <- tbl_df(dfCart %>% select(OrderId, Id, ProId, ProName, ProDesc, Price, Qty, TotalPrice, Status, CreatedDate))

# Renaming selected columns for consistency
names(dfCart)[names(dfCart) == "Id"] <- "CartID"
names(dfCart)[names(dfCart) == "OrderId"] <- "OrderID"
names(dfCart)[names(dfCart) == "ProId"] <- "ProdID"
names(dfCart)[names(dfCart) == "Status"] <- "CartItemStatus"
names(dfCart)[names(dfCart) == "CreatedDate"] <- "CartDateTime"
names(dfCart)[names(dfCart) == "Price"] <- "CartItemPrice"

# Converting data types for selected columns
dfCart$CartItemStatus <- as.integer(dfCart$CartItemStatus)
dfCart$CartItemPrice <- as.double(dfCart$CartItemPrice)
dfCart$TotalPrice <- as.double(dfCart$TotalPrice)

# Converting CartDateTime to POSIXct format
dfCart$CartDateTime <- strptime(dfCart$CartDateTime, "%m/%d/%Y %I:%M:%S %p")

# Converting CartDate to Date format
dfCart$CartDate <- as.Date(dfCart$CartDateTime)

#***************************************************************************
#BREAKER
#***************************************************************************

# Shipment Table ----

# Converting ListOfShipping to tibble format
dfShipment <- as_tibble(Data_Shipment$ListOfShipping)

# Creating ShipName by concatenating FirstName and LastName
dfShipment$ShipName <- paste(dfShipment$FName, dfShipment$LName)

# Renaming selected columns for consistency
names(dfShipment)[names(dfShipment) == "Id"] <- "ShipID"
names(dfShipment)[names(dfShipment) == "OrderId"] <- "OrderID"
names(dfShipment)[names(dfShipment) == "ShortName"] <- "Address"
names(dfShipment)[names(dfShipment) == "CreatedDate"] <- "AddShipDate"

# Selecting specific columns for the Shipment table
dfShipment <- tbl_df(dfShipment %>% select(OrderID, ShipID, AreaID, Phone, Address, CreatedMethod, AddShipDate))

# Converting AddShipDate to POSIXct format
dfShipment <- dfShipment %>% mutate(AddShipDate = strptime(AddShipDate, "%m/%d/%Y %I:%M:%S %p"))

#***************************************************************************
#BREAKER
#***************************************************************************

# Store Table ----

# Creating a tibble from the fetched JSON data
dfStore <- tbl_df(Data_Store$ListOfStore)

# Selecting specific columns for the Store table
dfStore <- tbl_df(dfStore %>% select(Id, NameEn, NameAr, Commission, CommissionNoneOwnedItems, CommissionOwnedItems, Status))

# Renaming selected columns for consistency
names(dfStore)[names(dfStore) == "Id"] <- "StoreID"
names(dfStore)[names(dfStore) == "NameEn"] <- "StoreName"
names(dfStore)[names(dfStore) == "Commission"] <- "StoreCommission"
names(dfStore)[names(dfStore) == "Status"] <- "StoreStatus"

#***************************************************************************
#BREAKER
#***************************************************************************

# Product Table ----

# Creating a tibble from the fetched JSON data
dfProduct <- tbl_df(Data_Product$ListOfProducts)

# Selecting specific columns for the Product table
dfProduct <- tbl_df(dfProduct %>% select(StoreID, Id, Name, NameAR, Slug, ShortDescription, 
                                         ShortDescriptionAr, Description, DescriptionAr, Cost, Price, isStorePickup,
                                         ImgURL, Barcode, AvailableQTY, Status, CreatedDate, Views, Disable, OrderID)) 

# Renaming selected columns for consistency
names(dfProduct)[names(dfProduct) == "Id"] <- "ProdID"
names(dfProduct)[names(dfProduct) == "Name"] <- "ProdName"
names(dfProduct)[names(dfProduct) == "ShortDescription"] <- "ProdShortDesc"
names(dfProduct)[names(dfProduct) == "Description"] <- "ProdLongDesc"
names(dfProduct)[names(dfProduct) == "ImgURL"] <- "ProdImgURL"
names(dfProduct)[names(dfProduct) == "Status"] <- "ProdStatus"
names(dfProduct)[names(dfProduct) == "NameAR"] <- "ProdNameAR"
names(dfProduct)[names(dfProduct) == "DescriptionAr"] <- "ProdLongDescAR"
names(dfProduct)[names(dfProduct) == "ShortDescriptionAr"] <- "ProdShortDescAR"
names(dfProduct)[names(dfProduct) == "CreatedDate"] <- "AddedItemDateTime"
names(dfProduct)[names(dfProduct) == "Disable"] <- "ProdInActive"
names(dfProduct)[names(dfProduct) == "Price"] <- "ProdPrice"
names(dfProduct)[names(dfProduct) == "OrderID"] <- "ProdSorting"

# Converting CreatedDate to POSIXct format
dfProduct$AddedItemDateTime <- strptime(dfProduct$AddedItemDateTime, "%m/%d/%Y %I:%M:%S %p") 

# Creating URLs for English and Arabic versions
dfProduct$ProdURLen <- paste0("https://www.petsmarket.com/en/dp/", dfProduct$Slug) 
dfProduct$ProdURLar <- paste0("https://www.petsmarket.com/ar/dp/", dfProduct$Slug) 

# Mutating columns for clarity
dfProduct <- dfProduct %>% 
  dplyr::mutate(ProdLocation = recode(isStorePickup, "0" = "Consignment", "1" = "Pick UP")) %>% 
  dplyr::mutate(ProdStatusName = recode(ProdStatus, "0" = "Draft", "1" = "Published", "2" = "Archived", "9" = "Mystery"))

#***************************************************************************
#BREAKER
#***************************************************************************

# Areas Table ----

# Creating a tibble from the fetched JSON data
dfAreas <- tbl_df(Data_Areas$ListOfArea)

# Selecting specific columns for the Areas table
dfAreas <- tbl_df(dfAreas %>% select(Id, Name, DeliveryCost))

# Renaming selected columns for consistency
names(dfAreas)[names(dfAreas) == "Id"] <- "AreaID"
names(dfAreas)[names(dfAreas) == "Name"] <- "AreaName"

#***************************************************************************
#BREAKER
#***************************************************************************

# MapCat Prod Table ----

# Creating a tibble from the fetched JSON data
dfMapCatProd <- tbl_df(Data_MapCatProd)

# Renaming selected columns for consistency
names(dfMapCatProd)[names(dfMapCatProd) == "catID"] <- "CatID"
names(dfMapCatProd)[names(dfMapCatProd) == "id"] <- "MapCatID"
names(dfMapCatProd)[names(dfMapCatProd) == "proId"] <- "ProdID"

#***************************************************************************
#BREAKER
#***************************************************************************

# Categories Table ----

# Creating a tibble from the fetched JSON data
dfCategories <- tbl_df(Data_Categories$ListOfCategories)

# Selecting specific columns for the Categories table
dfCategories <- tbl_df(dfCategories %>% select(Id, Name, UrlEn, ParentID))

# Renaming selected columns for consistency
names(dfCategories)[names(dfCategories) == "Id"] <- "CatID"
names(dfCategories)[names(dfCategories) == "Name"] <- "CatName"
names(dfCategories)[names(dfCategories) == "UrlEn"] <- "CatImgURL"
names(dfCategories)[names(dfCategories) == "ParentID"] <- "CatParentID"

#***************************************************************************
#BREAKER
#***************************************************************************

# Brands Mapping Table ----

# Creating a tibble from the fetched JSON data
dfMapBrand <- tibble::as_tibble(Data_Map_Brand)

# Renaming selected columns for consistency
names(dfMapBrand)[names(dfMapBrand) == "ProID"] <- "ProdID"
names(dfMapBrand)[names(dfMapBrand) == "EntityID"] <- "BrandID"

# Selecting specific columns for the Brands Mapping table
dfMapBrand <- dfMapBrand %>% select(BrandID, ProdID)
# rm(Data_Map_Brand)

# Brands Table ----

# Fetching JSON data for Brands from the specified URL
# Data_Brands <- fromJSON("https://petsmarket.com/api/apps/v1/api.svc/GetListOfBrands")

# Creating a tibble from the fetched JSON data
dfBrands <- tbl_df(Data_Brands$ListOfData)

# Renaming selected columns for consistency
names(dfBrands)[names(dfBrands) == "Id"] <- "BrandID"
names(dfBrands)[names(dfBrands) == "Name"] <- "BrandName"
names(dfBrands)[names(dfBrands) == "Ordernumber"] <- "BrandSorting"
names(dfBrands)[names(dfBrands) == "IsDisable"] <- "BrandStatus"
names(dfBrands)[names(dfBrands) == "ShowinNav"] <- "BrandList"
names(dfBrands)[names(dfBrands) == "NameAR"] <- "BrandAR"
names(dfBrands)[names(dfBrands) == "img_ar"] <- "BrandLogoAR"
names(dfBrands)[names(dfBrands) == "img_en"] <- "BrandLogoEN"

# Selecting specific columns for the Brands table
dfBrands <- dfBrands %>% select(BrandID, BrandName, BrandAR, BrandStatus,
                                IsActive, IsDeleted, BrandStatus,
                                BrandList, BrandSorting, BrandLogoEN, BrandLogoAR)

# Joining Brands table with the Brands Mapping table (dfMapBrand) on BrandID
dfBrands <- dfBrands %>% inner_join(dfMapBrand, by="BrandID")

# Creating a new column MultiBrands by grouping and concatenating BrandName for each ProdID
dfBrands <- dfBrands %>% 
  dplyr::distinct(BrandID, ProdID, .keep_all = TRUE) %>%
  group_by(ProdID) %>% 
  dplyr::mutate(MultiBrands = paste(BrandName, collapse=" ")) %>% 
  dplyr::distinct(ProdID, MultiBrands, .keep_all = TRUE) 

# Merging user data with order data based on UserID
dfCustomerOrders <- dfUsersList %>% inner_join(dfOrders, by="UserID")

# Merging the combined user and order data with cart data based on OrderID
dfCustomerOrdersShipAreaCart <- dfCustomerOrders %>% inner_join(dfCart, by="OrderID")

# Merging the above data with product data based on ProdID
dfCustomerOrdersShipAreaCartProd <- dfCustomerOrdersShipAreaCart %>% inner_join(dfProduct, by="ProdID")

# Merging the above data with store data based on StoreID
dfCustomerOrdersShipAreaCartProdStore <- dfCustomerOrdersShipAreaCartProd %>% inner_join(dfStore, by="StoreID")

# Merging the above data with brand data based on ProdID (left join)
dfCustomerOrdersShipAreaCartProdStoreBrand <- dfCustomerOrdersShipAreaCartProdStore %>% left_join(dfBrands, by = "ProdID")

# Creating a dataframe of store products by merging store data with product data based on StoreID
dfStoreProducts <- dfStore %>% inner_join(dfProduct, by="StoreID")

# Merging the above data with brand data based on ProdID (left join)
dfStoreBrandProducts <- dfStoreProducts %>% left_join(dfBrands, by = "ProdID")

# Merging category data with product mapping data based on CatID
dfCatMap <-  dfCategories %>% inner_join(dfMapCatProd, by="CatID")

# Merging the above data with store brand products data based on ProdID (right join)
dfStoreBrandProductsCatMap <- dfCatMap %>% right_join(dfStoreBrandProducts, by="ProdID")






