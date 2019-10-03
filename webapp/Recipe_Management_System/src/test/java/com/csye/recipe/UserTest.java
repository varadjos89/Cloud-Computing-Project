package com.csye.recipe;

import com.csye.recipe.pojo.User;
import com.csye.recipe.repository.UserRepository;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.Mockito;

import java.util.Date;
import java.util.UUID;

public class UserTest {

    @Mock
    UserRepository userDao = Mockito.mock(UserRepository.class);

    @Test
    public void testAddUser(){
        UUID id = UUID.randomUUID();
        Date d = new Date();
        User u = new User();

        u.setEmailId("test@gmail.com");
        u.setFirstName("testFirt");
        u.setLastName("testLast");
        u.setPassword("Test12345@");
        u.setUserId(id);
        u.setAccountCreated(d);
        u.setAccountUpdated(d);

        userDao.save(u);

        Mockito.verify(userDao,Mockito.times(1)).save(u);


    }
}