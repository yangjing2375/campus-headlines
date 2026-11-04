package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * 文章实体类 - 对应 article 表（草稿/待审/已发布/驳回/下架统一承载）
 * status: 0草稿 1待审核 2已发布 3已驳回 4已下架
 */
@Data
@TableName("article")
public class Article implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String summary;
    private String content;
    private String cover;
    /** 视频URL（视频新闻） */
    private String videoUrl;
    private Long channelId;
    /** 所属话题ID（一篇文章最多关联一个话题） */
    private Long topicId;
    private Long authorId;
    private String source;
    private Integer status;
    private String rejectReason;
    private Integer viewCount;
    private Integer likeCount;
    private Integer favoriteCount;
    private Integer commentCount;
    private Integer isTop;
    private Integer isUrgent;
    private Date publishTime;
    private Date createTime;
    private Date updateTime;

    /** 非数据库字段：关联信息 */
    @TableField(exist = false)
    private String channelName;
    @TableField(exist = false)
    private String topicName;
    @TableField(exist = false)
    private String authorName;
    @TableField(exist = false)
    private String authorCollege;
    @TableField(exist = false)
    private List<Material> materials;
    @TableField(exist = false)
    private List<AuditLog> auditLogs;
    /** 写稿时选择的素材ID集合 */
    @TableField(exist = false)
    private List<Long> materialIds;

}
