package com.campus.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.campus.entity.Material;
import com.campus.mapper.ArticleMaterialMapper;
import com.campus.mapper.MaterialMapper;
import com.campus.service.MaterialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.context.ServletContextAware;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletContext;
import java.io.File;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class MaterialServiceImpl implements MaterialService, ServletContextAware {

    private static final long MAX_SIZE = 50L * 1024 * 1024;
    private static final List<String> ALLOWED_IMG = Arrays.asList("jpg", "jpeg", "png", "gif");
    private static final List<String> ALLOWED_VIDEO = Arrays.asList("mp4");

    /** 上传目录，相对于 webapp */
    private static final String UPLOAD_DIR = "static/uploads/material";

    @Autowired
    private MaterialMapper materialMapper;

    @Autowired
    private ArticleMaterialMapper articleMaterialMapper;

    private ServletContext servletContext;

    @Override
    public void setServletContext(ServletContext servletContext) {
        this.servletContext = servletContext;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Material upload(MultipartFile file, Long userId) throws Exception {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("请选择要上传的文件");
        }
        if (file.getSize() > MAX_SIZE) {
            throw new IllegalArgumentException("文件大小不能超过 50MB");
        }
        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf(".") + 1).toLowerCase();
        }
        String type;
        if (ALLOWED_IMG.contains(ext)) {
            type = "image";
        } else if (ALLOWED_VIDEO.contains(ext)) {
            type = "video";
        } else {
            throw new IllegalArgumentException("仅支持 jpg/png/gif/mp4 格式");
        }

        // ====== 上传去重：先算文件 MD5，同用户同文件直接返回已有素材 ======
        byte[] fileBytes = file.getBytes();
        // 缺陷 BUG-06：仅校验扩展名可被改后缀绕过，补充文件头（magic number）校验
        if (!magicMatches(ext, fileBytes)) {
            throw new IllegalArgumentException("文件内容与扩展名不符，已拒绝上传");
        }
        String md5 = computeMd5Hex(fileBytes);
        Material dup = materialMapper.selectByUserAndMd5(userId, md5);
        if (dup != null) {
            return dup; // 已有完全相同的文件，直接返回
        }

        // 按日期分目录存储
        String datePath = new SimpleDateFormat("yyyyMM").format(new Date());
        String fileName = UUID.randomUUID().toString().replace("-", "") + "." + ext;
        String relativePath = UPLOAD_DIR + "/" + datePath + "/" + fileName;

        // 保存到 webapp 真实路径
        String realPath = getWebappRoot() + relativePath;
        File dest = new File(realPath);
        if (!dest.getParentFile().exists()) {
            dest.getParentFile().mkdirs();
        }
        file.transferTo(dest);

        // 访问 URL
        String url = "/" + relativePath;

        Material material = new Material();
        material.setName(originalName);
        material.setUrl(url);
        material.setType(type);
        material.setSize(file.getSize());
        material.setMd5(md5);
        material.setUserId(userId);
        materialMapper.insert(material);
        return material;
    }

    /** 校验文件头是否与扩展名一致（jpg/png/gif/mp4） */
    private boolean magicMatches(String ext, byte[] b) {
        if (b == null || b.length < 12) {
            return false;
        }
        switch (ext) {
            case "jpg":
            case "jpeg":
                return b[0] == (byte) 0xFF && b[1] == (byte) 0xD8 && b[2] == (byte) 0xFF;
            case "png":
                return b[0] == (byte) 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
            case "gif":
                return b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x38;
            case "mp4":
                return b[4] == 0x66 && b[5] == 0x74 && b[6] == 0x79 && b[7] == 0x70;
            default:
                return false;
        }
    }

    /** 计算字节数组的 MD5（32位小写十六进制） */
    private String computeMd5Hex(byte[] bytes) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(bytes);
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return "";
        }
    }

    @Override
    public IPage<Material> pageByUser(long current, long size, Long userId, String type) {
        Page<Material> page = new Page<>(current, size);
        return materialMapper.selectByUserPage(page, userId, type);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteIfUnused(Long id, Long userId) {
        Material material = materialMapper.selectById(id);
        if (material == null) return false;
        if (!material.getUserId().equals(userId)) {
            throw new IllegalArgumentException("无权删除他人素材");
        }
        // 检查是否被文章引用
        QueryWrapper<com.campus.entity.ArticleMaterial> qw = new QueryWrapper<>();
        qw.eq("material_id", id);
        if (articleMaterialMapper.selectCount(qw) > 0) {
            throw new IllegalArgumentException("该素材已被文章引用，无法删除");
        }
        // 删除本地文件
        String realPath = getWebappRoot() + material.getUrl().substring(1);
        File f = new File(realPath);
        if (f.exists()) f.delete();
        return materialMapper.deleteById(id) > 0;
    }

    @Override
    public Material getById(Long id) {
        return materialMapper.selectById(id);
    }

    private String getWebappRoot() {
        // 优先使用 ServletContext 获取 webapp 真实路径
        if (servletContext != null) {
            String real = servletContext.getRealPath("/");
            if (StringUtils.hasText(real)) {
                return real.endsWith(File.separator) || real.endsWith("/") ? real : real + File.separator;
            }
        }
        // 兜底：系统属性
        String root = System.getProperty("campus.webapp.root");
        if (StringUtils.hasText(root)) return root;
        // 默认当前目录下的 src/main/webapp（开发期）
        return System.getProperty("user.dir") + "/src/main/webapp/";
    }
}
