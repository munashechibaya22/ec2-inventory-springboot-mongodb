package com.InventoryManagementSoftware.domain.Entities;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "tblProduct")
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

    // Default constructor
    public TblProduct() {
    }

    // All-args constructor
    public TblProduct(String productId, String productName, String manufacturer, Integer quantity,
                      String barcode, String pipCode, Integer vat, String navCode, String price,
                      String batchExpiry, String status) {
        this.productId = productId;
        this.productName = productName;
        this.manufacturer = manufacturer;
        this.quantity = quantity;
        this.barcode = barcode;
        this.pipCode = pipCode;
        this.vat = vat;
        this.navCode = navCode;
        this.price = price;
        this.batchExpiry = batchExpiry;
        this.status = status;
    }

    // Getters and Setters
    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer) {
        this.manufacturer = manufacturer;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getBarcode() {
        return barcode;
    }

    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    public String getPipCode() {
        return pipCode;
    }

    public void setPipCode(String pipCode) {
        this.pipCode = pipCode;
    }

    public Integer getVat() {
        return vat;
    }

    public void setVat(Integer vat) {
        this.vat = vat;
    }

    public String getNavCode() {
        return navCode;
    }

    public void setNavCode(String navCode) {
        this.navCode = navCode;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public String getBatchExpiry() {
        return batchExpiry;
    }

    public void setBatchExpiry(String batchExpiry) {
        this.batchExpiry = batchExpiry;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
