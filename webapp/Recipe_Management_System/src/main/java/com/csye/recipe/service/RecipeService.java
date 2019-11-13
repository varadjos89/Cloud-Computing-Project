package com.csye.recipe.service;

import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class RecipeService{

    @Autowired
    private RecipeRepository recipeRepository;

    public void deleteRecipeById(UUID id) {
        recipeRepository.deleteById(id);
    }

    public Optional<Recipe> findById(UUID id){
        return recipeRepository.findById(id);
    }

    public List<Recipe> findAll(User user) {

        Iterable<Recipe> recipes= recipeRepository.findAll();
        List<Recipe> list = new ArrayList<>();
        for(Recipe recipe:recipes){
            if(recipe.getAuthorId().toString().equals(user.getUserId())){
                list.add(recipe);
            }
        }
        return (List<Recipe>) recipes;
    }
}
