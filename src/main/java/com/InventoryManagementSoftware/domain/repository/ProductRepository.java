package com.InventoryManagementSoftware.domain.repository;

import com.InventoryManagementSoftware.domain.Entities.TblProduct;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends MongoRepository<TblProduct, String> {

    @Query("{manufacturer : ?0 }")
    List<TblProduct> findByManufacturer(String manufacturer);

    Optional<TblProduct> findByProductId(String productId);
}
