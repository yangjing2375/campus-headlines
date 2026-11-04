package com.campus.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户实体类 - 对应 sys_user 表
 * role: USER 普通用户 / MEDIA 自媒体人 / AUDITOR 审核员 / ADMIN 管理员
 */
@Data
@TableName("sys_user")
public class SysUser implements Serializable {
    private static final long serialVersionUID = 1L;

    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String avatar;
    private String phone;
    private String college;
    private String role;
    private Integer status;
    private Date createTime;
    private Date updateTime;
}
