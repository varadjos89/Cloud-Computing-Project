package com.csye.recipe.repository;

import com.csye.recipe.pojo.Recipe;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RecipeRepository extends CrudRepository<Recipe,UUID> {
//    Optional<Recipe> findById(UUID id);

    List<Recipe> findByOrderByCreatedTs();
}
