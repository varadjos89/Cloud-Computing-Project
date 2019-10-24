package com.csye.recipe.repository;

import com.csye.recipe.pojo.Image;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ImageRepository extends CrudRepository<Image, UUID> {

    //Image findByImageId(UUID imageId);
    //Optional<Image> findById(UUID id);
    Image findByimageId(UUID imageId);

}
