package com.campus.interceptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 接口访问日志拦截器 - 对应考核方案"AOP + 拦截器：记录接口访问日志"
 *
 * 记录每个 /api 接口的请求方法、URI、响应状态与耗时，统一输出到日志文件。
 */
public class ApiLogInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(ApiLogInterceptor.class);
    private static final String START_TIME = "__api_start_time";

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) {
        request.setAttribute(START_TIME, System.currentTimeMillis());
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request,
                                HttpServletResponse response,
                                Object handler, Exception ex) {
        Object start = request.getAttribute(START_TIME);
        long cost = start instanceof Long ? System.currentTimeMillis() - (Long) start : 0L;
        log.info("[API] {} {} status={} cost={}ms{}",
                request.getMethod(), request.getRequestURI(),
                response.getStatus(), cost,
                ex == null ? "" : " error=" + ex.getMessage());
    }
}
