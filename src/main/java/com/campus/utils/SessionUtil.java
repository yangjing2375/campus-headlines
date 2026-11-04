package com.campus.utils;

import com.campus.entity.SysUser;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * Session 工具类 - 管理登录用户信息
 */
public class SessionUtil {

    public static final String SESSION_USER_KEY = "loginUser";

    public static HttpSession getSession() {
        ServletRequestAttributes attr =
            (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attr == null) return null;
        return attr.getRequest().getSession(true);
    }

    public static void setLoginUser(SysUser user) {
        HttpSession session = getSession();
        if (session != null) session.setAttribute(SESSION_USER_KEY, user);
    }

    public static SysUser getLoginUser() {
        HttpSession session = getSession();
        if (session == null) return null;
        return (SysUser) session.getAttribute(SESSION_USER_KEY);
    }

    public static void removeLoginUser() {
        HttpSession session = getSession();
        if (session != null) session.removeAttribute(SESSION_USER_KEY);
    }

    /** 获取当前请求 */
    public static HttpServletRequest getRequest() {
        ServletRequestAttributes attr =
            (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attr == null ? null : attr.getRequest();
    }
}
