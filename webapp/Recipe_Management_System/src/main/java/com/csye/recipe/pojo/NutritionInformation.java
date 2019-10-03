package com.csye.recipe.pojo;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

import javax.persistence.*;

@Entity
public class NutritionInformation {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
//    @JsonIgnore
//    @JsonProperty(value="nutritionId")
    private int nutritionId;

    @Column
    private int calories;

    @Column
    private float cholesterolInMg;

    @Column
    private int sodiumInMg;

    @Column
    private float carbohydratesInGrams;

    @Column
    private float proteinInGrams;

    @OneToOne(mappedBy="nutritionInformation",fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private Recipe recipe;

    public NutritionInformation() {
    }

    @JsonIgnore
    @JsonProperty(value = "nutritionId")
    public int getNutritionId() {
        return nutritionId;
    }

    public void setNutritionId(int nutritionId) {
        this.nutritionId = nutritionId;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public float getCholesterolInMg() {
        return cholesterolInMg;
    }

    public void setCholesterolInMg(float cholesterolInMg) {
        this.cholesterolInMg = cholesterolInMg;
    }

    public int getSodiumInMg() {
        return sodiumInMg;
    }

    public void setSodiumInMg(int sodiumInMg) {
        this.sodiumInMg = sodiumInMg;
    }

    public float getCarbohydratesInGrams() {
        return carbohydratesInGrams;
    }

    public void setCarbohydratesInGrams(float carbohydratesInGrams) {
        this.carbohydratesInGrams = carbohydratesInGrams;
    }

    public float getProteinInGrams() {
        return proteinInGrams;
    }

    public void setProteinInGrams(float proteinInGrams) {
        this.proteinInGrams = proteinInGrams;
    }
}