package com.csye.recipe.pojo;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Entity
public class Recipe {


    @Id
//    @GeneratedValue(generator = "uuid2")
//    @GenericGenerator(name = "uuid2", strategy = "org.hibernate.id.UUIDGenerator")
//    @Column(columnDefinition = "BINARY(16)")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    @JsonProperty(value = "id")
    @Type(type="org.hibernate.type.UUIDCharType")
    private UUID id;

    @Column
    @JsonIgnore
    @JsonProperty(value = "createdTs")
    private Date createdTs;

    @Column
    @JsonIgnore
    @JsonProperty(value = "updatedTs")
    private Date updatedTs;

    @Column
    @JsonIgnore
    @JsonProperty(value = "authorId")
    @Type(type="org.hibernate.type.UUIDCharType")
    private UUID authorId;

    @Column
    private int cookTimeInMin;

    @Column
    private int prepTimeInMin;

    @Column
    @JsonIgnore
    @JsonProperty(value = "totalTimeInMin")
    private int totalTimeInMin;

    @Column
    private String title;

    @Column
    private String cusine;

    @Column
    private int servings;

    @ElementCollection
    private List<String> ingredients = new ArrayList<>();

    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    //@OneToMany(mappedBy="recipe",fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OneToMany(cascade = CascadeType.ALL)
    @JoinColumn(name="id")
    private List<Steps> steps = new ArrayList<>();

    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    @OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JoinColumn(name="nutritionId")
    private NutritionInformation nutritionInformation;

    public Recipe() {
    }

    public List<String> getIngredients() {
        return ingredients;
    }

    public void setIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
    }

    public UUID getId() {
        return id;
    }

    public List<Steps> getSteps() {
        return steps;
    }

    public void setSteps(List<Steps> steps) {
        this.steps = steps;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public Date getCreatedTs() {
        return createdTs;
    }

    public void setCreatedTs(Date createdTs) {
        this.createdTs = createdTs;
    }

    public Date getUpdatedTs() {
        return updatedTs;
    }

    public void setUpdatedTs(Date updatedTs) {
        this.updatedTs = updatedTs;
    }

    public UUID getAuthorId() {
        return authorId;
    }

    public void setAuthorId(UUID authorId) {
        this.authorId = authorId;
    }

    public int getCookTimeInMin() {
        return cookTimeInMin;
    }

    public void setCookTimeInMin(int cookTimeInMin) {
        this.cookTimeInMin = cookTimeInMin;
    }

    public int getPrepTimeInMin() {
        return prepTimeInMin;
    }

    public void setPrepTimeInMin(int prepTimeInMin) {
        this.prepTimeInMin = prepTimeInMin;
    }

    public int getTotalTimeInMin() {
        return totalTimeInMin;
    }

    public void setTotalTimeInMin(int totalTimeInMin) {
        this.totalTimeInMin = totalTimeInMin;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCusine() {
        return cusine;
    }

    public void setCusine(String cusine) {
        this.cusine = cusine;
    }

    public int getServings() {
        return servings;
    }

    public void setServings(int servings) {
        this.servings = servings;
    }

    public NutritionInformation getNutritionInformation() {
        return nutritionInformation;
    }

    public void setNutritionInformation(NutritionInformation nutritionInformation) {
        this.nutritionInformation = nutritionInformation;
    }
}