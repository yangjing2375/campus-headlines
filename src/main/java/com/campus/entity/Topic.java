package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 话题实体类 - 对应 news_topic 表
 * status: 0待审核 1已上线 2已驳回 3已禁用
 */
@Data
@TableName("news_topic")
public class Topic implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String description;
    private String cover;
    private Long creatorId;
    private Integer status;
    private Integer isHot;
    private String rejectReason;
    private Date createTime;
    private Date updateTime;

    /** 非数据库字段：创建人昵称 */
    @TableField(exist = false)
    private String creatorName;
    /** 非数据库字段：话题下已发布文章数 */
    @TableField(exist = false)
    private Long articleCount;
    /** 非数据库字段：关注人数 */
    @TableField(exist = false)
    private Long followerCount;
    /** 非数据库字段：当前登录用户是否已关注 */
    @TableField(exist = false)
    private Boolean followed;
}
