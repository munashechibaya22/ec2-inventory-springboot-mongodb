package com.InventoryManagementSoftware.domain.Services;

import com.InventoryManagementSoftware.application.Exception.EntityNotFoundException;
import com.InventoryManagementSoftware.domain.Entities.TblProduct;

import java.util.List;
import java.util.Optional;

public interface ProductService {

    TblProduct saveProduct(TblProduct product);

    List<TblProduct> getAllProducts();

    List<TblProduct> getProductByManufacturer(String manufacturer);

    Optional<TblProduct> getProductById(String productId);

    TblProduct updateProduct(TblProduct product) throws EntityNotFoundException;
}
