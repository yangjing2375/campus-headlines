package com.campus.controller;

import com.campus.utils.R;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 全局异常处理器 - 对应考核方案技术点"全局异常处理"
 *
 * 统一捕获接口层（com.campus.controller.api）抛出的异常，
 * 统一转换为 {"code":500,"msg":"...","data":null} 结构，避免异常堆栈直接暴露给前端。
 */
@RestControllerAdvice(basePackages = "com.campus.controller.api")
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** 业务异常 -> 自定义错误码（同步设置 HTTP 状态码） */
    @ExceptionHandler(com.campus.exception.BusinessException.class)
    public R<?> handleBusiness(HttpServletRequest request,
                               HttpServletResponse response,
                               com.campus.exception.BusinessException e) {
        response.setStatus(e.getCode());
        return R.fail(e.getCode(), e.getMessage());
    }

    /** 参数缺失 / 类型不匹配 / JSON 解析失败 -> 400 */
    @ExceptionHandler({
            MissingServletRequestParameterException.class,
            MethodArgumentTypeMismatchException.class,
            HttpMessageNotReadableException.class
    })
    public R<?> handleBadRequest(HttpServletRequest request, Exception e) {
        log.warn("请求参数异常 uri={} message={}", request.getRequestURI(), e.getMessage());
        return R.fail(400, "请求参数不正确：" + e.getMessage());
    }

    /** 业务参数校验失败（文件类型、文件大小、必填项等） -> 400 */
    @ExceptionHandler(IllegalArgumentException.class)
    public R<?> handleIllegalArgument(HttpServletRequest request, IllegalArgumentException e) {
        log.warn("业务参数校验失败 uri={} message={}", request.getRequestURI(), e.getMessage());
        return R.fail(400, e.getMessage());
    }

    /** 上传文件超过大小限制 -> 400 */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public R<?> handleMaxUploadSize(HttpServletRequest request, MaxUploadSizeExceededException e) {
        log.warn("上传文件超过限制 uri={} message={}", request.getRequestURI(), e.getMessage());
        return R.fail(400, "上传文件超过大小限制（单个文件最大 50MB）");
    }

    /** 其余未捕获异常 -> 500，并记录统一日志 */
    @ExceptionHandler(Exception.class)
    public R<?> handleException(HttpServletRequest request, Exception e) {
        log.error("接口执行异常 uri={}", request.getRequestURI(), e);
        return R.fail(500, "系统异常，请联系管理员");
    }
}
