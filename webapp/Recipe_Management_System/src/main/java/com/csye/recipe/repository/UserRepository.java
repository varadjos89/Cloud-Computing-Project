package com.csye.recipe.repository;

import com.csye.recipe.pojo.User;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends CrudRepository<User,Integer> {

    User findByEmailId(String emailId);
}
