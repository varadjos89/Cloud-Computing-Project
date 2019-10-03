package com.csye.recipe;

import com.csye.recipe.pojo.NutritionInformation;
import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.pojo.Steps;
import com.csye.recipe.repository.RecipeRepository;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

import java.util.Date;
import java.util.UUID;

public class RecipeTest {

    @Mock
    RecipeRepository recipeDao = Mockito.mock(RecipeRepository.class);

    @Test
    public void testAddRecipe(){



        UUID id = UUID.randomUUID();
        Date d = new Date();
        Recipe recipe = new Recipe();

        recipe.setId(id);
        recipe.setCreatedTs(d);
        recipe.setUpdatedTs(d);
        recipe.setAuthorId(id);
        recipe.setCookTimeInMin(30);
        recipe.setPrepTimeInMin(10);
        recipe.setTotalTimeInMin(40);
        recipe.setTitle("Test-Recipe");
        recipe.setCusine("Test-Cuisine");
        recipe.setServings(3);
        recipe.getIngredients().add("test");

        //new dummy step object
        Steps s = new Steps();
        s.setPosition(1);
        s.setItems("test step");
        recipe.getSteps().add(s);

        //new Nutrition info obj
        NutritionInformation n = new NutritionInformation();
        n.setCalories(2000);
        n.setCarbohydratesInGrams(90);
        n.setCholesterolInMg(8);
        n.setProteinInGrams(200);
        n.setSodiumInMg(900);
        recipe.setNutritionInformation(n);

        recipeDao.save(recipe);

        Mockito.verify(recipeDao,Mockito.times(1)).save(recipe);


    }
}