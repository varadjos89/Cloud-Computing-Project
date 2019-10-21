package com.csye.recipe.controller;

import com.csye.recipe.service.AmazonClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@RestController
public class ImageController {

    //service to connect with aws
    private AmazonClient amazonClient;


    public ImageController(AmazonClient amazonClient) {
        this.amazonClient = amazonClient;
    }

    @RequestMapping(value = "/v1/recipe/{id}/image", method = RequestMethod.POST, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> uploadImage(@RequestPart(value = "file") MultipartFile file, HttpServletRequest req, HttpServletResponse res) {
        //return this.amazonClient.uploadFile(file);
    }

    @RequestMapping(value = "/v1/recipe/{recipeId}/image/{imageId}", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> getImage(HttpServletRequest req, HttpServletResponse res) {
        //return this.amazonClient.uploadFile(file);
    }

    @RequestMapping(value = "/v1/recipe/{recipeId}/image/{imageId}", method = RequestMethod.DELETE, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> deleteImage(HttpServletRequest req, HttpServletResponse res) {
        //return this.amazonClient.deleteFileFromS3Bucket(fileUrl);
    }

}
