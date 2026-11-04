package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 审核记录实体类 - 对应 audit_log 表
 * action: 1通过 2驳回
 */
@Data
@TableName("audit_log")
public class AuditLog implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private Long articleId;
    private Long auditorId;
    private Integer action;
    private String remark;
    private Date createTime;

    @TableField(exist = false)
    private String articleTitle;
    @TableField(exist = false)
    private String auditorName;
}
