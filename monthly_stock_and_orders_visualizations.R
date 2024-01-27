
# Filtering stores based on certain conditions
dfStock_vs_Orders <- dfStore %>% filter(StoreStatus == TRUE, !StoreID %in% c(33, 39, 42, 91, 97, 63, 70, 66, 71, 98)) %>% arrange(StoreID)

# Extracting relevant data for stock updates and sales
dfShopStockandSales <- dfCustomerOrdersShipAreaCartProdStoreBrand %>% 
  select(OrderID, StoreID, StoreName, OrderStatus, DeliveryCharges, 
         TotalPrice, ResultDate, CartItemStatus, Month, Year, Month_Name) %>%
  filter(OrderStatus == 2, ResultDate >= "2020-01-01", CartItemStatus == 1) %>%
  group_by(OrderID, StoreID, StoreName, Month, Month_Name, Year) %>%
  summarise(Order = n(), Amount = sum(TotalPrice)) %>%
  select(Month, Month_Name, Year, Amount) %>%
  group_by(StoreID, StoreName, Month, Month_Name, Year) %>%
  summarise(Order = n(), Amount = sum(Amount)) %>%
  arrange(Month, Year) %>% 
  select(LogMonth=Month, SalesMonthName=Month_Name, LogYear=Year, TotalOrders=Order, TotalSales=Amount) %>% 
  
  # Joining with stock update logs
  full_join(dfLogs %>% 
              filter(ActionType == "Product_Stock") %>% 
              inner_join(dfStoreProducts, by="ProdID") %>% 
              filter(as.Date(LogDateTime) >= "2022-01-01") %>% 
              distinct(ProdID, LogDate=as.Date(LogDateTime), .keep_all = TRUE) %>% 
              mutate(Week = case_when(LogDay >= 1 & LogDay <= 7 ~ "Week 1",
                                      LogDay >= 8 & LogDay <= 14 ~ "Week 2",
                                      LogDay >= 15 & LogDay <= 21 ~ "Week 3",
                                      LogDay >= 22 & LogDay <= 28 ~ "Week 4",
                                      LogDay >= 29 & LogDay <= 31 ~ "Week 5")) %>% 
              group_by(Week, LogMonth, LogMonthName, LogYear, StoreName, StoreID) %>% 
              summarise(Count = n()) %>% 
              arrange(Week) %>% 
              pivot_wider(names_from = Week, values_from = Count, values_fill = 0), 
            by= c("StoreID", "StoreName", "LogMonth", "LogYear")) %>% 
  
  # Calculating total stock updates for each week
  mutate(TotalStockUpdates = `Week 1` + `Week 2` + `Week 3` + `Week 4` + `Week 5`) %>% 
  select(StoreID, StoreName, LogMonth, LogYear, LogMonthName=LogMonthName, 
         Week1=`Week 1`, Week2=`Week 2`, Week3=`Week 3`, Week4=`Week 4`, Week5=`Week 5`, TotalStockUpdates,
         TotalOrders, TotalSales) %>% 
  select(StoreID, StoreName, Month=LogMonth, MonthName=SalesMonthName, Year=LogYear,  
         Week1, Week2, Week3, Week4, Week5, TotalStockUpdates,
         TotalOrders, TotalSales) %>% 
  
  arrange(Year, Month) %>% 
  replace_na(list(Week1 = 0, Week2 = 0, Week3 = 0, Week4 = 0, Week5 = 0, TotalStockUpdates = 0,
                  TotalOrders = 0, TotalSales = 0)) %>% 
  
  # Filtering data for the year 2023 and excluding June
  filter(Year >= 2023, Month != 6) %>% 

# Inner join for checking out-of-stock percentage
dfShopStockandSales <- dfShopStockandSales %>% 
  inner_join(dfStoreProducts %>% filter(ProdStatus == 1,  StoreStatus == TRUE) %>% 
               mutate(StockStatus = if_else(AvailableQTY >= 1, "InStock", "OutOfStock")) %>% 
               group_by(StoreID, StoreName, StockStatus) %>% 
               summarise(Count = n()) %>% 
               pivot_wider(names_from = StockStatus, values_from = Count, values_fill = 0) %>% 
               mutate(OutOfStock_Percentage = OutOfStock / (InStock + OutOfStock) * 100) %>% 
               mutate_if(is.numeric, round, digit = 1) %>% 
               arrange(-OutOfStock_Percentage),
             by=c("StoreID", "StoreName")) %>% 
  filter(Year >= 2023, Month != 6) 

  
  
  # Looping through each store to generate individual plots
  for (i in 1:nrow(dfStock_vs_Orders)) {
    print(dfStock_vs_Orders$StoreName[i])
    
    # Filtering data for a specific store and the year 2023
    dfGetStoreID <- dfShopStockandSales %>% 
      filter(StoreID == dfStock_vs_Orders$StoreID[i], Year >= 2023)
    
    # Calculate scaled TotalOrders for the specific store
    max_stock_updates <- max(dfGetStoreID$TotalStockUpdates)
    max_orders <- max(dfGetStoreID$TotalOrders)
    scaled_orders <- dfGetStoreID$TotalOrders * (max_stock_updates / max_orders)
    
    # Extract unique month names for the specific store
    unique_months <- unique(dfGetStoreID$MonthName)
    
    # Order the MonthName variable
    dfGetStoreID$MonthName <- factor(dfGetStoreID$MonthName, levels = unique_months)
    
    # Define the desired color
    lighter_color <- adjustcolor("#d62394", alpha.f = 0.7)
    
    # Plot for the specific store
    ggplot(data = dfGetStoreID, aes(x = MonthName)) +
      geom_col(aes(y = TotalStockUpdates, fill = "Stock Updates"), size = 2, color = "#d62394") +
      geom_line(aes(y = scaled_orders, group = 1, color = "Total Orders"), size = 3) +
      geom_point(aes(y = scaled_orders), color = "#8800ab", size = 7) +
      geom_label(aes(y = TotalStockUpdates, label = TotalStockUpdates), vjust = -0.3, color = "white",
                 fill = "#d62394", size = 4, fontface = "bold") +  # Set font color as white and background as associated color
      geom_label(aes(y = scaled_orders, label = TotalOrders), vjust = 2, color = "white",
                 fill = "#8800ab", size = 4, fontface = "bold") +  # Set font color as white and background as associated color
      labs(title = paste0("Stock Updates vs. Orders - 2023 ", "(", dfGetStoreID$StoreName, ")"),
           subtitle = paste0("\nAvailable / In-Stock Products: ", dfGetStoreID$InStock,
                             "  ---  Unavailable / Out Of Stock Products: ", dfGetStoreID$OutOfStock,
                             "  ---  Out of Stock Percentage: ", max(dfGetStoreID$OutOfStock_Percentage), "%"),
           x = "Month",
           y = "Stock Update Count",
           fill = "", color = "") +  # Remove the fill and color labels
      scale_y_continuous(labels = comma, name = "Stock Update Count", position = "left") +
      scale_color_manual(values = c("#8800ab")) +
      scale_fill_manual(values = c(lighter_color)) +
      theme_bw() +
      theme(
        plot.title = element_text(size = 25, face = "bold"),
        plot.subtitle = element_text(size = 11.5, face = "bold", colour = "red"),  # Set subtitle text to bold
        axis.title = element_text(size = 18, face = "bold"),
        axis.text = element_text(size = 12, face = "bold"),  # Increase size and make bold
        axis.text.y = element_text(size = 14, face = "bold"),  # Set y-axis text to bold
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14),
        plot.caption = element_text(size = 10, face = "bold", colour = "red")  # Set caption text to bold
      ) +
      scale_y_continuous(labels = comma, name = "Stock Update Count", position = "right",
                         sec.axis = sec_axis(~. / (max_stock_updates / max_orders), name = "Order Count")) 
    # Save the plot in a specific directory with high resolution and DPI
    ggsave(filename = paste0("StockvsOrders/", dfStock_vs_Orders$StoreName[i], ".png"), plot = last_plot(), dpi = 300, width = 10, height = 8, units = "in")
    paste("Plot saved successfully, ", dfStock_vs_Orders$StoreName[i])
  }


# Looping through each store to generate ggplot for each store
for (i in 1:nrow(dfStock_vs_Orders)) {
  print(dfStock_vs_Orders$StoreName[i])
  
  # Filtering data for a specific store and the year 2023
  dfGetStoreID <- dfShopStockandSales %>% 
    filter(StoreID == dfStock_vs_Orders$StoreID[i], Year >= 2023)
  
  # Calculate scaled TotalOrders for the specific store
  max_stock_updates <- max(dfGetStoreID$TotalStockUpdates)
  max_orders <- max(dfGetStoreID$TotalOrders)
  scaled_orders <- dfGetStoreID$TotalOrders * (max_stock_updates / max_orders)
  
  # Extract unique month names for the specific store
  unique_months <- unique(dfGetStoreID$MonthName)
  
  # Order the MonthName variable
  dfGetStoreID$MonthName <- factor(dfGetStoreID$MonthName, levels = unique_months)
  
  # Define the desired color
  lighter_color <- adjustcolor("#d62394", alpha.f = 0.7)
  
  # Plot for the specific store
  ggplot(data = dfGetStoreID, aes(x = MonthName)) +
    geom_col(aes(y = TotalStockUpdates, fill = "Stock Updates"), size = 2, color = "#d62394") +
    geom_line(aes(y = scaled_orders, group = 1, color = "Total Orders"), size = 3) +
    geom_point(aes(y = scaled_orders), color = "#8800ab", size = 7) +
    geom_label(aes(y = TotalStockUpdates, label = TotalStockUpdates), vjust = -0.3, color = "white",
               fill = "#d62394", size = 4, fontface = "bold") +  # Set font color as white and background as associated color
    geom_label(aes(y = scaled_orders, label = TotalOrders), vjust = 2, color = "white",
               fill = "#8800ab", size = 4, fontface = "bold") +  # Set font color as white and background as associated color
    labs(title = paste0("Stock Updates vs. Orders - 2023 ", "(", dfGetStoreID$StoreName, ")"),
         subtitle = paste0("\nAvailable / In-Stock Products: ", dfGetStoreID$InStock,
                           "  ---  Unavailable / Out Of Stock Products: ", dfGetStoreID$OutOfStock,
                           "  ---  Out of Stock Percentage: ", max(dfGetStoreID$OutOfStock_Percentage), "%"),
         x = "Month",
         y = "Stock Update Count",
         fill = "", color = "") +  # Remove the fill and color labels
    scale_y_continuous(labels = comma, name = "Stock Update Count", position = "left") +
    scale_color_manual(values = c("#8800ab")) +
    scale_fill_manual(values = c(lighter_color)) +
    theme_bw() +
    theme(
      plot.title = element_text(size = 25, face = "bold"),
      plot.subtitle = element_text(size = 11.5, face = "bold", colour = "red"),  # Set subtitle text to bold
      axis.title = element_text(size = 18, face = "bold"),
      axis.text = element_text(size = 12, face = "bold"),  # Increase size and make bold
      axis.text.y = element_text(size = 14, face = "bold"),  # Set y-axis text to bold
      legend.position = "bottom",
      legend.text = element_text(size = 12),
      legend.title = element_text(size = 14),
      plot.caption = element_text(size = 10, face = "bold", colour = "red")  # Set caption text to bold
    ) +
    scale_y_continuous(labels = comma, name = "Stock Update Count", position = "right",
                       sec.axis = sec_axis(~. / (max_stock_updates / max_orders), name = "Order Count")) 
  # Save the plot in a specific directory with high resolution and DPI
  ggsave(filename = paste0("StockvsOrders/", dfStock_vs_Orders$StoreName[i],".png"), plot = last_plot(), dpi = 300, width = 10, height = 8, units = "in")
  paste("Plot saved successfully, ", dfStock_vs_Orders$StoreName[i])
}
