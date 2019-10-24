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
    @JsonProperty(value = "imageId")
    @Type(type = "org.hibernate.type.UUIDCharType")
    private UUID imageId;

    @Column
    private String imageURL;

    @Column
    private String imagekey;

    @Column
    private long InstanceLength;

    @Column
    private long ContentLength;

    @Column
    private String Bucketname;

    @Column
    private String Etag;

    public Image(){}

    public UUID getImageId() {
        return imageId;
    }

    public void setImageId(UUID imageId) {
        this.imageId = imageId;
    }

    public String getImageURL() {
        return imageURL;
    }

    public void setImageURL(String imageURL) {
        this.imageURL = imageURL;
    }

    public String getImagekey() {
        return imagekey;
    }

    public void setImagekey(String imagekey) {
        this.imagekey = imagekey;
    }

    public long getInstanceLength() {
        return InstanceLength;
    }

    public void setInstanceLength(long instanceLength) {
        InstanceLength = instanceLength;
    }

    public long getContentLength() {
        return ContentLength;
    }

    public void setContentLength(long contentLength) {
        ContentLength = contentLength;
    }

    public String getBucketname() {
        return Bucketname;
    }

    public void setBucketname(String bucketname) {
        Bucketname = bucketname;
    }

    public String getEtag() {
        return Etag;
    }

    public void setEtag(String etag) {
        Etag = etag;
    }
}
