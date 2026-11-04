package com.campus.aspect;

import com.campus.entity.SysUser;
import com.campus.utils.SessionUtil;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class ServiceLogAspect {

    private static final Logger log = LoggerFactory.getLogger(ServiceLogAspect.class);

    /** 切入点：所有 Service 层的 public 方法 */
    @Pointcut("execution(public * com.campus.service..*.*(..))")
    public void serviceLayer() {}

    /** 前置通知：记录用户操作 */
    @Before("serviceLayer()")
    public void beforeLog(JoinPoint jp) {
        SysUser user = SessionUtil.getLoginUser();
        String username = (user != null) ? user.getUsername() : "匿名";
        String method   = jp.getSignature().toShortString();
        log.info("[操作日志] 用户: {} - 调用方法: {}", username, method);
    }
}
