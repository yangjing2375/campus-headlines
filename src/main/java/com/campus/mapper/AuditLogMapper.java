package com.campus.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.campus.entity.AuditLog;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

public interface AuditLogMapper extends BaseMapper<AuditLog> {

    @Select("SELECT l.*, u.nickname AS auditor_name "
            + "FROM audit_log l LEFT JOIN sys_user u ON l.auditor_id = u.id "
            + "WHERE l.article_id = #{articleId} ORDER BY l.create_time DESC")
    List<AuditLog> selectByArticleId(@Param("articleId") Long articleId);
}
