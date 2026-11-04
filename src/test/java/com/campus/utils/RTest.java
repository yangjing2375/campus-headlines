package com.campus.utils;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.LinkedHashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

/**
 * 统一响应结构单元测试：对应测试用例 UC-074（接口规范）
 */
@DisplayName("R - 统一响应结构")
class RTest {

    @Test
    @DisplayName("成功响应 code=200，默认 msg=success")
    void okWithoutData() {
        R<?> r = R.ok();
        assertEquals(200, r.getCode());
        assertEquals("success", r.getMsg());
        assertNull(r.getData());
    }

    @Test
    @DisplayName("成功响应可携带业务数据")
    void okWithData() {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("liked", true);
        R<Map<String, Object>> r = R.ok(data);
        assertEquals(200, r.getCode());
        assertEquals(Boolean.TRUE, r.getData().get("liked"));
    }

    @Test
    @DisplayName("失败响应默认业务码 400 并携带提示信息")
    void failDefault() {
        R<?> r = R.fail("参数错误");
        assertEquals(400, r.getCode());
        assertEquals("参数错误", r.getMsg());
        assertNull(r.getData());
    }

    @Test
    @DisplayName("失败响应可指定业务码（401/403/404）")
    void failWithCode() {
        assertEquals(401, R.fail(401, "请先登录").getCode());
        assertEquals(403, R.fail(403, "当前角色无权访问该接口").getCode());
        assertEquals(404, R.fail(404, "文章不存在或已下线").getCode());
    }
}
