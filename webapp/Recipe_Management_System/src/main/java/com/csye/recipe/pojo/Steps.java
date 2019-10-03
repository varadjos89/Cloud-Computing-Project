package com.csye.recipe.pojo;

import javax.persistence.*;

@Entity
public class Steps {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private int stepId;

    @Column
    private int position;

    @Column
    private String items;

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

    public String getItems() {
        return items;
    }

    public void setItems(String items) {
        this.items = items;
    }
}