package com.csye.recipe.pojo;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.annotations.Type;
import org.springframework.web.multipart.MultipartFile;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class Image {

    @Id
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    @JsonProperty(value = "id")
    @Type(type = "org.hibernate.type.UUIDCharType")
    private UUID imageId;

    @Column
    private String imageURL;

//    @OneToOne(mappedBy = "image", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
//    private Recipe recipe;

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public UUID getImageId() {
        return imageId;
    }

    public void setImageId(UUID imageId) {
        this.imageId = imageId;
    }

}
