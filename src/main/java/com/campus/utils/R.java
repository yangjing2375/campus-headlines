package com.campus.utils;

import java.io.Serializable;

/**
 * 统一响应结果封装
 */
public class R<T> implements Serializable {
    private static final long serialVersionUID = 1L;

    private int code;       // 200成功, 400参数错误, 401未登录, 403无权限, 500系统错误
    private String msg;
    private T data;

    public R() {}
    public R(int code, String msg, T data) {
        this.code = code; this.msg = msg; this.data = data;
    }

    public static <T> R<T> ok()                      { return new R<>(200, "success", null); }
    public static <T> R<T> ok(T data)                { return new R<>(200, "success", data); }
    public static <T> R<T> ok(String msg, T data)    { return new R<>(200, msg, data); }
    public static <T> R<T> fail(String msg)          { return new R<>(400, msg, null); }
    public static <T> R<T> fail(int code, String msg){ return new R<>(code, msg, null); }

    public int getCode()  { return code; }
    public void setCode(int code)  { this.code = code; }
    public String getMsg(){ return msg; }
    public void setMsg(String msg){ this.msg = msg; }
    public T getData()    { return data; }
    public void setData(T data)    { this.data = data; }
}
