package com.InventoryManagementSoftware.application.controllers;

import com.InventoryManagementSoftware.application.ServiceImpl.ProductServiceImpl;
import com.InventoryManagementSoftware.domain.Entities.TblProduct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Controller
public class ProductController {

    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);

    @Autowired
    private ProductServiceImpl productService;

    @GetMapping("/")
    public String index() {
        return "redirect:/user/productList";
    }

    @GetMapping("/api/health")
    @ResponseBody
    public String healthCheck() {
        return "UP";
    }

    @GetMapping("/user/productList")
    public String getProducts(Model model) {
        List<TblProduct> productList = productService.getAllProducts();
        model.addAttribute("getProducts", productList);
        return "user/productList";
    }

    @GetMapping("/user/addProduct")
    public String addProduct(Model model) {
        model.addAttribute("addProducts", new TblProduct());
        return "user/addProductForm";
    }

    @PostMapping("/user/addProduct")
    public String addProduct(@ModelAttribute("addProducts") TblProduct product, Model model,
                             BindingResult result) {
        try {
            logger.info("Saving product: {}", product);
            productService.saveProduct(product);
            logger.info("Product added successfully");
        } catch (Exception e) {
            logger.error("Error adding product", e);
            if (result.hasErrors()) {
                model.addAttribute("addProducts", product);
                return "user/addProductForm";
            }
        }
        return "redirect:/user/productList";
    }

    @GetMapping(path = { "/user/editProduct", "/user/editProduct/{productId}" })
    public String editProduct(@PathVariable(value = "productId", required = false) String pathId,
                              @RequestParam(value = "productId", required = false) String paramId,
                              Model model) {
        String productId = pathId != null ? pathId : paramId;
        if (productId == null || productId.isEmpty()) {
            return "redirect:/user/productList";
        }
        TblProduct product = productService.getProductById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid product Id:" + productId));

        model.addAttribute("productget", product);
        return "user/editProductForm";
    }

    @PostMapping(path = { "/user/editProduct", "/user/editProduct/{productId}" })
    public String editProduct(@ModelAttribute("productget") TblProduct product, Model model,
                             BindingResult result) throws IOException {
        try {
            logger.info("Updating product: {}", product);
            productService.updateProduct(product);
            logger.info("Product updated successfully");
        } catch (Exception e) {
            logger.error("Error updating product", e);
            if (result.hasErrors()) {
                model.addAttribute("productget", product);
                return "user/editProductForm";
            }
            throw new IOException(e);
        }
        return "redirect:/user/productList";
    }
}