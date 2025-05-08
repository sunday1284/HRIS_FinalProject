package kr.or.ddit.file.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.file.vo.FileDetailVO;
import kr.or.ddit.file.vo.FileInfoVO;
import kr.or.ddit.file.vo.FileVO;
import kr.or.ddit.mybatis.mappers.file.FileMapper;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class FileInfoService {

    @Autowired
    private FileMapper mapper;

    @Autowired
    private FileInfoVO fileInfoVO; // 파일 관련 설정 정보 (예: fileUploads, fileImages, maxFileSize 등)
    
    @Autowired
    private ResourceLoader resourceLoader;

    /**
     * 파일 그룹 생성 
     * - 신규 파일 그룹을 생성하고 DB에 파일 그룹 정보를 저장
     */
    @Transactional
    public Long createFileGroup() {
        FileVO fileVO = new FileVO();
        fileVO.setFileDel("N");
        mapper.insertFile(fileVO);
        return fileVO.getFileId();
    }

    /**
     * 기존 파일 그룹 업데이트 (파일 교체)
     * - 기존 파일들을 삭제한 후 새 파일들을 저장하는 로직
     */
    @Transactional
    public List<Long> updateFileGroup(Long fileId, MultipartFile[] files) throws IOException {
        if (fileId == null) {
            throw new IllegalArgumentException("파일 그룹 ID가 필요합니다.");
        }
        List<Long> detailIds = new ArrayList<>();

        // 기존 파일 삭제: 기존에 저장된 파일들을 삭제하고 DB에서도 제거
        List<FileDetailVO> existingFiles = mapper.getFileDetailsByFileId(fileId);
        for (FileDetailVO fileDetail : existingFiles) {
            if (fileDetail != null && fileDetail.getFilePath() != null) {
                // 파일이 이미지 파일인지 업로드 파일인지에 따라 basePath를 결정
                String basePath = fileDetail.getFilePath().startsWith(fileInfoVO.getFileImages()) 
                        ? fileInfoVO.getFileImages() 
                        : fileInfoVO.getFileUploads();
                File targetFile = new File(basePath, fileDetail.getFileSavename());
                if (targetFile.exists()) {
                    targetFile.delete();
                }
                mapper.deleteFile(fileDetail.getDetailId());
            }
        }

        long totalRequestSize = 0;
        // 파일 하나씩 처리 (파일 사이즈 체크 및 저장 처리)
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) continue;
            long fileSize = file.getSize();
            if (fileSize > fileInfoVO.getMaxFileSize() * 1024 * 1024) {
                throw new IllegalArgumentException("파일 크기가 너무 큽니다.");
            }
            totalRequestSize += fileSize;
            if (totalRequestSize > fileInfoVO.getMaxRequestSize() * 1024 * 1024) {
                throw new IllegalArgumentException("전체 요청 크기가 너무 큽니다.");
            }
            String contentType = file.getContentType();
            // 이미지 여부 확인
            boolean isImage = contentType != null && contentType.startsWith("image");
            String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
            File uploadDir = new File(basePath);
            // 디렉토리가 없으면 생성
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String originalFileName = file.getOriginalFilename();
            // 고유 파일명 생성: UUID와 원래 파일명을 결합하여 충돌 회피
            String uuidFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            File savedFile = new File(uploadDir, uuidFileName);
            try {
                file.transferTo(savedFile);
            } catch (IOException e) {
                // 파일 저장 중 예외 발생시에 경로 정보와 함께 예외 처리
                throw new IOException("파일 저장 실패: " + savedFile.getAbsolutePath(), e);
            }
            String relativeFilePath = basePath + uuidFileName;
            // 파일 상세 정보 VO 생성 및 DB 저장
            FileDetailVO fileDetail = new FileDetailVO();
            fileDetail.setFileId(fileId);
            fileDetail.setFileName(originalFileName);
            fileDetail.setFileSavename(uuidFileName);
            fileDetail.setFilePath(relativeFilePath);
            fileDetail.setFileSize(fileSize);
            fileDetail.setFileType(contentType);
            mapper.insertFileDetail(fileDetail);
            detailIds.add(fileDetail.getDetailId());
        }
        return detailIds;
    }

    /**
     * 파일 저장 (새 파일 그룹 생성)
     * - 새로운 파일 그룹을 생성한 후, 파일들을 저장 및 DB에 상세 정보 기록
     */
    @Transactional
    public List<Long> saveFiles(MultipartFile[] files) throws Exception {
        List<Long> detailIds = new ArrayList<>();
        FileVO fileVO = new FileVO();
        fileVO.setFileDel("N");
        mapper.insertFile(fileVO);
        Long fileId = fileVO.getFileId();
        long totalRequestSize = 0;
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) continue;
            long fileSize = file.getSize();
            if (fileSize > fileInfoVO.getMaxFileSize() * 1024 * 1024) {
                throw new IllegalArgumentException("파일 크기가 너무 큽니다.");
            }
            totalRequestSize += fileSize;
            if (totalRequestSize > fileInfoVO.getMaxRequestSize() * 1024 * 1024) {
                throw new IllegalArgumentException("전체 요청 크기가 너무 큽니다.");
            }
            String contentType = file.getContentType();
            boolean isImage = contentType != null && contentType.startsWith("image");
            String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
            File uploadDir = new File(basePath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String originalFileName = file.getOriginalFilename();
            String uuidFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            File savedFile = new File(uploadDir, uuidFileName);
            try {
                file.transferTo(savedFile);
            } catch (IOException e) {
                throw new IOException("파일 저장 실패: " + savedFile.getAbsolutePath(), e);
            }
            String relativeFilePath = basePath + uuidFileName;
            FileDetailVO fileDetail = new FileDetailVO();
            fileDetail.setFileId(fileId);
            fileDetail.setFileName(originalFileName);
            fileDetail.setFileSavename(uuidFileName);
            fileDetail.setFilePath(relativeFilePath);
            fileDetail.setFileSize(fileSize);
            fileDetail.setFileType(file.getContentType());
            mapper.insertFileDetail(fileDetail);
            detailIds.add(fileDetail.getDetailId());
        }
        return detailIds;
    }

    // 파일 ID로 파일 정보 조회
    public FileDetailVO getFileById(Long detailId) {
        return mapper.getFileById(detailId);
    }

    /**
     * 논리 삭제 (상태 변경)
     * - 파일 기록 자체는 남겨두고, 상태만 변경하여 삭제된 것으로 처리
     */
    @Transactional
    public void deleteFile(Long fileId) {
        FileDetailVO fileDetail = mapper.getFileById(fileId);
        if (fileDetail != null && fileDetail.getFilePath() != null) {
            // 논리 삭제 처리: DB 레코드의 상태만 변경함
            mapper.deleteFile(fileId);
        }
    }

    /**
     * 물리 삭제 (디스크 파일 + DB 레코드 삭제)
     * - 실제 파일이 저장된 디스크에서 파일 삭제 후 DB에서 완전히 삭제
     * @param detailId - FILE_DETAIL 테이블의 DETAIL_ID
     */
    @Transactional
    public void deletePhyFile(Long detailId) {
        FileDetailVO fileDetail = mapper.getFileById(detailId);
        if (fileDetail == null) {
            throw new RuntimeException("삭제할 파일 정보를 찾을 수 없습니다. (DETAIL_ID=" + detailId + ")");
        }
        String relativeFilePath = fileDetail.getFilePath();
        if (relativeFilePath == null || relativeFilePath.isEmpty()) {
            throw new RuntimeException("파일 경로가 유효하지 않습니다.");
        }
        // basePath 결정: 이미지 아닌 경우 업로드 경로 사용
        boolean isImage = relativeFilePath.startsWith(fileInfoVO.getFileImages());
        String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
        // 실제 저장된 파일 경로 구성
        File targetFile = new File(basePath, fileDetail.getFileSavename());
        if (targetFile.exists()) {
            boolean deleted = targetFile.delete();
            if (!deleted) {
                throw new RuntimeException("디스크 파일 삭제 실패: " + targetFile.getAbsolutePath());
            }
        } else {
            System.out.println("디스크에 해당 파일이 존재하지 않습니다: " + targetFile.getAbsolutePath());
        }
        // DB에서 파일 상세 레코드 삭제 (완전 삭제)
        mapper.deletePhyFile(fileDetail.getDetailId());
    }

    /**
     * 모든 파일 목록 조회
     * - DB에 저장된 모든 파일 상세 정보를 반환
     */
    public List<FileDetailVO> getAllFiles() {
        return mapper.getAllFiles();
    }

    /**
     * 파일 다운로드, 뷰어 등에 사용할 Resource 로딩
     * - 파일명을 받아 실제 파일 경로에 해당하는 Resource 객체를 반환
     */
    public Resource loadFileAsResource(String fileName) throws IOException {
        if (fileName == null || fileName.isEmpty()) {
            throw new IllegalArgumentException("파일 이름이 제공되지 않았습니다.");
        }
        // 파일 확장자를 통해 이미지 여부 판단
        boolean isImage = fileName.toLowerCase().matches(".*\\.(jpg|jpeg|png|gif|bmp|webp)$");
        String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
        // 경로 끝에 "/" 또는 파일 구분자가 없는 경우 추가
        if (!basePath.endsWith("/") && !basePath.endsWith(File.separator)) {
            basePath += "/";
        }
        Resource resource = resourceLoader.getResource("file:" + basePath + fileName);
        if (!resource.exists() || !resource.isReadable()) {
            throw new IOException("파일을 찾을 수 없거나 읽을 수 없습니다: " + fileName);
        }
        return resource;
    }

    /**
     * 파일 저장 (FILE_DETAIL 레코드 생성 포함)
     * - 기존 파일 그룹에 단일 파일을 추가 저장할 때 사용
     */
    @Transactional
    public Long saveFileWithGroup(MultipartFile file, Long fileId) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("업로드된 파일이 비어 있습니다.");
        }
        String contentType = file.getContentType();
        boolean isImage = contentType != null && contentType.startsWith("image");
        String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
        log.info("파일 저장 경로 basePath : {}", basePath);
        File uploadPath = new File(basePath);
        // 경로가 존재하지 않으면 생성
        if (!uploadPath.exists()) {
            uploadPath.mkdirs();
        }
        String originalFileName = file.getOriginalFilename();
        String uuidFileName = UUID.randomUUID().toString() + "_" + originalFileName;
        File savedFile = new File(uploadPath, uuidFileName);
        try {
            file.transferTo(savedFile);
        } catch (IOException e) {
            throw new IOException("파일 저장 실패: " + savedFile.getAbsolutePath(), e);
        }
        String relativeFilePath = basePath + uuidFileName;
        FileDetailVO fileDetail = new FileDetailVO();
        fileDetail.setFileId(fileId);
        fileDetail.setFileName(originalFileName);
        fileDetail.setFileSavename(uuidFileName);
        fileDetail.setFilePath(relativeFilePath);
        fileDetail.setFileSize(file.getSize());
        fileDetail.setFileType(contentType);
        mapper.insertFileDetail(fileDetail);
        return fileDetail.getDetailId();
    }

    /**
     * 파일 그룹 생성 및 여러 파일 저장
     * - 하나의 파일 그룹에 대해 여러 파일을 저장하며, 파일 사이즈와 요청 전체 사이즈를 체크
     */
    @Transactional
    public Long createFile(MultipartFile[] files) throws IOException {
        FileVO fileVO = new FileVO();
        fileVO.setFileDel("N");
        mapper.insertFile(fileVO);
        Long fileId = fileVO.getFileId();
        long totalRequestSize = 0;
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) continue;
            long fileSize = file.getSize();
            if (fileSize > fileInfoVO.getMaxFileSize() * 1024 * 1024) {
                throw new IllegalArgumentException("파일 크기가 너무 큽니다.");
            }
            totalRequestSize += fileSize;
            if (totalRequestSize > fileInfoVO.getMaxRequestSize() * 1024 * 1024) {
                throw new IllegalArgumentException("전체 요청 크기가 너무 큽니다.");
            }
            String contentType = file.getContentType();
            boolean isImage = contentType != null && contentType.startsWith("image");
            String basePath = isImage ? fileInfoVO.getFileImages() : fileInfoVO.getFileUploads();
            File uploadDir = new File(basePath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String originalFileName = file.getOriginalFilename();
            String uuidFileName = UUID.randomUUID().toString() + "_" + originalFileName;
            File savedFile = new File(uploadDir, uuidFileName);
            try {
                file.transferTo(savedFile);
            } catch (IOException e) {
                throw new IOException("파일 저장 실패: " + savedFile.getAbsolutePath(), e);
            }
            String relativeFilePath = basePath + uuidFileName;
            FileDetailVO fileDetail = new FileDetailVO();
            fileDetail.setFileId(fileId);
            fileDetail.setFileName(originalFileName);
            fileDetail.setFileSavename(uuidFileName);
            fileDetail.setFilePath(relativeFilePath);
            fileDetail.setFileSize(fileSize);
            fileDetail.setFileType(file.getContentType());
            mapper.insertFileDetail(fileDetail);
        }
        return fileId;
    }
}