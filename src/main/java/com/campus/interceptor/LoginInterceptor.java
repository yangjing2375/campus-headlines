package com.campus.interceptor;

import com.campus.entity.SysUser;
import com.campus.utils.SessionUtil;
import org.springframework.web.servlet.HandlerInterceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        SysUser user = SessionUtil.getLoginUser();
        if (user == null) {
            // AJAX 请求返回 401
            if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"msg\":\"未登录\"}");
            } else {
                // 普通请求重定向到登录页
                response.sendRedirect(request.getContextPath() + "/user/login");
            }
            return false;
        }
        return true;
    }
}
