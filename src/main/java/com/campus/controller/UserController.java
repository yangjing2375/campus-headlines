package com.campus.controller;

import com.campus.entity.SysUser;
import com.campus.entity.MediaApply;
import com.campus.service.ArticleFavoriteService;
import com.campus.service.ArticleLikeService;
import com.campus.service.SysUserService;
import com.campus.utils.R;
import com.campus.utils.SessionUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.ServletContextAware;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.UUID;

/**
 * 用户 Controller - 登录/注册/个人中心
 * 对应教材第5章 SpringMVC @RequestMapping / 数据绑定
 */
@Controller
@RequestMapping("/user")
public class UserController implements ServletContextAware {

    /** 头像允许的图片格式 */
    private static final List<String> AVATAR_EXT = Arrays.asList("jpg", "jpeg", "png", "gif", "webp");
    /** 头像大小上限 5MB */
    private static final long AVATAR_MAX_SIZE = 5L * 1024 * 1024;
    /** 未选择头像时的默认头像（绿色笑脸） */
    private static final String DEFAULT_AVATAR = "/static/img/avatars/a1.svg";

    @Autowired
    private SysUserService userService;

    @Autowired
    private ArticleFavoriteService articleFavoriteService;

    @Autowired
    private ArticleLikeService articleLikeService;

    @Autowired
    private com.campus.mapper.MediaApplyMapper mediaApplyMapper;

    private ServletContext servletContext;

    @Override
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;
    }

    /** 登录页 */
    @GetMapping("/login")
    public String loginPage() {
        return "user/login";
    }

    /** 注册页 */
    @GetMapping("/register")
    public String registerPage() {
        return "user/register";
    }

    /** 数字图形验证码：生成 4 位数字并以 SVG 图片输出，同时存入 session */
    @GetMapping("/captcha")
    public void captcha(HttpSession session, HttpServletResponse response) throws IOException {
        Random r = new Random();
        String code = String.valueOf(1000 + r.nextInt(9000));
        session.setAttribute("LOGIN_CAPTCHA", code);

        String[] palette = {"#2daf94", "#1f8f78", "#e07b39", "#3f7fbf", "#8e6bbf"};
        StringBuilder sb = new StringBuilder();
        sb.append("<svg xmlns='http://www.w3.org/2000/svg' width='120' height='44' viewBox='0 0 120 44'>")
          .append("<rect width='120' height='44' rx='8' fill='#f3f7f5'/>");
        // 干扰线
        for (int i = 0; i < 3; i++) {
            sb.append("<line x1='").append(r.nextInt(20))
              .append("' y1='").append(r.nextInt(44))
              .append("' x2='").append(100 + r.nextInt(20))
              .append("' y2='").append(r.nextInt(44))
              .append("' stroke='").append(palette[r.nextInt(palette.length)])
              .append("' stroke-opacity='0.28' stroke-width='1.4'/>");
        }
        // 4 位数字，随机倾斜与偏移
        for (int i = 0; i < 4; i++) {
            int x = 12 + i * 26 + r.nextInt(4);
            int y = 31 + r.nextInt(3);
            int rotate = r.nextInt(29) - 14;
            sb.append("<text x='").append(x).append("' y='").append(y)
              .append("' font-family='Consolas,Menlo,monospace' font-size='25' font-weight='700' fill='")
              .append(palette[r.nextInt(palette.length)])
              .append("' transform='rotate(").append(rotate).append(" ").append(x).append(" ").append(y).append(")'>")
              .append(code.charAt(i)).append("</text>");
        }
        sb.append("</svg>");

        response.setContentType("image/svg+xml;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.getWriter().write(sb.toString());
    }

    /** 处理登录 - @RequestBody JSON 数据绑定 */
    @PostMapping("/doLogin")
    @ResponseBody
    public R<SysUser> doLogin(@RequestBody SysUser loginUser,
                              @RequestParam(required = false) String captcha,
                              HttpSession session) {
        Object sessionCode = session.getAttribute("LOGIN_CAPTCHA");
        session.removeAttribute("LOGIN_CAPTCHA");
        if (sessionCode == null) {
            return R.fail("验证码已失效，请点击图片刷新后重试");
        }
        if (captcha == null || !sessionCode.toString().equalsIgnoreCase(captcha.trim())) {
            return R.fail("验证码错误");
        }

        SysUser user = userService.login(loginUser.getUsername(), loginUser.getPassword());
        if (user == null) {
            return R.fail("用户名或密码错误");
        }
        SessionUtil.setLoginUser(user);
        // 返回给前端的数据不要带密码
        user.setPassword(null);
        return R.ok("登录成功", user);
    }

    /** 处理注册 - @RequestParam 表单参数绑定 */
    @PostMapping("/doRegister")
    @ResponseBody
    public R<?> doRegister(@RequestParam String username,
                            @RequestParam String password,
                            @RequestParam(required = false) String nickname,
                            @RequestParam(required = false) String college,
                            @RequestParam(required = false) String avatar,
                            @RequestParam(required = false) String phone) {
        SysUser user = new SysUser();
        user.setUsername(username.trim());
        user.setPassword(password);
        user.setNickname(nickname);
        user.setCollege(college);
        user.setAvatar(avatar == null || avatar.trim().isEmpty() ? DEFAULT_AVATAR : avatar.trim());
        user.setPhone(phone == null || phone.trim().isEmpty() ? null : phone.trim());
        try {
            boolean ok = userService.register(user);
            return ok ? R.ok("注册成功") : R.fail("注册失败，该学号或手机号已被注册");
        } catch (IllegalArgumentException e) {
            return R.fail(e.getMessage());
        }
    }

    /** 退出登录：清除登录态后停留在当前页面（无来源页时回首页） */
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        SessionUtil.removeLoginUser();
        String referer = request.getHeader("Referer");
        String ctxPath = request.getContextPath();
        if (referer != null && ctxPath != null && referer.contains(ctxPath + "/")) {
            String path = referer.substring(referer.indexOf(ctxPath + "/") + ctxPath.length());
            if (path.contains("/user/logout") || path.contains("/user/login")) {
                return "redirect:/news/home";
            }
            return "redirect:" + path;
        }
        return "redirect:/news/home";
    }

    /** 获取当前登录用户信息 */
    @GetMapping("/info")
    @ResponseBody
    public R<SysUser> currentUser() {
        SysUser user = SessionUtil.getLoginUser();
        if (user != null) user.setPassword(null);
        return user != null ? R.ok(user) : R.fail(401, "未登录");
    }

    /** 个人中心页 */
    @GetMapping("/profile")
    public String profilePage() {
        return "user/profile";
    }

    /** 我的收藏页 */
    @GetMapping("/favorites")
    public String favoritesPage() {
        return "user/favorites";
    }

    /** 我赞过的页 */
    @GetMapping("/likes")
    public String likesPage() {
        return "user/likes";
    }

    /** 申请成为自媒体人（页面）：展示最近一次申请状态 */
    @GetMapping("/media-apply")
    public String mediaApplyPage(Model model) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return "redirect:/user/login";
        MediaApply latest = mediaApplyMapper.selectOne(new QueryWrapper<MediaApply>()
                .eq("user_id", login.getId()).orderByDesc("id").last("LIMIT 1"));
        model.addAttribute("apply", latest);
        model.addAttribute("isMedia", "MEDIA".equals(login.getRole()));
        return "user/media-apply";
    }

    /** 提交自媒体人申请 */
    @PostMapping("/media/apply")
    @ResponseBody
    public R<?> submitMediaApply(@RequestBody MediaApply form) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        if ("MEDIA".equals(login.getRole()) || "ADMIN".equals(login.getRole())) {
            return R.fail("当前身份无需申请");
        }
        String reason = form.getReason() == null ? "" : form.getReason().trim();
        if (reason.isEmpty()) return R.fail("请填写申请理由");
        if (reason.length() > 500) return R.fail("申请理由不能超过 500 字");

        Long pending = mediaApplyMapper.selectCount(new QueryWrapper<MediaApply>()
                .eq("user_id", login.getId()).eq("status", 0));
        if (pending != null && pending > 0) return R.fail("你已提交申请，请等待管理员审核");

        MediaApply apply = new MediaApply();
        apply.setUserId(login.getId());
        apply.setReason(reason);
        apply.setIntro(cut(form.getIntro(), 500));
        apply.setContact(cut(form.getContact(), 100));
        apply.setStatus(0);
        apply.setCreateTime(new Date());
        mediaApplyMapper.insert(apply);
        return R.ok("申请已提交，请等待管理员审核");
    }

    /** 去除首尾空白，超长截断，空串返回 null */
    private String cut(String s, int max) {
        if (s == null) return null;
        String t = s.trim();
        if (t.isEmpty()) return null;
        return t.length() > max ? t.substring(0, max) : t;
    }

    /** 我的收藏数据（JSP 页面用 session 登录态，不依赖 JWT） */
    @GetMapping("/favorites/data")
    @ResponseBody
    public R<?> favoritesData(@RequestParam(defaultValue = "1") long page,
                              @RequestParam(defaultValue = "10") long size,
                              @RequestParam(defaultValue = "article") String type) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        return R.ok(articleFavoriteService.listUserFavorites(page, size, login.getId()));
    }

    /** 我赞过的数据（JSP 页面用 session 登录态，不依赖 JWT） */
    @GetMapping("/likes/data")
    @ResponseBody
    public R<?> likesData(@RequestParam(defaultValue = "1") long page,
                          @RequestParam(defaultValue = "10") long size,
                          @RequestParam(defaultValue = "article") String type) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "请先登录");
        return R.ok(articleLikeService.listUserLiked(page, size, login.getId()));
    }

    /** 更新个人资料 */
    @PostMapping("/updateProfile")
    @ResponseBody
    public R<?> updateProfile(@RequestBody SysUser user) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "未登录");
        user.setId(login.getId());
        boolean ok = userService.update(user);
        if (ok) {
            // 同步刷新 session 中的用户信息，头像/昵称立即生效
            SysUser fresh = userService.getById(login.getId());
            if (fresh != null) {
                fresh.setPassword(null);
                SessionUtil.setLoginUser(fresh);
            }
        }
        return ok ? R.ok("更新成功") : R.fail("更新失败");
    }

    /** 上传头像（注册页未登录也可用），返回图片访问路径 */
    @PostMapping("/uploadAvatar")
    @ResponseBody
    public R<String> uploadAvatar(@RequestParam("file") MultipartFile file) {
        if (file == null || file.isEmpty()) return R.fail("请选择图片");
        if (file.getSize() > AVATAR_MAX_SIZE) return R.fail("头像图片不能超过 5MB");
        String original = file.getOriginalFilename();
        String ext = (original != null && original.contains("."))
                ? original.substring(original.lastIndexOf('.') + 1).toLowerCase() : "";
        if (!AVATAR_EXT.contains(ext)) return R.fail("仅支持 jpg / png / gif / webp 格式的图片");
        try {
            String datePath = new SimpleDateFormat("yyyyMM").format(new Date());
            String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
            String relative = "static/uploads/avatar/" + datePath + "/" + fileName;
            File dest = new File(servletContext.getRealPath("/") + relative);
            if (!dest.getParentFile().exists() && !dest.getParentFile().mkdirs()) {
                return R.fail("创建上传目录失败");
            }
            file.transferTo(dest);
            return R.ok("上传成功", "/" + relative);
        } catch (Exception e) {
            return R.fail("上传失败：" + e.getMessage());
        }
    }

    /** 个人中心修改头像 */
    @PostMapping("/updateAvatar")
    @ResponseBody
    public R<?> updateAvatar(@RequestParam String avatar) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "未登录");
        if (avatar == null || avatar.trim().isEmpty()) return R.fail("头像不能为空");
        SysUser upd = new SysUser();
        upd.setId(login.getId());
        upd.setAvatar(avatar.trim());
        boolean ok = userService.update(upd);
        if (ok) {
            SysUser fresh = userService.getById(login.getId());
            if (fresh != null) {
                fresh.setPassword(null);
                SessionUtil.setLoginUser(fresh);
            }
        }
        return ok ? R.ok("头像已更新") : R.fail("头像更新失败");
    }

    /** 修改密码 */
    @PostMapping("/changePassword")
    @ResponseBody
    public R<?> changePassword(@RequestParam String oldPassword,
                                @RequestParam String newPassword) {
        SysUser login = SessionUtil.getLoginUser();
        if (login == null) return R.fail(401, "未登录");
        boolean ok = userService.updatePassword(login.getId(), oldPassword, newPassword);
        return ok ? R.ok("密码修改成功") : R.fail("原密码错误");
    }
}
