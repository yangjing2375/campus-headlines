package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.util.Date;

/**
 * 自媒体人申请表 - 对应 media_apply
 * status: 0 待审核 / 1 已通过 / 2 已驳回
 */
@Data
@TableName("media_apply")
public class MediaApply implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    /** 申请理由 */
    private String reason;
    /** 擅长领域 / 个人简介 */
    private String intro;
    /** 联系方式 */
    private String contact;
    private Integer status;
    /** 驳回理由 */
    private String rejectReason;
    private Long auditorId;
    private Date createTime;
    private Date auditTime;

    /** 以下字段不映射数据库，仅用于页面展示 */
    @TableField(exist = false)
    private String userName;
    @TableField(exist = false)
    private String userCollege;
    @TableField(exist = false)
    private String userPhone;
}
