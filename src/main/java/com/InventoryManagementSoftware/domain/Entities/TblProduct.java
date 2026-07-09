package com.InventoryManagementSoftware.domain.Entities;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "tblProduct")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TblProduct {

    @Id
    private String productId;
    private String productName;
    private String manufacturer;
    private Integer quantity;
    private String barcode;
    private String pipCode;
    private Integer vat;
    private String navCode;
    private String price;
    private String batchExpiry;
    private String status;
}
