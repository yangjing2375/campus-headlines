package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/** 话题关注实体类 - 对应 news_topic_follow 表 */
@Data
@TableName("news_topic_follow")
public class TopicFollow implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long topicId;
    private Long userId;
    private Date createTime;
}
