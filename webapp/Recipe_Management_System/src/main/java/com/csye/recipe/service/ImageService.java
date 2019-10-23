package com.csye.recipe.service;

import com.csye.recipe.pojo.Image;
import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.repository.ImageRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.UUID;

@Service
public class ImageService {

    @Autowired
    private ImageRepository imageRepository;

    public Optional<Image> findByImageId(UUID id){
        return imageRepository.findById(id);
    }

    public boolean checkIfImageAlreadyExist(Recipe recipe){
        if(recipe.getImage()!=null){
            return false;
        }
        return true;
    }
}
