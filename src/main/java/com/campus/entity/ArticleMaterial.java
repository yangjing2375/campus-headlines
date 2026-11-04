package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/** 文章素材关联实体类 - 文章与素材多对多 */
@Data
@TableName("article_material")
public class ArticleMaterial implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long articleId;
    private Long materialId;
    private Integer sortNo;
    private Date createTime;
}
