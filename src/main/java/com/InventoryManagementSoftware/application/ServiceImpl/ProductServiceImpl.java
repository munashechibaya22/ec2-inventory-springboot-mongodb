package com.InventoryManagementSoftware.application.ServiceImpl;

import com.InventoryManagementSoftware.application.Exception.EntityNotFoundException;
import com.InventoryManagementSoftware.domain.Entities.TblProduct;
import com.InventoryManagementSoftware.domain.Services.ProductService;
import com.InventoryManagementSoftware.domain.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Override
    public TblProduct saveProduct(TblProduct product) {
        if (product.getProductId() == null || product.getProductId().isEmpty()) {
            product.setProductId(UUID.randomUUID().toString().split("-")[0]);
        }
        return productRepository.save(product);
    }

    @Override
    public List<TblProduct> getAllProducts() {
        return productRepository.findAll();
    }

    @Override
    public List<TblProduct> getProductByManufacturer(String manufacturer) {
        return productRepository.findByManufacturer(manufacturer);
    }

    @Override
    public Optional<TblProduct> getProductById(String productId) {
        return productRepository.findByProductId(productId);
    }

    @Override
    public TblProduct updateProduct(TblProduct product) {
        Optional<TblProduct> existingProducts = productRepository.findByProductId(product.getProductId());
        if (!existingProducts.isPresent()) {
            throw new EntityNotFoundException("Product not found with id: " + product.getProductId());
        }
        TblProduct updateProducts = existingProducts.get();
        updateProducts.setManufacturer(product.getManufacturer());
        updateProducts.setProductName(product.getProductName());
        updateProducts.setQuantity(product.getQuantity());
        updateProducts.setBarcode(product.getBarcode());
        updateProducts.setPipCode(product.getPipCode());
        updateProducts.setVat(product.getVat());
        updateProducts.setNavCode(product.getNavCode());
        updateProducts.setPrice(product.getPrice());
        updateProducts.setBatchExpiry(product.getBatchExpiry());
        updateProducts.setStatus(product.getStatus());
        return productRepository.save(updateProducts);
    }
}
