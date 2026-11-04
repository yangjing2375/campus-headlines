package com.campus.interceptor;

import com.campus.entity.SysUser;
import com.campus.utils.SessionUtil;
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 角色权限拦截器（JSP 页面端）
 * 自媒体人(MEDIA) / 审核员(AUDITOR) / 管理员(ADMIN) 区分访问权限
 * 管理员拥有所有权限
 */
public class RoleInterceptor implements HandlerInterceptor {

    /** 允许的角色，逗号分隔，如 "AUDITOR,ADMIN" */
    private String requiredRoles;

    public void setRequiredRoles(String requiredRoles) {
        this.requiredRoles = requiredRoles;
    }

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        SysUser user = SessionUtil.getLoginUser();
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return false;
        }

        // 管理员拥有所有权限
        if ("ADMIN".equalsIgnoreCase(user.getRole())) return true;

        if (!roleAllowed(user.getRole())) {
            if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                response.setStatus(403);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":403,\"msg\":\"无权限访问\"}");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "无权限访问");
            }
            return false;
        }
        return true;
    }

    private boolean roleAllowed(String role) {
        if (requiredRoles == null || requiredRoles.trim().isEmpty()) return true;
        if (role == null) return false;
        for (String item : requiredRoles.split(",")) {
            if (item.trim().equalsIgnoreCase(role)) return true;
        }
        return false;
    }
}
