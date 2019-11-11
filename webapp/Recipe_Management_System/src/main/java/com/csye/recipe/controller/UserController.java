package com.csye.recipe.controller;

import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.UserRepository;
import com.csye.recipe.service.UserService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.timgroup.statsd.StatsDClient;
import org.json.JSONObject;
import org.apache.commons.validator.routines.EmailValidator;
import org.apache.tomcat.util.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.*;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.HashMap;
import java.util.UUID;

@RestController
public class UserController {

    @Autowired
    private UserRepository userDao;

    @Autowired
    private UserService userService;

//    @Autowired
//    private BCryptPasswordEncoder bCryptPasswordEncoder;

    String userHeader;

    @Autowired
    private StatsDClient metric;

    @RequestMapping(value = "/v1/user/self", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> userHome(HttpServletRequest req, HttpServletResponse res) throws JsonProcessingException {

        String[] userCredentials;
        String userName;
        String password;
        JSONObject jo;
        String error;

        metric.incrementCounter("userHome");
        try {
            userHeader = req.getHeader("Authorization");

            //user sending no userName and password
            if(userHeader.endsWith("Og==")) {
                error = "{\"error\": \"No Credentials sent\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            else if (userHeader!=null && userHeader.startsWith("Basic")) {
                userCredentials = userService.getUserCredentials(userHeader);
            } else {
                error = "{\"error\": \"No Credentials sent\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }

            userName = userCredentials[0];
            password = userCredentials[1];

            User existUser = userDao.findByEmailId(userName);
            HashMap<String,String> userDetails = new HashMap<>();

            if(existUser!=null && BCrypt.checkpw(password, existUser.getPassword())){
                userDetails.put("id",existUser.getUserId().toString());
                userDetails.put("firstName",existUser.getFirstName());
                userDetails.put("lastName",existUser.getLastName());
                userDetails.put("emailId",existUser.getEmailId());
                userDetails.put("accountCreated",existUser.getAccountCreated().toString());
                userDetails.put("accountUpdated",existUser.getAccountUpdated().toString());

            }
            else{
                error = "{\"error\": \"User unauthorized\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
            }
            return new ResponseEntity<Object>(userDetails, HttpStatus.OK);
        }
        catch(Exception e){
            error = "{\"error\": \"Please provide authorization as basic auth\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }


    @RequestMapping(value = "/v1/user", method = RequestMethod.POST, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> createUser(@RequestBody User user, HttpServletRequest req, HttpServletResponse res){

        metric.incrementCounter("createUser");
        JSONObject jo;
        String error;
        //if user already exist
        User existUser = userDao.findByEmailId(user.getEmailId());
        if(existUser!=null){
            error = "{\"error\": \"User already exists\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        //check user has sent all fields
        if(user.getPassword()==null || user.getFirstName()==null || user.getLastName()==null ||
            user.getEmailId()==null) {
            error = "{\"error\": \"FirstName or LastName or EmailId or Password cannot be null\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }
//        if(!userService.isValidEmail(user.getEmailId())){
//            return new ResponseEntity<Object>(HttpStatus.BAD_REQUEST);
//        }

        if(!EmailValidator.getInstance().isValid(user.getEmailId())){
            error = "{\"error\": \"Please enter valid EmailId\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        if(!userService.isValidPassword(user.getPassword())){
            error = "{\"error\": \"FirstName or LastName or EmailId or Password cannot be null\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        Date d= new Date();

        user.setPassword(BCrypt.hashpw(user.getPassword(), BCrypt.gensalt()));
        user.setAccountCreated(d);
        user.setAccountUpdated(d);

        UUID id = UUID.randomUUID();
        user.setUserId(id);

        userDao.save(user);

        HashMap<String,String> userDetails = new HashMap<>();

        userDetails.put("id",user.getUserId().toString());
        userDetails.put("firstName",user.getFirstName());
        userDetails.put("lastName",user.getLastName());
        userDetails.put("emailId",user.getEmailId());
        userDetails.put("accountCreated",user.getAccountCreated().toString());
        userDetails.put("accountUpdated",user.getAccountUpdated().toString());

        return new ResponseEntity<Object>(userDetails,HttpStatus.CREATED);
    }

    @RequestMapping(value="/v1/user/self", method=RequestMethod.PUT,produces="application/json")
    @ResponseBody
    public ResponseEntity<Object> updateUser(@RequestBody User user,HttpServletRequest req,HttpServletResponse res){

        metric.incrementCounter("updateUser");
        JSONObject jo;
        String error;
        //checking if user sent no data to update
        if(user.equals(null)){
            error = "{\"error\": \"Unable to find the user\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }
        //user not allowed to update certain attributes
        if(user.getEmailId()!=null || user.getUserId()!=null || user.getAccountCreated()!=null ||
            user.getAccountUpdated()!=null){
            error = "{\"error\": \"EmailId or UserId or AccountCreated or AccountUpdated cannot be updated\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
        }

        //to store user credentials
        String[] userCredentials;
        String userName;
        String password;

        try {
            //variables to store update values from user
            String updateFirstName, updateLastName, passwordUpdate;
            userHeader = req.getHeader("Authorization");

            //no credentials provided
            if(userHeader.endsWith("Og==")) {
                error = "{\"error\": \"No Credentials sent\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }
            else if (userHeader!=null && userHeader.startsWith("Basic")) {
                userCredentials = userService.getUserCredentials(userHeader);
            }
            else {
                error = "{\"error\": \"No Credentials sent\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(),HttpStatus.BAD_REQUEST);
            }

            userName = userCredentials[0];
            password = userCredentials[1];

            User existUser = userDao.findByEmailId(userName);
            updateFirstName = user.getFirstName();
            updateLastName = user.getLastName();
            passwordUpdate = user.getPassword();
            //System.out.println("updateLastName: "+updateLastName);
    //        System.out.println(BCrypt.hashpw(password, BCrypt.gensalt()));
    //        System.out.println(BCrypt.checkpw(password, BCrypt.hashpw(password, BCrypt.gensalt())));

            if(existUser!=null && BCrypt.checkpw(password, existUser.getPassword())){
                if(updateFirstName!=null){
                    existUser.setFirstName(updateFirstName);
                }
                if(updateLastName!=null){
                    System.out.println("lastName not null");
                    existUser.setLastName(updateLastName);
                }
                if(passwordUpdate!=null){
                    existUser.setPassword(BCrypt.hashpw(passwordUpdate, BCrypt.gensalt()));
                }
                existUser.setAccountUpdated(new Date());
                userDao.save(existUser);
            }
            else{
                error = "{\"error\": \"Incorrect password\"}";
                jo = new JSONObject(error);
                return new ResponseEntity<Object>(jo.toString(), HttpStatus.UNAUTHORIZED);
            }

            return new ResponseEntity<Object>(HttpStatus.NO_CONTENT);
        }
        catch(Exception e){
            error = "{\"error\": \"Please provide authorization as basic auth\"}";
            jo = new JSONObject(error);
            return new ResponseEntity<Object>(jo.toString(),HttpStatus.UNAUTHORIZED);
        }
    }
}
