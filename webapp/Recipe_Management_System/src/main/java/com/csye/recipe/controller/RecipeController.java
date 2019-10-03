package com.csye.recipe.controller;

import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.pojo.Steps;
import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.RecipeRepository;
import com.csye.recipe.repository.UserRepository;
import com.csye.recipe.service.RecipeService;
import com.csye.recipe.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@RestController
public class RecipeController {

    @Autowired
    UserService userService;

    @Autowired
    private UserRepository userDao;

    @Autowired
    private RecipeRepository recipeDao;

//    @Autowired
//    private IRecipeService recipeService;
    @Autowired
    private RecipeService recipeService;

    @RequestMapping(value = "/v1/recipe", method = RequestMethod.POST, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> createRecipe(@RequestBody Recipe recipe, HttpServletRequest req, HttpServletResponse res){

        String[] userCredentials;
        String userName;
        String userHeader;

        if(recipe.getCookTimeInMin()%5!=0 || recipe.getPrepTimeInMin()%5!=0){
            return new ResponseEntity<Object>("Cook time and Prep time should be multiple of 5",HttpStatus.BAD_REQUEST);
        }

        if(recipe.getCookTimeInMin()==0 || recipe.getPrepTimeInMin()==0){
            return new ResponseEntity<Object>("Cook time and prep time cannot be zero",HttpStatus.BAD_REQUEST);
        }

        //System.out.println(recipe.getServings());
        if(recipe.getServings()>5 || recipe.getServings()<1){
            //System.out.println(recipe.getServings());
            return new ResponseEntity<Object>("Recipe serving should be between 1 and 5",HttpStatus.BAD_REQUEST);
        }

        if(recipe.getTitle()==null || recipe.getTitle().equals("")){
            return new ResponseEntity<Object>("Title cannot be null or blank",HttpStatus.BAD_REQUEST);
        }

        if(recipe.getCusine()==null || recipe.getCusine().equals("")){
            return new ResponseEntity<Object>("Cuisine cannot be null or blank",HttpStatus.BAD_REQUEST);
        }

        if(recipe.getIngredients().size()==0){
            return new ResponseEntity<Object>("No ingredients provided",HttpStatus.BAD_REQUEST);
        }

        if(recipe.getNutritionInformation()!=null){
            if(recipe.getNutritionInformation().getCalories()==0){
                return new ResponseEntity<Object>("Calories cannot be zero",HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getCarbohydratesInGrams()==0){
                return new ResponseEntity<Object>("Carbs cannot be zero",HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getCholesterolInMg()==0){
                return new ResponseEntity<Object>("Cholesterol cannot be zero",HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getProteinInGrams()==0){
                return new ResponseEntity<Object>("Proteins cannot be zero",HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getSodiumInMg()==0){
                return new ResponseEntity<Object>("Sodium cannot be zero",HttpStatus.BAD_REQUEST);
            }
        }else{
            return new ResponseEntity<Object>("Nutrition information cannot be blank!!",HttpStatus.BAD_REQUEST);
        }

        //for(Steps s:recipe.getSteps()){
            if(recipe.getSteps().size()==0){
            //if(s.getPosition()<1){
                return new ResponseEntity<Object>("Atleast one step required",HttpStatus.BAD_REQUEST);
            }
        //}

        userHeader = req.getHeader("Authorization");

        if(userHeader!=null && userHeader.startsWith("Basic")){
            userCredentials = userService.getUserCredentials(userHeader);
        }
        else{
            return new ResponseEntity<Object>(HttpStatus.BAD_REQUEST);
        }

        userName = userCredentials[0];

        User existUser = userDao.findByEmailId(userName);

        UUID id = UUID.randomUUID();
        recipe.setId(id);
        recipe.setCreatedTs(new Date());
        recipe.setUpdatedTs(new Date());
        recipe.setAuthorId(existUser.getUserId());
        recipe.setTotalTimeInMin(recipe.getCookTimeInMin()+recipe.getPrepTimeInMin());

        recipeDao.save(recipe);

        return new ResponseEntity<Object>(recipe,HttpStatus.CREATED);
    }

    @RequestMapping(value = "/v1/recipe/{id}", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> getRecipe(Recipe recipe, HttpServletRequest req, HttpServletResponse res,@PathVariable("id") UUID id){
        try {
            Optional<Recipe> existRecipe = recipeService.findById(id);
            if (existRecipe.isPresent()) {
                return new ResponseEntity<Object>(existRecipe, HttpStatus.OK);
            } else {
                return new ResponseEntity<Object>(HttpStatus.NOT_FOUND);
            }
        }
        catch(Exception e){
            return new ResponseEntity<Object>("Something went wrong!! Please check your id.",HttpStatus.BAD_REQUEST);
        }
    }