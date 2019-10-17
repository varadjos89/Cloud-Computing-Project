package com.csye.recipe.controller;

import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.pojo.Steps;
import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.RecipeRepository;
import com.csye.recipe.repository.UserRepository;
import com.csye.recipe.service.RecipeService;
import com.csye.recipe.service.UserService;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCrypt;
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
        String password;
        String userHeader;
        JSONObject jo;
        String error;

        if(recipe.getCookTimeInMin()%5!=0 || recipe.getPrepTimeInMin()%5!=0){
            error = "{\"error\": \"Cook time and Prep time should be multiple of 5\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(recipe.getCookTimeInMin()==0 || recipe.getPrepTimeInMin()==0){
            error = "{\"error\": \"Cook time and Prep time cannot be zero\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        //System.out.println(recipe.getServings());
        if(recipe.getServings()>5 || recipe.getServings()<1){
            //System.out.println(recipe.getServings());
            error = "{\"error\": \"Recipe serving should be between 1 and 5\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(recipe.getTitle()==null || recipe.getTitle().equals("")){
            error = "{\"error\": \"Title cannot be null or blank\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(recipe.getCusine()==null || recipe.getCusine().equals("")){
            error = "{\"error\": \"Cuisine cannot be null or blank\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(recipe.getIngredients().size()==0){
            error = "{\"error\": \"No ingredients provided\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(recipe.getNutritionInformation()!=null){
            if(recipe.getNutritionInformation().getCalories()==0){
                error = "{\"error\": \"Calories cannot be zero\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getCarbohydratesInGrams()==0){
                error = "{\"error\": \"Carbs cannot be zero\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getCholesterolInMg()==0){
                error = "{\"error\": \"Cholesterol cannot be zero\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getProteinInGrams()==0){
                error = "{\"error\": \"Proteins cannot be zero\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            if(recipe.getNutritionInformation().getSodiumInMg()==0){
                error = "{\"error\": \"Sodium cannot be zero\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
        }else{
            error = "{\"error\": \"Nutrition information cannot be blank!!\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        //for(Steps s:recipe.getSteps()){
            if(recipe.getSteps().size()==0){
            //if(s.getPosition()<1){
                error = "{\"error\": \"Atleast one step required\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
        //}
        try {
            userHeader = req.getHeader("Authorization");

            if(userHeader!=null && userHeader.startsWith("Basic")){
                userCredentials = userService.getUserCredentials(userHeader);
            }
            else{
                error = "{\"error\": \"Please give Basic auth as authorization!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
            }

            userName = userCredentials[0];
            password = userCredentials[1];

            User existUser = userDao.findByEmailId(userName);
            if(existUser != null && BCrypt.checkpw(password, existUser.getPassword())) {
                UUID id = UUID.randomUUID();
                recipe.setId(id);
                recipe.setCreatedTs(new Date());
                recipe.setUpdatedTs(new Date());
                recipe.setAuthorId(existUser.getUserId());
                recipe.setTotalTimeInMin(recipe.getCookTimeInMin()+recipe.getPrepTimeInMin());

                recipeDao.save(recipe);

                return new ResponseEntity<Object>(recipe,HttpStatus.CREATED);
            }
            else {
                error = "{\"error\": \"User unauthorized to update this recipe!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
            }
        }
        catch (Exception e){
            error = "{\"error\": \"Please provide basic auth as authorization!!\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }

    @RequestMapping(value = "/v1/recipe/{id}", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> getRecipe(Recipe recipe, HttpServletRequest req, HttpServletResponse res,@PathVariable("id") UUID id){

        JSONObject jo;
        String error;
        try {
            Optional<Recipe> existRecipe = recipeService.findById(id);
            if (existRecipe.isPresent()) {
                return new ResponseEntity<Object>(existRecipe, HttpStatus.OK);
            } else {
                return new ResponseEntity<Object>(HttpStatus.NOT_FOUND);
            }
        }
        catch(Exception e){
            error = "{\"error\": \"Something went wrong!! Please check your id.\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }
    }

    @RequestMapping(value="/v1/recipe/{id}", method=RequestMethod.PUT, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> updateRecipe(@RequestBody Recipe recipe, @PathVariable("id") UUID id, HttpServletRequest req, HttpServletResponse res){

        String userCredentials[];
        String userName;
        String password;
        String userHeader;
        JSONObject jo;
        String error;
        try {
            userHeader = req.getHeader("Authorization");

            userCredentials = userService.getUserCredentials(userHeader);
            userName = userCredentials[0];
            password = userCredentials[1];
            User user = userDao.findByEmailId(userName);

            Optional<Recipe> val = recipeService.findById(id);
            if(user != null && BCrypt.checkpw(password, user.getPassword())) {
                if (val.isPresent()) {
                    if (user.getUserId().toString().equals(val.get().getAuthorId().toString())) {
                        if (recipe.getCookTimeInMin() != 0) {
                            val.get().setCookTimeInMin(recipe.getCookTimeInMin());
                            val.get().setTotalTimeInMin(recipe.getCookTimeInMin()+val.get().getPrepTimeInMin());
                        }
                        if (recipe.getPrepTimeInMin() != 0) {
                            val.get().setPrepTimeInMin(recipe.getPrepTimeInMin());
                            val.get().setTotalTimeInMin(recipe.getPrepTimeInMin()+val.get().getCookTimeInMin());
                        }
                        if (recipe.getTitle() != null) {
                            val.get().setTitle(recipe.getTitle());
                        }
                        if (recipe.getCusine() != null) {
                            val.get().setCusine(recipe.getCusine());
                        }
                        if (recipe.getServings() != 0) {
                            val.get().setServings(recipe.getServings());
                        }
                        if (recipe.getIngredients().size() != 0) {
                            val.get().setIngredients(recipe.getIngredients());
                        }
                        if (recipe.getSteps().size() != 0) {
                            val.get().setSteps(recipe.getSteps());
                        }
                        if (recipe.getNutritionInformation() != null) {
                            if (recipe.getNutritionInformation().getCalories() != 0) {
                                val.get().getNutritionInformation().setCalories(recipe.getNutritionInformation().getCalories());
                            }
                            if (recipe.getNutritionInformation().getSodiumInMg() != 0) {
                                val.get().getNutritionInformation().setSodiumInMg(recipe.getNutritionInformation().getSodiumInMg());
                            }
                            if (recipe.getNutritionInformation().getCarbohydratesInGrams() != 0) {
                                val.get().getNutritionInformation().setCarbohydratesInGrams(recipe.getNutritionInformation().getCarbohydratesInGrams());
                            }
                            if (recipe.getNutritionInformation().getCholesterolInMg() != 0) {
                                val.get().getNutritionInformation().setCholesterolInMg(recipe.getNutritionInformation().getCholesterolInMg());
                            }
                            if (recipe.getNutritionInformation().getProteinInGrams() != 0) {
                                val.get().getNutritionInformation().setProteinInGrams(recipe.getNutritionInformation().getProteinInGrams());
                            }
                        }

                        val.get().setCreatedTs(new Date());
                        val.get().setUpdatedTs(new Date());
                        val.get().setAuthorId(user.getUserId());
                        recipeDao.save(val.get());
                    } else {
                        error = "{\"error\": \"User unauthorized to update this recipe!!\"}";
                        jo = new JSONObject(error);
                        return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
                    }
                } else {
                    error = "{\"error\": \"Recipe not found!!\"}";
                    jo = new JSONObject(error);
                    return new ResponseEntity<Object>(jo.toString(),HttpStatus.NOT_FOUND);
                }

                return new ResponseEntity<Object>(val.get(), HttpStatus.OK);
            }else {
                error = "{\"error\": \"User unauthorized to update this recipe!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
            }

        }
        catch (Exception e){
            error = "{\"error\": \"User unauthorized to update this recipe!!\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }

    @RequestMapping(value="/v1/recipe/{id}", method=RequestMethod.DELETE, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> deleteRecipe(@PathVariable("id") UUID id, HttpServletRequest req, HttpServletResponse res){
        String userCredentials[];
        String userName;
        String password;
        String userHeader;
        JSONObject jo;
        String error;
        try {
            userHeader = req.getHeader("Authorization");

            userCredentials = userService.getUserCredentials(userHeader);
            userName = userCredentials[0];
            password = userCredentials[1];
            User user = userDao.findByEmailId(userName);


            Optional<Recipe> val = recipeService.findById(id);

            if(user != null && BCrypt.checkpw(password, user.getPassword())) {
                if (val.isPresent()) {
                    if (user.getUserId().toString().equals(val.get().getAuthorId().toString())) {
                        recipeService.deleteRecipeById(id);
                        return new ResponseEntity<Object>(HttpStatus.NO_CONTENT);
                    } else {
                        error = "{\"error\": \"User Unauthorized to delete this recipe!!\"}";
                        jo = new JSONObject(error);
                        return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
                    }
                } else {
                    error = "{\"error\": \"Recipe not found!!\"}";
                    jo = new JSONObject(error);
                    return new ResponseEntity<Object>(jo.toString(),HttpStatus.NOT_FOUND);
                }
            }
            else {
                error = "{\"error\": \"User unauthorized to delete this recipe!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
            }
        }
        catch(Exception e){
            error = "{\"error\": \"Please provide Basic auth as authorization!!\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }
}
