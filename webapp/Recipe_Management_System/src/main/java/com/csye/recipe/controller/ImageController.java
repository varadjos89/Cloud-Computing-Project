package com.csye.recipe.controller;

import com.csye.recipe.pojo.Image;
import com.csye.recipe.pojo.Recipe;
import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.ImageRepository;
import com.csye.recipe.repository.RecipeRepository;
import com.csye.recipe.repository.UserRepository;
import com.csye.recipe.service.AmazonClient;
import com.csye.recipe.service.ImageService;
import com.csye.recipe.service.RecipeService;
import com.csye.recipe.service.UserService;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.InputStream;
import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@RestController
public class ImageController {

    //service to connect with aws
    @Autowired
    private AmazonClient amazonClient;

    @Autowired
    UserService userService;

    @Autowired
    private RecipeService recipeService;

    @Autowired
    private ImageService imageService;

    @Autowired
    private UserRepository userDao;

    @Autowired
    private ImageRepository imageRepository;

    @Autowired
    private RecipeRepository recipeRepository;

    public ImageController(AmazonClient amazonClient) {
        this.amazonClient = amazonClient;
    }

    @RequestMapping(value = "/v1/recipe/{id}/image", method = RequestMethod.POST, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> uploadImage(@RequestPart(value = "file") MultipartFile file, HttpServletRequest req, HttpServletResponse res,@PathVariable("id") UUID id) {
        String[] userCredentials;
        String userName;
        String password;
        String userHeader;
        JSONObject jo;
        String error;

        //check if user uploaded an image file only
        try (InputStream input = file.getInputStream()) {

            if (ImageIO.read(input).toString() == null) {
                error = "{\"error\": \"Input file is not an image\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(), HttpStatus.BAD_REQUEST);
            }
        }
        catch(Exception e){
            error = "{\"error\": \"Invalid input\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(), HttpStatus.BAD_REQUEST);
        }

        try {
            userHeader = req.getHeader("Authorization");

            if (userHeader != null && userHeader.startsWith("Basic")) {
                userCredentials = userService.getUserCredentials(userHeader);
            } else {
                System.out.println("ONE");
                error = "{\"error\": \"Please give Basic auth as authorization!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(), HttpStatus.UNAUTHORIZED);
            }

            userName = userCredentials[0];
            password = userCredentials[1];

            User existUser = userDao.findByEmailId(userName);
            if (existUser != null && BCrypt.checkpw(password, existUser.getPassword())) {
                //check if recipe exists for the id given
                Optional<Recipe> existRecipe = recipeService.findById(id);
                if (existRecipe.isPresent()) {
                    //checking if userId matches author Id in recipe
                    if(!(existUser.getUserId().toString().equals(existRecipe.get().getAuthorId().toString()))){
                        error = "{\"error\": \"User unauthorized to add image to this recipe!!\"}";
                        jo = new JSONObject(error);
                        return new ResponseEntity<Object>(jo.toString(), HttpStatus.UNAUTHORIZED);
                    }
                    //check if recipe already has an image
                    if(imageService.checkIfImageAlreadyExist(existRecipe.get())){
                        Image img = new Image();
                        //creating new image and storing in S3 bucket
                        String s3Url = this.amazonClient.uploadFile(file);

                        UUID imageId = UUID.randomUUID();
                        img.setImageId(imageId);
                        img.setImageURL(s3Url);
                        //saving to local db
                        imageRepository.save(img);
                        //setting recipe object
                        existRecipe.get().setImage(img);
                        recipeRepository.save(existRecipe.get());
                        System.out.println(existRecipe.get().getImage());

                        return new ResponseEntity<Object>(img, HttpStatus.CREATED);
                    }
                    else{
                        error = "{\"error\": \"Image for Recipe already exists\"}";
                        jo = new JSONObject(error);
                        return new ResponseEntity<Object>(jo.toString(), HttpStatus.BAD_REQUEST);
                    }

                } else {
                    error = "{\"error\": \"RecipeId not found\"}";
                    jo = new JSONObject(error);
                    return new ResponseEntity<Object>(jo.toString(), HttpStatus.NOT_FOUND);
                }
                //return new ResponseEntity<Object>(recipe,HttpStatus.CREATED);
            } else {
                error = "{\"error\": \"User unauthorized to add image to this recipe!!\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(), HttpStatus.UNAUTHORIZED);
            }
        }
        catch (Exception e){
            System.out.println("TWO");
            error = "{\"error\": \"Please provide basic auth as authorization!!\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }

    @RequestMapping(value = "/v1/recipe/{recipeId}/image/{imageId}", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> getImage(HttpServletRequest req, HttpServletResponse res,@PathVariable("recipeId") UUID recipeId,@PathVariable("imageId") UUID imageId) {
        //return this.amazonClient.uploadFile(file);
        JSONObject jo;
        String error;
        try {
            Optional<Recipe> existRecipe = recipeService.findById(recipeId);
            if (existRecipe.isPresent()) {
                Optional<Image> image = imageService.findByImageId(imageId);
                if(image.get()!=null){
                    return new ResponseEntity<Object>(image.get(), HttpStatus.OK);
                }
                else{
                    error = "{\"error\": \"ImageId not found\"}";
                    jo = new JSONObject(error);
                    return new ResponseEntity<Object>(jo.toString(),HttpStatus.NOT_FOUND);
                }
            }
            else {
                error = "{\"error\": \"RecipeId not found\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.NOT_FOUND);
            }
        }
        catch(Exception e){
            error = "{\"error\": \"Something went wrong!! Please check your id.\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }
    }

    @RequestMapping(value = "/v1/recipe/{recipeId}/image/{imageId}", method = RequestMethod.DELETE, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> deleteImage(HttpServletRequest req, HttpServletResponse res) {
        //return this.amazonClient.deleteFileFromS3Bucket(fileUrl);

        return new ResponseEntity<Object>(HttpStatus.OK);
    }

}
