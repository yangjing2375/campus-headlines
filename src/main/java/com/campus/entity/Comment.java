package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 评论实体类 - 对应 comment 表
 * status: 0待审核 1已发布 2已删除
 */
@Data
@TableName("comment")
public class Comment implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long articleId;
    private Long userId;
    private String content;
    /** 父评论ID：null 为一级评论，否则为回复 */
    private Long parentId;
    /** 被回复用户ID */
    private Long replyUserId;
    /** 点赞数 */
    private Integer likeCount;
    private Integer status;
    private Date createTime;

    /** 非数据库字段 */
    @TableField(exist = false)
    private String userName;
    @TableField(exist = false)
    private String articleTitle;
    /** 被回复人昵称（展示"回复 @某某"） */
    @TableField(exist = false)
    private String replyUserName;
    /** 当前登录用户是否已点赞该评论 */
    @TableField(exist = false)
    private Boolean liked;
    /** 子回复列表（楼中楼二级展示） */
    @TableField(exist = false)
    private java.util.List<Comment> replies;
}
