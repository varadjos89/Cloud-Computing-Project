package com.csye.recipe.controller;

import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.UserRepository;
import com.csye.recipe.service.UserService;
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

    @RequestMapping(value = "/v1/user/self", method = RequestMethod.GET, produces = "application/json")
    @ResponseBody
    public ResponseEntity<Object> userHome(HttpServletRequest req, HttpServletResponse res) {

        String[] userCredentials;
        String userName;
        String password;
        userHeader = req.getHeader("Authorization");

        //user sending no userName and password
        if(userHeader.endsWith("Og==")) {
            return new ResponseEntity<Object>("No Credentials sent",HttpStatus.BAD_REQUEST);
        }
        else if (userHeader!=null && userHeader.startsWith("Basic")) {
            userCredentials = userService.getUserCredentials(userHeader);
        } else {
            return new ResponseEntity<Object>(HttpStatus.BAD_REQUEST);

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
            return new ResponseEntity<Object>(HttpStatus.UNAUTHORIZED);
        }
        return new ResponseEntity<Object>(userDetails, HttpStatus.OK);

    }

    

}
