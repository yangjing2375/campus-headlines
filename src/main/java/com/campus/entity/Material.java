package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/** 素材实体类 - 对应 material 表 */
@Data
@TableName("material")
public class Material implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private String url;
    private String type;
    private Long size;
    private String md5;
    private Long userId;
    private Date createTime;
}
